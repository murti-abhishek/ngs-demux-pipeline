// modules/gatk_addreadgroups.nf
// Add read group tags required by GATK HaplotypeCaller.
// Sort by coordinate after adding RGs — required for MarkDuplicates.

process GATK_ADDREADGROUPS {
    label 'star_gatk'
    label 'process_medium'

    tag "$sample_id"

    input:
    tuple val(sample_id), path(bam)

    output:
    tuple val(sample_id), path("${sample_id}_rg.bam"), emit: bam

    script:
    """
    gatk AddOrReplaceReadGroups \
        -I ${bam} \
        -O ${sample_id}_rg.bam \
        -ID ${sample_id} \
        -LB lib1 \
        -PL ILLUMINA \
        -PU ${sample_id} \
        -SM ${sample_id} \
        --SORT_ORDER coordinate
    """
}
