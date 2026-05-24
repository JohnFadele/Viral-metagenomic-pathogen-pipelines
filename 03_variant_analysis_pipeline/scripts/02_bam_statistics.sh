#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

source ../config/config.sh

mkdir -p "$SUMMARY_DIR"

OUT="${SUMMARY_DIR}/bam_statistics_summary.csv"

echo "Sample,Mapped_Reads,Average_Depth,Depth_SD,CV" > "$OUT"

shopt -s nullglob
BAMS=("$BAM_DIR"/*.sorted.bam)

echo
echo "=============================================="
echo "STEP 2: BAM quality statistics"
echo "=============================================="

echo "[INFO] Found ${#BAMS[@]} BAM files"

if [[ ${#BAMS[@]} -eq 0 ]]; then
    echo "[ERROR] No BAM files found"
    exit 1
fi

#############################################
# LOOP
#############################################

for BAM in "${BAMS[@]}"; do

    echo
    echo "----------------------------------------------"
    echo "[INFO] Processing $(basename "$BAM")"
    echo "----------------------------------------------"

    SAMPLE=$(basename "$BAM" .sorted.bam)

    #############################################
    # VALIDATE BAM
    #############################################

    if ! samtools quickcheck -v "$BAM"; then
        echo "[WARN] Invalid BAM — skipping"
        continue
    fi

    #############################################
    # MAPPED READS
    #############################################

    MAPPED=$(samtools view -c -F 4 "$BAM" 2>/dev/null || echo 0)

    #############################################
    # DEPTH STATISTICS
    #############################################

    STATS=$(samtools depth -a "$BAM" 2>/dev/null | awk '
    {
        x = $3
        sum += x
        sumsq += x*x
        count++
    }
    END {
        if (count > 0) {
            mean = sum / count
            variance = (sumsq / count) - (mean * mean)
            sd = (variance > 0) ? sqrt(variance) : 0
            cv = (mean > 0) ? sd / mean : 0

            printf "%.2f,%.2f,%.3f", mean, sd, cv
        } else {
            print "0,0,0"
        }
    }')

    MEAN=$(echo "$STATS" | cut -d',' -f1)
    SD=$(echo "$STATS" | cut -d',' -f2)
    CV=$(echo "$STATS" | cut -d',' -f3)

    #############################################
    # WRITE OUTPUT
    #############################################

    echo "${SAMPLE},${MAPPED},${MEAN},${SD},${CV}" >> "$OUT"

    echo "[DONE] $SAMPLE processed"

done

echo
echo "=============================================="
echo "BAM statistics completed"
echo "Output: $OUT"
echo "=============================================="
