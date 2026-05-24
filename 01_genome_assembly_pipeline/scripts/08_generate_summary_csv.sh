#!/usr/bin/env bash

set -eu
IFS=$'\n\t'

source ../config/config.sh

mkdir -p "$SUMMARY_DIR"

OUTFILE="$SUMMARY_DIR/resolved_summary_wide.csv"

#############################################
# HEADER
#############################################

echo "S/N,Sample ID,ORF Resolved Bases,ORF Reference Length (bp),ORF % Resolved,B2L Resolved Bases,B2L Reference Length (bp),B2L % Resolved,F1L Resolved Bases,F1L Reference Length (bp),F1L % Resolved,EEV109 Resolved Bases,EEV109 Reference Length (bp),EEV109 % Resolved,VEGF Resolved Bases,VEGF Reference Length (bp),VEGF % Resolved,VIL10 Resolved Bases,VIL10 Reference Length (bp),VIL10 % Resolved" > "$OUTFILE"

#############################################
# FUNCTION
#############################################

calc_resolved () {
    local CONS=$1
    local REF=$2

    if [[ ! -f "$CONS" ]]; then
        echo "0,0,0.00"
        return
    fi

    local RESOLVED
    local REFLEN
    local PERC

    RESOLVED=$(grep -v "^>" "$CONS" | tr -d '\n' | grep -o "[ACGT]" | wc -l)
    REFLEN=$(grep -v "^>" "$REF" | tr -d '\n' | wc -c)

    PERC=$(awk "BEGIN {printf \"%.2f\", ($RESOLVED/$REFLEN)*100}")

    echo "$RESOLVED,$REFLEN,$PERC"
}

#############################################
# LOOP
#############################################

SN=1

for CONS in "$ALL_FASTA_DIR"/*_ORF.fa; do

    [[ -f "$CONS" ]] || continue

    SAMPLE=$(basename "$CONS" _ORF.fa)

    CONS_ORF="$ALL_FASTA_DIR/${SAMPLE}_ORF.fa"
    CONS_B2L="$ALL_FASTA_DIR/${SAMPLE}_B2L.fa"
    CONS_F1L="$ALL_FASTA_DIR/${SAMPLE}_F1L.fa"
    CONS_EEV109="$ALL_FASTA_DIR/${SAMPLE}_EEV109.fa"
    CONS_VEGF="$ALL_FASTA_DIR/${SAMPLE}_VEGF.fa"
    CONS_VIL10="$ALL_FASTA_DIR/${SAMPLE}_VIL10.fa"

    ORF_STATS=$(calc_resolved "$CONS_ORF" "$ORF_REF")
    B2L_STATS=$(calc_resolved "$CONS_B2L" "$B2L_REF")
    F1L_STATS=$(calc_resolved "$CONS_F1L" "$F1L_REF")
    EEV109_STATS=$(calc_resolved "$CONS_EEV109" "$EEV109_REF")
    VEGF_STATS=$(calc_resolved "$CONS_VEGF" "$VEGF_REF")
    VIL10_STATS=$(calc_resolved "$CONS_VIL10" "$VIL10_REF")

    echo "$SN,$SAMPLE,$ORF_STATS,$B2L_STATS,$F1L_STATS,$EEV109_STATS,$VEGF_STATS,$VIL10_STATS" >> "$OUTFILE"

    SN=$((SN+1))

done

echo
echo "=============================================="
echo "[DONE] Summary CSV generated"
echo "Output: $OUTFILE"
echo "=============================================="
