// modules/bcftools_merge.nf
// Merge per-sample VCFs into one multi-sample VCF for Demuxafy.
// Collects all VCFs as a list (fan-in from parallel GATK runs).

process BCFTOOLS_MERGE {
    label 'bcftools'
    label 'process_low'

    publishDir "${params.outdir}/merged_vcf", mode: 'copy'

    input:
    path vcfs

    output:
    path "merged.vcf.gz",     emit: vcf
    path "merged.vcf.gz.tbi", emit: tbi

    script:
    // TODO Phase B
    """
    echo "BCFTOOLS_MERGE stub — Phase B"
    touch merged.vcf.gz merged.vcf.gz.tbi
    """
}
