#!/bin/bash
#SBATCH --job-name=prometheus
#SBATCH --output=logs/prom_%j.out
#SBATCH --error=logs/prom_%j.err
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --time=72:00:00
# env
source ~/.bashrc
eval "$(micromamba shell hook --shell bash)"
micromamba activate prometheus

# ensure no singularity vars shadow apptainer
unset SINGULARITY_CACHEDIR NXF_SINGULARITY_CACHEDIR NXF_SINGULARITY_OPTS

# run
cd /hpc/group/cagpm/nfb9/projects/PrometheusReanalysis/munging/RNA_bulk_nasal/
bash rnaseq_run.sh
