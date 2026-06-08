// modules/gatk_haplotypecaller.nf
// Call variants per sample with GATK HaplotypeCaller.
// RNA-seq mode flags:
//   --dont-use-soft-clipped-bases
//   --standard-min-confidence-threshold-for-calling 20
// genome.fa.fai already exists in the 10x reference.
// genome.dict is generated at runtime (not included in 10x reference tarball).

process GATK_HAPLOTYPECALLER {
    label 'star_gatk'
    label 'process_high'

    tag "$sample_id"

    publishDir "${params.outdir}/vcfs/${sample_id}", mode: 'copy'

    input:
    tuple val(sample_id), path(bam), path(bai)
    path  fasta
    path  fasta_fai

    output:
    tuple val(sample_id), path("${sample_id}.vcf.gz"),     emit: vcf
    tuple val(sample_id), path("${sample_id}.vcf.gz.tbi"), emit: tbi

    script:
    """
    # Generate sequence dictionary (not included in 10x reference)
    gatk CreateSequenceDictionary -R ${fasta}

    gatk HaplotypeCaller \
        -R ${fasta} \
        -I ${bam} \
        -O ${sample_id}.vcf.gz \
        --dont-use-soft-clipped-bases \
        --standard-min-confidence-threshold-for-calling 20
    """
}
