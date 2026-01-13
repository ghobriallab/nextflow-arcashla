# arcasHLA Docker Image

This directory contains the Dockerfile and scripts for building the arcasHLA Docker image.

## Building the Image Locally

```bash
cd docker
docker build -t arcashla:latest .
```

## Testing the Image

```bash
# Test that arcasHLA is accessible
docker run --rm arcashla:latest python3 /opt/arcasHLA/arcasHLA --help

# Test with a sample BAM file
docker run --rm \
  -v /path/to/your/data:/data \
  arcashla:latest \
  python3 /opt/arcasHLA/arcasHLA extract /data/sample.bam -o /data/out -t 8 -v
```

## Pushing to Google Cloud Artifact Registry

### Prerequisites

1. Authenticate with Google Cloud:
```bash
gcloud auth login
gcloud config set project ghobrial-pipelines
```

2. Configure Docker for Artifact Registry:
```bash
gcloud auth configure-docker us-docker.pkg.dev
```

3. Create repository (if not exists):
```bash
gcloud artifacts repositories create arcashla \
  --repository-format=docker \
  --location=us \
  --description="arcasHLA Docker images for HLA typing"
```

### Build and Push

Use the provided script:
```bash
chmod +x build_and_push.sh
./build_and_push.sh ghobrial-pipelines us-docker.pkg.dev arcashla
```

Or manually:
```bash
# Build
docker build -t arcashla:0.6.0 .

# Tag
docker tag arcashla:0.6.0 us-docker.pkg.dev/ghobrial-pipelines/arcashla/arcashla:0.6.0
docker tag arcashla:0.6.0 us-docker.pkg.dev/ghobrial-pipelines/arcashla/arcashla:latest

# Push
docker push us-docker.pkg.dev/ghobrial-pipelines/arcashla/arcashla:0.6.0
docker push us-docker.pkg.dev/ghobrial-pipelines/arcashla/arcashla:latest
```

## Image Contents

- **Base**: Ubuntu 22.04
- **arcasHLA**: Latest version from GitHub (master branch)
- **Python**: 3.x with required dependencies (biopython, numpy, pandas, scipy)
- **Tools**: samtools, bedtools, pigz

## Notes

- arcasHLA reference data needs to be downloaded on first use or pre-built into the image
- The image is designed to work with Nextflow's Docker integration
- For production use, consider pinning arcasHLA to a specific commit/tag instead of master
