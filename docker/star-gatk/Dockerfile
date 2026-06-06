FROM ubuntu:22.04

LABEL maintainer="Abhishek Murti"
LABEL description="STAR 2.7.11b + GATK 4.6.2.0 + samtools for bulk RNA-seq alignment and variant calling"

ENV DEBIAN_FRONTEND=noninteractive
ENV STAR_VERSION=2.7.11b
ENV GATK_VERSION=4.6.2.0
ENV SAMTOOLS_VERSION=1.21

# ------------------------------------------------------------
# System dependencies
# ------------------------------------------------------------
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    unzip \
    bzip2 \
    build-essential \
    gcc \
    make \
    libncurses5-dev \
    libbz2-dev \
    liblzma-dev \
    zlib1g-dev \
    libcurl4-openssl-dev \
    openjdk-17-jre-headless \
    python3 \
    python-is-python3 \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# samtools
# ------------------------------------------------------------
RUN wget -q https://github.com/samtools/samtools/releases/download/${SAMTOOLS_VERSION}/samtools-${SAMTOOLS_VERSION}.tar.bz2 \
    && tar -xjf samtools-${SAMTOOLS_VERSION}.tar.bz2 \
    && cd samtools-${SAMTOOLS_VERSION} \
    && ./configure --prefix=/usr/local \
    && make -j4 \
    && make install \
    && cd .. \
    && rm -rf samtools-${SAMTOOLS_VERSION} samtools-${SAMTOOLS_VERSION}.tar.bz2

# ------------------------------------------------------------
# STAR
# ------------------------------------------------------------
RUN wget -q https://github.com/alexdobin/STAR/releases/download/${STAR_VERSION}/STAR_${STAR_VERSION}.zip \
    && unzip -q STAR_${STAR_VERSION}.zip \
    && mv STAR_${STAR_VERSION}/Linux_x86_64_static/STAR /usr/local/bin/STAR \
    && chmod +x /usr/local/bin/STAR \
    && rm -rf STAR_${STAR_VERSION} STAR_${STAR_VERSION}.zip

# ------------------------------------------------------------
# GATK
# ------------------------------------------------------------
RUN wget -q https://github.com/broadinstitute/gatk/releases/download/${GATK_VERSION}/gatk-${GATK_VERSION}.zip \
    && unzip -q gatk-${GATK_VERSION}.zip \
    && mv gatk-${GATK_VERSION} /opt/gatk \
    && ln -s /opt/gatk/gatk /usr/local/bin/gatk \
    && rm gatk-${GATK_VERSION}.zip

# ------------------------------------------------------------
# Verify installations
# ------------------------------------------------------------
RUN STAR --version \
    && samtools --version | head -1 \
    && gatk --version

WORKDIR /data