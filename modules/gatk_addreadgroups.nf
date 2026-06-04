// modules/gatk_addreadgroups.nf
// Add read group tags required by GATK HaplotypeCaller.
// -ID, -LB, -PL, -PU, -SM all set to sample_id for simplicity.

process GATK_ADDREADGROUPS {
    label 'star_gatk'
    label 'process_medium'

    tag "$sample_id"

    input:
    tuple val(sample_id), path(bam)

    output:
    tuple val(sample_id), path("${sample_id}_rg.bam"), emit: bam

    script:
    // TODO Phase B
    """
    echo "GATK_ADDREADGROUPS stub for ${sample_id} — Phase B"
    touch ${sample_id}_rg.bam
    """
}
