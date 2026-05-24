Description fof this pipeline

This pipeline provides an end-to-end workflow for the recovery of Orf virus genomes and selected gene targets from metagenomic sequencing datasets. It integrates input file validation, read quality control, host read depletion, and taxonomic classification to identify pathogen-associated reads from complex sequencing data.

To improve species-level genome recovery, the workflow includes a targeted rescue strategy that re-evaluates reads classified only at the Parapoxvirus genus level, addressing limitations of k-mer based taxonomic classification in conserved genomic regions. High confidence rescued reads are merged with directly classified Orf virus reads to generate refined datasets for downstream analysis.

The pipeline supports reference-based assembly of the complete Orf virus genome and selected genes of epidemiological relevance, followed by assembly quality assessment through resolved base quantification and summary reporting. Additional utilities are included for output organisation and downstream data management.

Overall, this workflow provides a reproducible framework for pathogen-focused metagenomic genome reconstruction, comparative genomic analysis, and downstream molecular epidemiology.
