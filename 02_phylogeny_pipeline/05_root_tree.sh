#!/usr/bin/env bash

set -eu
IFS=$'\n\t'

source ../config/config.sh

cd "$IQTREE_DIR"

echo
echo "=============================================="
echo "STEP 5: Outgroup rooting"
echo "=============================================="

#############################################
# FIND TREE FILE
#############################################

TREE_FILE=$(find . -maxdepth 1 -name "*.contree" | head -n 1)

if [[ -z "$TREE_FILE" ]]; then
    echo "[ERROR] No IQ-TREE consensus tree (.contree) found"
    exit 1
fi

echo "[INFO] Tree detected: $TREE_FILE"

#############################################
# OUTGROUP ROOTING
#############################################

echo
echo "[STEP] Rooting tree using outgroup: $OUTGROUP_ID"

nw_reroot "$TREE_FILE" "$OUTGROUP_ID" > "$REROOTED_TREE"

if [[ $? -ne 0 ]]; then
    echo "[ERROR] Tree rooting failed"
    exit 1
fi

echo
echo "[DONE] Rooted tree generated"
echo "Output: $REROOTED_TREE"

echo
echo "=============================================="
echo "Tree rooting completed"
echo "=============================================="
