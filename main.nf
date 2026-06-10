#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// ============================================================
// ngs-demux-pipeline | main.nf
// ============================================================

include { GENOTYPE_CALLING } from './subworkflows/genotype_calling'
include { SINGLECELL_PREP  } from './subworkflows/singlecell_prep'
include { DEMULTIPLEXING   } from './subworkflows/demultiplexing'

params.samplesheet  = "${projectDir}/assets/samplesheet.csv"
params.star_index   = null
params.genome_fasta = null
params.ref_dir      = null
params.n_donors     = null
params.outdir       = "s3://nextflow-scrna-abhishek/ngs-demux/outputs"
params.help         = false

if (params.help) {
    log.info """
    =========================================
    n g s - d e m u x - p i p e l i n e
    =========================================
    Usage:
        nextflow run main.nf \\
            --samplesheet  assets/samplesheet.csv \\
            --star_index   s3://bucket/reference/star_index_2.7.11b/ \\
            --genome_fasta s3://bucket/reference/refdata-gex-GRCh38-2020-A/fasta/genome.fa \\
            --ref_dir      s3://bucket/reference/refdata-gex-GRCh38-2020-A/ \\
            --n_donors     4 \\
            --outdir       s3://bucket/outputs/run_001

    Required:
        --samplesheet   Path to CSV (see assets/samplesheet.csv for schema)
        --star_index    Path to pre-built STAR index directory
        --genome_fasta  Path to genome FASTA
        --ref_dir       Path to full 10x reference directory (for Cell Ranger)
        --n_donors      Number of pooled donors

    Optional:
        --outdir        Output directory (default: S3)
    """.stripIndent()
    System.exit(0)
}

if (!params.star_index)   error "ERROR: --star_index is required"
if (!params.genome_fasta) error "ERROR: --genome_fasta is required"
if (!params.n_donors)     error "ERROR: --n_donors is required"

workflow {

    Channel
        .fromPath(params.samplesheet)
        .splitCsv(header: true, strip: true)
        .branch {
            bulk:       it.data_type == 'bulk_rna'
            singlecell: it.data_type == 'singlecell'
        }
        .set { samples }

    ch_bulk = samples.bulk.map { row ->
        def sample_id = row.sample_id
        def r1 = file("${row.fastq_dir}/${sample_id}_R1_001.fastq.gz")
        def r2 = file("${row.fastq_dir}/${sample_id}_R2_001.fastq.gz")
        [ sample_id, r1, r2 ]
    }

    ch_singlecell = samples.singlecell.map { row ->
        [ row.sample_id, file(row.fastq_dir), row.expected_cells as Integer ]
    }

    ch_star_index = Channel.value(file(params.star_index))
    ch_fasta      = Channel.value(file(params.genome_fasta))
    ch_fasta_fai  = Channel.value(file("${params.genome_fasta}.fai"))
    ch_ref_dir    = Channel.value(file(params.ref_dir))
    ch_n_donors   = Channel.value(params.n_donors as Integer)

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
        GENOTYPE_CALLING.out.merged_tbi,
        SINGLECELL_PREP.out.bam.map { it[1] },
        SINGLECELL_PREP.out.bai.map { it[1] },
        SINGLECELL_PREP.out.barcodes.map { it[1] },
        ch_fasta,
        ch_n_donors
    )
}

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
