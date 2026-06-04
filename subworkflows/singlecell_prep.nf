// ============================================================
// subworkflows/singlecell_prep.nf
//
// Pooled snRNA-seq FASTQs → BAM + barcodes via Cell Ranger
//
// Steps:
//   1. CELLRANGER_COUNT  align + count
//                        outputs: possorted_genome_bam.bam
//                                 barcodes.tsv.gz
//
// LICENSING NOTE:
//   Cell Ranger is a commercial tool (10x Genomics EULA).
//   Build the Docker image privately using docker/cellranger/Dockerfile.
//   Push to private ECR only — never to a public registry.
//   See docker/cellranger/README.md for instructions.
// ============================================================

include { CELLRANGER_COUNT } from '../modules/cellranger_count'

workflow SINGLECELL_PREP {

    take:
    ch_singlecell  // [ sample_id, fastq_dir, expected_cells ]
    ch_fasta       // genome FASTA

    main:

    // TODO Phase C: implement CELLRANGER_COUNT
    // CELLRANGER_COUNT(ch_singlecell, ch_fasta)

    emit:
    bam      = Channel.empty()   // placeholder until Phase C
    barcodes = Channel.empty()   // placeholder until Phase C
}
