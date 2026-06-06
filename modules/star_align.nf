// modules/star_align.nf
// Align bulk RNA-seq FASTQs with STAR using the pre-built 10x index.
// Two-pass mode disabled — index already contains splice junctions from Cell Ranger build.
// Outputs coordinate-sorted BAM ready for GATK downstream.

process STAR_ALIGN {
    label 'star_gatk'
    label 'process_high'

    tag "$sample_id"

    publishDir "${params.outdir}/star_align/${sample_id}", mode: 'copy',
        pattern: "*.{bam,bai,Log.final.out}"

    input:
    tuple val(sample_id), path(fastq_dir)
    path  star_index   // pre-built star/ directory from 10x reference

    output:
    tuple val(sample_id), path("${sample_id}_Aligned.sortedByCoord.out.bam"),     emit: bam
    tuple val(sample_id), path("${sample_id}_Aligned.sortedByCoord.out.bam.bai"), emit: bai
    path  "${sample_id}_Log.final.out",                                            emit: log

    script:
    def threads = task.cpus
    def r1 = file("${fastq_dir}/*_R1_001.fastq.gz")
    def r2 = file("${fastq_dir}/*_R2_001.fastq.gz")
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
