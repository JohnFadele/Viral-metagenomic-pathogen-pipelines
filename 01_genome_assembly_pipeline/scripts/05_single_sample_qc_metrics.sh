#!/usr/bin/env bash

set -eu
IFS=$'\n\t'

source ../config/config.sh

#############################################
# INPUT
#############################################

ASSEMBLY_SAMPLE_DIR="/path/to/single/sample/assembly_directory"

CONS_EEV109="${ASSEMBLY_SAMPLE_DIR}/$(basename "$ASSEMBLY_SAMPLE_DIR")_EEV109.fa"
CONS_VEGF="${ASSEMBLY_SAMPLE_DIR}/$(basename "$ASSEMBLY_SAMPLE_DIR")_VEGF.fa"
CONS_VIL10="${ASSEMBLY_SAMPLE_DIR}/$(basename "$ASSEMBLY_SAMPLE_DIR")_VIL10.fa"

#############################################
# FUNCTION
#############################################

calc_resolved () {
    local CONS=$1
    local REF=$2
    local GENE=$3

    if [[ ! -f "$CONS" ]]; then
        echo "[WARN] Missing consensus file for $GENE"
        return
    fi

    CONS_ACTG=$(grep -v "^>" "$CONS" | tr -d '\n' | grep -o "[ACGT]" | wc -l)
    REF_LEN=$(grep -v "^>" "$REF" | tr -d '\n' | wc -c)

    PERCENT=$(awk "BEGIN {printf \"%.2f\", ($CONS_ACTG/$REF_LEN)*100}")

    echo "=============================================="
    echo "$GENE resolved bases (A/C/T/G): $CONS_ACTG"
    echo "$GENE reference length (bp):     $REF_LEN"
    echo "$GENE percent resolved:          $PERCENT %"
}

#############################################
# RUN
#############################################

calc_resolved "$CONS_EEV109" "$EEV109_REF" "EEV109"
calc_resolved "$CONS_VEGF" "$VEGF_REF" "VEGF"
calc_resolved "$CONS_VIL10" "$VIL10_REF" "VIL10"
