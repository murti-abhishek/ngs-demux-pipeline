// modules/gatk_haplotypecaller.nf
// Call variants per sample using GATK HaplotypeCaller.
// RNA-seq mode flags (Phase B):
//   --dont-use-soft-clipped-bases
//   --standard-min-confidence-threshold-for-calling 20

process GATK_HAPLOTYPECALLER {
    label 'star_gatk'
    label 'process_high'

    tag "$sample_id"

    publishDir "${params.outdir}/vcfs/${sample_id}", mode: 'copy'

    input:
    tuple val(sample_id), path(bam), path(bai)
    path  fasta

    output:
    tuple val(sample_id), path("${sample_id}.vcf.gz"), emit: vcf

    script:
    // TODO Phase B
    """
    echo "GATK_HAPLOTYPECALLER stub for ${sample_id} — Phase B"
    touch ${sample_id}.vcf.gz
    """
}
