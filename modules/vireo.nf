// modules/vireo.nf
// Genotype-guided demultiplexing with Vireo.
// Step 1: cellsnp-lite pileup
// Step 2: bcftools view — subset VCF to target donors
// Step 3: vireo --callAmbientRNAs

process VIREO {
    label 'demuxafy'
    label 'process_medium'

    publishDir "${params.outdir}/demultiplexing/vireo", mode: 'copy'

    input:
    path merged_vcf
    path bam
    path barcodes

    output:
    path "vireo/", emit: results

    script:
    // TODO Phase D
    """
    echo "VIREO stub — Phase D"
    mkdir -p vireo
    touch vireo/donor_ids.tsv
    """
}
