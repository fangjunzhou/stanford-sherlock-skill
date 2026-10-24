#!/bin/bash
#SBATCH --job-name=sherlock-array
#SBATCH --partition=normal
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=00:05:00
#SBATCH --array=0-3%2
#SBATCH --output=logs/%x-%A_%a.out
#SBATCH --error=logs/%x-%A_%a.err

# Four independent smoke tasks, with at most two running concurrently.
# Submit from SCRATCH/GROUP_SCRATCH after creating logs/.
set -euo pipefail
: "${SLURM_JOB_ID:?Submit this file with sbatch on Sherlock}"
: "${SLURM_ARRAY_TASK_ID:?This template requires a Slurm array job}"
# Slurm sets the working directory, including any sbatch --chdir override.
export OMP_NUM_THREADS="${SLURM_CPUS_PER_TASK:-1}"

printf 'job=%s task=%s directory=%s\n' "$SLURM_JOB_ID" "$SLURM_ARRAY_TASK_ID" "$PWD"

# Replace with the project's per-item command, passing SLURM_ARRAY_TASK_ID.
# Keep separate output/checkpoint paths for each array element.
srun --ntasks=1 hostname
