#!/usr/bin/env nextflow

/*
 * BLAST Baseline Workflow for CAFA
 * 
 * This workflow generates Gene Ontology (GO) function predictions for query proteins
 * using sequence similarity-based annotation transfer from a reference database of
 * experimentally annotated proteins.
 * 
 * Authors: Parnal Joshi
 * License: MIT
 */

nextflow.enable.dsl = 2

// Import modules
include { PREPARE_REFERENCE_DB } from './modules/prepare_db.nf'
include { RUN_BLASTP } from './modules/run_blastp.nf'
include { COMBINE_BLAST_RESULTS } from './modules/combine_results.nf'
include { GENERATE_PREDICTIONS } from './modules/generate_predictions.nf'

// Hardcoded input files
def query_fasta = "testsuperset.fasta"
def reference_fasta = "final_blast_db_seqs.fasta"
def annotation_file = "annotation.tab"
def go_obo = "go-basic.obo"
def output_dir = "results"
def ontologies = ["BPO", "MFO", "CCO"]
def num_splits = 10
def blastp_evalue = 10.0
def blastp_num_threads = 8

log.info """
    =====================================================
    BLAST Baseline Workflow for CAFA
    =====================================================
    Starting workflow...
    =====================================================
    """.stripIndent()

workflow {
    // Step 1: Build BLAST database from reference sequences
    PREPARE_REFERENCE_DB(
        file(reference_fasta),
        file(annotation_file)
    )

    // Step 2: Run BLASTP searches
    Channel.fromPath(query_fasta)
        | splitFasta(by: num_splits, file: true)
        | set { query_splits }
    
    RUN_BLASTP(
        query_splits,
        PREPARE_REFERENCE_DB.out.db,
        blastp_evalue,
        blastp_num_threads
    )

    // Step 3: Gather and format BLAST results
    COMBINE_BLAST_RESULTS(
        RUN_BLASTP.out.blast_results.collect()
    )

    // Step 4: Generate GO predictions using MATLAB
    ontologies_ch = Channel.from(ontologies)
    
    GENERATE_PREDICTIONS(
        COMBINE_BLAST_RESULTS.out.combined_blast,
        file(annotation_file),
        file(go_obo),
        ontologies_ch
    )
}

workflow.onComplete {
    log.info """
        =====================================================
        Workflow completed successfully!
        Results are in: ${output_dir}
        =====================================================
        """.stripIndent()
}

workflow.onError {
    log.info """
        =====================================================
        An error occurred during workflow execution!
        Error message: ${workflow.errorMessage}
        =====================================================
        """.stripIndent()
}
