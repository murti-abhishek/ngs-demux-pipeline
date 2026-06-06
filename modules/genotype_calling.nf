// ============================================================
// subworkflows/genotype_calling.nf
//
// Bulk RNA-seq FASTQs → merged multi-sample VCF
//
// Uses pre-built STAR index and pre-indexed FASTA from the
// 10x GRCh38-2020-A reference — no index building required.
// ============================================================

include { STAR_ALIGN           } from '../modules/star_align'
include { GATK_ADDREADGROUPS   } from '../modules/gatk_addreadgroups'
include { GATK_MARKDUPLICATES  } from '../modules/gatk_markduplicates'
include { GATK_HAPLOTYPECALLER } from '../modules/gatk_haplotypecaller'
include { BCFTOOLS_MERGE       } from '../modules/bcftools_merge'

workflow GENOTYPE_CALLING {

    take:
    ch_bulk       // [ sample_id, fastq_dir ]
    ch_star_index // pre-built star/ directory
    ch_fasta      // genome.fa
    ch_fasta_fai  // genome.fa.fai
    ch_fasta_dict // genome.dict

    main:

    // 1. Align each bulk RNA-seq sample in parallel
    STAR_ALIGN(ch_bulk, ch_star_index)

    // 2. Add read groups
    GATK_ADDREADGROUPS(STAR_ALIGN.out.bam)

    // 3. Mark duplicates + index
    GATK_MARKDUPLICATES(GATK_ADDREADGROUPS.out.bam)

    // 4. Call variants per sample in parallel
    GATK_HAPLOTYPECALLER(
        GATK_MARKDUPLICATES.out.bam.join(GATK_MARKDUPLICATES.out.bai),
        ch_fasta,
        ch_fasta_fai,
        ch_fasta_dict
    )

    // 5. Fan-in: merge all per-sample VCFs into one
    BCFTOOLS_MERGE(
        GATK_HAPLOTYPECALLER.out.vcf.map { it[1] }.collect(),
        GATK_HAPLOTYPECALLER.out.tbi.map { it[1] }.collect()
    )

    emit:
    merged_vcf = BCFTOOLS_MERGE.out.vcf
    merged_tbi = BCFTOOLS_MERGE.out.tbi
}
