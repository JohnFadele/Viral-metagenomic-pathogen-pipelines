#!/usr/bin/env bash

set -eu
IFS=$'\n\t'

source ../config/config.sh

cd "$WORK_DIR"

echo
echo "=============================================="
echo "STEP 2: Alignment trimming"
echo "=============================================="

#############################################
# CHECK INPUT
#############################################

if [[ ! -f "$ALIGNED_FASTA" ]]; then
    echo "[ERROR] Aligned FASTA not found"
    echo "$ALIGNED_FASTA"
    exit 1
fi

#############################################
# RUN TRIMAL
#############################################

echo "[STEP] Removing poorly aligned and gappy regions"

trimal \
    -in "$ALIGNED_FASTA" \
    -automated1 \
    -out "$TRIMMED_FASTA" \
    -htmlout "$TRIMMED_HTML"

if [[ $? -ne 0 ]]; then
    echo "[ERROR] TrimAl failed"
    exit 1
fi

echo
echo "[DONE] Alignment trimming completed"
echo "Trimmed FASTA: $TRIMMED_FASTA"
echo "HTML report:   $TRIMMED_HTML"
