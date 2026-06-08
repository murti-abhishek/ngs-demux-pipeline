// modules/cellranger_count.nf
// Run Cell Ranger count on pooled snRNA-seq FASTQs.
//
// LICENSING NOTE:
//   Cell Ranger is a commercial tool (10x Genomics EULA).
//   The container image is stored in private ECR only.
//   See docker/cellranger/README.md for build instructions.

process CELLRANGER_COUNT {
    label 'cellranger'
    label 'process_high'

    tag "$sample_id"

    publishDir "${params.outdir}/cellranger/${sample_id}", mode: 'copy'

    input:
    tuple val(sample_id), path(fastq_dir), val(expected_cells)
    path  ref_dir

    output:
    tuple val(sample_id), path("${sample_id}/outs/possorted_genome_bam.bam"),                        emit: bam
    tuple val(sample_id), path("${sample_id}/outs/possorted_genome_bam.bam.bai"),                    emit: bai
    tuple val(sample_id), path("${sample_id}/outs/filtered_feature_bc_matrix/barcodes.tsv.gz"),      emit: barcodes

    script:
    """
    cellranger count \
        --id ${sample_id} \
        --transcriptome ${ref_dir} \
        --fastqs ${fastq_dir} \
        --sample ${sample_id} \
        --expected-cells ${expected_cells} \
        --localcores ${task.cpus} \
        --localmem ${task.memory.toGiga()}
    """
}
