// ============================================================
// subworkflows/demultiplexing.nf
//
// Merged VCF + snRNA BAM → donor barcode assignments
//
// All three Demuxafy tools run in parallel on the same inputs:
//   1. DEMUXLET    popscle pileup → demuxlet
//   2. VIREO       cellsnp-lite → bcftools subset → vireo
//   3. SOUPORCELL  souporcell → Assign_Indiv_by_Geno.R
//
// Container: Demuxafy .sif converted to Docker — see docker/demuxafy/README.md
// ============================================================

include { DEMUXLET   } from '../modules/demuxlet'
include { VIREO      } from '../modules/vireo'
include { SOUPORCELL } from '../modules/souporcell'

workflow DEMULTIPLEXING {

    take:
    ch_merged_vcf  // merged VCF from GENOTYPE_CALLING
    ch_bam         // possorted_genome_bam.bam from SINGLECELL_PREP
    ch_barcodes    // barcodes.tsv from SINGLECELL_PREP

    main:

    // TODO Phase D: run all three tools in parallel
    // DEMUXLET(ch_merged_vcf, ch_bam, ch_barcodes)
    // VIREO(ch_merged_vcf, ch_bam, ch_barcodes)
    // SOUPORCELL(ch_merged_vcf, ch_bam, ch_barcodes)

    emit:
    assignments = Channel.empty()   // placeholder until Phase D
}
