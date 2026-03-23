/*
 * Module: Run BLASTP
 * 
 * Executes BLASTP searches for query sequences against the reference database.
 * Processes query sequences in parallel for efficiency.
 */

process RUN_BLASTP {
    label 'high_cpu'
    publishDir "${params.output_dir}/blast_results", mode: 'copy', pattern: '*.out'
    tag "${query_fasta.baseName}"

    input:
    path query_fasta
    path blast_db
    val blastp_evalue
    val blastp_num_threads

    output:
    path "*.out", emit: blast_results
    path "*.log", emit: logs

    script:
    """
    # Get the basename for the output file
    query_name=\$(basename "${query_fasta}" .fasta)
    
    # Run BLASTP with specified parameters
    blastp \\
        -query "${query_fasta}" \\
        -db "${blast_db}" \\
        -evalue ${blastp_evalue} \\
        -num_threads ${task.cpus} \\
        -max_target_seqs 500 \\
        -outfmt "6 qseqid sseqid evalue length pident nident" \\
        -out "\${query_name}_blastp.out" \\
        2> "\${query_name}_blastp.log"
    
    # Log summary
    echo "BLASTP Results Summary:" >> "\${query_name}_blastp.log"
    echo "Query file: \${query_name}.fasta" >> "\${query_name}_blastp.log"
    echo "Number of hits: \$(wc -l < "\${query_name}_blastp.out")" >> "\${query_name}_blastp.log"
    echo "Completion time: \$(date)" >> "\${query_name}_blastp.log"
    """
}
