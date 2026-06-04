// modules/star_align.nf
// Align bulk RNA-seq FASTQs with STAR (splice-aware, two-pass mode).
// Outputs coordinate-sorted BAM for GATK downstream.
// Key flags (Phase B): --twopassMode Basic
//                      --readFilesCommand zcat
//                      --outSAMtype BAM SortedByCoordinate

process STAR_ALIGN {
    label 'star_gatk'
    label 'process_high'

    tag "$sample_id"

    publishDir "${params.outdir}/star_align/${sample_id}", mode: 'copy'

    input:
    tuple val(sample_id), path(fastq_dir)
    path  index

    output:
    tuple val(sample_id), path("${sample_id}_Aligned.sortedByCoord.out.bam"), emit: bam

    script:
    // TODO Phase B
    """
    echo "STAR_ALIGN stub for ${sample_id} — Phase B"
    touch ${sample_id}_Aligned.sortedByCoord.out.bam
    """
}
