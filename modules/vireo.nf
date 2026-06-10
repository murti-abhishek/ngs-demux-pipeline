process VIREO {
    label 'demuxafy'
    label 'process_medium'

    publishDir "${params.outdir}/demultiplexing/vireo", mode: 'copy'

    input:
    path merged_vcf
    path merged_tbi
    path bam
    path bai
    path barcodes
    val  n_donors

    output:
    path "vireo/", emit: results

    script:
    def field   = params.demuxlet_field ?: 'GT'
    def threads = task.cpus
    """
    mkdir -p vireo

    cellsnp-lite \
        -s ${bam} \
        -b ${barcodes} \
        -O vireo \
        -R ${merged_vcf} \
        -p ${threads} \
        --minMAF 0.1 \
        --minCOUNT 20 \
        --cellTAG CB \
        --UMItag UB \
        --gzip

    bgzip vireo/cellSNP.base.vcf

    bcftools view ${merged_vcf} \
        -R vireo/cellSNP.base.vcf.gz \
        -Oz \
        -o vireo/donor_subset.vcf.gz

    vireo \
        -c vireo \
        -d vireo/donor_subset.vcf.gz \
        -o vireo \
        -N ${n_donors} \
        -t ${field} \
        --callAmbientRNAs
    """
}
