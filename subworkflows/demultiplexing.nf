// ============================================================
// subworkflows/demultiplexing.nf
//
// Merged VCF + snRNA BAM → donor barcode assignments
//
// All three Demuxafy tools run in parallel:
//   1. DEMUXLET    popscle pileup → demuxlet
//   2. VIREO       cellsnp-lite → bcftools → vireo
//   3. SOUPORCELL  souporcell → Assign_Indiv_by_Geno.R
// ============================================================

include { DEMUXLET   } from '../modules/demuxlet'
include { VIREO      } from '../modules/vireo'
include { SOUPORCELL } from '../modules/souporcell'

workflow DEMULTIPLEXING {

    take:
    ch_merged_vcf  // merged VCF from GENOTYPE_CALLING
    ch_merged_tbi  // VCF index
    ch_bam         // possorted_genome_bam.bam from SINGLECELL_PREP
    ch_bai         // BAM index
    ch_barcodes    // barcodes.tsv.gz from SINGLECELL_PREP
    ch_fasta       // genome.fa (needed by Souporcell)
    ch_n_donors    // number of donors (integer)

    main:

    // All three tools run in parallel on the same inputs
    DEMUXLET(
        ch_merged_vcf,
        ch_merged_tbi,
        ch_bam,
        ch_bai,
        ch_barcodes,
        ch_n_donors
    )

    VIREO(
        ch_merged_vcf,
        ch_merged_tbi,
        ch_bam,
        ch_bai,
        ch_barcodes,
        ch_n_donors
    )

    SOUPORCELL(
        ch_merged_vcf,
        ch_merged_tbi,
        ch_bam,
        ch_bai,
        ch_barcodes,
        ch_fasta,
        ch_n_donors
    )

    emit:
    demuxlet    = DEMUXLET.out.results
    vireo       = VIREO.out.results
    souporcell  = SOUPORCELL.out.results
}
