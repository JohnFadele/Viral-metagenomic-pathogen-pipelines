Phylogenetic inference workflows

Description of what this workflow does

This pipeline provides a reproducible workflow for maximum likelihood phylogenetic analysis of curated nucleotide sequence datasets, from sequence preparation through tree inference and rooting. It is designed to support robust evolutionary analysis by ensuring that only clean, unique, and properly formatted sequences are carried forward into phylogenetic reconstruction.

The workflow begins with sequence preparation, including removal of duplicate records, correction of formatting inconsistencies, and replacement of invalid nucleotide characters that may interfere with downstream alignment and tree building. Multiple sequence alignment is then performed using MAFFT, with sequence reorientation included to ensure consistent directional alignment across all sequences.

To improve phylogenetic reliability, the aligned dataset undergoes trimming to remove poorly aligned and highly gapped regions that may introduce noise into tree inference. Additional post-alignment cleanup steps are included to standardise sequence identifiers and remove residual duplicate accession entries where necessary.

Phylogenetic reconstruction is performed using the maximum likelihood framework implemented in IQ-TREE, with automated substitution model selection and statistical branch support estimation. The resulting phylogeny can then be re-rooted using either a defined biological outgroup or midpoint rooting, depending on the analytical objective.

Overall, this workflow provides a structured and reproducible framework for phylogenetic inference, comparative evolutionary analysis, and downstream interpretation of pathogen sequence relationships.
