import pandas as pd

df = pd.read_csv("evalset_embedding_distances_denorm_1000.tsv", sep="\t")
x_max = df["Similarity"].max()
def norm_sim(x):
    x = (x_max - x)/x_max
    sim_per = x*100
    return round(sim_per, 2)

df["Similarity"] = df["Similarity"].map(norm_sim)
df.to_csv("evalset_similarity_norm_1000.tsv", sep="\t", index=False)
