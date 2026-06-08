// modules/star_align.nf
// Align bulk RNA-seq FASTQs with STAR using the pre-built 10x index.
// Takes explicit R1/R2 file paths resolved in main.nf.

process STAR_ALIGN {
    label 'star_gatk'
    label 'process_high'

    tag "$sample_id"

    publishDir "${params.outdir}/star_align/${sample_id}", mode: 'copy',
        pattern: "*.{bam,bai,Log.final.out}"

    input:
    tuple val(sample_id), path(r1), path(r2)
    path  star_index

    output:
    tuple val(sample_id), path("${sample_id}_Aligned.sortedByCoord.out.bam"),     emit: bam
    tuple val(sample_id), path("${sample_id}_Aligned.sortedByCoord.out.bam.bai"), emit: bai
    path  "${sample_id}_Log.final.out",                                            emit: log

    script:
    def threads = task.cpus
    """
    STAR \
        --runMode alignReads \
        --genomeDir ${star_index} \
        --readFilesIn ${r1} ${r2} \
        --readFilesCommand zcat \
        --outSAMtype BAM SortedByCoordinate \
        --outSAMattributes NH HI AS NM MD \
        --runThreadN ${threads} \
        --outFileNamePrefix ${sample_id}_

    samtools index ${sample_id}_Aligned.sortedByCoord.out.bam
    """
}
