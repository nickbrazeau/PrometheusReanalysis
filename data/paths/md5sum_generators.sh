#!/usr/bin/env bash

## Transcriptomics Data
### Nasal Lavage RNA-Seq (1.2 Tb)
md5sum /Volumes/Private/CAGPM_Projects/2017_Prometheus/Data/RNA/Nasal/PRESAGE/Data/Burke_5229/BURKE_5229_181112B6_fastq/* > /Volumes/Private/CAGPM_Projects/2017_Prometheus/Workspace/nfb_md5sums/nasalrnaseq-BURKE_5229_181112B6_fastq_checksums.md5

### Whole Blood Peripheral Blood Mononuclear Cells (Batch 1: 293Gb; Batch 2: 467Gb)
md5sum /Volumes/Private/CAGPM_Projects/2017_Prometheus/Data/RNA/Whole_Blood/Data/Batch1/fastq/* > /Volumes/Private/CAGPM_Projects/2017_Prometheus/Workspace/nfb_md5sums/bulkrnaseq-Batch1_checksums.md5
md5sum /Volumes/Private/CAGPM_Projects/2017_Prometheus/Data/RNA/Whole_Blood/Data/Batch2/Janus_batch2_091218/batch2_fastq/* > /Volumes/Private/CAGPM_Projects/2017_Prometheus/Workspace/nfb_md5sums/bulkrnaseq-Batch2_checksums.md5

### Single Cell RNA Sequencing Data (pre-FASTQ: Batch 1 89 Gb; Batch 2 526 Gb; Gb)
md5sum /Volumes/Private/CAGPM_Projects/2017_Prometheus/Data/RNA/Single_Cell/Data/Batch1/*  > /Volumes/Private/CAGPM_Projects/2017_Prometheus/Workspace/nfb_md5sums/scrnaseq-Batch1_checksums.md5
md5sum /Volumes/Private/CAGPM_Projects/2017_Prometheus/Data/RNA/Single_Cell/Data/Batch2/*  > /Volumes/Private/CAGPM_Projects/2017_Prometheus/Workspace/nfb_md5sums/scrnaseq-Batch2_checksums.md5
md5sum /Volumes/Private/CAGPM_Projects/2017_Prometheus/Data/RNA/Single_Cell/Data/Batch3/*  > /Volumes/Private/CAGPM_Projects/2017_Prometheus/Workspace/nfb_md5sums/scrnaseq-Batch3_checksums.md5


