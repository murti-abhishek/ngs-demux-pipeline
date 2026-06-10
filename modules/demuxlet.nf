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
    def field = params.demuxlet_field ?: 'GT'
    """
    mkdir -p demuxlet

    popscle dsc-pileup \
        --sam ${bam} \
        --vcf ${merged_vcf} \
        --group-list ${barcodes} \
        --tag-group CB \
        --tag-UMI UB \
        --out demuxlet/pileup

    popscle demuxlet \
        --plp demuxlet/pileup \
        --vcf ${merged_vcf} \
        --field ${field} \
        --group-list ${barcodes} \
        --out demuxlet/demuxlet
    """
}
