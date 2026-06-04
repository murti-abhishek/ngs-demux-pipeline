// ============================================================
// subworkflows/genotype_calling.nf
//
// Bulk RNA-seq FASTQs → merged multi-sample VCF
//
// Steps:
//   1. STAR_INDEX            build genome index (once, cached)
//   2. STAR_ALIGN            align per sample (parallel)
//   3. GATK_ADDREADGROUPS    add RG tags (parallel)
//   4. GATK_MARKDUPLICATES   mark duplicates + index (parallel)
//   5. GATK_HAPLOTYPECALLER  call variants per sample (parallel)
//   6. BCFTOOLS_MERGE        fan-in → merged VCF
// ============================================================

include { STAR_INDEX           } from '../modules/star_index'
include { STAR_ALIGN           } from '../modules/star_align'
include { GATK_ADDREADGROUPS   } from '../modules/gatk_addreadgroups'
include { GATK_MARKDUPLICATES  } from '../modules/gatk_markduplicates'
include { GATK_HAPLOTYPECALLER } from '../modules/gatk_haplotypecaller'
include { BCFTOOLS_MERGE       } from '../modules/bcftools_merge'

workflow GENOTYPE_CALLING {

    take:
    ch_bulk   // [ sample_id, fastq_dir ]
    ch_fasta  // genome FASTA
    ch_gtf    // genome GTF

    main:

    // TODO Phase B: wire up each module in sequence
    // STAR_INDEX(ch_fasta, ch_gtf)
    // STAR_ALIGN(ch_bulk, STAR_INDEX.out.index)
    // GATK_ADDREADGROUPS(STAR_ALIGN.out.bam)
    // GATK_MARKDUPLICATES(GATK_ADDREADGROUPS.out.bam)
    // GATK_HAPLOTYPECALLER(GATK_MARKDUPLICATES.out.bam.join(GATK_MARKDUPLICATES.out.bai), ch_fasta)
    // BCFTOOLS_MERGE(GATK_HAPLOTYPECALLER.out.vcf.map { it[1] }.collect())

    emit:
    merged_vcf = Channel.empty()   // placeholder until Phase B
}
