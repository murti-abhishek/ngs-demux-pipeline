// ============================================================
// subworkflows/singlecell_prep.nf
//
// Pooled snRNA-seq FASTQs → BAM + barcodes via Cell Ranger
// ============================================================

include { CELLRANGER_COUNT } from '../modules/cellranger_count'

workflow SINGLECELL_PREP {

    take:
    ch_singlecell  // [ sample_id, fastq_dir, expected_cells ]
    ch_ref_dir     // full 10x reference directory

    main:

    CELLRANGER_COUNT(ch_singlecell, ch_ref_dir)

    emit:
    bam      = CELLRANGER_COUNT.out.bam
    barcodes = CELLRANGER_COUNT.out.barcodes
}
