process CELLRANGER_COUNT {
    label 'cellranger'
    label 'process_high'

    tag "$sample_id"

    publishDir "${params.outdir}/cellranger/${sample_id}", mode: 'copy'

    input:
    tuple val(sample_id), path(fastq_dir), val(expected_cells)
    path  ref_dir

    output:
    tuple val(sample_id), path("${sample_id}_out/outs/possorted_genome_bam.bam"),                   emit: bam
    tuple val(sample_id), path("${sample_id}_out/outs/possorted_genome_bam.bam.bai"),               emit: bai
    tuple val(sample_id), path("${sample_id}_out/outs/filtered_feature_bc_matrix/barcodes.tsv.gz"), emit: barcodes

    script:
    """
    cellranger count \
        --id ${sample_id}_out \
        --transcriptome ${ref_dir} \
        --fastqs ${fastq_dir} \
        --sample ${sample_id} \
        --expect-cells ${expected_cells} \
        --create-bam true \
        --disable-ui \
        --localcores ${task.cpus} \
        --localmem ${task.memory.toGiga()}
    """
}
