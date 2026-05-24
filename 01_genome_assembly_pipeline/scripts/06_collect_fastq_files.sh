#!/usr/bin/env bash

set -eu
IFS=$'\n\t'

source ../config/config.sh

mkdir -p "$ALL_FASTQ_DIR"

echo
echo "=============================================="
echo "Collecting FASTQ files from rescued directories"
echo "=============================================="

find "$RESCUED_OUT" \
    -type f \
    -name "*.fastq" \
    -exec mv {} "$ALL_FASTQ_DIR"/ \;

echo
echo "[DONE] FASTQ files collected"
echo "Destination: $ALL_FASTQ_DIR"
