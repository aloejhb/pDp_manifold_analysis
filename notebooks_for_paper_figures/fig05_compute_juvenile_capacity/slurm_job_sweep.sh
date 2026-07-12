#!/bin/bash
#SBATCH --account=gfri
#SBATCH --job-name=geomm
#SBATCH --output=./logs/%j_%a.out  # Include array task ID in output filename
#SBATCH --error=./logs/%j_%a.err
#SBATCH --time=0-20:00:00
#SBATCH --partition=several
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1          # CPUs per MPI process
#SBATCH --mail-type=FAIL
#SBATCH --mem-per-cpu=2G

module purge
module load mpi/openmpi-x86_64

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

source /gfriedri/hubo/Software/miniconda3/etc/profile.d/conda.sh
conda activate catrace_gpu

# Determine the job file based on SLURM_ARRAY_TASK_ID
TASK_ID=${SLURM_ARRAY_TASK_ID}
JOB_FILE="./jobs_sweep/task_${TASK_ID}.json"

# Run the Python script with mpirun
mpirun -n $SLURM_NTASKS_PER_NODE python single_task.py -p "${JOB_FILE}"
