import argparse
import pandas as pd
from tqdm import tqdm

def naive_from_freqs(freqs, protIDs):
    """
      Generate Naive prediction file where every protein in protIDs is assigned a score for
      each term equal to the frequency of that term in freqs
    """
    predictions = []
    for prot in tqdm(protIDs):
        p_df = freqs.copy()
        p_df.insert(0, 'EntryID', prot)
        predictions.append(p_df)

    return pd.concat(predictions)


if __name__ == "__main__":
    parser=argparse.ArgumentParser(
        description='''Generate Naive Prediction file from term frequencies and list of targets. ''')
    
    parser.add_argument('--freq', type=str, default='.', help='Frequencies file, tsv with first column termID and second column frequency. No headers or index column.')
    parser.add_argument('--target', type=str, default='.', help='Target file, One protein ID per row. No headers or index column.')
    parser.add_argument('--out', type=str, default='naive_predictions.tsv', help='file destination to save output')
    


    args=parser.parse_args()

    freq_file = args.freq
    target_file =  args.target

    freqs = pd.read_csv(freq_file, header=None, sep='\t')
    targets = pd.read_csv(target_file, header=None)[0].to_list()
    
    prediction_df = naive_from_freqs(freqs, targets)

    print(f'Saving to file {args.out}') 
    prediction_df.to_csv(args.out, index=False, header=False, sep='\t')
    print('File saved')
