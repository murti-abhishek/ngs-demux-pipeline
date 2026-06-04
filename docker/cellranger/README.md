# Cell Ranger Docker Image

Cell Ranger is a commercial tool distributed by 10x Genomics under a proprietary EULA.
The binary cannot be redistributed publicly. This Dockerfile is a build recipe only.

## Build Instructions

1. Download `cellranger-7.2.0.tar.gz` from:
   https://www.10xgenomics.com/support/software/cell-ranger/downloads
   Place the tarball in this directory.

2. Build the image:
   ```bash
   docker build --build-arg CELLRANGER_VERSION=7.2.0 -t cellranger:7.2.0 .
   ```

3. Push to **private** ECR only:
   ```bash
   aws ecr get-login-password --region us-east-1 \
     | docker login --username AWS \
       --password-stdin YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

   docker tag cellranger:7.2.0 \
     YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/cellranger:7.2.0

   docker push \
     YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/cellranger:7.2.0
   ```

4. Set in nextflow.config:
   ```
   params.ecr_registry = 'YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com'
   ```

> Do NOT push to Docker Hub or any public registry.
