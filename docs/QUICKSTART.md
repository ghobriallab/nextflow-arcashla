# Quick Start - Replicating User's Original Workflow

This guide shows how to replicate the exact workflow the user was performing with Docker commands, but now using the Nextflow pipeline.

## Original Docker Commands

The user was running these commands:

```bash
# 1) Extract chromosome 6 reads and HLA sequences
sudo docker run --rm \
  -v $HOME/arcasHLA:/app \
  -v $HOME/arcasHLA/test_acc_bam:/data \
  arcas_hla_test \
  /app/arcasHLA extract /data/P9_PB_V2_Cilta_Pre_RM_GEX_5.bam -o /data/out -t 8 --unmapped -v

# 2) Genotype with specific HLA genes
sudo docker run --rm \
  -v $HOME/arcasHLA:/app \
  -v $HOME/arcasHLA/test_acc_bam:/data \
  arcas_hla_test \
  /app/arcasHLA genotype \
  /data/out/P9_PB_V2_Cilta_Pre_RM_GEX_5.extracted.1.fq.gz \
  /data/out/P9_PB_V2_Cilta_Pre_RM_GEX_5.extracted.2.fq.gz \
  -g A,B,C,DMA,DMB,DOA,DOB,DPA1,DPB1,DQA1,DQB1,DRA,DRB1,DRB3,DRB5,E,F,G,H,J,K,L \
  -o /data/out \
  -t 8 \
  -v

# 3) View results
cat P9_PB_V2_Cilta_Pre_RM_GEX_5.genotype.json
```

## Nextflow Pipeline Equivalent

### Step 1: Build the Docker Image

```bash
cd nextflow-arcashla/docker
docker build -t arcashla:latest .
cd ..
```

### Step 2: Create Samplesheet

Create a file called `samplesheet.csv`:

```csv
sample_id,bam_file
P9_PB_V2_Cilta_Pre_RM_GEX_5,/path/to/P9_PB_V2_Cilta_Pre_RM_GEX_5.bam
```

**Important**: Replace `/path/to/` with the actual path to your BAM file.

### Step 3: Ensure BAM Index Exists

```bash
# If you don't have a .bai file, create it:
samtools index /path/to/P9_PB_V2_Cilta_Pre_RM_GEX_5.bam
```

### Step 4: Run the Pipeline

```bash
nextflow run main.nf \
    -profile local \
    --samplesheet samplesheet.csv \
    --hla_genes "A,B,C,DMA,DMB,DOA,DOB,DPA1,DPB1,DQA1,DQB1,DRA,DRB1,DRB3,DRB5,E,F,G,H,J,K,L" \
    --threads 8 \
    --include_unmapped \
    --verbose \
    --outdir results
```

### Step 5: View Results

```bash
# View the genotype JSON
cat results/P9_PB_V2_Cilta_Pre_RM_GEX_5/genotype/P9_PB_V2_Cilta_Pre_RM_GEX_5.genotype.json

# Or use jq for pretty formatting (if installed)
cat results/P9_PB_V2_Cilta_Pre_RM_GEX_5/genotype/P9_PB_V2_Cilta_Pre_RM_GEX_5.genotype.json | jq .

# View logs
cat results/P9_PB_V2_Cilta_Pre_RM_GEX_5/extract/P9_PB_V2_Cilta_Pre_RM_GEX_5.extract.log
cat results/P9_PB_V2_Cilta_Pre_RM_GEX_5/genotype/P9_PB_V2_Cilta_Pre_RM_GEX_5.genotype.log
```

## Expected Output

The genotype JSON should look similar to:

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

## Advantages of Using the Pipeline

1. **Automation**: Run multiple samples at once
2. **Reproducibility**: All parameters documented in config
3. **Resource Management**: Automatic CPU/memory allocation
4. **Error Handling**: Automatic retries on failures
5. **Tracking**: Execution reports and logs
6. **Resume**: Can resume if interrupted
7. **Cloud-Ready**: Easy to scale to GCP

## Running Multiple Samples

If you have multiple BAM files, just add them to the samplesheet:

```csv
sample_id,bam_file
P9_PB_V2_Cilta_Pre_RM_GEX_5,/path/to/P9_PB_V2_Cilta_Pre_RM_GEX_5.bam
P10_PB_V2_Sample,/path/to/P10_PB_V2_Sample.bam
P11_PB_V2_Sample,/path/to/P11_PB_V2_Sample.bam
```

Then run the same command - all samples will be processed in parallel!

## Customizing for Specific HLA-II Loci

If you want to restrict to specific HLA-II loci as mentioned in the user notes:

```bash
nextflow run main.nf \
    -profile local \
    --samplesheet samplesheet.csv \
    --hla_genes "DPB1,DQA1,DQB1,DRB1" \
    --threads 8 \
    --include_unmapped \
    --outdir results
```

## Troubleshooting

### If Docker permissions are an issue:
```bash
# Add your user to docker group
sudo usermod -aG docker $USER
# Log out and log back in

# Or run nextflow with sudo (not recommended)
sudo nextflow run main.nf ...
```

### If you get memory errors:
```bash
# Increase memory allocation
nextflow run main.nf \
    --max_memory 128.GB \
    ...
```

### To see what's happening:
```bash
# Watch the Nextflow log
tail -f .nextflow.log

# Check Docker containers
docker ps
```

## Next Steps

Once you've validated the results match your original workflow:
1. Add more samples to the samplesheet
2. Consider using the GCP profile for larger batches
3. Explore other HLA gene combinations
4. Adjust parameters if needed (see docs/USAGE.md)
