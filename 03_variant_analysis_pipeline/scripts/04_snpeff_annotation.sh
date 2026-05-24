#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

source ../config/config.sh

mkdir -p "$ANNOTATED_VCF_DIR"

echo
echo "=============================================="
echo "STEP 4: SnpEff functional annotation"
echo "=============================================="

#############################################
# CHECKS
#############################################

command -v java >/dev/null 2>&1 || {
    echo "[ERROR] Java not found"
    exit 1
}

[[ -d "$FILTERED_VCF_DIR" ]] || {
    echo "[ERROR] Filtered VCF directory not found"
    exit 1
}

[[ -f "$SNPEFF_JAR" ]] || {
    echo "[ERROR] snpEff.jar not found"
    exit 1
}

#############################################
# COLLECT VCF FILES
#############################################

shopt -s nullglob
VCF_FILES=("$FILTERED_VCF_DIR"/*.vcf.gz)

echo "[INFO] Found ${#VCF_FILES[@]} filtered VCF files"

if [[ ${#VCF_FILES[@]} -eq 0 ]]; then
    echo "[ERROR] No filtered VCF files found"
    exit 1
fi

#############################################
# LOOP
#############################################

for VCF in "${VCF_FILES[@]}"; do

    SAMPLE=$(basename "$VCF" .filtered.vcf.gz)

    echo
    echo "----------------------------------------------"
    echo "[INFO] Annotating sample: $SAMPLE"
    echo "----------------------------------------------"

    OUT_VCF="$ANNOTATED_VCF_DIR/${SAMPLE}.annotated.vcf"

    if ! {

        java -Xmx"$JAVA_MEM" -jar "$SNPEFF_JAR" \
            "$SNPEFF_DB_NAME" \
            "$VCF" \
            > "$OUT_VCF"

    }; then

        echo "[ERROR] Annotation failed for $SAMPLE"
        continue

    fi

    if [[ -s "$OUT_VCF" ]]; then
        echo "[DONE] Annotation completed"
    else
        echo "[WARN] Empty output generated"
    fi

done

echo
echo "=============================================="
echo "SnpEff annotation completed"
echo "Output: $ANNOTATED_VCF_DIR"
echo "=============================================="
