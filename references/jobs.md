# Slurm jobs

Reviewed: **2026-10-24**. Commands in this reference run in a **Sherlock shell**, reached directly or through the login SSH connection. Follow [access](access.md) for quoting remote commands correctly.

## Discover resources and choose the execution mode

```bash
sh_part
```

Use its current output for accessible partitions and limits. Do not assume an owner account, reservation, partition, or QOS. Choose cores, host memory, runtime, and GPUs from the workload's requirements or observed use. Queue time is not guaranteed; requesting unnecessary resources can delay a job.

- For development, the user or an agent with a persistent interactive terminal runs `sh_dev` from a login shell. Inspect `sh_dev -h` for resource options. Use `salloc` when its full option set is needed.
- For unattended work or one-shot SSH tools, prepare a batch script and use `sbatch`.
- On an existing compute allocation, verify that it is active and adequate before reusing it. A shell on a login node is not moved to a compute node just because a job ID is known.

## Prepare a batch script

Start with [CPU](../assets/cpu.sbatch), [GPU](../assets/gpu.sbatch), or [array](../assets/array.sbatch). These run tiny visibility checks with explicit five-minute resource requests. They are starting points, not workload sizing recommendations. Templates do not need a Python module for their smoke commands.

1. Stage inputs and the script under `$SCRATCH` or `$GROUP_SCRATCH`. Keep a durable source copy. Run `mkdir -p logs` in the submission directory **before** submitting; Slurm opens the log paths before the script runs.
2. Adapt resource requests to `sh_part` and the application. For GPU work also read [GPUs](gpu.md). Select a Slurm account only when the task or cluster configuration requires one and its identity is known.
3. Load discovered, version-pinned modules and activate the project's environment in the script, after its directives and before the workload. See [environments](environments.md).
4. Replace the smoke command with the actual command, using `srun` as appropriate for the application. Ensure thread/process counts fit the allocation. Keep failures visible; do not mask a failing `srun` with a succeeding command.

`#SBATCH` directives are parsed before the shell starts: `$SCRATCH`, `$HOME`, command substitutions, and shell variables inside them are not expanded. Submit from the resolved scratch directory or pass an absolute `--chdir`/log path on the command line. Slurm output tokens such as `%j` and `%A_%a` are supported. Place all directives before executable shell statements. The templates retain Slurm's effective working directory; `SLURM_SUBMIT_DIR` can differ when `--chdir` is used, so do not unconditionally change back to it.

## Validate and submit

**Sherlock shell, with the template already copied to this scratch project:**

```bash
cd "${SCRATCH:?}/my-project"
mkdir -p logs
bash -n cpu.sbatch
sbatch --test-only cpu.sbatch
```

`bash -n` checks syntax. `--test-only` contacts the scheduler without submitting; it does not prove application correctness or promise a start time. Inspect any `SBATCH_*` environment variables or extra command-line flags that could override the script's requests. Once the requested submission is ready:

```bash
sbatch --parsable cpu.sbatch
```

Capture the successful output, which is a job ID and can include a `;cluster` suffix. Use the ID portion for subsequent commands. Record the exact submitted script, directory, log paths, resources, and observed state. If the connection drops during submission, inspect existing jobs and accounting before submitting again.

## Monitor, diagnose, and finish

Use the returned numeric job ID in place of `JOB_ID`:

```bash
squeue --me
squeue -j JOB_ID -o '%.18i %.12P %.24j %.10T %.10M %.6D %R'
scontrol show job JOB_ID
sacct -j JOB_ID --format=JobID,JobName,State,ExitCode,Elapsed,AllocCPUS,ReqMem,MaxRSS
seff JOB_ID
```

Pending jobs often reflect resource availability, priority, or limits; inspect the reported reason before changing requests. Queue absence alone does not mean success. Accounting can lag, and memory data may live on step rows rather than the parent row. Inspect the output/error files and expected application results as well as terminal state and exit codes. Query at useful intervals rather than in a tight polling loop.

Use the actual log paths, for example `tail -n 80 logs/sherlock-cpu-JOB_ID.err`; do not dump all output by default. Preserve necessary results before scratch expiration. Use measured runtime/memory/utilization to improve later resource requests.

When cancellation is authorized, first verify that the ID belongs to the intended job, then run `scancel JOB_ID` and inspect its resulting state. Do not use a broad user-wide cancellation to fix one job. A troubleshooting request alone does not authorize cancellation, resubmission, or changing resources.

## Arrays and restartable workloads

The array template uses `0-3%2`: four items, at most two concurrent. Use `SLURM_ARRAY_TASK_ID` to select an input and distinct output/checkpoint paths for each item. Size the range and concurrency from the manifest, workload, and current submission limits. Array elements count toward queue limits; avoid flooding the scheduler.

For longer or preemptible work, preserve checkpoints and make restarts idempotent. The reviewed docs describe `long` QOS for eligible non-owner jobs in `normal` and preemption in the shared `owners` partition. Verify current access and limits before choosing either; do not silently requeue or retry a failing workload.

Sources: [Running jobs and partitions](https://www.sherlock.stanford.edu/docs/user-guide/running-jobs/), [queue limits](https://www.sherlock.stanford.edu/docs/advanced-topics/job-management/), [Slurm sbatch](https://slurm.schedmd.com/sbatch.html), [Slurm sacct](https://slurm.schedmd.com/sacct.html), [Slurm job arrays](https://slurm.schedmd.com/job_array.html).
