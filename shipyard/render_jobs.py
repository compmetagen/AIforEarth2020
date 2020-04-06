import os.path
import sys

import pandas as pd
from jinja2 import Environment, FileSystemLoader


input_fn = sys.argv[1]

input_df = pd.read_csv(input_fn, delimiter='\t', index_col=False, header=0,
    dtype=str)

template_dir = "config/genome-recovery"
jobs_dir = "jobs/genome-recovery"

env = Environment(loader = FileSystemLoader(template_dir))
template = env.get_template("jobs.yaml")
for run in input_df["Run"][0:50]:
    jobs_fn = os.path.join(jobs_dir, "{}.yaml".format(run))
    with open(jobs_fn, 'w') as jobs_handle:
        jobs_handle.write(template.render(sra_accession=run))
