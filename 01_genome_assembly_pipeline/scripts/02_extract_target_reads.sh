#!/usr/bin/env bash

set -uo pipefail
IFS=$'\n\t'

source ../config/config.sh

mkdir -p "$ORF_DIR" "$PARAPOX_DIR"

echo
echo "=============================================="
echo "Starting pathogen-specific read extraction"
echo "=============================================="

for R1 in "$DEHOST_DIR"/*_R1.nonhost.fastq.gz; do
    [[ -f "$R1" ]] || continue

    SAMPLE=$(basename "$R1" _R1.nonhost.fastq.gz)
    R2="$DEHOST_DIR/${SAMPLE}_R2.nonhost.fastq.gz"
    KRAKEN_OUT="$KRKN_DIR/${SAMPLE}_output.txt"

    echo
    echo "----------------------------------------------"
    echo "[INFO] Processing sample: $SAMPLE"
    echo "----------------------------------------------"

    #############################################
    # INPUT CHECK
    #############################################

    if [[ ! -f "$R2" || ! -f "$KRAKEN_OUT" ]]; then
        echo "[WARN] Missing required input files for $SAMPLE"
        echo "Skipping sample"
        continue
    fi

    #############################################
    # ORF VIRUS READ EXTRACTION
    #############################################

    echo "[STEP] Extracting ORF virus reads (taxid 10258)"

    if ! python3 "$KRAKEN_TOOLS" \
        -k "$KRAKEN_OUT" \
        -s "$R1" \
        -s2 "$R2" \
        -t 10258 \
        --fastq-output \
        -o "$ORF_DIR/${SAMPLE}_Orf_R1.fastq" \
        -o2 "$ORF_DIR/${SAMPLE}_Orf_R2.fastq"
    then
        echo "[WARN] ORF extraction failed for $SAMPLE"
        continue
    fi

    #############################################
    # PARAPOX GENUS EXTRACTION
    #############################################

    echo "[STEP] Extracting Parapox genus reads (taxid 10257)"

    if ! python3 "$KRAKEN_TOOLS" \
        -k "$KRAKEN_OUT" \
        -s "$R1" \
        -s2 "$R2" \
        -t 10257 \
        --fastq-output \
        -o "$PARAPOX_DIR/${SAMPLE}_Parapox_Genus_R1.fastq" \
        -o2 "$PARAPOX_DIR/${SAMPLE}_Parapox_Genus_R2.fastq"
    then
        echo "[WARN] Parapox extraction failed for $SAMPLE"
        continue
    fi

    echo "[DONE] Extraction completed for $SAMPLE"

done

echo
echo "=============================================="
echo "Read extraction step completed"
echo "=============================================="
