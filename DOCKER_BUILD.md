# Docker Build and Push Summary

## ✅ Successfully Completed

### 1. Docker Image Built
- **Image Name**: `arcashla`
- **Version**: `0.6.0` and `latest`
- **Size**: 768 MB (271 MB compressed)
- **Base**: Ubuntu 22.04
- **Contents**:
  - arcasHLA (cloned from GitHub master branch)
  - Python 3.10.12
  - samtools 1.13
  - bedtools 2.30.0
  - Python packages: biopython, numpy, pandas, scipy

### 2. Pushed to Google Artifact Registry
- **Repository**: `us-docker.pkg.dev/ghobrial-pipelines/arcashla/arcashla`
- **Tags**:
  - `0.6.0` - Versioned tag
  - `latest` - Latest tag
- **Digest**: `sha256:3d5e5c91cf353782d252198692eb777b31a7ca110081cfcf4ab06f8a316fcd2c`
- **Push Time**: 2026-01-13 19:44:20 UTC

### 3. Pipeline Configuration Updated
- Updated `nextflow.config` to use the GCP container:
  ```groovy
  arcashla_container = 'us-docker.pkg.dev/ghobrial-pipelines/arcashla/arcashla:latest'
  ```

## Usage

### Pull the Image
```bash
docker pull us-docker.pkg.dev/ghobrial-pipelines/arcashla/arcashla:latest
```

### Test the Image Locally
```bash
# Test basic tools
docker run --rm us-docker.pkg.dev/ghobrial-pipelines/arcashla/arcashla:latest \
  bash -c "python3 --version && samtools --version && bedtools --version"

# Test arcasHLA (note: arcasHLA is a bash script)
docker run --rm us-docker.pkg.dev/ghobrial-pipelines/arcashla/arcashla:latest \
  bash /opt/arcasHLA/arcasHLA --help
```

### Run the Nextflow Pipeline
```bash
# The pipeline will automatically pull the container when running
nextflow run main.nf \
  -profile gcp \
  --samplesheet samplesheet.csv \
  --outdir gs://your-bucket/results
```

## Repository Details

To view the repository:
```bash
gcloud artifacts repositories describe arcashla \
  --location=us \
  --project=ghobrial-pipelines
```

To list all images:
```bash
gcloud artifacts docker images list \
  us-docker.pkg.dev/ghobrial-pipelines/arcashla/arcashla
```

## Next Steps

1. **Test the pipeline locally** with the Docker image:
   ```bash
   nextflow run main.nf -profile local --samplesheet samplesheet.csv
   ```

2. **Run on GCP** with the pushed image (no additional setup needed):
   ```bash
   nextflow run main.nf -profile gcp --samplesheet gs://bucket/samplesheet.csv
   ```

3. **Update to a specific version** if needed by changing in `nextflow.config`:
   ```groovy
   arcashla_container = 'us-docker.pkg.dev/ghobrial-pipelines/arcashla/arcashla:0.6.0'
   ```

## Troubleshooting

### If you need to rebuild and push:
```bash
cd docker
docker build -t arcashla:latest .
docker tag arcashla:latest us-docker.pkg.dev/ghobrial-pipelines/arcashla/arcashla:latest
docker push us-docker.pkg.dev/ghobrial-pipelines/arcashla/arcashla:latest
```

### If authentication fails:
```bash
gcloud auth configure-docker us-docker.pkg.dev
```

### To delete and recreate the repository:
```bash
gcloud artifacts repositories delete arcashla --location=us --project=ghobrial-pipelines
gcloud artifacts repositories create arcashla --repository-format=docker --location=us --project=ghobrial-pipelines
```

## Image Information

- **Created**: January 13, 2026
- **Last Updated**: January 13, 2026
- **Compressed Size**: ~271 MB
- **Uncompressed Size**: ~768 MB
- **Layers**: 6
- **Project**: ghobrial-pipelines
- **Location**: us (multi-region)

## Build Time Details

Total build time: ~2 minutes
- System dependencies installation: ~1 minute
- Git clone arcasHLA: ~5 seconds
- Python packages installation: ~30 seconds
- Container optimization: ~5 seconds

The image is ready for production use! 🎉
