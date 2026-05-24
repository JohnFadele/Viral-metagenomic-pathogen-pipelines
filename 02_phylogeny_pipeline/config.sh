#!/usr/bin/env bash

#############################################
# GLOBAL CONFIGURATION
#############################################

THREADS=8

#############################################
# INPUT
#############################################

WORK_DIR="/path/to/phylogeny_project"

INPUT_FASTA="$WORK_DIR/input_sequences.fasta"

#############################################
# OUTPUT FILES
#############################################

DEDUP_FASTA="$WORK_DIR/sequences_deduplicated.fasta"
CLEAN_FASTA="$WORK_DIR/sequences_cleaned.fasta"

ORIENTED_FASTA="$WORK_DIR/sequences_oriented.fasta"
ALIGNED_FASTA="$WORK_DIR/sequences_aligned.fasta"

TRIMMED_FASTA="$WORK_DIR/sequences_trimmed.fasta"
TRIMMED_HTML="$WORK_DIR/sequences_trimmed_report.html"

CLEAN_TRIMMED_FASTA="$WORK_DIR/sequences_trimmed_clean.fasta"
UNIQUE_NAMES_FASTA="$WORK_DIR/sequences_names_unique.fasta"

IQTREE_DIR="$WORK_DIR/IQTREE_results"

#############################################
# TREE OUTPUT
#############################################

OUTGROUP_ID="NC_013804.1"

REROOTED_TREE="$IQTREE_DIR/tree_rerooted.contree"
MIDPOINT_TREE="$IQTREE_DIR/tree_midpoint.contree"
