#!/bin/bash
#
# Test run script for arcasHLA pipeline
# Uses the test profile with arcasHLA test data
#

set -e

echo "=================================================="
echo "Running arcasHLA pipeline with test data"
echo "=================================================="
echo ""
echo "Test samplesheet: test_data/samplesheet_test.csv"
echo "Output directory: results_test"
echo "HLA genes: A,B,C,DPB1,DQB1,DQA1,DRB1"
echo ""
echo "Expected genotype results:"
echo "  A: A*01:01:01, A*03:01:01"
echo "  B: B*39:01:01, B*07:02:01"
echo "  C: C*08:01:01, C*01:02:01"
echo "  DPB1: DPB1*14:01:01, DPB1*02:01:02"
echo "  DQA1: DQA1*02:01:01, DQA1*05:03"
echo "  DQB1: DQB1*02:02:01, DQB1*06:09:01"
echo "  DRB1: DRB1*10:01:01, DRB1*14:02:01"
echo ""
echo "=================================================="
echo ""

# Clean previous test results
if [ -d "results_test" ]; then
    echo "Cleaning previous test results..."
    rm -rf results_test
fi

# Run the pipeline with test profile
nextflow run main.nf \
    -profile test \
    -resume

echo ""
echo "=================================================="
echo "Test completed!"
echo "=================================================="
echo ""
echo "Check results in: results_test/"
echo "Genotype results: results_test/genotype/test.genotype.json"
echo ""
