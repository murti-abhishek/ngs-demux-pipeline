#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// ============================================================
// ngs-demux-pipeline | main.nf
// ============================================================

include { GENOTYPE_CALLING } from './subworkflows/genotype_calling'
include { SINGLECELL_PREP  } from './subworkflows/singlecell_prep'
include { DEMULTIPLEXING   } from './subworkflows/demultiplexing'

// ------------------------------------------------------------
// Parameter defaults
// ------------------------------------------------------------
params.samplesheet  = "${projectDir}/assets/samplesheet.csv"
params.star_index   = null
params.genome_fasta = null
params.ref_dir      = null
params.n_donors     = null
params.outdir       = "results"
params.help         = false

// ------------------------------------------------------------
// Help message
// ------------------------------------------------------------
if (params.help) {
    log.info """
    =========================================
    n g s - d e m u x - p i p e l i n e
    =========================================
    Usage:
        nextflow run main.nf \\
            --samplesheet  assets/samplesheet.csv \\
            --star_index   s3://bucket/reference/refdata-gex-GRCh38-2020-A/star/ \\
            --genome_fasta s3://bucket/reference/refdata-gex-GRCh38-2020-A/fasta/genome.fa \\
            --ref_dir      s3://bucket/reference/refdata-gex-GRCh38-2020-A/ \\
            --outdir       s3://bucket/outputs/run_001

    Required:
        --samplesheet   Path to CSV (see assets/samplesheet.csv for schema)
        --star_index    Path to pre-built STAR index directory
        --genome_fasta  Path to genome FASTA (genome.fa.fai must be alongside it)
        --ref_dir       Path to full 10x reference directory (for Cell Ranger)

    Optional:
        --n_donors      Number of pooled donors (default: inferred from bulk rows)
        --outdir        Output directory (default: results)
    """.stripIndent()
    System.exit(0)
}

// ------------------------------------------------------------
// Validate required params
// ------------------------------------------------------------
if (!params.star_index)   error "ERROR: --star_index is required"
if (!params.genome_fasta) error "ERROR: --genome_fasta is required"

// ------------------------------------------------------------
// Parse samplesheet
// ------------------------------------------------------------
Channel
    .fromPath(params.samplesheet, checkIfExists: true)
    .splitCsv(header: true, strip: true)
    .branch {
        bulk:       it.data_type == 'bulk_rna'
        singlecell: it.data_type == 'singlecell'
    }
    .set { samples }

// Bulk: resolve explicit R1/R2 paths from the sample directory
ch_bulk = samples.bulk.map { row ->
    def sample_id = row.sample_id
    def r1 = file("${row.fastq_dir}/${sample_id}_R1_001.fastq.gz", checkIfExists: true)
    def r2 = file("${row.fastq_dir}/${sample_id}_R2_001.fastq.gz", checkIfExists: true)
    [ sample_id, r1, r2 ]
}

// Single-cell: full directory passed to Cell Ranger
ch_singlecell = samples.singlecell.map { row ->
    [ row.sample_id, file(row.fastq_dir, checkIfExists: true), row.expected_cells as Integer ]
}

// Reference channels
ch_star_index = Channel.fromPath(params.star_index,            checkIfExists: true)
ch_fasta      = Channel.fromPath(params.genome_fasta,          checkIfExists: true)
ch_fasta_fai  = Channel.fromPath("${params.genome_fasta}.fai", checkIfExists: true)

// ref_dir only needed for Phase C (Cell Ranger)
ch_ref_dir = params.ref_dir
    ? Channel.fromPath(params.ref_dir, checkIfExists: true)
    : Channel.empty()

// ------------------------------------------------------------
// Workflow
// ------------------------------------------------------------
workflow {

    GENOTYPE_CALLING(
        ch_bulk,
        ch_star_index,
        ch_fasta,
        ch_fasta_fai
    )

    SINGLECELL_PREP(
        ch_singlecell,
        ch_ref_dir
    )

    DEMULTIPLEXING(
        GENOTYPE_CALLING.out.merged_vcf,
        SINGLECELL_PREP.out.bam,
        SINGLECELL_PREP.out.barcodes
    )
}

// ------------------------------------------------------------
// Completion handler
// ------------------------------------------------------------
workflow.onComplete {
    log.info """
    =========================================
    Pipeline complete!
    Status   : ${workflow.success ? 'SUCCESS' : 'FAILED'}
    Output   : ${params.outdir}
    Duration : ${workflow.duration}
    =========================================
    """.stripIndent()
}
