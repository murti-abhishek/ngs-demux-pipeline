# ngs-demux-pipeline

A cloud-native Nextflow DSL2 pipeline for **genetic demultiplexing of pooled single-nuclei RNA-seq data**, using bulk RNA-seq for genotype calling.

---

## Overview

![Pipeline overview](assets/workflow.png)

## Architecture

| Layer | Technology |
|---|---|
| Orchestration | Nextflow DSL2 |
| Cloud compute | AWS Batch |
| Storage | Amazon S3 |
| Containers | Docker |
| Monitoring | Seqera Platform |
| Event trigger | S3 + Lambda → Seqera API *(planned)* |

## Pipeline Phases

| Phase | Subworkflow | Status |
|---|---|---|
| A | Reference staging to S3 + Docker images | ✅ Complete |
| B | GENOTYPE_CALLING (STAR → GATK → bcftools) | ✅ Complete |
| C | SINGLECELL_PREP (Cell Ranger) | ✅ Complete |
| D | DEMULTIPLEXING (Demuxlet + Vireo + Souporcell) | 🔜 In progress — pending validation with real variant data |
| E | End-to-end integration + event-driven trigger | ⬜ Planned |

## Samplesheet Format

```csv
sample_id,fastq_dir,data_type,expected_cells
sample1,s3://bucket/inputs/bulk_rna/sample1/,bulk_rna,
sample2,s3://bucket/inputs/bulk_rna/sample2/,bulk_rna,
pooled_liver,s3://bucket/inputs/singlecell/pooled_liver/,singlecell,5000
```

- `bulk_rna` rows → `GENOTYPE_CALLING` (runs in parallel across all samples)
- `singlecell` rows → `SINGLECELL_PREP`
- Number of donors inferred from number of `bulk_rna` rows

## Quick Start

```bash
nextflow run main.nf \
    --samplesheet  assets/samplesheet.csv \
    --star_index   s3://nextflow-scrna-abhishek/ngs-demux/reference/star_index_2.7.11b/ \
    --genome_fasta s3://nextflow-scrna-abhishek/ngs-demux/reference/refdata-gex-GRCh38-2020-A/fasta/genome.fa \
    --ref_dir      s3://nextflow-scrna-abhishek/ngs-demux/reference/refdata-gex-GRCh38-2020-A/ \
    -profile batch,tower \
    -w s3://nextflow-scrna-abhishek/ngs-demux/work
```

## Container Images

| Process | Image | Registry |
|---|---|---|
| STAR 2.7.11b, GATK 4.6.2.0, samtools 1.21, bcftools, AWS CLI v2 | `murtiabhishek/star-gatk:1.4.0` | Docker Hub |
| Cell Ranger 10.0.0 | `267643289527.dkr.ecr.us-east-1.amazonaws.com/cellranger:10.0.2` | Private ECR only |
| Demuxafy 3.0.0 (Demuxlet, Vireo, Souporcell) | `267643289527.dkr.ecr.us-east-1.amazonaws.com/demuxafy:3.0.0` | Private ECR only *(Phase D)* |

See `docker/cellranger/README.md` and `docker/demuxafy/README.md` for build instructions.

## Reference Data

Uses the 10x Genomics GRCh38-2020-A reference (Ensembl 98 / GENCODE v32), staged to S3:

```
s3://nextflow-scrna-abhishek/ngs-demux/reference/
├── refdata-gex-GRCh38-2020-A/
│   ├── fasta/
│   │   ├── genome.fa        # used by GATK HaplotypeCaller
│   │   ├── genome.fa.fai    # pre-built FASTA index
│   │   └── genome.dict      # pre-built sequence dictionary
│   ├── genes/
│   │   └── genes.gtf
│   └── star/                # Cell Ranger pre-built index (used by Cell Ranger only)
└── star_index_2.7.11b/      # custom STAR index built with STAR 2.7.11b
                             # used by STAR_ALIGN for bulk RNA-seq variant calling
```

> **Note on STAR index compatibility:** The Cell Ranger pre-built `star/` index is incompatible
> with standalone STAR. A custom index was built with STAR 2.7.11b using the same FASTA and GTF,
> ensuring reference consistency across both alignment arms of the pipeline.

## S3 Layout

```
s3://nextflow-scrna-abhishek/ngs-demux/
├── reference/
├── inputs/
│   ├── bulk_rna/
│   │   ├── sample1/
│   │   ├── sample2/
│   │   ├── sample3/
│   │   └── sample4/
│   └── singlecell/
│       └── pooled_liver/
├── work/                    # Nextflow work directory
└── outputs/
    ├── star_align/          # per-sample BAMs
    ├── markduplicates/      # duplicate metrics
    ├── vcfs/                # per-sample VCFs
    ├── merged_vcf/          # merged multi-sample VCF (input to Demuxafy)
    ├── cellranger/          # Cell Ranger outputs (BAM + barcodes)
    ├── pipeline_report.html
    ├── pipeline_timeline.html
    ├── pipeline_trace.txt
    └── pipeline_dag.html
```

## HPC vs Cloud

| Aspect | UCSF HPC (SGE) | This pipeline (AWS Batch) |
|---|---|---|
| Job scheduling | `#$ -t 1-N` array jobs | Nextflow channels — automatic parallelism |
| Containers | Singularity modules | Docker |
| Storage | `/wynton/scratch` | S3 |
| Monitoring | qstat / log files | Seqera Platform |
| Scalability | Fixed cluster | On-demand |
| Failure handling | Manual resubmission | Automatic retry with `-resume` |

## References

- [Demuxafy documentation](https://demultiplexing-doublet-detecting-docs.readthedocs.io)
- [Nextflow DSL2](https://nextflow.io/docs/latest/)
- [GATK RNA-seq variant calling best practices](https://gatk.broadinstitute.org/hc/en-us/articles/360035531192)
- [10x Genomics GRCh38-2020-A reference](https://www.10xgenomics.com/support/software/cell-ranger/downloads)
- [Seqera Platform](https://seqera.io)