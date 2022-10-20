from scipy.optimize import nnls
import numpy as np
import pandas as pd
import re

#
source_eem_data = pd.read_csv("source_eems.csv")
source_labels = source_eem_data.columns.values
source_labels = np.array([re.sub("[.].*", "", x) for x in source_labels])

#
unknown_eem_data = pd.read_csv("unknown_eems.csv")
unknown_labels = unknown_eem_data.columns.values

#
sources = np.unique(source_labels)
K = sources.size
N = source_labels.size
G = np.zeros([K, N])
for k in range(K):
  for n in range(N):
    if source_labels[n] == sources[k]:
      G[k, n] = 1

#
source_contributions = np.zeros([unknown_labels.size, K])
for j in range(unknown_labels.size):
  #
  b = unknown_eem_data.values[:, j]
  A = source_eem_data.values

  #
  na_b = np.isnan(b)
  na_A = np.isnan(A).any(axis=1)

  #
  b = b[~na_b * ~na_A]
  A = A[~na_b * ~na_A, :]
  
  #
  coefs = nnls(A, b)[0]
  source_contributions[j, :] = np.matmul(G, coefs)

#
pd.DataFrame(data=source_contributions, index=unknown_labels, columns=sources).to_csv("source_contributions.csv")
