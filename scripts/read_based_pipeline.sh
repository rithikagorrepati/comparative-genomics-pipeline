#!/usr/bin/env bash

set -euo pipefail

READS_DIR="${1:-raw_reads}"
REFERENCE="${2:-ref/E1376901_S01_L001_contigs.fasta}"
OUTDIR="${3:-results/read_based}"
THREADS="${THREADS:-4}"

mkdir -p "${OUTDIR}/cleaned_reads"
mkdir -p "${OUTDIR}/snippy"

for R1 in "${READS_DIR}"/*_R1_001.fastq.gz; do
    sample=$(basename "${R1}" _R1_001.fastq.gz)
    R2="${READS_DIR}/${sample}_R2_001.fastq.gz"

    fastp \
        -i "${R1}" \
        -I "${R2}" \
        -o "${OUTDIR}/cleaned_reads/${sample}_R1_trimmed.fq.gz" \
        -O "${OUTDIR}/cleaned_reads/${sample}_R2_trimmed.fq.gz"

    snippy \
        --cpus "${THREADS}" \
        --outdir "${OUTDIR}/snippy/${sample}" \
        --ref "${REFERENCE}" \
        --R1 "${OUTDIR}/cleaned_reads/${sample}_R1_trimmed.fq.gz" \
        --R2 "${OUTDIR}/cleaned_reads/${sample}_R2_trimmed.fq.gz"
done

snippy-core \
    --ref "${REFERENCE}" \
    --prefix "${OUTDIR}/core" \
    "${OUTDIR}"/snippy/*

iqtree \
    -s "${OUTDIR}/core.aln" \
    -nt AUTO \
    -pre "${OUTDIR}/core"
