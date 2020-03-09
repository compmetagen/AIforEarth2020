# python3 checkm_mimag.py BINS_DIR CHECKM_QA OUT_DIR

import sys
import os
import shutil
import glob

import pandas as pd


BINS_DIR = sys.argv[1]
CHECKM_QA = sys.argv[2]
OUT_DIR = sys.argv[3]


def set_mimag_cat(row):
    mimag_cat = None
    if (row["Completeness"] > 90) & (row["Contamination"] < 5):
        mimag_cat = 'HQ'
    elif (row["Completeness"] < 50) | (row["Contamination"] >= 10):
        mimag_cat = 'LQ'
    else:
        mimag_cat = 'MQ'
    return mimag_cat


for d in ['HQ', 'MQ', 'LQ']:
    try:
        os.makedirs(os.path.join(OUT_DIR, d))
    except FileExistsError:
        pass

checkm_qa = pd.read_table(CHECKM_QA, sep='\s{2,}', skiprows=[0, 2],
    skipfooter=1, header=0, engine='python', index_col=0) 

checkm_qa['MIMAG cat'] = checkm_qa.apply(set_mimag_cat, axis=1)

for bin_fn in glob.glob(os.path.join(BINS_DIR, "*")):
    bin_id, _ = os.path.splitext(os.path.split(bin_fn)[-1])
    try:
        mimag_cat = checkm_qa.loc[bin_id, 'MIMAG cat']
    except KeyError:
        pass
    else:
        if mimag_cat is not None:
            shutil.copy(bin_fn, os.path.join(OUT_DIR, mimag_cat))
