// modules/souporcell.nf
// Genotype-free demultiplexing with Souporcell.
// Uses known genotypes (merged VCF) to assign cluster names to donors.
// Followed by Assign_Indiv_by_Geno.R to map clusters → named donors.

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

    # Souporcell requires unzipped VCF
    bcftools view ${merged_vcf} -Ov -o souporcell/merged.vcf

    Souporcell.py \
        -i ${bam} \
        -b ${barcodes} \
        -f ${fasta} \
        -t ${threads} \
        -o souporcell \
        -k ${n_donors} \
        --common_variants souporcell/merged.vcf

    # Map cluster IDs to donor names using reference genotypes
    Assign_Indiv_by_Geno.R \
        -r souporcell/merged.vcf \
        -c souporcell/cluster_genotypes.vcf \
        -o souporcell || true
    """
}
