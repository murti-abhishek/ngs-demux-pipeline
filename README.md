# ngs-demux-pipeline

A cloud-native Nextflow DSL2 pipeline for **genetic demultiplexing of pooled single-nuclei RNA-seq data**, using bulk RNA-seq (or WGS/WES) for genotype calling.

---

## Overview

![Pipeline overview](assets/workflow.png)

## Architecture

| Layer | Technology |
|---|---|
| Orchestration | Nextflow DSL2 |
| Cloud compute | AWS Batch |
| Storage | Amazon S3 (Fusion filesystem) |
| Containers | Docker (Wave) |
| Monitoring | Seqera Platform |
| Event trigger | S3 + Lambda → Seqera API *(planned)* |

## Pipeline Phases

| Phase | Subworkflow | Status |
|---|---|---|
| A | Reference staging + STAR_INDEX | 🔜 In progress |
| B | GENOTYPE_CALLING (STAR → GATK → bcftools) | ⬜ Planned |
| C | SINGLECELL_PREP (Cell Ranger) | ⬜ Planned |
| D | DEMULTIPLEXING (Demuxlet + Vireo + Souporcell) | ⬜ Planned |
| E | End-to-end integration + event-driven trigger | ⬜ Planned |

## Samplesheet Format

```csv
sample_id,fastq_dir,data_type,expected_cells
HB_patient1,s3://bucket/inputs/bulk_rna/HB_patient1/,bulk_rna,
HB_patient2,s3://bucket/inputs/bulk_rna/HB_patient2/,bulk_rna,
pooled_liver,s3://bucket/inputs/singlecell/pooled_liver/,singlecell,8000
```

- `bulk_rna` rows → `GENOTYPE_CALLING`
- `singlecell` rows → `SINGLECELL_PREP`
- Number of donors inferred from number of `bulk_rna` rows

## Quick Start

```bash
nextflow run main.nf \
    --samplesheet assets/samplesheet.csv \
    --genome_fasta s3://bucket/reference/genome.fa \
    --genome_gtf   s3://bucket/reference/genes.gtf \
    --outdir       s3://bucket/outputs/run_001 \
    -profile batch,tower
```

## Container Images

| Process | Image | Registry |
|---|---|---|
| STAR, GATK, samtools | `murtiabhishek/star-gatk:1.0.0` | Docker Hub |
| bcftools | `murtiabhishek/bcftools:1.0.0` | Docker Hub |
| Cell Ranger | `cellranger:7.2.0` | Private ECR only |
| Demuxafy tools | `demuxafy:2.0.1` | Private ECR only |

See `docker/cellranger/README.md` and `docker/demuxafy/README.md` for build instructions.

## S3 Layout

```
s3://ngs-demux-pipeline/
├── inputs/
│   ├── bulk_rna/
│   │   ├── HB_patient1/
│   │   └── HB_patient2/
│   ├── singlecell/
│   │   └── pooled_liver/
│   └── reference/
│       ├── genome.fa
│       └── genes.gtf
└── outputs/
    └── {run_id}/
```

## HPC vs Cloud

| Aspect | UCSF HPC (SGE) | This pipeline (AWS Batch) |
|---|---|---|
| Job scheduling | `#$ -t 1-N` array jobs | Nextflow channels |
| Containers | Singularity modules | Docker (Wave) |
| Storage | `/wynton/scratch` | S3 + Fusion |
| Monitoring | qstat / log files | Seqera Platform |
| Scalability | Fixed cluster | On-demand |

## References

- [Demuxafy documentation](https://demultiplexing-doublet-detecting-docs.readthedocs.io)
- [Nextflow DSL2](https://nextflow.io/docs/latest/)
- [GATK RNA-seq variant calling best practices](https://gatk.broadinstitute.org/hc/en-us/articles/360035531192)
- [Seqera Platform](https://seqera.io)
