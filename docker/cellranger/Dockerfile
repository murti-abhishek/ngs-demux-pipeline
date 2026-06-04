FROM ubuntu:22.04

ARG CELLRANGER_VERSION=7.2.0

# Download Cell Ranger tarball before building:
#   https://www.10xgenomics.com/support/software/cell-ranger/downloads
# Place cellranger-${CELLRANGER_VERSION}.tar.gz in this directory.

RUN apt-get update && apt-get install -y bc coreutils wget \
    && rm -rf /var/lib/apt/lists/*

COPY cellranger-${CELLRANGER_VERSION}.tar.gz /tmp/
RUN tar -xzf /tmp/cellranger-${CELLRANGER_VERSION}.tar.gz -C /opt/ \
    && rm /tmp/cellranger-${CELLRANGER_VERSION}.tar.gz

ENV PATH="/opt/cellranger-${CELLRANGER_VERSION}:${PATH}"

ENTRYPOINT ["cellranger"]
