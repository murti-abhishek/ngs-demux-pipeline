# ngs-demux-pipeline

A cloud-native Nextflow DSL2 pipeline for **genetic demultiplexing of pooled single-nuclei RNA-seq data**, using bulk RNA-seq (or WGS/WES) for genotype calling.

Built as a portfolio project demonstrating production-grade pipeline orchestration on AWS Batch with Seqera Platform monitoring.

---

## Overview

Pooled single-nuclei sequencing allows multiple donors to be captured in a single 10X lane, reducing batch effects and cost. Demultiplexing assigns each cell barcode back to its donor of origin using genetic variants as a fingerprint.

This pipeline automates the full workflow:

```
Bulk RNA-seq FASTQs (N donors)          Pooled snRNA-seq FASTQs
         │                                        │
         ▼                                        ▼
   STAR alignment                         Cell Ranger count
   GATK variant calling                         │
   bcftools merge                         BAM + barcodes
         │                                        │
         └──────────────┬─────────────────────────┘
                        ▼
              Demuxafy ensemble
          ┌───────┬────────┬──────────┐
       Demuxlet  Vireo  Souporcell
          └───────┴────────┴──────────┘
                        │
                 Barcode assignments
```

## Architecture

| Layer | Technology |
|---|---|
| Orchestration | Nextflow DSL2 |
| Cloud compute | AWS Batch |
| Storage | Amazon S3 (Fusion filesystem) |
| Containers | Docker (Wave for pull-time building) |
| Monitoring | Seqera Platform (Tower) |
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

- `bulk_rna` rows are routed to `GENOTYPE_CALLING`
- `singlecell` rows are routed to `SINGLECELL_PREP`
- Number of donors (`n_donors`) is inferred from the number of `bulk_rna` rows

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

### Cell Ranger (licensing)
Cell Ranger is a commercial tool (10x Genomics EULA) and cannot be redistributed publicly.
Build the image locally using `docker/cellranger/Dockerfile` and push to a private ECR repository.
See [`docker/cellranger/README.md`](docker/cellranger/README.md) for step-by-step instructions.

### Demuxafy (Singularity → Docker conversion)
Demuxafy is distributed as a Singularity `.sif` image. For AWS Batch compatibility,
convert it to Docker using `singularity build --docker-daemon` and push to private ECR.
See [`docker/demuxafy/README.md`](docker/demuxafy/README.md) for instructions.

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

> The `inputs/` prefix is designed as an S3 event trigger target for future Lambda-based
> pipeline automation via the Seqera Platform API.

## Comparison: HPC vs Cloud

| Aspect | UCSF HPC (SGE) | This pipeline (AWS Batch) |
|---|---|---|
| Job scheduling | `#$ -t 1-N` array jobs | Nextflow channels (automatic) |
| Containers | Singularity modules | Docker (Wave) |
| Storage | `/wynton/scratch` | S3 + Fusion filesystem |
| Monitoring | qstat / log files | Seqera Platform dashboard |
| Scalability | Fixed cluster allocation | On-demand, auto-scaled |
| Reproducibility | Module versions | Container image tags |

## Skills Demonstrated

- Nextflow DSL2 pipeline development (subworkflows, modules, channels)
- Cloud-native bioinformatics on AWS Batch + S3 + Seqera Platform
- Multi-tool ensemble demultiplexing (Demuxlet, Vireo, Souporcell)
- GATK variant calling best practices for RNA-seq input
- Docker containerization + ECR for licensed/Singularity-only tools
- Event-driven architecture design (S3 → Lambda → Seqera API)

## References

- [Demuxafy documentation](https://demultiplexing-doublet-detecting-docs.readthedocs.io)
- [Nextflow DSL2 documentation](https://nextflow.io/docs/latest/)
- [GATK RNA-seq variant calling best practices](https://gatk.broadinstitute.org/hc/en-us/articles/360035531192)
- [Seqera Platform](https://seqera.io)
