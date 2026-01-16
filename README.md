# arcasHLA Pipeline - HLA Typing from RNA-seq

A Nextflow pipeline for HLA typing from single-cell or bulk RNA-seq BAM files using [arcasHLA](https://github.com/RabadanLab/arcasHLA).

## Features

- **Extract**: Extracts chromosome 6 reads and HLA-related sequences from BAM files
- **Genotype**: Predicts HLA alleles for multiple loci (HLA-I and HLA-II)
- **Containerized**: All processes run in Docker containers for reproducibility
- **Cloud-ready**: Configured for Google Cloud Platform with local testing profile
- **Flexible**: Supports custom HLA gene panels and various parameter tuning options

## Pipeline Overview

```
Input BAM files
    |
    v
arcasHLA extract --> Extracted paired-end FASTQs (chr6 + HLA reads)
    |
    v
arcasHLA genotype --> HLA genotype predictions (JSON format)
```

## Quick Start

### Prerequisites

- Nextflow (>=23.04.0)
- Docker
- BAM files from RNA-seq data (single-cell or bulk)
- BAM index files (.bai)

### Installation

```bash
git clone https://github.com/ghobriallab/nextflow-arcashla.git
cd nextflow-arcashla
```

### Building the Docker Image

```bash
cd docker
docker build -t arcashla:latest .
cd ..
```

For Google Cloud Artifact Registry:
```bash
cd docker
./build_and_push.sh ghobrial-pipelines us-docker.pkg.dev arcashla
cd ..
```

### Running the Pipeline

#### Basic Usage

```bash
nextflow run main.nf \
    -profile local \
    --samplesheet samplesheet.csv \
    --outdir results
```

#### Example Samplesheet (samplesheet.csv)

```csv
sample_id,bam_file
sample1,/path/to/sample1.bam
sample2,/path/to/sample2.bam
P9_PB_V2_Cilta_Pre_RM_GEX_5,/path/to/P9_PB_V2_Cilta_Pre_RM_GEX_5.bam
```

**Note**: BAM index files (.bai) should exist in the same directory as the BAM files.

#### With Custom HLA Genes

By default, the pipeline types all major HLA genes. To specify a subset:

```bash
nextflow run main.nf \
    -profile local \
    --samplesheet samplesheet.csv \
    --hla_genes "A,B,C,DPB1,DQA1,DQB1,DRB1" \
    --outdir results
```

#### On Google Cloud Platform

```bash
nextflow run main.nf \
    -profile gcp \
    --samplesheet gs://your-bucket/samplesheet.csv \
    --outdir gs://your-bucket/results
```

## Parameters

### Required Parameters

| Parameter | Description |
|-----------|-------------|
| `--samplesheet` | Path to CSV file with `sample_id` and `bam_file` columns |
| `--outdir` | Output directory for results |

### Optional Parameters

#### HLA Typing Options

| Parameter | Default | Description |
|-----------|---------|-------------|
| `--hla_genes` | All genes* | Comma-separated list of HLA genes to type |
| `--threads` | 8 | Number of threads for arcasHLA |
| `--include_unmapped` | true | Include unmapped reads in extraction |

*Default genes: A,B,C,DMA,DMB,DOA,DOB,DPA1,DPB1,DQA1,DQB1,DRA,DRB1,DRB3,DRB5,E,F,G,H,J,K,L

#### Genotyping Advanced Options

| Parameter | Default | Description |
|-----------|---------|-------------|
| `--min_count` | 75 | Minimum read count threshold |
| `--max_count` | null | Maximum read count threshold |
| `--min_likelihood` | 0.0 | Minimum likelihood score |
| `--drop_iterations` | 4 | Number of iterations for allele dropout |
| `--drop_threshold` | 0.1 | Threshold for allele dropout |
| `--zygosity_threshold` | 0.15 | Threshold for determining zygosity |

#### Resource Limits

| Parameter | Default | Description |
|-----------|---------|-------------|
| `--max_cpus` | 16 | Maximum CPUs per process |
| `--max_memory` | 64.GB | Maximum memory per process |
| `--max_time` | 48.h | Maximum time per process |

## Output Structure

```
results/
├── sample1/
│   ├── extract/
│   │   ├── sample1.extracted.1.fq.gz
│   │   ├── sample1.extracted.2.fq.gz
│   │   └── sample1.extract.log
│   └── genotype/
│       ├── sample1.genotype.json
│       ├── sample1.alignment.p
│       └── sample1.genotype.log
├── sample2/
│   └── ...
└── pipeline_info/
    ├── execution_report.html
    ├── execution_timeline.html
    └── execution_trace.txt
```

### Output Files

#### Extract Output
- `*.extracted.1.fq.gz`: Paired-end read 1 (chromosome 6 + HLA reads)
- `*.extracted.2.fq.gz`: Paired-end read 2 (chromosome 6 + HLA reads)
- `*.extract.log`: Extraction log file

#### Genotype Output
- `*.genotype.json`: HLA genotype predictions in JSON format
- `*.alignment.p`: Alignment pickle file (optional)
- `*.genotype.log`: Genotyping log file

### Example Genotype Output

```json
{
  "A": ["A*25:01:01", "A*01:01:01"],
  "B": ["B*08:01:01", "B*18:01:01"],
  "C": ["C*07:01:01", "C*12:03:01"],
  "DPB1": ["DPB1*09:01:01", "DPB1*04:01:01"],
  "DQA1": ["DQA1*01:02:01", "DQA1*05:01:01"],
  "DQB1": ["DQB1*02:01:01", "DQB1*06:02:01"],
  "DRB1": ["DRB1*03:01:01", "DRB1*15:01:01"]
}
```

## Execution Profiles

### local
Default profile for local testing with Docker
```bash
nextflow run main.nf -profile local --samplesheet samplesheet.csv
```

### gcp
Google Cloud Platform profile using Google Batch executor
```bash
nextflow run main.nf -profile gcp --samplesheet gs://bucket/samplesheet.csv
```

### standard
Standard profile with default Docker settings
```bash
nextflow run main.nf -profile standard --samplesheet samplesheet.csv
```

### test
Minimal resources for quick testing
```bash
nextflow run main.nf -profile test --samplesheet samplesheet.csv
```

## Example Run

Based on the provided user example:

```bash
# Create samplesheet
cat > samplesheet.csv << EOF
sample_id,bam_file
P9_PB_V2_Cilta_Pre_RM_GEX_5,/data/P9_PB_V2_Cilta_Pre_RM_GEX_5.bam
EOF

# Run pipeline
nextflow run main.nf \
    -profile local \
    --samplesheet samplesheet.csv \
    --hla_genes "A,B,C,DMA,DMB,DOA,DOB,DPA1,DPB1,DQA1,DQB1,DRA,DRB1,DRB3,DRB5" \
    --threads 8 \
    --include_unmapped \
    --outdir results

# View results
cat results/P9_PB_V2_Cilta_Pre_RM_GEX_5/genotype/P9_PB_V2_Cilta_Pre_RM_GEX_5.genotype.json
```

## Troubleshooting

### BAM Index Not Found
Ensure `.bai` files exist alongside BAM files:
```bash
samtools index your_file.bam
```

### Memory Issues
Increase memory allocation in `nextflow.config` or use `-profile gcp` for cloud resources.

### Docker Permission Issues
Add user to docker group or run with sudo (not recommended for production):
```bash
sudo usermod -aG docker $USER
```

## References

- [arcasHLA GitHub Repository](https://github.com/RabadanLab/arcasHLA)
- [arcasHLA Publication](https://doi.org/10.1093/bioinformatics/btz474)
- [Nextflow Documentation](https://www.nextflow.io/docs/latest/index.html)

## Citation

If you use this pipeline, please cite:

- **arcasHLA**: Orenbuch R, et al. (2019) arcasHLA: high-resolution HLA typing from RNAseq. Bioinformatics.
- **Nextflow**: Di Tommaso P, et al. (2017) Nextflow enables reproducible computational workflows. Nature Biotechnology.

## License

This pipeline is distributed under the MIT License.

## Contact

For questions or issues, please open an issue on GitHub or contact the Ghobrial Lab.
