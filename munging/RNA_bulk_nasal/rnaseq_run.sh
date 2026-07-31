#!/usr/bin/env bash
set -euo pipefail

######################################################
#######  Nextflow nf-core/rnaseq Pipeline    #########
#######  Prometheus Study                    #########
######################################################

# ---------------------------
## project-specific configurations
# ---------------------------
indir="/hpc/group/cagpm/nfb9/projects/PrometheusReanalysis/munging/RNA_bulk_nasal"
outdir="/work/nfb9/projects/PrometheusReanalysis/rnaseq_work"
SAMPLESHEET="${indir}/sample_fastq_sheet.csv"
RESULTS="${outdir}/results"
LOGDIR="${indir}/logs"
GENOME="GRCh38"
PIPELINE_VERSION="3.26.0"
NFCONFIG="${indir}/config/dcc.config"

# ---------------------------
# Environment
# ---------------------------
# EDIT: point at your micromamba/conda env with nextflow installed,
export PATH="/hpc/home/nfb9/micromamba/envs/prometheus/bin:${PATH}"

# Redirect caches off $HOME
export NXF_SINGULARITY_CACHEDIR="/work/nfb9/nxf_apptainer_cache"
export NXF_APPTAINER_CACHEDIR="/work/nfb9/nxf_apptainer_cache"
export APPTAINER_CACHEDIR="/work/nfb9/.apptainer"

# dirs we need
mkdir -p "${LOGDIR}" "${outdir}" "${RESULTS}" \
         "${NXF_SINGULARITY_CACHEDIR}" "${APPTAINER_CACHEDIR}" "${outdir}/work"

# -----------------------------------------------
# Pipeline
# -----------------------------------------------
nextflow run nf-core/rnaseq \
  -r "${PIPELINE_VERSION}" \
  -profile apptainer \
  -c "${NFCONFIG}" \
  -w "${outdir}/work" \
  --input "${SAMPLESHEET}" \
  --outdir "${RESULTS}" \
  --genome "${GENOME}" \
  --skip_biotype_qc \
  --max_cpus 32 \
  --max_memory 128.GB \
  --max_time 96.h \
  -resume \
  2> "${LOGDIR}/rnaseq.2out.txt"

# ---------------------------
# tidy up
# ---------------------------
rm -rf /work/nfb9/projects/PrometheusReanalysis/rnaseq_work/work/ # need to remove for size 
echo "[$(date)] rnaseq pipeline completed. Cheers 🍻!"
