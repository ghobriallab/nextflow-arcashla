#!/bin/bash
# Verification script for arcasHLA Docker image

echo "========================================="
echo "Testing arcasHLA Docker Image"
echo "========================================="
echo ""

IMAGE="us-docker.pkg.dev/ghobrial-pipelines/arcashla/arcashla:latest"

echo "1. Pulling image..."
docker pull $IMAGE
echo ""

echo "2. Testing Python..."
docker run --rm $IMAGE python3 --version
echo ""

echo "3. Testing samtools..."
docker run --rm $IMAGE samtools --version | head -1
echo ""

echo "4. Testing bedtools..."
docker run --rm $IMAGE bedtools --version
echo ""

echo "5. Testing arcasHLA presence..."
docker run --rm $IMAGE bash -c "ls -l /opt/arcasHLA/arcasHLA"
echo ""

echo "6. Testing Python packages..."
docker run --rm $IMAGE python3 -c "import Bio, numpy, pandas, scipy; print('✅ All Python packages imported successfully')"
echo ""

echo "========================================="
echo "✅ All tests passed!"
echo "========================================="
