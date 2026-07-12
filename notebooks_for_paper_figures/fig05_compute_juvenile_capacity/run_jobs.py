from mpi4py import MPI
import subprocess
import json
import os

# MPI Initialization
comm = MPI.COMM_WORLD
rank = comm.Get_rank()
size = comm.Get_size()

def run_job(job_config):
    """
    Run a single job based on its configuration.
    """
    # Example: Assume job_config contains a command to execute
    cmd = job_config.get("command", "")
    if cmd:
        print(f"Rank {rank} running command: {cmd}")
        subprocess.run(cmd, shell=True)

def load_jobs_from_json(task_file):
    """
    Load jobs from a JSON file.
    """
    with open(task_file, 'r') as f:
        jobs = json.load(f)
    return jobs

# Main logic
if __name__ == "__main__":
    # Each rank handles one task file
    task_files = ["task1.json", "task2.json", "task3.json"]  # List of task files
    if rank < len(task_files):
        task_file = task_files[rank]
        jobs = load_jobs_from_json(task_file)
        
        # Parallel execution of jobs in a task
        for job_config in jobs:
            run_job(job_config)
    else:
        print(f"Rank {rank} has no task to process.")
