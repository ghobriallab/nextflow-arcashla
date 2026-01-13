process ARCASHLA_EXTRACT {
    tag "$sample_id"
    label 'process_medium'
    publishDir "${params.outdir}/${sample_id}/extract", mode: params.publish_dir_mode

    input:
    tuple val(sample_id), path(bam)

    output:
    tuple val(sample_id), path("${sample_id}.extracted.1.fq.gz"), path("${sample_id}.extracted.2.fq.gz"), emit: fastqs
    path "${sample_id}.extract.log", emit: log
    path "versions.yml", emit: versions

    script:
    def unmapped_flag = params.include_unmapped ? '--unmapped' : ''
    def verbose_flag = params.verbose ? '-v' : ''
    
    """
    # Create output directory
    mkdir -p output
    
    # Run arcasHLA extract
    # Note: The container has arcasHLA installed at /opt/arcasHLA
    arcasHLA extract \\
        ${bam} \\
        -o output \\
        -t ${params.threads} \\
        ${unmapped_flag} \\
        ${verbose_flag} \\
        2>&1 | tee ${sample_id}.extract.log
    
    # Rename output files to include sample_id
    mv output/*.extracted.1.fq.gz ${sample_id}.extracted.1.fq.gz
    mv output/*.extracted.2.fq.gz ${sample_id}.extracted.2.fq.gz
    
    # Create versions file
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        arcasHLA: \$(python /opt/arcasHLA/arcasHLA version 2>&1 || echo "unknown")
        python: \$(python --version 2>&1 | sed 's/Python //')
    END_VERSIONS
    """

    stub:
    """
    touch ${sample_id}.extracted.1.fq.gz
    touch ${sample_id}.extracted.2.fq.gz
    touch ${sample_id}.extract.log
    touch versions.yml
    """
}
