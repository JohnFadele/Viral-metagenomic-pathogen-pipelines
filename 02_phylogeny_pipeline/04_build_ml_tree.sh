#!/usr/bin/env bash

set -eu
IFS=$'\n\t'

source ../config/config.sh

mkdir -p "$IQTREE_DIR"

cd "$IQTREE_DIR"

echo
echo "=============================================="
echo "STEP 4: Maximum likelihood phylogenetic inference"
echo "=============================================="

#############################################
# CHECK INPUT
#############################################

if [[ ! -f "$UNIQUE_NAMES_FASTA" ]]; then
    echo "[ERROR] Final cleaned alignment not found"
    echo "$UNIQUE_NAMES_FASTA"
    exit 1
fi

#############################################
# START LOG
#############################################

echo "IQ-TREE started at $(date)" | tee iqtree_start.log

#############################################
# RUN IQ-TREE
#############################################

echo
echo "[STEP] Running IQ-TREE with model selection and branch support"

iqtree \
    -s "$UNIQUE_NAMES_FASTA" \
    -m MFP \
    -bb 1000 \
    -alrt 1000 \
    -nt AUTO \
    2>&1 | tee iqtree_run.log

#############################################
# CHECK OUTPUT
#############################################

if [[ $? -ne 0 ]]; then
    echo "[ERROR] IQ-TREE failed"
    exit 1
fi

echo
echo "IQ-TREE finished at $(date)" | tee -a iqtree_run.log

echo
echo "[DONE] Maximum likelihood phylogeny completed"
echo "Results directory: $IQTREE_DIR"
