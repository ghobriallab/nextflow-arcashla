process ARCASHLA_GENOTYPE {
    tag "$sample_id"
    label 'process_medium'
    publishDir "${params.outdir}/${sample_id}/genotype", mode: params.publish_dir_mode

    input:
    tuple val(sample_id), path(fq1), path(fq2)

    output:
    tuple val(sample_id), path("${sample_id}.genotype.json"), emit: genotype
    tuple val(sample_id), path("${sample_id}.alignment.p"), emit: alignment, optional: true
    path "${sample_id}.genotype.log", emit: log
    path "versions.yml", emit: versions

    script:
    def genes = params.hla_genes ? "-g ${params.hla_genes}" : ''
    def verbose_flag = params.verbose ? '-v' : ''
    def min_count = params.min_count ? "--min_count ${params.min_count}" : ''
    def max_count = params.max_count ? "--max_count ${params.max_count}" : ''
    def min_likelihood = params.min_likelihood ? "--min_likelihood ${params.min_likelihood}" : ''
    def drop_iterations = params.drop_iterations ? "--drop_iterations ${params.drop_iterations}" : ''
    def drop_threshold = params.drop_threshold ? "--drop_threshold ${params.drop_threshold}" : ''
    def zygosity_threshold = params.zygosity_threshold ? "--zygosity_threshold ${params.zygosity_threshold}" : ''
    
    """
    # Create output directory
    mkdir -p output
    
    # Run arcasHLA genotype
    # Note: The container has arcasHLA installed at /opt/arcasHLA
    arcasHLA genotype \\
        ${fq1} \\
        ${fq2} \\
        ${genes} \\
        -o output \\
        -t ${params.threads} \\
        ${min_count} \\
        ${max_count} \\
        ${min_likelihood} \\
        ${drop_iterations} \\
        ${drop_threshold} \\
        ${zygosity_threshold} \\
        ${verbose_flag} \\
        2>&1 | tee ${sample_id}.genotype.log
    
    # Rename output files to include sample_id
    mv output/*.genotype.json ${sample_id}.genotype.json
    
    # Move alignment file if it exists
    if [ -f output/*.alignment.p ]; then
        mv output/*.alignment.p ${sample_id}.alignment.p
    fi
    
    # Create versions file
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        arcasHLA: \$(arcasHLA version 2>&1 || echo "unknown")
    END_VERSIONS
    """

    stub:
    """
    touch ${sample_id}.genotype.json
    touch ${sample_id}.alignment.p
    touch ${sample_id}.genotype.log
    touch versions.yml
    """
}
