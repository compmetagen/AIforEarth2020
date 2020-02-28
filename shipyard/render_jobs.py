import os.path

from jinja2 import Environment, FileSystemLoader


# Single-end HMP mock: https://www.ncbi.nlm.nih.gov/sra?linkname=bioproject_sra_all&from_uid=48475
sra_accessions = ["SRR11126255", "SRR11126257"]

template_dir = "config/sraassembly"
jobs_dir = "jobs/sraassembly"

env = Environment(loader = FileSystemLoader(template_dir))
template = env.get_template("jobs.yaml")
for sra_accession in sra_accessions:
    jobs_fn = os.path.join(jobs_dir, "{}.yaml".format(sra_accession))
    with open(jobs_fn, 'w') as jobs_handle:
        jobs_handle.write(template.render(sra_accession=sra_accession))
