#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

source ../config/config.sh

mkdir -p "$ANNOTATED_CSV_DIR"

echo
echo "=============================================="
echo "STEP 5: Extract coding-region variants"
echo "=============================================="

#############################################
# CHECK INPUT
#############################################

[[ -d "$ANNOTATED_VCF_DIR" ]] || {
    echo "[ERROR] Annotated VCF directory not found"
    exit 1
}

shopt -s nullglob
VCF_FILES=("$ANNOTATED_VCF_DIR"/*.annotated.vcf)

echo "[INFO] Found ${#VCF_FILES[@]} annotated VCF files"

if [[ ${#VCF_FILES[@]} -eq 0 ]]; then
    echo "[ERROR] No annotated VCF files found"
    exit 1
fi

#############################################
# LOOP
#############################################

for VCF in "${VCF_FILES[@]}"; do

    SAMPLE=$(basename "$VCF" .annotated.vcf)
    OUT_FILE="$ANNOTATED_CSV_DIR/${SAMPLE}.coding_variants.csv"

    echo
    echo "----------------------------------------------"
    echo "[INFO] Processing sample: $SAMPLE"
    echo "----------------------------------------------"

    #############################################
    # HEADER
    #############################################

    echo "Gene,Effect,Impact,Feature,HGVS_c,HGVS_p" > "$OUT_FILE"

    #############################################
    # EXTRACTION
    #############################################

    awk '
    BEGIN { FS="\t"; OFS="," }
    /^#/ { next }

    {
        split($8, info, "ANN=")
        n = split(info[2], ann_list, ",")

        for (i=1; i<=n; i++) {

            split(ann_list[i], a, "|")

            effect = a[2]
            impact = a[3]

            if (effect ~ /missense_variant|synonymous_variant|stop_gained|stop_lost|start_lost|frameshift_variant|inframe/) {

                gene    = a[4]
                feature = a[6]
                hgvs_c  = a[10]
                hgvs_p  = a[11]

                print gene, effect, impact, feature, hgvs_c, hgvs_p
            }
        }
    }' "$VCF" >> "$OUT_FILE"

    #############################################
    # CHECK OUTPUT
    #############################################

    if [[ -s "$OUT_FILE" ]]; then
        echo "[DONE] Coding variants extracted"
    else
        echo "[WARN] No coding variants found"
    fi

done

echo
echo "=============================================="
echo "Coding variant extraction completed"
echo "Output: $ANNOTATED_CSV_DIR"
echo "=============================================="
