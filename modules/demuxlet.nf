// modules/demuxlet.nf
// Genotype-based demultiplexing with Demuxlet (popscle).
// Step 1: popscle_pileup.py — pileup from BAM + VCF
// Step 2: popscle demuxlet — assign barcodes to donors

process DEMUXLET {
    label 'demuxafy'
    label 'process_medium'

    publishDir "${params.outdir}/demultiplexing/demuxlet", mode: 'copy'

    input:
    path merged_vcf
    path merged_tbi
    path bam
    path bai
    path barcodes
    val  n_donors

    output:
    path "demuxlet/", emit: results

    script:
    def field      = params.demuxlet_field ?: 'GT'
    def threads    = task.cpus
    """
    mkdir -p demuxlet

    # Step 1: pileup
    popscle_pileup.py \
        --sam ${bam} \
        --vcf ${merged_vcf} \
        --group-list ${barcodes} \
        --tag-group CB \
        --tag-UMI UB \
        --out demuxlet/pileup

    # Step 2: demuxlet
    popscle demuxlet \
        --plp demuxlet/pileup \
        --vcf ${merged_vcf} \
        --field ${field} \
        --group-list ${barcodes} \
        --out demuxlet/demuxlet \
        --r2-info INFO

    # Summary
    bash Demuxlet_summary.sh demuxlet/demuxlet.best \
        > demuxlet/demuxlet_summary.tsv || true
    """
}
