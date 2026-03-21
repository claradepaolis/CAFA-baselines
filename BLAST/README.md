# BLAST Baseline for CAFA - Nextflow Workflow

A reproducible, scalable Nextflow pipeline for generating BLAST-based Gene Ontology (GO) function predictions for proteins. This workflow serves as a baseline method for the CAFA 5 (Critical Assessment of Functional Annotation 5) challenge.

## Overview

This pipeline implements a sequence similarity-based approach for transferring functional annotations from a reference database of experimentally annotated proteins to query proteins using BLASTP. The method is straightforward but effective, making it an excellent baseline for evaluating more complex prediction algorithms.

### Workflow Steps

1. **Prepare Reference Database** - Validate and index the reference protein database
2. **Split Query Sequences** - Divide queries into manageable chunks for parallel processing
3. **Run BLASTP** - Perform parallel sequence similarity searches
4. **Combine Results** - Merge BLAST results from all parallel runs
5. **Generate Predictions** - Transfer annotations based on similarity and generate GO predictions
6. **Output** - Format predictions for evaluation

## Requirements

### Software

- **Nextflow** ≥22.10.0 ([Installation](https://www.nextflow.io/docs/latest/getstarted.html))
- **NCBI BLAST+** v2.15.0+ ([Download](https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/))
- **MATLAB** R2020b or later (or Octave 5.2+ as alternative)
- **Perl** 5.0+ (for FASTA splitting)

### System Requirements

- **Minimum**: 8 CPU cores, 16 GB RAM
- **Recommended**: 36 CPU cores, 128 GB RAM
- **Disk space**: ~50 GB (depending on database size)

## Installation

### 1. Clone or Download Repository

```bash
git clone https://github.com/claradepaolis/CAFA-baselines.git
cd CAFA-baselines/blast-baseline-nextflow
```

### 2. Install Dependencies

**On macOS (with Homebrew):**
```bash
brew install nextflow ncbi-blast
```

**On Linux (Ubuntu/Debian):**
```bash
# Install Nextflow
curl -s https://get.nextflow.io | bash
chmod +x nextflow
mv nextflow ~/bin/

# Install BLAST
sudo apt-get install ncbi-blast+

# Install MATLAB or Octave
sudo apt-get install octave  # or install MATLAB separately
```

**Using Conda:**
```bash
conda create -n blast-baseline -c bioconda nextflow blast
conda activate blast-baseline
```

### 3. Download Input Data

The pipeline requires:
- **Reference protein sequences** (FASTA format)
- **GO annotations** for reference proteins (tab-delimited: protein_id ↦ GO_term)
- **Query protein sequences** (FASTA format)
- **GO ontology** (OBO format)

Example data download:
```bash
# Download from UniProt
wget https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz
gunzip uniprot_sprot.fasta.gz

# Download GO ontology
wget http://purl.obolibrary.org/obo/go/go-basic.obo

# Create annotation file (example format provided)
# Each line: <protein_id>\t<GO_term_id>
```

## Usage

### Basic Run

```bash
nextflow run main.nf \
    --query_fasta testsuperset.fasta \
    --reference_fasta final_blast_db_seqs.fasta \
    --annotation_file annotation.tab \
    --go_obo go-basic.obo \
    --output_dir results
```

### Advanced Options

```bash
nextflow run main.nf \
    --query_fasta testsuperset.fasta \
    --reference_fasta final_blast_db_seqs.fasta \
    --annotation_file annotation.tab \
    --go_obo go-basic.obo \
    --output_dir results \
    --num_splits 20 \                    # Split queries into 20 parts
    --blastp_evalue 1e-5 \              # More stringent E-value cutoff
    --blastp_num_threads 8 \            # Threads per BLASTP run
    --similarity_metric rscore \         # Use R-score instead of sequence identity
    -profile slurm                       # Use SLURM job scheduler
```

### Profiles

**Local execution (single machine):**
```bash
nextflow run main.nf -profile local
```

**SLURM cluster:**
```bash
nextflow run main.nf -profile slurm
```

**Docker containerization:**
```bash
nextflow run main.nf -profile docker
```

**Singularity containerization:**
```bash
nextflow run main.nf -profile singularity
```

## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `query_fasta` | `testsuperset.fasta` | Path to query protein sequences (FASTA) |
| `reference_fasta` | `final_blast_db_seqs.fasta` | Path to reference protein sequences (FASTA) |
| `annotation_file` | `annotation.tab` | Path to protein-GO term associations (TSV) |
| `go_obo` | `go-basic.obo` | Path to Gene Ontology structure (OBO) |
| `output_dir` | `results` | Output directory for all results |
| `ontologies` | `['BPO', 'MFO', 'CCO']` | Which GO ontologies to predict (Biological Process, Molecular Function, Cellular Component) |
| `num_splits` | `10` | Number of query sequence chunks for parallel processing |
| `blastp_evalue` | `10.0` | BLASTP E-value threshold (default is permissive) |
| `blastp_num_threads` | `8` | CPU threads per BLASTP process |
| `similarity_metric` | `sid` | Metric for annotation transfer: `sid` (sequence identity) or `rscore` (R-score) |

## Input File Formats

### Query FASTA
```fasta
>query_protein_1
MIVLQRWVPVVQVLNQMPQQQQQQ...
>query_protein_2
MVQQQAVLNQMPQQQQQQQ...
```

### Reference FASTA
```fasta
>ref_protein_1 UniProt:P12345
MIVLQRWVPVVQVLNQMPQQQQQQ...
>ref_protein_2 UniProt:Q98765
MVQQQAVLNQMPQQQQQQQ...
```

### Annotation File (TSV)
```
ref_protein_1	GO:0008150
ref_protein_1	GO:0005575
ref_protein_1	GO:0003674
ref_protein_2	GO:0006810
ref_protein_2	GO:0016020
```

### GO OBO File
Download from: http://purl.obolibrary.org/obo/go/go-basic.obo

## Output

Results are organized in `${output_dir}/`:

```
results/
├── database/
│   ├── final_blast_db_seqs.fasta
│   └── annotation.processed
├── blast_results/
│   ├── blastp_testsuperset.part-01.out
│   ├── blastp_testsuperset.part-02.out
│   └── blast_combined.out
├── predictions/
│   ├── blast_baseline_BPO.tsv
│   ├── blast_baseline_MFO.tsv
│   └── blast_baseline_CCO.tsv
├── execution_report.html
├── execution_timeline.html
└── pipeline_dag.html
```

### Prediction Output Format (TSV)

```
query_protein_1	GO:0005575	0.98
query_protein_1	GO:0008150	0.85
query_protein_1	GO:0006810	0.72
```

**Columns:**
- **Column 1**: Query protein ID
- **Column 2**: Predicted GO term ID
- **Column 3**: Confidence score (0.0-1.0, normalized from sequence identity)

## Algorithm Details

### Prediction Scoring

For each GO term $t$ and query protein $q$:

$$\text{score}(q, t) = \max_{h \in \text{hits}(q)} \text{similarity}(q, h) \times \text{annotated}(h, t)$$

Where:
- $\text{hits}(q)$ = all BLASTP hits for query $q$
- $\text{similarity}(q, h)$ = sequence identity or R-score
- $\text{annotated}(h, t)$ = 1 if hit $h$ is annotated with term $t$, 0 otherwise

### Similarity Metrics

**Sequence Identity (default):**
$$\text{sid} = \frac{\text{pident}}{100}$$

**R-score:**
$$\text{rscore} = -\log(E\text{-value}) + 2$$

## Running Tests

```bash
# Run with test data
nextflow run main.nf \
    --query_fasta test_data/query_test.fasta \
    --reference_fasta test_data/reference_test.fasta \
    --annotation_file test_data/annotation_test.tab \
    --go_obo test_data/go-basic.obo \
    -profile local
```

## Troubleshooting

### MATLAB License Issues
If MATLAB is not available, use Octave (compatible with most MATLAB code):
```bash
# Edit modules/generate_predictions.nf to use:
octave --eval "..."
```

### Out of Memory
- Reduce `blastp_num_threads`
- Increase `num_splits` to process queries in smaller batches
- Increase available system memory

### BLASTP Database Issues
```bash
# Pre-build BLAST database (optional, Nextflow does this automatically)
makeblastdb -in final_blast_db_seqs.fasta -dbtype prot
```

### Nextflow Cache Issues
```bash
# Clear Nextflow cache if encountering issues
rm -rf .nextflow/
nextflow clean -f
```

## Citation

If you use this workflow in your research, please cite:

```bibtex
@article{jiang2016structure,
  title={Structure-based prediction of function},
  author={Jiang, Yuxiang and Oron, Tom R and Clark, Wyatt C and ...},
  journal={Bioinformatics},
  year={2016}
}
```

## License

MIT License - See LICENSE file for details

## Contributing

Contributions are welcome! Please submit issues or pull requests to:
https://github.com/claradepaolis/CAFA-baselines

## Authors

- Parnal Joshi (primary developer)
- Contributors to CAFA baseline methods

## Support

For issues, questions, or suggestions:
- Open an issue on GitHub
- Contact: parnal@iastate.edu

## References

- [NCBI BLAST Documentation](https://blast.ncbi.nlm.nih.gov/doc/)
- [Nextflow Documentation](https://www.nextflow.io/docs/)
- [Gene Ontology](http://geneontology.org/)
- [CAFA Challenge](http://www.biofunctionprediction.org/)
