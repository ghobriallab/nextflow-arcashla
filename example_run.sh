#!/bin/bash

# Example run script for arcasHLA pipeline
# This demonstrates the basic usage as described by the user

# Set paths
SAMPLESHEET="samplesheet.csv"
OUTDIR="results"

# Run the pipeline with parameters matching the user's example
nextflow run main.nf \
    -profile local \
    --samplesheet ${SAMPLESHEET} \
    --hla_genes "A,B,C,DMA,DMB,DOA,DOB,DPA1,DPB1,DQA1,DQB1,DRA,DRB1,DRB3,DRB5,E,F,G,H,J,K,L" \
    --threads 8 \
    --include_unmapped \
    --verbose \
    --outdir ${OUTDIR}

echo ""
echo "Pipeline completed!"
echo "Results are in: ${OUTDIR}"
echo ""
echo "To view genotype results:"
echo "  cat ${OUTDIR}/*/genotype/*.genotype.json"
