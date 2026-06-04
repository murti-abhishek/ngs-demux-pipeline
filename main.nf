#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// ============================================================
// ngs-demux-pipeline | main.nf
// Genetic demultiplexing of pooled single-nuclei RNA-seq data
// using bulk RNA-seq or WGS/WES for genotype calling.
//
// Subworkflows:
//   GENOTYPE_CALLING  - bulk RNA-seq → per-sample VCFs → merged VCF
//   SINGLECELL_PREP   - pooled snRNA-seq FASTQs → BAM + barcodes
//   DEMULTIPLEXING    - merged VCF + snRNA BAM → donor assignments
// ============================================================

include { GENOTYPE_CALLING } from './subworkflows/genotype_calling'
include { SINGLECELL_PREP  } from './subworkflows/singlecell_prep'
include { DEMULTIPLEXING   } from './subworkflows/demultiplexing'

// ------------------------------------------------------------
// Parameter defaults
// ------------------------------------------------------------
params.samplesheet  = "${projectDir}/assets/samplesheet.csv"
params.genome_fasta = null
params.genome_gtf   = null
params.n_donors     = null
params.outdir       = "results"
params.star_index   = null
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
            --samplesheet assets/samplesheet.csv \\
            --genome_fasta s3://bucket/reference/genome.fa \\
            --genome_gtf   s3://bucket/reference/genes.gtf \\
            --outdir       s3://bucket/outputs/run_001

    Required:
        --samplesheet     Path to CSV (see assets/samplesheet.csv for schema)
        --genome_fasta    Path to reference genome FASTA
        --genome_gtf      Path to reference genome GTF

    Optional:
        --n_donors        Number of pooled donors (default: inferred from bulk rows)
        --star_index      Path to pre-built STAR index (skips STAR_INDEX step)
        --outdir          Output directory (default: results)
    """.stripIndent()
    System.exit(0)
}

// ------------------------------------------------------------
// Validate required params
// ------------------------------------------------------------
if (!params.genome_fasta) error "ERROR: --genome_fasta is required"
if (!params.genome_gtf)   error "ERROR: --genome_gtf is required"

// ------------------------------------------------------------
// Parse samplesheet into two channels
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
    def fastq_dir = file(row.fastq_dir, checkIfExists: true)
    [ row.sample_id, fastq_dir ]
}

ch_singlecell = samples.singlecell.map { row ->
    def fastq_dir = file(row.fastq_dir, checkIfExists: true)
    [ row.sample_id, fastq_dir, row.expected_cells as Integer ]
}

ch_fasta = Channel.fromPath(params.genome_fasta, checkIfExists: true)
ch_gtf   = Channel.fromPath(params.genome_gtf,   checkIfExists: true)

// ------------------------------------------------------------
// Workflow
// ------------------------------------------------------------
workflow {

    // 1. Genotype calling: bulk RNA-seq FASTQs → merged VCF
    GENOTYPE_CALLING(
        ch_bulk,
        ch_fasta,
        ch_gtf
    )

    // 2. Single-cell prep: pooled snRNA FASTQs → BAM + barcodes
    SINGLECELL_PREP(
        ch_singlecell,
        ch_fasta
    )

    // 3. Demultiplexing: merged VCF + snRNA BAM → donor assignments
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
