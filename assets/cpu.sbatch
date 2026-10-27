#!/bin/bash
#SBATCH --job-name=sherlock-cpu
#SBATCH --partition=normal
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=00:05:00
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err

# Submit from a project directory on SCRATCH/GROUP_SCRATCH with logs/ present.
# These are smoke-test resources; adapt them after checking sh_part.
set -euo pipefail
: "${SLURM_JOB_ID:?Submit this file with sbatch on Sherlock}"
# Slurm sets the working directory, including any sbatch --chdir override.
export OMP_NUM_THREADS="${SLURM_CPUS_PER_TASK:-1}"

printf 'job=%s directory=%s cpus=%s\n' "$SLURM_JOB_ID" "$PWD" "$OMP_NUM_THREADS"

# For research work, load discovered, version-pinned modules here and activate
# the project's environment before replacing the smoke command below.
srun --ntasks=1 hostname
