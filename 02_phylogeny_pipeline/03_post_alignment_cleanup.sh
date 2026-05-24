#!/usr/bin/env bash

set -eu
IFS=$'\n\t'

source ../config/config.sh

cd "$WORK_DIR"

echo
echo "=============================================="
echo "STEP 3: Post-alignment cleanup"
echo "=============================================="

#############################################
# CHECK INPUT
#############################################

if [[ ! -f "$TRIMMED_FASTA" ]]; then
    echo "[ERROR] Trimmed alignment not found"
    exit 1
fi

#############################################
# REMOVE MAFFT REORIENTATION TAGS
#############################################

echo "[STEP] Removing MAFFT reorientation labels"

sed 's/_R_//g' "$TRIMMED_FASTA" > "$CLEAN_TRIMMED_FASTA"

#############################################
# REMOVE DUPLICATE ACCESSION IDS
#############################################

echo "[STEP] Removing duplicate accession identifiers"

awk '
/^>/ {
    split(substr($0,2), a, /[ \t]/)
    id=a[1]
    skip=seen[id]++
}
!skip
' "$CLEAN_TRIMMED_FASTA" > "$UNIQUE_NAMES_FASTA"

#############################################
# FINAL COUNT
#############################################

echo
echo "[INFO] Final sequence count"
grep "^>" "$UNIQUE_NAMES_FASTA" | wc -l

echo
echo "[DONE] Post-alignment cleanup completed"
echo "Final alignment: $UNIQUE_NAMES_FASTA"
