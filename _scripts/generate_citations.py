import re
from doi2bib import crossref
import requests

citations = {
  "comparisonsinglecell_saelens2019": "10.1038/s41587-019-0071-9",
  "benchmarkingatlaslevel_luecken2020": "10.1038/s41592-021-01336-8",
  "benchmarkingsinglecell_mereu2020": "10.1038/s41587-020-0469-4",
  "benchmarkingalgorithmsgene_pratapa2019": "10.1101/642926",
  "benchmarkingintegrationmethods_yan2022": "10.1093/bioinformatics/btac805",
  "spotlessreproduciblepipeline_sangaram2023": "10.1101/2023.03.22.533802"
}

bibs = []

for name, doi in citations.items():
  print(f"Processing {name}", flush=True)
  if doi.startswith('@'):
    # text is already a bibtex
    bib = doi
  else:
    try:
      bib = crossref.get_bib_from_doi(doi)[1]
    except requests.exceptions.RequestException as e:
      print(f"Could not find doi '{doi}'", flush=True)
      bib = ""
  bib = re.sub(r"(@[a-zA-Z]+\{)[A-Za-z0-9_-]+", f"\\1{name}", bib)
  bibs.append(bib)

with open("library.bib", 'w') as f:
    f.write('\n'.join(bibs))