Description of the Variant calling, annotation, and mutation profiling workflows

This pipeline provides a reproducible workflow for variant discovery, functional mutation annotation, and comparative mutation profiling from pathogen sequencing datasets. It supports analysis from aligned sequencing reads through biologically interpretable mutation summaries suitable for downstream comparative genomics and molecular epidemiology.

The workflow includes generation of reference-aligned BAM files, quality assessment of alignment depth and coverage consistency, variant calling using defined filtering thresholds, and functional annotation through a custom SnpEff database. Downstream filtering isolates coding-region variants and amino acid altering mutations, followed by automated generation of merged summary datasets for comparative mutation analysis across multiple samples.

Overall, this workflow provides a structured framework for mutation detection, annotation, impact filtering, and generation of analysis-ready mutation datasets.
