#!/usr/bin/env bash

#############################################
# GLOBAL CONFIGURATION
#############################################

# Threads
THREADS=16

#############################################
# INPUT DATA
#############################################

DATA_DIR="/path/to/raw_input_files"
INPUT_DIR="/path/to/paired_fastq"

#############################################
# REFERENCES
#############################################

HOST_REF="/path/to/host_genome/Cattle.fa"

ORF_REF="/path/to/references/orf.fasta"
B2L_REF="/path/to/references/orf_B2L.fasta"
F1L_REF="/path/to/references/orf_F1L.fasta"

EEV109_REF="/path/to/references/orf_EEV109.fasta"
VEGF_REF="/path/to/references/orf_VEGF.fasta"
VIL10_REF="/path/to/references/orf_VIL10.fasta"

#############################################
# TOOLS
#############################################

KRAKEN_DB="/path/to/kraken/database"
KRAKEN_TOOLS="/path/to/KrakenTools/extract_kraken_reads.py"

#############################################
# OUTPUT BASE
#############################################

OUT_BASE="/path/to/output"

#############################################
# STEP OUTPUTS
#############################################

FILECHECK_DIR="$OUT_BASE/file_check"

TRIM_DIR="$OUT_BASE/trimmed"
DEHOST_DIR="$OUT_BASE/dehosted"
KRKN_DIR="$OUT_BASE/taxonomy"
LOG_DIR="$OUT_BASE/logs"

ORF_DIR="$OUT_BASE/orf_reads"
PARAPOX_DIR="$OUT_BASE/parapox_reads"

RESCUED_OUT="$OUT_BASE/rescued_orf"
FINAL_OUT="$OUT_BASE/orf_dedup"

ASSEMBLY_DIR="$OUT_BASE/orf_assembly"

ALL_FASTQ_DIR="$OUT_BASE/all_fastq"
ALL_FASTA_DIR="$OUT_BASE/all_fasta"

SUMMARY_DIR="$OUT_BASE/summaries"
