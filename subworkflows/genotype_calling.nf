// ============================================================
// subworkflows/genotype_calling.nf
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

    main:

    STAR_ALIGN(ch_bulk, ch_star_index)
    GATK_ADDREADGROUPS(STAR_ALIGN.out.bam)
    GATK_MARKDUPLICATES(GATK_ADDREADGROUPS.out.bam)

    GATK_HAPLOTYPECALLER(
        GATK_MARKDUPLICATES.out.bam.join(GATK_MARKDUPLICATES.out.bai),
        ch_fasta,
        ch_fasta_fai
    )

    BCFTOOLS_MERGE(
        GATK_HAPLOTYPECALLER.out.vcf.map { it[1] }.collect(),
        GATK_HAPLOTYPECALLER.out.tbi.map { it[1] }.collect()
    )

    emit:
    merged_vcf = BCFTOOLS_MERGE.out.vcf
    merged_tbi = BCFTOOLS_MERGE.out.tbi
}
