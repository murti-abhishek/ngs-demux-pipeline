// modules/star_index.nf
// Build STAR genome index from FASTA + GTF.
// Cached with storeDir — only runs once per reference.

process STAR_INDEX {
    label 'star_gatk'
    label 'process_high'

    storeDir { params.star_index ?: "${params.outdir}/star_index" }

    input:
    path fasta
    path gtf

    output:
    path "star_index/", emit: index

    script:
    // TODO Phase B
    """
    echo "STAR_INDEX stub — Phase B"
    mkdir -p star_index
    """
}
