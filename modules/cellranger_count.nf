// modules/cellranger_count.nf
// Run Cell Ranger count on pooled snRNA-seq FASTQs.
//
// LICENSING NOTE:
//   Cell Ranger is a commercial tool (10x Genomics EULA).
//   The container image must be built privately and stored in ECR only.
//   Do NOT push to a public registry.
//   See docker/cellranger/README.md for build instructions.

process CELLRANGER_COUNT {
    label 'cellranger'
    label 'process_high'

    tag "$sample_id"

    publishDir "${params.outdir}/cellranger/${sample_id}", mode: 'copy'

    input:
    tuple val(sample_id), path(fastq_dir), val(expected_cells)
    path  fasta

    output:
    tuple val(sample_id), path("${sample_id}/outs/possorted_genome_bam.bam"),                   emit: bam
    tuple val(sample_id), path("${sample_id}/outs/filtered_feature_bc_matrix/barcodes.tsv.gz"), emit: barcodes

    script:
    // TODO Phase C
    """
    echo "CELLRANGER_COUNT stub for ${sample_id} — Phase C"
    mkdir -p ${sample_id}/outs/filtered_feature_bc_matrix
    touch ${sample_id}/outs/possorted_genome_bam.bam
    touch ${sample_id}/outs/filtered_feature_bc_matrix/barcodes.tsv.gz
    """
}
