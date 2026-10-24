#!/bin/bash
#SBATCH --job-name=sherlock-gpu
#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --gpus=1
#SBATCH --mem=4G
#SBATCH --time=00:05:00
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err

# Submit from a project directory on SCRATCH/GROUP_SCRATCH with logs/ present.
# Select available GPU constraints only after checking node_feat -p gpu.
set -euo pipefail
: "${SLURM_JOB_ID:?Submit this file with sbatch on Sherlock}"
# Slurm sets the working directory, including any sbatch --chdir override.
export OMP_NUM_THREADS="${SLURM_CPUS_PER_TASK:-1}"

printf 'job=%s directory=%s cpus=%s\n' "$SLURM_JOB_ID" "$PWD" "$OMP_NUM_THREADS"

# This checks GPU visibility, not application/framework compatibility. Load
# discovered, version-pinned application modules before a research workload.
srun --ntasks=1 nvidia-smi --query-gpu=name,memory.total --format=csv,noheader
