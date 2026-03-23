# BLAST Baseline for CAFA - Nextflow Workflow

A Nextflow pipeline for generating BLAST-based Gene Ontology (GO) term predictions for proteins. This workflow implements a sequence similarity-based baseline method for the CAFA 5 (Critical Assessment of Functional Annotation 5) challenge.

## Overview

This pipeline transfers functional annotations from a reference database of experimentally annotated proteins to query proteins (testsuperset) using BLASTP. For each query protein, BLASTP finds similar sequences in the reference database, and GO annotations from the best matches are transferred as predictions.

## Requirements

### Software

- **Nextflow** ≥22.10.0 ([Installation](https://www.nextflow.io/docs/latest/getstarted.html))
- **NCBI BLAST+** v2.15.0+ ([Download](https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/))
- **MATLAB** R2020b or later (or Octave 5.2+ as alternative)

## Installation

Install dependencies on your system. The easiest approach is using Conda:

```bash
conda create -n blast-baseline -c bioconda nextflow blast matlab
conda activate blast-baseline
```

Or install individually on Linux:
```bash
sudo apt-get install ncbi-blast+
curl -s https://get.nextflow.io | bash && chmod +x nextflow && mv nextflow ~/bin/
```

## Quick Start

Place your input files in the workflow directory:

- `testsuperset.fasta` - Query protein sequences (required)
- `final_blast_db_seqs.fasta` - Reference protein database (required)  
- `annotation.tab` - GO annotations for reference proteins (required)
- `go-basic.obo` - Gene Ontology structure file (required)

Then run:

```bash
nextflow run main.nf -profile local
```

## Input Files

**testsuperset.fasta** - FASTA format query sequences
```
>protein_id_1
MIVLQRWVPVVQVLNQMPQQQQQQ...
>protein_id_2
MVQQQAVLNQMPQQQQQQQ...
```

**final_blast_db_seqs.fasta** - FASTA format reference sequences
```
>ref_protein_1
MIVLQRWVPVVQVLNQMPQQQQQQ...
>ref_protein_2
MVQQQAVLNQMPQQQQQQQ...
```

**annotation.tab** - Tab-separated file: protein_id    GO_term
```
ref_protein_1	GO:0008150
ref_protein_1	GO:0005575
ref_protein_2	GO:0006810
```

**go-basic.obo** - Download from: http://purl.obolibrary.org/obo/go/go-basic.obo

## Output

Results are saved in `results/` directory:

```
results/
├── predictions/
│   ├── blast_baseline_BPO.tsv    # Biological Process predictions
│   ├── blast_baseline_MFO.tsv    # Molecular Function predictions
│   └── blast_baseline_CCO.tsv    # Cellular Component predictions
└── blast_combined.out             # Combined BLASTP results
```

Each prediction file contains: `query_id`    `GO_term`    `score`

Example output:
```
protein_1	GO:0005575	0.98
protein_1	GO:0008150	0.85
protein_2	GO:0006810	0.72
```

## How It Works

The workflow consists of 4 steps:

1. **Prepare Database** - Index the reference protein database for BLASTP
2. **BLASTP Search** - Find similar sequences in reference database for each query
3. **Combine Results** - Merge BLASTP results from all searches
4. **Predict GO Terms** - Transfer GO annotations from best-matching reference proteins

For each query protein, the pipeline finds all BLASTP matches with E-value ≤ 10.0. For each GO term annotated on any reference protein match, a confidence score is calculated as the sequence similarity of the best match annotated with that term.

## Customization

To modify the pipeline behavior, edit `nextflow.config`:

```groovy
params {
    query_fasta = 'testsuperset.fasta'
    reference_fasta = 'final_blast_db_seqs.fasta'
    annotation_file = 'annotation.tab'
    go_obo = 'go-basic.obo'
    output_dir = 'results'
    
    num_splits = 10              // Number of parallel BLASTP jobs
    blastp_evalue = 10.0        // E-value threshold
    blastp_num_threads = 8      // Threads per job
}
```

## Troubleshooting

**MATLAB not available?**  
Use Octave instead (requires code adjustment in `modules/generate_predictions.nf`)

**Out of memory?**  
- Increase `num_splits` to process queries in smaller batches
- Reduce `blastp_num_threads`

**Clear cache issues:**  
```bash
rm -rf .nextflow/
nextflow clean -f
```

## License

MIT License - See LICENSE file for details

## References

- [NCBI BLAST Documentation](https://blast.ncbi.nlm.nih.gov/doc/)
- [Nextflow Documentation](https://www.nextflow.io/docs/)
- [Gene Ontology](http://geneontology.org/)
- [CAFA Challenge](http://www.biofunctionprediction.org/)

