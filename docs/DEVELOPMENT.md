# Development Notes

This document contains notes for developers working on the arcasHLA pipeline.

## Project Structure

```
nextflow-arcashla/
├── main.nf                 # Main workflow file
├── nextflow.config         # Configuration file
├── README.md              # User documentation
├── CHANGELOG.md           # Version history
├── .gitignore            # Git ignore patterns
├── samplesheet.csv       # Example samplesheet
├── example_run.sh        # Local run example
├── example_run_gcp.sh    # GCP run example
├── conf/
│   └── modules.config    # Module-specific configs
├── modules/
│   └── local/
│       ├── arcashla_extract/
│       │   └── main.nf   # Extract process
│       └── arcashla_genotype/
│           └── main.nf   # Genotype process
├── docker/
│   ├── Dockerfile        # Docker image definition
│   ├── build_and_push.sh # Build script
│   └── README.md         # Docker documentation
└── docs/
    └── USAGE.md          # Detailed usage guide
```

## Design Decisions

### Module Structure
- Followed the same structure as nextflow-cellranger for consistency
- Two main processes: EXTRACT and GENOTYPE
- Each module is self-contained with inputs, outputs, and versioning

### Docker Image
- Based on Ubuntu 22.04 for stability
- Clones arcasHLA from GitHub (master branch)
- Includes all required dependencies (samtools, bedtools, python packages)
- Can be easily updated to use a specific arcasHLA version

### Configuration
- Separated module-specific configs in `conf/modules.config`
- Default parameters suitable for most use cases
- Easy to override via command line or parameter files

### Output Organization
- Results organized by sample_id
- Separate directories for extract and genotype outputs
- Pipeline info directory for execution reports

## Adding New Features

### Adding a New Process

1. Create a new directory in `modules/local/`:
```bash
mkdir -p modules/local/new_process
```

2. Create `main.nf` in the new directory with the process definition

3. Add the process to `main.nf`:
```groovy
include { NEW_PROCESS } from './modules/local/new_process/main'
```

4. Add configuration in `conf/modules.config`:
```groovy
withName: 'NEW_PROCESS' {
    cpus   = ...
    memory = ...
    time   = ...
}
```

### Adding New Parameters

1. Add default value in `nextflow.config`:
```groovy
params {
    new_parameter = 'default_value'
}
```

2. Use in process:
```groovy
def my_arg = params.new_parameter ? "--flag ${params.new_parameter}" : ''
```

3. Document in README.md

## Testing

### Local Testing

```bash
# Build Docker image
cd docker
docker build -t arcashla:latest .

# Test with small dataset
cd ..
nextflow run main.nf \
    -profile test \
    --samplesheet test_data/samplesheet.csv \
    --outdir test_results
```

### Testing on GCP

```bash
# Use test profile with GCP
nextflow run main.nf \
    -profile gcp \
    -profile test \
    --samplesheet gs://bucket/test_samplesheet.csv \
    --outdir gs://bucket/test_results
```

## Version Updates

### Updating arcasHLA Version

To use a specific version of arcasHLA:

1. Modify `docker/Dockerfile`:
```dockerfile
RUN git clone https://github.com/RabadanLab/arcasHLA.git && \
    cd arcasHLA && \
    git checkout v0.6.0  # Specify version/tag
```

2. Update version in `docker/Dockerfile` LABEL

3. Rebuild and push Docker image

### Updating Pipeline Version

1. Update version in `nextflow.config` manifest section
2. Update `CHANGELOG.md`
3. Tag the release in Git:
```bash
git tag -a v1.0.1 -m "Release version 1.0.1"
git push origin v1.0.1
```

## CI/CD Considerations

For future automation:
- GitHub Actions for Docker image builds
- Automated testing with test datasets
- Version tagging and releases
- Documentation generation

## Known Limitations

1. arcasHLA reference data must be downloaded on first use
2. Requires BAM index files to be present
3. Memory requirements can be high for large BAM files
4. Currently only supports paired-end data

## Future Enhancements

Potential improvements:
- [ ] Support for single-end reads
- [ ] Pre-built arcasHLA reference in Docker image
- [ ] Batch mode for processing multiple samples more efficiently
- [ ] Integration with other HLA typing tools for validation
- [ ] Summary report across all samples
- [ ] VCF output format option
- [ ] Support for targeted HLA sequencing data

## Contributing

When contributing:
1. Follow the existing code style
2. Update documentation
3. Add tests for new features
4. Update CHANGELOG.md
5. Ensure compatibility with both local and GCP profiles

## Debugging

### Enable verbose logging
```bash
nextflow run main.nf -profile local --verbose true ...
```

### Check process logs
```bash
# Find the work directory for a failed process
cat .nextflow.log | grep "ERROR"

# Navigate to the work directory and check
cd work/xx/xxxxxxxxxxxxxxxx
cat .command.log
cat .command.err
```

### Test Docker container
```bash
# Test the extract command
docker run --rm -v $(pwd):/data arcashla:latest \
    python /opt/arcasHLA/arcasHLA extract --help

# Interactive debugging
docker run --rm -it -v $(pwd):/data arcashla:latest /bin/bash
```

## Resources

- [arcasHLA GitHub](https://github.com/RabadanLab/arcasHLA)
- [Nextflow Documentation](https://www.nextflow.io/docs/latest/index.html)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Google Cloud Batch](https://cloud.google.com/batch/docs)
