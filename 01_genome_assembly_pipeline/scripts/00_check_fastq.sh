#!/usr/bin/env bash

set -uo pipefail
IFS=$'\n\t'

source ../config/config.sh

FASTQ_LIST="${FILECHECK_DIR}/valid_fastq_files.txt"
NON_FASTQ_LIST="${FILECHECK_DIR}/non_fastq_files.txt"
ERROR_LIST="${FILECHECK_DIR}/error_files.txt"

mkdir -p "$FILECHECK_DIR"

> "$FASTQ_LIST"
> "$NON_FASTQ_LIST"
> "$ERROR_LIST"

echo "[INFO] Scanning directory: $DATA_DIR"
echo

for f in "$DATA_DIR"/*; do
    [[ -f "$f" ]] || continue

    echo "[CHECK] Inspecting: $(basename "$f")"

    if file -b "$f" | grep -q "gzip compressed"; then
        HEADER=$(gzip -cd "$f" 2>/dev/null | sed -n '1,4p')
    else
        HEADER=$(sed -n '1,4p' "$f" 2>/dev/null)
    fi

    if [[ -z "$HEADER" ]]; then
        echo "  [ERROR] Could not read FASTQ header"
        echo "$f" >> "$ERROR_LIST"
        continue
    fi

    LINE1=$(echo "$HEADER" | sed -n '1p')
    LINE3=$(echo "$HEADER" | sed -n '3p')

    if [[ "$LINE1" == @* && "$LINE3" == "+"* ]]; then
        echo "  [OK] FASTQ detected"
        echo "$f" >> "$FASTQ_LIST"
    else
        echo "  [SKIP] Not FASTQ"
        echo "$f" >> "$NON_FASTQ_LIST"
    fi
done

echo
echo "[DONE] File scan complete"
echo "[RESULT] Valid FASTQ files:  $FASTQ_LIST"
echo "[RESULT] Non-FASTQ files:    $NON_FASTQ_LIST"
echo "[RESULT] Error files:        $ERROR_LIST"
