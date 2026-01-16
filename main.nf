#!/usr/bin/env nextflow

/*
========================================================================================
    arcasHLA Pipeline - HLA Typing from RNA-seq
========================================================================================
    Pipeline for HLA typing from single-cell or bulk RNA-seq BAM files
    Uses arcasHLA to:
    1. Extract chromosome 6 reads and HLA sequences (extract)
    2. Predict HLA genotypes (genotype)
    
    Based on: https://github.com/RabadanLab/arcasHLA
========================================================================================
*/

nextflow.enable.dsl = 2

/*
========================================================================================
    IMPORT MODULES
========================================================================================
*/

include { ARCASHLA_EXTRACT } from './modules/local/arcashla_extract/main'
include { ARCASHLA_GENOTYPE } from './modules/local/arcashla_genotype/main'

/*
========================================================================================
    MAIN WORKFLOW
========================================================================================
*/

workflow {
    /*
    ========================================================================================
        PRINT PARAMETER SUMMARY
    ========================================================================================
    */

    log.info """
    ========================================
    arcasHLA Pipeline - HLA Typing
    ========================================
    Output Directory   : ${params.outdir}
    Sample Sheet       : ${params.samplesheet}
    HLA Genes          : ${params.hla_genes}
    Threads            : ${params.threads}
    Include Unmapped   : ${params.include_unmapped}
    ========================================
    """

    
    // Parse input samplesheet
    // Expected columns: sample, bam
    ch_samplesheet = Channel.fromPath(params.samplesheet, checkIfExists: true)
        .splitCsv(header: true, sep: ',')
        .map { row -> 
            def sample_id = row.sample_id
            def bam_file = file(row.bam, checkIfExists: true)
            return tuple(sample_id, bam_file)
        }

    // Step 1: Extract chromosome 6 reads and HLA sequences
    ARCASHLA_EXTRACT(ch_samplesheet)

    // Step 2: Genotype - predict HLA alleles from extracted FASTQs
    ARCASHLA_GENOTYPE(ARCASHLA_EXTRACT.out.fastqs)
}

/*
========================================================================================
    COMPLETION SUMMARY
========================================================================================
*/

workflow.onComplete {
    log.info """
    ========================================
    Pipeline completed!
    ========================================
    Status      : ${workflow.success ? 'SUCCESS' : 'FAILED'}
    Work Dir    : ${workflow.workDir}
    Results Dir : ${params.outdir}
    Duration    : ${workflow.duration}
    ========================================
    """.stripIndent()
}

workflow.onError {
    log.error """
    ========================================
    Pipeline execution stopped with error
    ========================================
    Error Message: ${workflow.errorMessage}
    ========================================
    """.stripIndent()
}
