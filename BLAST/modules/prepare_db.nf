/*
 * Module: Prepare Reference Database
 * 
 * Validates the reference FASTA file and creates BLAST database indices
 * for efficient sequence searching.
 */

process PREPARE_REFERENCE_DB {
    label 'low_memory'
    publishDir "${params.output_dir}/database", mode: 'copy', pattern: '*.p*'

    input:
    path ref_fasta
    path annotation_file

    output:
    path "${ref_fasta.baseName}.fasta*", emit: db
    path "annotation.processed", emit: annotations
    path "database_info.txt", emit: info

    script:
    """
    # Validate FASTA file format
    if ! grep -q "^>" "${ref_fasta}"; then
        echo "Error: Invalid FASTA file - no sequences found" >&2
        exit 1
    fi

    # Count sequences
    seq_count=\$(grep -c "^>" "${ref_fasta}")
    echo "Processing reference database with \$seq_count sequences..."

    # Copy FASTA file with consistent naming
    cp "${ref_fasta}" "${ref_fasta.baseName}.fasta"

    # Create BLAST database
    makeblastdb \\
        -in "${ref_fasta.baseName}.fasta" \\
        -dbtype prot \\
        -title "CAFA Reference Database" \\
        -out "${ref_fasta.baseName}.fasta"

    # Validate annotation file
    if [ ! -f "${annotation_file}" ]; then
        echo "Error: Annotation file not found" >&2
        exit 1
    fi

    # Count annotation entries
    annot_count=\$(wc -l < "${annotation_file}")

    # Process annotation file (validate and copy)
    cp "${annotation_file}" annotation.processed

    # Write database info
    cat > database_info.txt << EOF
Reference Database Information
==============================
Date created: \$(date)
Reference FASTA: ${ref_fasta.baseName}.fasta
Total sequences: \$seq_count
Annotation file: annotation.processed
Total annotations: \$annot_count
Database type: BLAST protein database
EOF

    echo "Database preparation complete!"
    """
}
