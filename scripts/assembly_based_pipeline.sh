#!/usr/bin/env bash

set -euo pipefail

READS_DIR="${1:-raw_reads}"
REFERENCE="${2:-!}"
OUTDIR="${3:-results/assembly_based}"
THREADS="${THREADS:-4}"

CLEAN_DIR="${OUTDIR}/cleaned_reads"
ASSEMBLY_DIR="${OUTDIR}/assemblies"
PARSNP_DIR="${OUTDIR}/parsnp"

mkdir -p "${CLEAN_DIR}" "${ASSEMBLY_DIR}" "${PARSNP_DIR}"

for R1 in "${READS_DIR}"/*_R1_001.fastq.gz; do
    sample=$(basename "${R1}" _R1_001.fastq.gz)
    R2="${READS_DIR}/${sample}_R2_001.fastq.gz"

    fastp \
        -i "${R1}" \
        -I "${R2}" \
        -o "${CLEAN_DIR}/${sample}_R1_trimmed.fq.gz" \
        -O "${CLEAN_DIR}/${sample}_R2_trimmed.fq.gz" \
        --json "${CLEAN_DIR}/${sample}_fastp.json" \
        --html "${CLEAN_DIR}/${sample}_fastp.html"

    skesa \
        --fastq "${CLEAN_DIR}/${sample}_R1_trimmed.fq.gz,${CLEAN_DIR}/${sample}_R2_trimmed.fq.gz" \
        --cores "${THREADS}" \
        --contigs_out "${ASSEMBLY_DIR}/${sample}_contigs.fasta"
done

parsnp \
    -d "${ASSEMBLY_DIR}" \
    -r "${REFERENCE}" \
    -o "${PARSNP_DIR}" \
    -p "${THREADS}" \
    --use-fasttree \
    --fo
