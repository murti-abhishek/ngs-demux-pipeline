# Demuxafy Docker Image

Demuxafy is distributed as a Singularity `.sif` image. AWS Batch requires Docker/OCI
containers, so we convert the `.sif` to Docker once and push to private ECR.

## Conversion Instructions

1. Download the official Demuxafy Singularity image:
   https://demultiplexing-doublet-detecting-docs.readthedocs.io/en/latest/Installation.html

2. Verify the checksum (see Demuxafy docs for expected md5).

3. Convert .sif to Docker (requires Singularity installed locally):
   ```bash
   singularity build --docker-daemon demuxafy:2.0.1 Demuxafy.sif
   ```

4. Push to private ECR:
   ```bash
   aws ecr get-login-password --region us-east-1 \
     | docker login --username AWS \
       --password-stdin YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

   docker tag demuxafy:2.0.1 \
     YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/demuxafy:2.0.1

   docker push \
     YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/demuxafy:2.0.1
   ```

## References
- Demuxafy docs: https://demultiplexing-doublet-detecting-docs.readthedocs.io
- GitHub: https://github.com/drneavin/Demultiplexing_Doublet_Detecting_Docs
