// modules/gatk_haplotypecaller.nf
// Call variants per sample with GATK HaplotypeCaller.
// RNA-seq mode flags:
//   --dont-use-soft-clipped-bases
//   --standard-min-confidence-threshold-for-calling 20
//
// genome.fa.fai and genome.dict are already present in the 10x reference
// fasta/ directory — no need to generate them here.

process GATK_HAPLOTYPECALLER {
    label 'star_gatk'
    label 'process_high'

    tag "$sample_id"

    publishDir "${params.outdir}/vcfs/${sample_id}", mode: 'copy'

    input:
    tuple val(sample_id), path(bam), path(bai)
    path  fasta      // genome.fa
    path  fasta_fai  // genome.fa.fai  (staged alongside fasta)
    path  fasta_dict // genome.dict    (staged alongside fasta)

    output:
    tuple val(sample_id), path("${sample_id}.vcf.gz"),     emit: vcf
    tuple val(sample_id), path("${sample_id}.vcf.gz.tbi"), emit: tbi

    script:
    """
    gatk HaplotypeCaller \
        -R ${fasta} \
        -I ${bam} \
        -O ${sample_id}.vcf.gz \
        --dont-use-soft-clipped-bases \
        --standard-min-confidence-threshold-for-calling 20
    """
}
