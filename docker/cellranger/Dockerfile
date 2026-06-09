FROM ubuntu:22.04

ARG CELLRANGER_VERSION=10.0.0

# Download Cell Ranger tarball before building:
#   https://www.10xgenomics.com/support/software/cell-ranger/downloads
# Place cellranger-${CELLRANGER_VERSION}.tar.gz in this directory.

RUN apt-get update && apt-get install -y bc coreutils wget curl unzip \
    && rm -rf /var/lib/apt/lists/*

# AWS CLI v2 — required for S3 file staging in AWS Batch
RUN curl -sS "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip -q awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws/

COPY cellranger-${CELLRANGER_VERSION}.tar.gz /tmp/
RUN tar -xzf /tmp/cellranger-${CELLRANGER_VERSION}.tar.gz -C /opt/ \
    && rm /tmp/cellranger-${CELLRANGER_VERSION}.tar.gz

ENV PATH="/opt/cellranger-${CELLRANGER_VERSION}:${PATH}"

RUN cellranger --version && aws --version