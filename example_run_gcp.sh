#!/bin/bash

# Example run script for Google Cloud Platform
# This demonstrates running the pipeline on GCP with Google Batch

# Set paths (GCS bucket paths)
SAMPLESHEET="gs://your-bucket/samplesheet.csv"
OUTDIR="gs://your-bucket/arcashla-results"

# Run the pipeline on GCP
nextflow run main.nf \
    -profile gcp \
    --samplesheet ${SAMPLESHEET} \
    --hla_genes "A,B,C,DPB1,DQA1,DQB1,DRB1" \
    --threads 8 \
    --include_unmapped \
    --outdir ${OUTDIR}

echo ""
echo "Pipeline submitted to Google Cloud!"
echo "Monitor progress in the Nextflow log"
echo "Results will be in: ${OUTDIR}"
