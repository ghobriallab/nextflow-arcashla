# arcasHLA Pipeline Usage Guide

This guide provides detailed information on using the arcasHLA Nextflow pipeline.

## Table of Contents

1. [Setup](#setup)
2. [Input Preparation](#input-preparation)
3. [Running the Pipeline](#running-the-pipeline)
4. [Understanding the Output](#understanding-the-output)
5. [Advanced Usage](#advanced-usage)
6. [Troubleshooting](#troubleshooting)

## Setup

### 1. Install Nextflow

```bash
# Install Nextflow
curl -s https://get.nextflow.io | bash
sudo mv nextflow /usr/local/bin/

# Verify installation
nextflow -version
```

### 2. Clone the Pipeline

```bash
git clone https://github.com/ghobriallab/nextflow-arcashla.git
cd nextflow-arcashla
```

### 3. Build the Docker Image

```bash
cd docker
docker build -t arcashla:latest .
cd ..
```

## Input Preparation

### BAM File Requirements

- **Format**: BAM files from RNA-seq data (single-cell or bulk)
- **Index**: BAM index files (.bai) must exist
- **Coverage**: Sufficient coverage of HLA region (chromosome 6)

### Creating BAM Index

If you don't have .bai files:

```bash
# For a single file
samtools index sample1.bam

# For multiple files
for bam in *.bam; do
    samtools index "$bam"
done
```

### Creating the Samplesheet

Create a CSV file with two columns:

1. `sample_id`: Unique identifier for each sample
2. `bam_file`: Full path to the BAM file

Example:
```csv
sample_id,bam_file
patient_001,/data/bams/patient_001.bam
patient_002,/data/bams/patient_002.bam
control_001,/data/bams/control_001.bam
```

**Tips:**
- Use absolute paths for BAM files
- Ensure sample_id is unique
- No spaces in sample_id (use underscores)
- BAM files can be local or on network storage

## Running the Pipeline

### Basic Local Run

```bash
nextflow run main.nf \
    -profile local \
    --samplesheet samplesheet.csv \
    --outdir results
```

### Specifying HLA Genes

#### All HLA Class I and II (default)
```bash
nextflow run main.nf \
    -profile local \
    --samplesheet samplesheet.csv \
    --outdir results
```

#### Common HLA genes only
```bash
nextflow run main.nf \
    -profile local \
    --samplesheet samplesheet.csv \
    --hla_genes "A,B,C,DRB1,DQA1,DQB1,DPB1" \
    --outdir results
```

#### HLA Class I only
```bash
nextflow run main.nf \
    -profile local \
    --samplesheet samplesheet.csv \
    --hla_genes "A,B,C" \
    --outdir results
```

#### HLA Class II only
```bash
nextflow run main.nf \
    -profile local \
    --samplesheet samplesheet.csv \
    --hla_genes "DMA,DMB,DOA,DOB,DPA1,DPB1,DQA1,DQB1,DRA,DRB1,DRB3,DRB5" \
    --outdir results
```

### Adjusting Resources

#### Increase threads
```bash
nextflow run main.nf \
    -profile local \
    --samplesheet samplesheet.csv \
    --threads 16 \
    --outdir results
```

#### Adjust memory limits
```bash
nextflow run main.nf \
    -profile local \
    --samplesheet samplesheet.csv \
    --max_memory 128.GB \
    --max_cpus 32 \
    --outdir results
```

### Running on Google Cloud Platform

```bash
# Ensure you're authenticated
gcloud auth login
gcloud config set project ghobrial-pipelines

# Run pipeline
nextflow run main.nf \
    -profile gcp \
    --samplesheet gs://my-bucket/samplesheet.csv \
    --outdir gs://my-bucket/results
```

### Resume a Failed Run

Nextflow caches completed tasks. To resume:

```bash
nextflow run main.nf \
    -profile local \
    --samplesheet samplesheet.csv \
    --outdir results \
    -resume
```

## Understanding the Output

### Directory Structure

```
results/
├── sample1/
│   ├── extract/
│   │   ├── sample1.extracted.1.fq.gz    # R1 reads (chr6 + HLA)
│   │   ├── sample1.extracted.2.fq.gz    # R2 reads (chr6 + HLA)
│   │   └── sample1.extract.log          # Extraction log
│   └── genotype/
│       ├── sample1.genotype.json        # HLA predictions
│       ├── sample1.alignment.p          # Alignment data (optional)
│       └── sample1.genotype.log         # Genotyping log
└── pipeline_info/
    ├── execution_report.html            # Resource usage report
    ├── execution_timeline.html          # Timeline visualization
    └── execution_trace.txt              # Detailed trace
```

### Genotype JSON Format

The main output is the `*.genotype.json` file:

```json
{
  "A": ["A*02:01:01", "A*24:02:01"],
  "B": ["B*07:02:01", "B*44:03:01"],
  "C": ["C*07:02:01", "C*05:01:01"],
  "DRB1": ["DRB1*15:01:01", "DRB1*04:01:01"]
}
```

**Interpretation:**
- Each HLA gene shows up to 2 alleles (diploid)
- Allele names follow standard HLA nomenclature
- Format: Gene*Allele:Protein:Synonymous:Non-coding

### Viewing Results

```bash
# View all genotypes
for json in results/*/genotype/*.genotype.json; do
    echo "=== $(basename $json) ==="
    cat "$json"
    echo ""
done

# Extract specific gene
grep -h "\"DRB1\"" results/*/genotype/*.genotype.json
```

### Quality Metrics

Check the log files for quality information:

```bash
# View extraction statistics
cat results/sample1/extract/sample1.extract.log

# View genotyping details
cat results/sample1/genotype/sample1.genotype.log
```

## Advanced Usage

### Fine-tuning Genotyping Parameters

For difficult samples or low coverage:

```bash
nextflow run main.nf \
    -profile local \
    --samplesheet samplesheet.csv \
    --min_count 50 \
    --min_likelihood -1000 \
    --drop_iterations 10 \
    --outdir results
```

### Excluding Unmapped Reads

By default, unmapped reads are included. To exclude:

```bash
nextflow run main.nf \
    -profile local \
    --samplesheet samplesheet.csv \
    --include_unmapped false \
    --outdir results
```

### Running with Custom Docker Image

If you've pushed to a registry:

```bash
nextflow run main.nf \
    -profile local \
    --samplesheet samplesheet.csv \
    --arcashla_container us-docker.pkg.dev/ghobrial-pipelines/arcashla/arcashla:latest \
    --outdir results
```

### Processing Subset of Samples

Create a filtered samplesheet:

```bash
# Select first 5 samples
head -n 6 samplesheet.csv > samplesheet_subset.csv

nextflow run main.nf \
    -profile local \
    --samplesheet samplesheet_subset.csv \
    --outdir results
```

## Troubleshooting

### Issue: "BAM index not found"

**Solution:**
```bash
# Create index for your BAM files
samtools index your_file.bam
```

### Issue: "Out of memory"

**Solution 1 - Increase memory limit:**
```bash
nextflow run main.nf \
    --max_memory 128.GB \
    ...
```

**Solution 2 - Use GCP profile:**
```bash
nextflow run main.nf \
    -profile gcp \
    ...
```

### Issue: "No reads extracted"

**Possible causes:**
1. BAM file is not from RNA-seq
2. No coverage of chromosome 6
3. Wrong reference genome

**Check:**
```bash
samtools view your_file.bam chr6 | head
```

### Issue: "Docker permission denied"

**Solution:**
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Log out and log back in, or:
newgrp docker
```

### Issue: Pipeline hangs or is slow

**Check:**
1. Docker has enough resources allocated
2. Sufficient disk space
3. Network connectivity (for GCP)

**Monitor:**
```bash
# In another terminal
docker stats
df -h
```

### Issue: "No genotype called"

**Possible causes:**
1. Low coverage of HLA regions
2. Poor read quality
3. Restricted gene panel

**Solutions:**
```bash
# Try with more lenient parameters
nextflow run main.nf \
    --min_count 25 \
    --min_likelihood -2000 \
    ...

# Or try all genes
nextflow run main.nf \
    --hla_genes "A,B,C,DMA,DMB,DOA,DOB,DPA1,DPB1,DQA1,DQB1,DRA,DRB1,DRB3,DRB4,DRB5" \
    ...
```

## Getting Help

1. Check the log files in `results/pipeline_info/`
2. Review the process logs in the `work/` directory
3. Open an issue on GitHub
4. Contact the Ghobrial Lab

## Tips for Best Results

1. **Coverage**: Ensure good coverage of chromosome 6 (at least 30x recommended)
2. **Quality**: Use high-quality RNA-seq data
3. **Processing**: Start with default parameters, then fine-tune if needed
4. **Validation**: Compare results with known HLA types when available
5. **Resources**: Use GCP profile for large batches (>10 samples)
