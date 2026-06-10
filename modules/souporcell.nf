process SOUPORCELL {
    label 'demuxafy'
    label 'process_high'

    publishDir "${params.outdir}/demultiplexing/souporcell", mode: 'copy'

    input:
    path merged_vcf
    path merged_tbi
    path bam
    path bai
    path barcodes
    path fasta
    val  n_donors

    output:
    path "souporcell/", emit: results

    script:
    def threads = task.cpus
    """
    mkdir -p souporcell

    bcftools view ${merged_vcf} -Ov -o souporcell/merged.vcf

    souporcell_pipeline.py \
        -i ${bam} \
        -b ${barcodes} \
        -f ${fasta} \
        -t ${threads} \
        -o souporcell \
        -k ${n_donors} \
        --common_variants souporcell/merged.vcf
    """
}
