# Naive baseline
The Naive baseline predicts the same scores for all proteins, the prediction file is large (about 29GB for the full CAFA 5 evaluation) evaluation. Instead of packaging this file here, we provide the list of proteins on which we evaluate (in file `cafa5_targets_toeval.tsv`) and the list of GO term frequencies (in file `cafa5_naive_frequencies.tsv`). These files can be used to generate the full Naive prediction file with the script `naive.py`:  

```
python3 naive.py --freq cafa5_naive_frequencies.tsv --target cafa5_targets_toeval.tsv --out naive.tsv
```

The script requires python 3.5+ and the packages [pandas](https://pypi.org/project/pandas/) and [tqdm](https://pypi.org/project/tqdm/).
