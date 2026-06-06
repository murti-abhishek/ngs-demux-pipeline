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
params.star_index   = null   // s3://.../refdata-gex-GRCh38-2020-A/star/
params.genome_fasta = null   // s3://.../refdata-gex-GRCh38-2020-A/fasta/genome.fa
params.ref_dir      = null   // s3://.../refdata-gex-GRCh38-2020-A/ (for Cell Ranger)
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
        --genome_fasta  Path to genome FASTA (genome.fa.fai and genome.dict must be alongside it)
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
if (!params.ref_dir)      error "ERROR: --ref_dir is required"

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

ch_bulk = samples.bulk.map { row ->
    [ row.sample_id, file(row.fastq_dir, checkIfExists: true) ]
}

ch_singlecell = samples.singlecell.map { row ->
    [ row.sample_id, file(row.fastq_dir, checkIfExists: true), row.expected_cells as Integer ]
}

// Reference channels
ch_star_index  = Channel.fromPath(params.star_index,   checkIfExists: true)
ch_fasta       = Channel.fromPath(params.genome_fasta, checkIfExists: true)
ch_fasta_fai   = Channel.fromPath("${params.genome_fasta}.fai", checkIfExists: true)
ch_fasta_dict  = Channel.fromPath(
    params.genome_fasta.replace('.fa', '.dict'), checkIfExists: true
)
ch_ref_dir     = Channel.fromPath(params.ref_dir, checkIfExists: true)

// ------------------------------------------------------------
// Workflow
// ------------------------------------------------------------
workflow {

    GENOTYPE_CALLING(
        ch_bulk,
        ch_star_index,
        ch_fasta,
        ch_fasta_fai,
        ch_fasta_dict
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
