#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { GENOTYPE_CALLING } from './subworkflows/genotype_calling'
include { SINGLECELL_PREP  } from './subworkflows/singlecell_prep'
include { DEMULTIPLEXING   } from './subworkflows/demultiplexing'

params.samplesheet  = "${projectDir}/assets/samplesheet.csv"
params.star_index   = null
params.genome_fasta = null
params.ref_dir      = null
params.n_donors     = null
params.outdir       = "results"
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
            --outdir       s3://bucket/outputs/run_001
    """.stripIndent()
    System.exit(0)
}

if (!params.star_index)   error "ERROR: --star_index is required"
if (!params.genome_fasta) error "ERROR: --genome_fasta is required"

workflow {

    Channel
        .fromPath(params.samplesheet)
        .splitCsv(header: true, strip: true)
        .branch {
            bulk:       it.data_type == 'bulk_rna'
            singlecell: it.data_type == 'singlecell'
        }
        .set { samples }

    // Pass R1/R2 as strings — Nextflow stages them when the job runs on Batch
    ch_bulk = samples.bulk.map { row ->
        def sample_id = row.sample_id
        def r1 = "${row.fastq_dir}${sample_id}_R1_001.fastq.gz"
        def r2 = "${row.fastq_dir}${sample_id}_R2_001.fastq.gz"
        [ sample_id, file(r1), file(r2) ]
    }

    ch_singlecell = samples.singlecell.map { row ->
        [ row.sample_id, file(row.fastq_dir), row.expected_cells as Integer ]
    }

    ch_star_index = Channel.value(file(params.star_index))
    ch_fasta      = Channel.value(file(params.genome_fasta))
    ch_fasta_fai  = Channel.value(file("${params.genome_fasta}.fai"))

    ch_ref_dir = params.ref_dir
        ? Channel.value(file(params.ref_dir))
        : Channel.empty()

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
