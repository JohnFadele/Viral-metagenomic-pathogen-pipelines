#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

source ../config/config.sh

mkdir -p "$RAW_VCF_DIR" "$FILTERED_VCF_DIR"

echo
echo "=============================================="
echo "STEP 3: Variant calling"
echo "=============================================="

#############################################
# TOOL CHECKS
#############################################

command -v bcftools >/dev/null 2>&1 || {
    echo "[ERROR] bcftools not found"
    exit 1
}

command -v samtools >/dev/null 2>&1 || {
    echo "[ERROR] samtools not found"
    exit 1
}

[[ -f "$REF_GENOME" ]] || {
    echo "[ERROR] Reference genome missing"
    exit 1
}

#############################################
# BAM COLLECTION
#############################################

shopt -s nullglob
BAM_FILES=("$BAM_DIR"/*.sorted.bam)

echo "[INFO] Found ${#BAM_FILES[@]} BAM files"

if [[ ${#BAM_FILES[@]} -eq 0 ]]; then
    echo "[ERROR] No BAM files found"
    exit 1
fi

#############################################
# LOOP
#############################################

for BAM in "${BAM_FILES[@]}"; do

    SAMPLE=$(basename "$BAM" .sorted.bam)

    echo
    echo "----------------------------------------------"
    echo "[INFO] Processing sample: $SAMPLE"
    echo "----------------------------------------------"

    RAW_VCF="$RAW_VCF_DIR/${SAMPLE}.vcf.gz"
    FILTERED_VCF="$FILTERED_VCF_DIR/${SAMPLE}.filtered.vcf.gz"

    #############################################
    # SAFE SAMPLE BLOCK
    #############################################

    if ! {

        #########################################
        # BAM INDEX
        #########################################

        if [[ ! -f "${BAM}.bai" ]]; then
            samtools index "$BAM"
        fi

        #########################################
        # VARIANT CALLING
        #########################################

        bcftools mpileup \
            -Ou \
            -f "$REF_GENOME" \
            -q 20 \
            -Q 20 \
            --max-depth 20000 \
            "$BAM" \
        | bcftools call \
            -mv \
            -Oz \
            -o "$RAW_VCF"

        bcftools index "$RAW_VCF"

        #########################################
        # FILTERING
        #########################################

        bcftools filter \
            -i 'DP>=100 && ((DP4[2]+DP4[3]) / (DP4[0]+DP4[1]+DP4[2]+DP4[3])) >= 0.60' \
            "$RAW_VCF" \
            -Oz \
            -o "$FILTERED_VCF"

        bcftools index "$FILTERED_VCF"

    }; then

        echo "[ERROR] Variant calling failed for $SAMPLE"
        continue

    fi

    echo "[DONE] Variant calling completed for $SAMPLE"

done

echo
echo "=============================================="
echo "Variant calling completed"
echo "Results: $VARIANT_DIR"
echo "=============================================="
