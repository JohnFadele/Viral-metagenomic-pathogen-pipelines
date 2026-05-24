#!/usr/bin/env bash

#############################################
# GLOBAL CONFIGURATION
#############################################

THREADS=16

#############################################
# DIRECTORIES
#############################################

WORK_DIR="/path/to/variant_analysis"

INPUT_FASTQ_DIR="/path/to/clean_fastq"

BAM_DIR="$WORK_DIR/BAM"
VARIANT_DIR="$WORK_DIR/variant_calling"

RAW_VCF_DIR="$VARIANT_DIR/raw_vcf"
FILTERED_VCF_DIR="$VARIANT_DIR/filtered_vcf"
ANNOTATED_VCF_DIR="$VARIANT_DIR/annotated_vcf"
ANNOTATED_CSV_DIR="$VARIANT_DIR/annotated_csv"
IMPACT_CSV_DIR="$VARIANT_DIR/impact_csv"
SUMMARY_DIR="$VARIANT_DIR/combined_summary"

#############################################
# REFERENCES
#############################################

REF_GENOME="/path/to/references/orf.fasta"
GFF_FILE="/path/to/annotations/ORFV_annotation.gff"

#############################################
# SNP-EFF
#############################################

SNPEFF_DIR="/path/to/snpEff/latest_snpEff"
SNPEFF_JAR="$SNPEFF_DIR/snpEff.jar"

SNPEFF_DB_NAME="ORFV"
SNPEFF_GENOME_LABEL="ORF virus"

#############################################
# JAVA
#############################################

JAVA_MEM="4g"

#############################################
# SELECTED SAMPLES
#############################################

SAMPLES=(
"AD_YS_KR_GT_023"
"AIAMAGOAT001_S48"
"AIAMA_PIG003_RS_S51"
"SENONOWISUGOT002_OS_S76"
"SENONOWISUGOT006_OS_S73"
)
