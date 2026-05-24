#!/usr/bin/env bash

set -uo pipefail
IFS=$'\n\t'

source ../config/config.sh

mkdir -p "$TRIM_DIR" "$DEHOST_DIR" "$KRKN_DIR" "$LOG_DIR"

ERROR_LOG="${LOG_DIR}/pipeline_errors.log"
> "$ERROR_LOG"

#############################################
# INDEX HOST IF NEEDED
#############################################

if [[ ! -f "${HOST_REF}.bwt" ]]; then
    echo "[INFO] Indexing host genome..."
    bwa-mem2 index "$HOST_REF"
else
    echo "[INFO] Host genome already indexed"
fi

#############################################
# SAMPLE LOOP
#############################################

for R1 in "$INPUT_DIR"/*_R1.fastq.gz; do
    [[ -f "$R1" ]] || continue

    R2="${R1/_R1/_R2}"

    if [[ ! -f "$R2" ]]; then
        echo "[WARN] Missing R2 for $R1" | tee -a "$ERROR_LOG"
        continue
    fi

    SAMPLE=$(basename "$R1" | sed 's/_R1.*//')

    echo
    echo "=============================================="
    echo "[INFO] Processing sample: $SAMPLE"
    echo "=============================================="

    set +e

    #############################################
    # STEP 1: TRIMMING
    #############################################

    TRIM_R1="$TRIM_DIR/${SAMPLE}_R1.trimmed.fastq.gz"
    TRIM_R2="$TRIM_DIR/${SAMPLE}_R2.trimmed.fastq.gz"

    FASTP_HTML="$TRIM_DIR/${SAMPLE}.fastp.html"
    FASTP_JSON="$TRIM_DIR/${SAMPLE}.fastp.json"

    if [[ ! -f "$TRIM_R1" || ! -f "$TRIM_R2" ]]; then
        echo "[STEP] Trimming"

        fastp \
            --in1 "$R1" \
            --in2 "$R2" \
            --out1 "$TRIM_R1" \
            --out2 "$TRIM_R2" \
            --detect_adapter_for_pe \
            --cut_front \
            --cut_tail \
            --cut_window_size 4 \
            --cut_mean_quality 20 \
            --length_required 50 \
            --thread "$THREADS" \
            --html "$FASTP_HTML" \
            --json "$FASTP_JSON"

        if [[ $? -ne 0 ]]; then
            echo "[ERROR] fastp failed for $SAMPLE" | tee -a "$ERROR_LOG"
            set -e
            continue
        fi
    else
        echo "[SKIP] Trimming already completed"
    fi

    #############################################
    # STEP 2: DEHOSTING
    #############################################

    DH_R1="$DEHOST_DIR/${SAMPLE}_R1.nonhost.fastq.gz"
    DH_R2="$DEHOST_DIR/${SAMPLE}_R2.nonhost.fastq.gz"

    HOST_BAM="$DEHOST_DIR/${SAMPLE}_host.bam"
    NONHOST_BAM="$DEHOST_DIR/${SAMPLE}_nonhost.bam"

    if [[ ! -f "$DH_R1" || ! -f "$DH_R2" ]]; then
        echo "[STEP] Dehosting"

        bwa-mem2 mem \
            -t "$THREADS" \
            "$HOST_REF" \
            "$TRIM_R1" \
            "$TRIM_R2" \
            | samtools view -b -o "$HOST_BAM"

        if [[ $? -ne 0 ]]; then
            echo "[ERROR] bwa-mem2 failed for $SAMPLE" | tee -a "$ERROR_LOG"
            set -e
            continue
        fi

        samtools view -b -f 4 "$HOST_BAM" > "$NONHOST_BAM"

        samtools fastq \
            -1 "$DH_R1" \
            -2 "$DH_R2" \
            -0 /dev/null \
            -s /dev/null \
            -n \
            "$NONHOST_BAM"

        if [[ $? -ne 0 ]]; then
            echo "[ERROR] Dehosting failed for $SAMPLE" | tee -a "$ERROR_LOG"
            set -e
            continue
        fi
    else
        echo "[SKIP] Dehosting already completed"
    fi

    #############################################
    # STEP 3: KRAKEN2 CLASSIFICATION
    #############################################

    KRKN_REPORT="$KRKN_DIR/${SAMPLE}_report.txt"
    KRKN_OUT="$KRKN_DIR/${SAMPLE}_output.txt"

    if [[ ! -f "$KRKN_REPORT" || ! -f "$KRKN_OUT" ]]; then
        echo "[STEP] Kraken2 classification"

        kraken2 \
            --db "$KRAKEN_DB" \
            --threads "$THREADS" \
            --paired \
            --report "$KRKN_REPORT" \
            --output "$KRKN_OUT" \
            "$DH_R1" \
            "$DH_R2"

        if [[ $? -ne 0 ]]; then
            echo "[ERROR] Kraken2 failed for $SAMPLE" | tee -a "$ERROR_LOG"
            set -e
            continue
        fi
    else
        echo "[SKIP] Kraken2 already completed"
    fi

    set -e

    echo "[DONE] Completed sample: $SAMPLE"

done

echo
echo "Pipeline step completed"
echo "Errors logged at: $ERROR_LOG"
