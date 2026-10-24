---
name: sherlock
description: Connect to Stanford Sherlock HPC, transfer project files, prepare software environments, and submit, monitor, or troubleshoot Slurm CPU/GPU research jobs. Use for local SSH workflows and agents running on Sherlock, including requests about Sherlock storage, modules, and job scripts.
---

# Sherlock

Use the user's requested outcome to select the relevant workflow below. Read only the references needed for that task. This skill uses native OpenSSH, rsync, Lmod, and Slurm; it supplies no custom command runner.

## Establish the execution context

Distinguish the agent's own machine, a Sherlock login node, and a compute node with an active allocation before running commands. For an existing cluster shell, inspect:

```bash
hostname -f
printf 'SLURM_JOB_ID=%s\n' "${SLURM_JOB_ID:-}"
printf 'SLURM_JOB_NODELIST=%s\n' "${SLURM_JOB_NODELIST:-}"
```

A Slurm environment variable alone does not establish that the allocation is still active or that this shell is on its compute node. When relevant, verify the job and node with `scontrol show job JOB_ID`. Never infer a SUNet ID from a local username.

- **Local agent:** use [access](references/access.md) to establish or reuse an authenticated SSH connection. Execute cluster commands through that connection; keep local and remote paths distinct.
- **Sherlock login shell:** edit files, discover software/resources, and submit or inspect jobs. Obtain a compute allocation for builds, tests, data processing, and substantial agent work.
- **Allocated compute shell:** work within the job's CPU, memory, GPU, and time limits. Do not request a nested allocation when the existing one already meets the task.

Label command blocks by execution location when explaining a workflow. Single-quote remote shell programs or use a quoted heredoc so `$SCRATCH`, `$HOME`, and Slurm variables expand on Sherlock. Transfer programs need resolved remote paths; see the transfer reference.

## Select a workflow

| Requested outcome | Read | Starting assets |
| --- | --- | --- |
| Connect, reuse Duo authentication, or fix SSH access | [Access](references/access.md) | [SSH configuration](assets/ssh_config) |
| Choose storage, stage inputs, or retrieve results | [Storage and transfers](references/storage-and-transfers.md) | Native rsync/scp/Globus |
| Discover modules, build software, or create a Python environment | [Software environments](references/environments.md) | Existing project dependency files |
| Prepare, submit, monitor, or cancel a Slurm job | [Jobs](references/jobs.md) | [CPU](assets/cpu.sbatch), [array](assets/array.sbatch) |
| Request GPUs or diagnose GPU allocation issues | [Jobs](references/jobs.md), [GPUs](references/gpu.md) | [GPU](assets/gpu.sbatch) |
| Investigate failed access, transfers, environments, or jobs | [Troubleshooting](references/troubleshooting.md) | Exact errors and job logs |
| Run an agent on Sherlock or find remote editor/model guidance | [Agents on Sherlock](references/agents-on-sherlock.md) | An interactive compute allocation |

## Apply Sherlock-specific constraints

- Authentication is user-operated SUNet password plus Duo, or an existing supported Kerberos setup. SSH public-key authentication is unsupported. Never request passwords, Duo codes, or API keys in chat or store them in generated files. A headless agent must hand interactive authentication back to the user's terminal.
- Use the load-balanced login hostname by default. Keep host-key checking enabled and verify fingerprints against the current official documentation. Stop on authentication failures; do not loop retries.
- Submit computation through Slurm. A compute node is accessible only while the user has an allocation there. Do not start an SSH server on any Sherlock node.
- Discover the user's available partitions with `sh_part`, GPU features with `node_feat`, and module versions with `module spider`. Do not treat documentation examples as a current hardware/software inventory.
- Stage active job I/O on `$SCRATCH` or `$GROUP_SCRATCH`; preserve important outputs elsewhere before scratch expiration. DTNs transfer files and do not provide an interactive shell.
- Keep account details and project paths in the user's environment. Honor existing task authorization for file changes, submissions, and cancellations; do not add a blanket confirmation step. A diagnosis request alone does not authorize cancelling jobs or changing data.

## Finish with a useful handoff

For submitted jobs, report the job ID, submission directory, script, requested resources, log locations, current observed state, and how to inspect results. Submission success is not execution success. For a proposed job, identify unverified module versions or resource assumptions before claiming it is ready. For transfers, report source, destination, whether the operation was a preview or actual transfer, and the result observed.

References were reviewed against [official Sherlock documentation](https://www.sherlock.stanford.edu/docs/) on **2026-10-24**. Check current documentation for host fingerprints and policy changes, and use live cluster queries for account-specific limits and available software. Do not claim live verification when only a local template or example was checked.
