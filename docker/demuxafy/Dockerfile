FROM mambaorg/micromamba:1.5.8

LABEL maintainer="Abhishek Murti"
LABEL description="Demuxlet (popscle) + Vireo + cellsnp-lite + Souporcell + bcftools + AWS CLI v2"

USER root

ENV DEBIAN_FRONTEND=noninteractive

# System dependencies + AWS CLI v2
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    procps \
    && curl -sS "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip -q awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws/ \
    && rm -rf /var/lib/apt/lists/*

# Install all tools via conda/mamba
RUN micromamba install --yes --name base \
    -c bioconda -c conda-forge \
    popscle \
    vireosnp \
    cellsnp-lite \
    souporcell \
    bcftools \
    htslib \
    && micromamba clean --all --yes

ENV PATH="/opt/conda/bin:${PATH}"

# Verify installations
RUN aws --version \
    && popscle 2>&1 | grep -i "version\|popscle" | head -2 || true \
    && vireo --help 2>&1 | head -2 || true \
    && souporcell --help 2>&1 | head -2 || true \
    && bcftools --version | head -1 \
    && cellsnp-lite --version 2>&1 | head -1 || true

WORKDIR /data