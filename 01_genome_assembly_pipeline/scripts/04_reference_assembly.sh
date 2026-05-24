#!/usr/bin/env bash

set -uo pipefail
IFS=$'\n\t'

source ../config/config.sh

mkdir -p "$ASSEMBLY_DIR"

#############################################
# FUNCTION: INDEX REFERENCE IF NEEDED
#############################################

index_ref () {
    local REF=$1

    if [[ ! -f "${REF}.bwt" ]]; then
        echo "[INFO] Indexing BWA reference: $REF"
        bwa index "$REF" || {
            echo "[ERROR] Failed to index $REF"
            exit 1
        }
    fi

    if [[ ! -f "${REF}.fai" ]]; then
        echo "[INFO] Indexing FASTA reference: $REF"
        samtools faidx "$REF" || {
            echo "[ERROR] Failed to create FASTA index for $REF"
            exit 1
        }
    fi
}

#############################################
# INDEX REFERENCES
#############################################

index_ref "$ORF_REF"
index_ref "$B2L_REF"
index_ref "$F1L_REF"
index_ref "$EEV109_REF"
index_ref "$VEGF_REF"
index_ref "$VIL10_REF"

echo
echo "=============================================="
echo "Starting reference-based assembly pipeline"
echo "=============================================="

#############################################
# SAMPLE LOOP
#############################################

for R1 in "$FINAL_OUT"/*_R1.fastq; do

    [[ -f "$R1" ]] || continue

    SAMPLE_ID=$(basename "$R1" _R1.fastq)
    R2="$FINAL_OUT/${SAMPLE_ID}_R2.fastq"

    if [[ ! -f "$R2" ]]; then
        echo "[WARN] Missing R2 for $SAMPLE_ID"
        continue
    fi

    SAMPLE_OUT="$ASSEMBLY_DIR/$SAMPLE_ID"
    mkdir -p "$SAMPLE_OUT"

    echo
    echo "----------------------------------------------"
    echo "[INFO] Processing sample: $SAMPLE_ID"
    echo "----------------------------------------------"

    #############################################
    # FUNCTION: ASSEMBLE TARGET
    #############################################

    assemble_target () {
        local TARGET_NAME=$1
        local REF=$2

        echo "[STEP] Assembling $TARGET_NAME"

        BAM="$SAMPLE_OUT/${SAMPLE_ID}_${TARGET_NAME}_sorted.bam"

        bwa mem -t "$THREADS" "$REF" "$R1" "$R2" \
            | samtools view -b -F 4 - \
            | samtools sort -o "$BAM"

        if [[ $? -ne 0 ]]; then
            echo "[WARN] Assembly failed for ${TARGET_NAME}"
            return
        fi

        samtools index "$BAM"

        samtools mpileup -aa -A -d 0 -Q 0 "$BAM" \
            | ivar consensus \
                -p "$SAMPLE_OUT/${SAMPLE_ID}_${TARGET_NAME}" \
                -t 0.5 \
                -m 10

        if [[ $? -ne 0 ]]; then
            echo "[WARN] Consensus generation failed for ${TARGET_NAME}"
        fi
    }

    #############################################
    # TARGETS
    #############################################

    assemble_target "ORF" "$ORF_REF"
    assemble_target "B2L" "$B2L_REF"
    assemble_target "F1L" "$F1L_REF"
    assemble_target "EEV109" "$EEV109_REF"
    assemble_target "VEGF" "$VEGF_REF"
    assemble_target "VIL10" "$VIL10_REF"

    echo "[DONE] Sample completed: $SAMPLE_ID"

done

echo
echo "=============================================="
echo "Reference assembly pipeline completed"
echo "Results: $ASSEMBLY_DIR"
echo "=============================================="
