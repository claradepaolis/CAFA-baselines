import h5py
from sklearn.metrics.pairwise import euclidean_distances
from tqdm import tqdm
import time
from scipy.spatial import distance
import pandas as pd
from joblib import Parallel, delayed
import numpy as np
import warnings

warnings.simplefilter(action='ignore', category=FutureWarning)

print(time.ctime())
query_embeddings = h5py.File('embeddings/evalset_embeddings.h5')
X = []
test_ids = []
Y = []
db_ids = []

db_embeddings = h5py.File('embeddings/blast_db_embeddings.h5')
for db in tqdm(db_embeddings.keys()):
    # print(db, db_embeddings[db][:])
    db_ids.append(db)
    Y.append(db_embeddings[db][:])
    time.sleep(0.1)

df = pd.DataFrame()
super_df = [] 
for i in tqdm(range(0, len(query_embeddings.keys()))):
    X = query_embeddings[list(query_embeddings.keys())[i]][:]
    test_ids = list(query_embeddings.keys())[i]
    d = pd.DataFrame(None, columns=["Query ID", "DB ID", "e-val", "Length", "Similarity", "N-ident"])

    sim_matrix = euclidean_distances(X.reshape(1, -1), Y)
    d = pd.concat([d, pd.DataFrame(list(zip(np.repeat(test_ids, len(db_ids)), db_ids, np.repeat(0, len(db_ids)),
                                            np.repeat(0, len(db_ids)), np.transpose(sim_matrix[0]),
                                            np.repeat(0, len(db_ids)))),
                                   columns=["Query ID", "DB ID", "e-val", "Length", "Similarity", "N-ident"])])

    super_df.append(d.nsmallest(1000, 'Similarity'))
    time.sleep(0.1)

super_df = pd.concat(super_df, axis=0)
super_df.to_csv("evalset_embedding_distances_denorm_1000.tsv", sep="\t")

print(time.ctime())
