#!/bin/bash

# Build and push arcasHLA Docker image to Google Cloud Artifact Registry
# Usage: ./build_and_push.sh [PROJECT_ID] [REGION] [REPOSITORY]

set -e

# Default values
PROJECT_ID="${1:-ghobrial-pipelines}"
REGION="${2:-us-docker.pkg.dev}"
REPOSITORY="${3:-arcashla}"
IMAGE_NAME="arcashla"
VERSION="0.6.0"

# Full image path
FULL_IMAGE_PATH="${REGION}/${PROJECT_ID}/${REPOSITORY}/${IMAGE_NAME}:${VERSION}"
LATEST_IMAGE_PATH="${REGION}/${PROJECT_ID}/${REPOSITORY}/${IMAGE_NAME}:latest"

echo "Building arcasHLA Docker image..."
docker build -t ${IMAGE_NAME}:${VERSION} -t ${IMAGE_NAME}:latest .

echo "Tagging image for Google Artifact Registry..."
docker tag ${IMAGE_NAME}:${VERSION} ${FULL_IMAGE_PATH}
docker tag ${IMAGE_NAME}:latest ${LATEST_IMAGE_PATH}

echo "Pushing image to Google Artifact Registry..."
docker push ${FULL_IMAGE_PATH}
docker push ${LATEST_IMAGE_PATH}

echo "Successfully pushed images:"
echo "  - ${FULL_IMAGE_PATH}"
echo "  - ${LATEST_IMAGE_PATH}"
echo ""
echo "To use this image in your pipeline, update nextflow.config:"
echo "  params.arcashla_container = '${FULL_IMAGE_PATH}'"
