# Comparative Genomics Pipeline

Reproducible comparative genomics workflow for bacterial whole-genome sequencing, variant calling, phylogenetic analysis, and genomic clustering.

## Overview

This project analyzed 34 *Campylobacter jejuni* isolates using complementary read-based and assembly-based comparative genomics workflows to evaluate genetic relatedness across isolates.

Two analytical approaches were implemented:

### Read-based workflow

FASTQ reads → fastp quality control → Snippy variant calling → core SNP alignment → IQ-TREE phylogeny → R-based distance analysis and clustering

### Assembly-based workflow

FASTQ reads → fastp quality control → SKESA genome assembly → ParSNP core-genome alignment → FastTree phylogeny → R-based distance analysis and clustering

A Nextflow DSL2 implementation was also developed for the assembly-based fastp → SKESA → ParSNP workflow.

## Dataset

- 34 *Campylobacter jejuni* isolates
- 68 paired-end FASTQ files
- 34 draft genome assemblies
- Two reference strategies evaluated:
  - NCBI reference genome GCF_000009085.1
  - High-quality dataset isolate E1376901

Raw sequencing data are not included in this repository.

## Analysis

Phylogenetic trees were converted into pairwise evolutionary-distance matrices in R and analyzed using hierarchical clustering.

A project-defined genetic-distance threshold of 0.005 substitutions per site was used to distinguish closely related multi-isolate clusters from sporadic isolates.

The read-based analysis used complete-linkage clustering, while the assembly-based analysis used average-linkage clustering.

## Tools

**Bioinformatics:** fastp, Snippy, SKESA, ParSNP, IQ-TREE, FastTree

**Programming and analysis:** Bash, R

**R packages:** ape, ggtree, ggplot2, dplyr

**Workflow and reproducibility:** Nextflow DSL2, Conda, Bioconda

**Version control:** Git, GitHub

## Project Context

This project was completed collaboratively as part of the Computational Genomics course at the Georgia Institute of Technology (Team E, Group 4). This repository presents a cleaned and reorganized version of the project workflow for portfolio and reproducibility purposes.

## Repository Structure

```text
comparative-genomics-pipeline/
├── docs/
│   └── data_description.md
├── scripts/
│   ├── read_based_pipeline.sh
│   ├── assembly_based_pipeline.sh
│   ├── snippy_tree_analysis.R
│   └── parsnp_tree_analysis.R
├── workflow/
│   ├── main.nf
│   ├── nextflow.config
│   └── environment.yml
└── README.md

