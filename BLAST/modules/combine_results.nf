/*
 * Module: Combine and Format BLAST Results
 * 
 * Merges BLAST results from parallel runs and fixes UniProt ID formatting
 * (removes sp| and tr| prefixes for clean protein identifiers).
 */

process COMBINE_BLAST_RESULTS {
    label 'low_memory'
    publishDir "${params.output_dir}/blast_results", mode: 'copy'

    input:
    path blast_files

    output:
    path "blast_combined.out", emit: combined_blast
    path "blast_summary.txt", emit: summary

    script:
    """
    # Step 3a: Combine all BLAST results from parallel chunks
    cat ${blast_files.join(' ')} > blast_combined_unsorted.out
    
    # Step 3b: Remove duplicate lines while preserving order per query
    awk '!seen[\$0]++' blast_combined_unsorted.out | sort -k1,1 -k5,5nr > blast_combined.out
    
    # Step 3c: Format UniProt IDs - remove sp| and tr| prefixes
    sed -ri 's/sp\\|//g' blast_combined.out
    sed -ri 's/tr\\|//g' blast_combined.out
    sed -ri 's/\\|[^\\t]*\\t/\\t/g' blast_combined.out
    
    # Generate summary statistics
    total_hits=\$(wc -l < blast_combined.out)
    unique_queries=\$(cut -f1 blast_combined.out | sort -u | wc -l)
    
    cat > blast_summary.txt << EOF
BLAST Results Summary
====================
Files combined: ${blast_files.size()}
Total hits: \$total_hits
Unique queries: \$unique_queries
Date: \$(date)
EOF

    echo "BLAST results formatted and combined:"
    cat blast_summary.txt
    
    # Cleanup
    rm -f blast_combined_unsorted.out
    """
}
