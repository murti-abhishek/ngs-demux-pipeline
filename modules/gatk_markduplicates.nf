// modules/gatk_markduplicates.nf
// Mark PCR duplicates with GATK MarkDuplicates.
// Index the output BAM for HaplotypeCaller.

process GATK_MARKDUPLICATES {
    label 'star_gatk'
    label 'process_medium'

    tag "$sample_id"

    publishDir "${params.outdir}/markduplicates/${sample_id}", mode: 'copy', pattern: "*.txt"

    input:
    tuple val(sample_id), path(bam)

    output:
    tuple val(sample_id), path("${sample_id}_dedup.bam"),     emit: bam
    tuple val(sample_id), path("${sample_id}_dedup.bam.bai"), emit: bai
    path "${sample_id}_metrics.txt",                           emit: metrics

    script:
    """
    gatk MarkDuplicates \
        -I ${bam} \
        -O ${sample_id}_dedup.bam \
        -M ${sample_id}_metrics.txt \
        --CREATE_INDEX true

    # Rename the index to .bai (GATK creates .bam.bai by default)
    if [ -f ${sample_id}_dedup.bai ]; then
        mv ${sample_id}_dedup.bai ${sample_id}_dedup.bam.bai
    fi
    """
}
