import sys
import csv
import re
import os

import pandas as pd
from Bio import Entrez


input_fn = sys.argv[1]
output_fn = sys.argv[2]


Entrez.email = "davide.albanese@fmach.it"

input_df = pd.read_csv(input_fn, delimiter='\t', index_col=False, header=0,
    dtype=str)
output_df = pd.DataFrame()

biosample_count, run_count = 0, 0
for _, input_row in input_df.iterrows():
    biosample = input_row["NCBI Biosample Accession"]
    if biosample != '':
        ehandle = Entrez.esearch(db="sra", term=biosample)
        erecord = Entrez.read(ehandle)
        ehandle.close()

        ehandle = Entrez.efetch(db="sra", rettype="runinfo",
            id=erecord['IdList'], retmode="text")
        runs_df = pd.read_csv(ehandle, index_col=False, header=0, dtype=str)
        ehandle.close()

        biosample_count += 1
        print(biosample_count)

        for _, runs_row in runs_df.iterrows():
            output_row = input_row.append(runs_row)
            output_df = output_df.append(output_row, ignore_index=True,
                sort=False)
            output_df = output_df.reindex(output_row.index, axis=1)

            run_count += 1

output_df.to_csv(output_fn, sep='\t', index=False)
print("Biosamples: {:d}, Runs: {:d}".format(biosample_count, run_count))
