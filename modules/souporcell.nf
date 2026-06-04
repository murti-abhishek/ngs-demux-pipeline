// modules/souporcell.nf
// Genotype-free demultiplexing with Souporcell.
// Requires unzipped VCF and genome FASTA.
// Followed by Assign_Indiv_by_Geno.R to map clusters → named donors.

process SOUPORCELL {
    label 'demuxafy'
    label 'process_high'

    publishDir "${params.outdir}/demultiplexing/souporcell", mode: 'copy'

    input:
    path merged_vcf
    path bam
    path barcodes
    val  n_donors

    output:
    path "souporcell/", emit: results

    script:
    // TODO Phase D
    """
    echo "SOUPORCELL stub for ${n_donors} donors — Phase D"
    mkdir -p souporcell
    touch souporcell/clusters.tsv
    """
}
