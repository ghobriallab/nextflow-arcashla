# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2026-01-13

### Added
- Initial release of arcasHLA Nextflow pipeline
- arcasHLA extract module for extracting chromosome 6 and HLA reads from BAM files
- arcasHLA genotype module for HLA typing from extracted FASTQs
- Docker containerization support
- Google Cloud Platform (GCP) execution profile
- Local execution profile for testing
- Comprehensive documentation and examples
- Parameter configuration for HLA gene selection
- Support for all major HLA genes (Class I and II)
- Flexible resource allocation
- Pipeline execution reports and timelines

### Features
- Processes single-cell and bulk RNA-seq BAM files
- Supports custom HLA gene panels
- Includes unmapped reads option
- Advanced genotyping parameter tuning
- Automatic result organization by sample
- JSON output format for easy parsing

### Documentation
- README with quick start guide
- Detailed USAGE guide
- Docker build instructions
- Example samplesheets and run scripts
- Troubleshooting section
