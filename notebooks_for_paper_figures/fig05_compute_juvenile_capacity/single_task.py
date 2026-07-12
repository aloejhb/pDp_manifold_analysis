import argparse
import json
import os
import sys
import traceback
from mpi4py import MPI

# Import from current directory
from catrace.run.run_capacity import main as run_analysis


def main(jobs_file):
    comm = MPI.COMM_WORLD
    rank = comm.Get_rank()
    nthreads = comm.Get_size()
    print(f'Running as MPI rank {rank} out of {nthreads} processes')

    # Load jobs for this task
    with open(jobs_file) as f:
        processes_jobs = json.load(f)  # List of jobs per process

    if rank >= len(processes_jobs):
        print(f'Rank {rank}: No jobs assigned, exiting.')
        sys.exit(0)

    runs = processes_jobs[rank]  # List of runs assigned to this process
    print(f'Rank {rank} processing {len(runs)} runs')

    # Execute runs sequentially
    for run in runs:
        print(f'Rank {rank} starting run: {run}')
        try:
            run_analysis(run)
        except Exception as e:
            print(f'Rank {rank} failed run: {run}')
            print(e)
            # Print traceback
            traceback.print_exc()
        print(f'Rank {rank} completed run: {run}')

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-p', '--params-file', required=True)
    args = parser.parse_args()
    main(args.params_file)