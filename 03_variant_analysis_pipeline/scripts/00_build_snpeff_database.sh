#!/usr/bin/env bash

set -eu
IFS=$'\n\t'

source ../config/config.sh

echo
echo "=============================================="
echo "STEP 0: Build custom SnpEff database"
echo "=============================================="

#############################################
# CREATE DATABASE DIRECTORY
#############################################

DB_DIR="$SNPEFF_DIR/data/$SNPEFF_DB_NAME"

mkdir -p "$DB_DIR"

#############################################
# COPY REFERENCE FILES
#############################################

echo "[STEP] Copying reference genome"

cp "$REF_GENOME" "$DB_DIR/sequences.fa"

echo "[STEP] Copying annotation GFF"

cp "$GFF_FILE" "$DB_DIR/genes.gff"

#############################################
# CONFIG CHECK
#############################################

CONFIG_FILE="$SNPEFF_DIR/snpEff.config"

if ! grep -q "^${SNPEFF_DB_NAME}.genome" "$CONFIG_FILE"; then
    echo
    echo "[ACTION REQUIRED]"
    echo "Add this line to snpEff.config:"
    echo
    echo "${SNPEFF_DB_NAME}.genome : ${SNPEFF_GENOME_LABEL}"
    echo
    exit 1
fi

#############################################
# BUILD DATABASE
#############################################

cd "$SNPEFF_DIR"

echo "[STEP] Building SnpEff database"

java -Xmx"$JAVA_MEM" -jar "$SNPEFF_JAR" \
    build \
    -gff3 \
    -v \
    "$SNPEFF_DB_NAME"

#############################################
# VERIFY
#############################################

echo
echo "[STEP] Verifying database"

java -jar "$SNPEFF_JAR" databases | grep -i "$SNPEFF_DB_NAME"

echo
echo "[DONE] Custom SnpEff database ready"
