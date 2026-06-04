// modules/gatk_markduplicates.nf
// Mark PCR duplicates and index the output BAM for HaplotypeCaller.

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
    // TODO Phase B
    """
    echo "GATK_MARKDUPLICATES stub for ${sample_id} — Phase B"
    touch ${sample_id}_dedup.bam ${sample_id}_dedup.bam.bai ${sample_id}_metrics.txt
    """
}
