#!/usr/bin/env bash

set -uo pipefail
IFS=$'\n\t'

source ../config/config.sh

mkdir -p "$BAM_DIR"

#############################################
# INDEX REFERENCE
#############################################

if [[ ! -f "${REF_GENOME}.bwt" ]]; then
    echo "[STEP] Indexing BWA reference"
    bwa index "$REF_GENOME"
fi

if [[ ! -f "${REF_GENOME}.fai" ]]; then
    echo "[STEP] Indexing FASTA reference"
    samtools faidx "$REF_GENOME"
fi

echo
echo "=============================================="
echo "STEP 1: Generate BAM files"
echo "=============================================="

#############################################
# SAMPLE LOOP
#############################################

for SAMPLE in "${SAMPLES[@]}"; do

    echo
    echo "----------------------------------------------"
    echo "[INFO] Processing sample: $SAMPLE"
    echo "----------------------------------------------"

    R1="$INPUT_FASTQ_DIR/${SAMPLE}_ORF_combined_dedup_R1.fastq"
    R2="$INPUT_FASTQ_DIR/${SAMPLE}_ORF_combined_dedup_R2.fastq"

    if [[ ! -f "$R1" || ! -f "$R2" ]]; then
        echo "[WARN] Missing FASTQ files"
        continue
    fi

    BAM_OUT="$BAM_DIR/${SAMPLE}.sorted.bam"

    bwa mem \
        -t "$THREADS" \
        "$REF_GENOME" \
        "$R1" \
        "$R2" \
        | samtools view -b -F 4 - \
        | samtools sort -@ "$THREADS" -o "$BAM_OUT"

    if [[ $? -ne 0 ]]; then
        echo "[ERROR] BAM generation failed"
        continue
    fi

    samtools index "$BAM_OUT"

    echo "[DONE] BAM created: $BAM_OUT"

done

echo
echo "=============================================="
echo "BAM generation completed"
echo "=============================================="
