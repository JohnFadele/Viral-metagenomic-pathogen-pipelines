#!/usr/bin/env bash

set -eu
IFS=$'\n\t'

source ../config/config.sh

cd "$WORK_DIR"

echo
echo "=============================================="
echo "STEP 0: Sequence preparation"
echo "=============================================="

#############################################
# REMOVE DUPLICATE FULL HEADERS
#############################################

echo "[STEP] Removing duplicate sequence headers"

awk '
/^>/ {
    if (seen[$0]++) skip=1;
    else skip=0;
}
!skip
' "$INPUT_FASTA" > "$DEDUP_FASTA"

#############################################
# CHECK SEQUENCE COUNTS
#############################################

echo
echo "[INFO] Sequence counts"
echo "Original:"
grep "^>" "$INPUT_FASTA" | wc -l

echo "Deduplicated:"
grep "^>" "$DEDUP_FASTA" | wc -l

#############################################
# NORMALISE WINDOWS LINE ENDINGS
#############################################

echo
echo "[STEP] Converting Windows line endings if present"

dos2unix "$DEDUP_FASTA" 2>/dev/null || true

#############################################
# CLEAN INVALID CHARACTERS
#############################################

echo "[STEP] Replacing invalid nucleotide characters"

sed '/^>/! s/[^ACGTURYKMSWBDHVNacgturykmswbdhvn]/N/g' \
    "$DEDUP_FASTA" \
    > "$CLEAN_FASTA"

echo
echo "[DONE] Sequence preparation completed"
echo "Output: $CLEAN_FASTA"
