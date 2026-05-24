#!/usr/bin/env bash

set -eu
IFS=$'\n\t'

source ../config/config.sh

mkdir -p "$ALL_FASTA_DIR"

echo
echo "=============================================="
echo "Collecting consensus FASTA files"
echo "=============================================="

find "$ASSEMBLY_DIR" \
    -type f \
    -name "*.fa" \
    -exec mv {} "$ALL_FASTA_DIR"/ \;

echo
echo "[DONE] FASTA files collected"
echo "Destination: $ALL_FASTA_DIR"
