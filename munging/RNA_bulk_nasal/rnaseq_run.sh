#!/usr/bin/env bash
set -euo pipefail

######################################################
#######  Nextflow nf-core/rnaseq Pipeline    #########
#######  Prometheus Study                    #########
######################################################

# ---------------------------
## project-specific configurations
# ---------------------------
indir="/hpc/group/cagpm/nfb9/projects/prometheus/"
outdir="/work/${NETID}/projects/prometheus/rnaseq_work"
SAMPLESHEET="${outdir}/samplesheet.csv"
RESULTS="${outdir}/results"
LOGDIR="${indir}/logs"
GENOME="GRCh38"
PIPELINE_VERSION="1.00.00"
NFCONFIG="${indir}/config/dcc.config"

# ---------------------------
# Environment
# ---------------------------
# EDIT: point at your micromamba/conda env with nextflow installed,
# same pattern as the bactopia 'prealm' env
export PATH="/hpc/home/${NETID}/micromamba/envs/prometheus/bin:${PATH}"

# Redirect caches off $HOME 
export NXF_SINGULARITY_CACHEDIR="/work/${NETID}/nxf_apptainer_cache"
export NXF_APPTAINER_CACHEDIR="/work/${NETID}/nxf_apptainer_cache"
export APPTAINER_CACHEDIR="/work/${NETID}/.apptainer"

# dirs we need
mkdir -p "${LOGDIR}" "${outdir}" "${RESULTS}" \
         "${NXF_SINGULARITY_CACHEDIR}" "${APPTAINER_CACHEDIR}"

# -----------------------------------------------
# Pipeline
# -----------------------------------------------
nextflow run nf-core/rnaseq \
  -r "${PIPELINE_VERSION}" \
  -profile apptainer \
  -c "${NFCONFIG}" \
  --input "${SAMPLESHEET}" \
  --outdir "${RESULTS}" \
  --genome "${GENOME}" \
  --max_cpus 32 \
  --max_memory 128.GB \
  --max_time 72.h \
  -resume \
  2> "${LOGDIR}/rnaseq.2out.txt"

# ---------------------------
# tidy up
# ---------------------------
# Uncomment once you've confirmed results/multiqc looks good and you don't need
# to resume from cached work/ -- same pattern as the bactopia cleanup step:
# rm -rf "${indir}/work/"

echo "[$(date)] rnaseq pipeline completed. Cheers 🍻!"
