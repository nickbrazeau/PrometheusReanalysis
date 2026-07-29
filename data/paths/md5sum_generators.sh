#!/usr/bin/env bash

mkdir -p nfb_md5sums

## Transcriptomics Data
### Nasal Lavage RNA-Seq (1.2 Tb)
md5sum /nfs/datacommons/henao/Projects/2017_Prometheus/BURKE_5229_181112B6_fastq/* > nfb_md5sums/nasalrnaseq-BURKE_5229_181112B6_fastq_checksums.md5

### Whole Blood Peripheral Blood Mononuclear Cells (Batch 1: 293Gb; Batch 2: 467Gb)
md5sum /nfs/datacommons/henao/Projects/2017_Prometheus/whole_blood_Data_Batch1_fastq/* > nfb_md5sums/bulkrnaseq-Batch1_checksums.md5
md5sum /nfs/datacommons/henao/Projects/2017_Prometheus/whole_blood_Data_Batch2_fastq/* > nfb_md5sums/bulkrnaseq-Batch2_checksums.md5

### Single Cell RNA Sequencing Data (pre-FASTQ: Batch 1 89 Gb; Batch 2 526 Gb; Gb)
cd /nfs/datacommons/henao/Projects/2017_Prometheus/single_cell_Data_Batch1; find . -type f ! -name "checksums.md5" -print0 | sort -z | xargs -0 md5sum > nfb_md5sums/scRNAseq-Batch1_checksums.md5
cd /nfs/datacommons/henao/Projects/2017_Prometheus/single_cell_data_Batch2; find . -type f ! -name "checksums.md5" -print0 | sort -z | xargs -0 md5sum > nfb_md5sums/scRNAseq-Batch2_checksums.md5
cd /nfs/datacommons/henao/Projects/2017_Prometheus/single_cell_data_Batch3; find . -type f ! -name "checksums.md5" -print0 | sort -z | xargs -0 md5sum > nfb_md5sums/scRNAseq-Batch3_checksums.md5
