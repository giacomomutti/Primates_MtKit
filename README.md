# Primates_MtKit Snakemake Pipeline

This repository contains a Snakemake-based pipeline for processing mtDNA reads across multiple datasets, extracting references from dataset-specific MSAs, indexing those references, aligning reads, and running PathPhynder analysis.

## What it does

- loads dataset definitions from `config.yaml`
- parses one samples file per dataset, where each line contains:
  - sample FASTQ path
  - sample name
  - comma-separated reference IDs
- extracts each reference sequence from the dataset MSA and removes gaps
- builds per-dataset samtools/faidx and bwa-mem2 indices for extracted references
- aligns each sample to its assigned references
- generates BAM lists per reference for PathPhynder
- runs PathPhynder on dataset-specific reference trees

## Required files

- `config.yaml` - pipeline configuration with dataset blocks
- per-dataset samples file, e.g. `data/gorillas_samples.txt` and `data/papio_samples.txt`
  - each line must contain:
    - sample FASTQ path
    - sample name
    - comma-separated reference IDs
- per-dataset MSA file and tree defined in `config.yaml`

## Example config structure

```yaml
datasets:
  gorillas:
    refs: data/gorillas_samples.txt
    msa: data/references/mts_gorilla_aln.fa
    tree: data/references/mts_gorilla_rooted.nwk

  papio:
    refs: data/papio_samples.txt
    msa: data/references/mts_papio_aln.fa
    tree: data/references/mts_papio_rooted.nwk
```

## Pipeline files

- `workflow/Snakefile` - Snakemake workflow definition
- `config.yaml` - pipeline configuration
- `workflow/envs/vcf.yaml` - conda environment for alignment, indexing, and VCF generation
- `workflow/envs/pathphynder.yaml` - conda environment for PathPhynder
- `workflow/scripts/blast_reads_eda.R` - R script for filtering BLAST results
- `workflow/scripts/get_ref_coords.R` - R script for reference coordinate processing

## Usage

From the repository root:

```bash
cd /data/unipr_bkup/unipr_bkup/RIS
snakemake -s workflow/Snakefile
```

For a dry run:

```bash
snakemake -n -s workflow/Snakefile
```

To execute a specific target, for example a BAM file:

```bash
snakemake -s workflow/Snakefile results/gorillas/bams/GGO2_Gorilla_gorilla_45.bam
```

## Notes

- The pipeline uses conda environments defined in `workflow/envs/`.
- Make sure `snakemake` and `conda` are installed and available.
- Each dataset sample file must provide the exact path to each sample FASTQ file.
- If you change sample files or `config.yaml`, the workflow will automatically use the updated dataset definitions.
