// modules/vireo.nf
// Genotype-guided demultiplexing with Vireo.
// Step 1: cellsnp_pileup.py — pileup SNPs in each barcode
// Step 2: bcftools view — subset VCF to target SNPs
// Step 3: vireo — assign barcodes to donors

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

    # Step 1: cellsnp-lite pileup
    cellsnp_pileup.py \
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

    # bgzip the base VCF for vireo
    bgzip vireo/cellSNP.base.vcf

    # Step 2: subset VCF to SNPs found in pileup
    bcftools view ${merged_vcf} \
        -R vireo/cellSNP.base.vcf.gz \
        -Oz \
        -o vireo/donor_subset.vcf.gz

    # Step 3: vireo
    vireo \
        -c vireo \
        -d vireo/donor_subset.vcf.gz \
        -o vireo \
        -N ${n_donors} \
        -t ${field} \
        --callAmbientRNAs
    """
}
