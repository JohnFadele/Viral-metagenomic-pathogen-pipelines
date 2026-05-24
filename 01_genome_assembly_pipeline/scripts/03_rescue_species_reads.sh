#!/usr/bin/env bash

set -u
IFS=$'\n\t'

source ../config/config.sh

mkdir -p "$RESCUED_OUT" "$FINAL_OUT"

#############################################
# INDEX ORF REFERENCE
#############################################

if [[ ! -f "${ORF_REF}.bwt" && ! -f "${ORF_REF}.0123" ]]; then
    echo "[INFO] Building ORF reference index"
    bwa index "$ORF_REF"
else
    echo "[INFO] ORF reference already indexed"
fi

echo
echo "=============================================="
echo "Starting ORF species rescue pipeline"
echo "=============================================="

for R1 in "$PARAPOX_DIR"/*_Parapox_Genus_R1.fastq; do

    [[ -e "$R1" ]] || {
        echo "[ERROR] No Parapox input files found"
        break
    }

    SAMPLE_ID=$(basename "$R1" _Parapox_Genus_R1.fastq)
    R2="$PARAPOX_DIR/${SAMPLE_ID}_Parapox_Genus_R2.fastq"

    echo
    echo "----------------------------------------------"
    echo "[INFO] Processing sample: $SAMPLE_ID"
    echo "----------------------------------------------"

    #############################################
    # INPUT CHECK
    #############################################

    if [[ ! -f "$R2" ]]; then
        echo "[WARN] Missing Parapox R2 for $SAMPLE_ID"
        continue
    fi

    ORF_R1="${ORF_DIR}/${SAMPLE_ID}_Orf_R1.fastq"
    ORF_R2="${ORF_DIR}/${SAMPLE_ID}_Orf_R2.fastq"

    if [[ ! -f "$ORF_R1" || ! -f "$ORF_R2" ]]; then
        echo "[WARN] Missing Kraken-assigned ORF reads"
        continue
    fi

    SAMPLE_OUT="${RESCUED_OUT}/${SAMPLE_ID}"
    mkdir -p "$SAMPLE_OUT"

    BAM_MAPPED="${SAMPLE_OUT}/${SAMPLE_ID}_mapped.bam"
    BAM_FILTERED="${SAMPLE_OUT}/${SAMPLE_ID}_filtered.bam"
    BAM_SORTED="${SAMPLE_OUT}/${SAMPLE_ID}_namesorted.bam"

    RESCUED_R1="${SAMPLE_OUT}/${SAMPLE_ID}_rescued_R1.fastq"
    RESCUED_R2="${SAMPLE_OUT}/${SAMPLE_ID}_rescued_R2.fastq"

    #############################################
    # ALIGNMENT
    #############################################

    echo "[STEP] Aligning genus-level reads to ORF reference"

    if ! bwa mem \
        -t "$THREADS" \
        -T 50 \
        "$ORF_REF" \
        "$R1" \
        "$R2" \
        | samtools view -b -f 3 - \
        > "$BAM_MAPPED"
    then
        echo "[WARN] Alignment failed"
        continue
    fi

    #############################################
    # STRINGENT FILTERING
    #############################################

    echo "[STEP] Applying rescue filters"

    if ! samtools view -h "$BAM_MAPPED" \
        | awk '
        BEGIN { OFS="\t" }
        {
            if ($1 ~ /^@/) { print; next }

            cigar = $6
            nm = 0
            mapq = $5
            aln = 0

            for (i=12; i<=NF; i++) {
                if ($i ~ /^NM:i:/) {
                    split($i,a,":")
                    nm=a[3]
                }
            }

            while (match(cigar, /[0-9]+[MID=X]/)) {
                token = substr(cigar, RSTART, RLENGTH)
                len = substr(token, 1, length(token)-1)
                op = substr(token, length(token), 1)

                if (op ~ /[MD=X]/)
                    aln += len

                cigar = substr(cigar, RSTART+RLENGTH)
            }

            readlen = length($10)

            if (aln/readlen >= 0.95 && nm <= 2 && mapq >= 50)
                print
        }' \
        | samtools view -b - \
        > "$BAM_FILTERED"
    then
        echo "[WARN] Filtering failed"
        continue
    fi

    #############################################
    # NAME SORT
    #############################################

    samtools sort -n -o "$BAM_SORTED" "$BAM_FILTERED"

    #############################################
    # FASTQ EXTRACTION
    #############################################

    echo "[STEP] Extracting rescued reads"

    samtools fastq \
        -1 "$RESCUED_R1" \
        -2 "$RESCUED_R2" \
        -0 /dev/null \
        -s /dev/null \
        -n \
        "$BAM_SORTED"

    #############################################
    # MERGE + DEDUP
    #############################################

    FINAL_R1="${FINAL_OUT}/${SAMPLE_ID}_ORF_combined_dedup_R1.fastq"
    FINAL_R2="${FINAL_OUT}/${SAMPLE_ID}_ORF_combined_dedup_R2.fastq"

    echo "[STEP] Merging rescued + Kraken ORF reads"

    cat "$ORF_R1" "$RESCUED_R1" \
        | seqkit rmdup -n \
        > "$FINAL_R1"

    cat "$ORF_R2" "$RESCUED_R2" \
        | seqkit rmdup -n \
        > "$FINAL_R2"

    echo "[DONE] $SAMPLE_ID completed"

done

echo
echo "=============================================="
echo "Species rescue pipeline completed"
echo "Final reads: $FINAL_OUT"
echo "=============================================="
