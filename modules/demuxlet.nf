// modules/demuxlet.nf
// Genotype-based demultiplexing with Demuxlet (popscle).
// Step 1: popscle pileup  — pileup from BAM + VCF
// Step 2: popscle demuxlet — assign barcodes to donors

process DEMUXLET {
    label 'demuxafy'
    label 'process_medium'

    publishDir "${params.outdir}/demultiplexing/demuxlet", mode: 'copy'

    input:
    path merged_vcf
    path bam
    path barcodes

    output:
    path "demuxlet.*", emit: results

    script:
    // TODO Phase D
    """
    echo "DEMUXLET stub — Phase D"
    touch demuxlet.best
    """
}
