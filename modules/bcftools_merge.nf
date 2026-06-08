// modules/bcftools_merge.nf
// Merge per-sample VCFs into one multi-sample VCF for Demuxafy.
// Collects all per-sample VCFs as a list (fan-in from parallel GATK runs).

process BCFTOOLS_MERGE {
    label 'star_gatk'
    label 'process_low'

    publishDir "${params.outdir}/merged_vcf", mode: 'copy'

    input:
    path vcfs
    path tbis

    output:
    path "merged.vcf.gz",     emit: vcf
    path "merged.vcf.gz.tbi", emit: tbi

    script:
    """
    bcftools merge \
        --output-type z \
        --output merged.vcf.gz \
        ${vcfs}

    bcftools index --tbi merged.vcf.gz
    """
}
