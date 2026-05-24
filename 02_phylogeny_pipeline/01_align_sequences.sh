#!/usr/bin/env bash

set -eu
IFS=$'\n\t'

source ../config/config.sh

cd "$WORK_DIR"

echo
echo "=============================================="
echo "STEP 1: Sequence reorientation and alignment"
echo "=============================================="

#############################################
# REORIENT SEQUENCES
#############################################

echo "[STEP] Reorienting sequences with MAFFT"

mafft \
    --adjustdirection \
    --thread "$THREADS" \
    "$CLEAN_FASTA" \
    > "$ORIENTED_FASTA"

echo "[DONE] Reorientation completed"

#############################################
# MULTIPLE SEQUENCE ALIGNMENT
#############################################

echo
echo "[STEP] Performing multiple sequence alignment"

mafft \
    --auto \
    --thread "$THREADS" \
    "$ORIENTED_FASTA" \
    > "$ALIGNED_FASTA"

echo
echo "[DONE] Alignment completed"
echo "Oriented output: $ORIENTED_FASTA"
echo "Aligned output:  $ALIGNED_FASTA"
