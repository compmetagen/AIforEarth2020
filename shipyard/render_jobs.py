import os.path
import sys
import subprocess

import pandas as pd
from jinja2 import Environment, FileSystemLoader


input_fn = sys.argv[1]

input_df = pd.read_csv(input_fn, delimiter='\t', index_col=False, header=0,
    dtype=str)

template_dir = "config/genome-recovery"
jobs_dir = "jobs/genome-recovery"


proc = subprocess.run(
    "az storage fs directory list -f data --path genome_recovery " \
    "--account-name aiforearth2020data --recursive false --output tsv" \
    "> accession_list.tsv", shell=True
)

if proc.returncode != 0:
    print("az error")
    exit(1)

processed_df = pd.read_csv("accession_list.tsv", delimiter='\t', index_col=False,
    header=None, dtype=str)

processed = [os.path.basename(elem) for elem in processed_df[5].values]

env = Environment(loader = FileSystemLoader(template_dir))
template = env.get_template("jobs.yaml")
for i, row in input_df.iterrows():
    run, platform = row["Run"], row["Platform"]
    if (platform == "ILLUMINA") and (run not in processed):
        jobs_fn = os.path.join(jobs_dir, "{}.yaml".format(run))
        with open(jobs_fn, 'w') as jobs_handle:
            jobs_handle.write(template.render(sra_accession=run))
