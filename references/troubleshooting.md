# Troubleshooting

Reviewed: **2026-10-24**. Capture the exact error, command, execution location, and relevant job ID first. Prefer focused reads of the affected files and state over broad changes or retries.

| Symptom | Inspect | Next useful action |
| --- | --- | --- |
| Authentication fails, Duo cannot complete, or connection is refused after failures | Account prerequisites, user terminal, current master status | Stop automated retries; have the user resolve authentication. Repeated failures can temporarily block the source IP. |
| SSH times out | Host/port, current connectivity, documented service status | Check the stated endpoint and network once; the docs suggest Stanford VPN for connection trouble. |
| Unknown or changed host key | Fingerprint against current official documentation | Verify identity before accepting or changing known-host entries; never disable checking as a fix. |
| Cached SSH session expired | `ssh -O check sherlock` locally | Hand authentication back to the user; batch mode cannot renew Duo access. |
| DTN rejects a shell command or files appear in an unexpected directory | Endpoint and resolved destination path | Run shell setup through the login host; use absolute paths with transfer clients. |
| Module or executable missing | `module spider PACKAGE`, prerequisites, shell initialization | Load the discovered stack in the actual remote/job shell. |
| Transfer/write fails despite free bytes | `sh_quota`, inode quota, permissions, parent directory | Inspect the affected path; do not delete data without task authorization. |
| Job remains pending | `squeue`, `scontrol show job JOB_ID`, `sh_part` | Read the reason; priority/resources do not imply a broken script. |
| Submission rejected for limits | Exact error and current user/group limits | Distinguish user versus account queue limits; reduce/consolidate requested work rather than bypass limits. |
| Job vanished from the queue | `sacct`, output/error files, expected results | Accounting can lag; establish final state instead of assuming completion. |
| Host out-of-memory or timeout | Accounting including steps, stderr, resource requests | Propose workload or resource changes from evidence; resubmit only within task authorization. |
| GPU unavailable or device OOM | GPU request, `node_feat`, allocated devices, framework error | Distinguish scheduler allocation, CUDA compatibility, and VRAM exhaustion; extra host RAM does not add VRAM. |
| Job produced no logs | Submission directory, log path, existing parent directory, job state | Create log parents before the next submission; check whether the job ever started. |
| Python logs appear stuck | Application state and buffering | Use `python3 -u` or `PYTHONUNBUFFERED=1` when helpful; absent log updates alone do not prove a hang. |

## Evidence for a job failure

**Sherlock shell; substitute the actual job ID:**

```bash
scontrol show job JOB_ID
sacct -j JOB_ID --format=JobID,JobName,State,ExitCode,Elapsed,AllocCPUS,ReqMem,MaxRSS
```

Also read a bounded portion of the actual stderr/stdout and inspect the submitted script. Completed jobs may no longer be in `scontrol`; use accounting. Preserve evidence before editing. Do not automatically cancel all jobs, remove checkpoints, reinstall environments, increase allocations, or submit duplicate jobs.

## Escalation evidence

If the issue remains unresolved, prepare a concise support draft for `srcc-support@stanford.edu` with the user-supplied SUNet ID, context, node, paths, command/script, relevant job IDs, exact error, and checks already performed. Include only relevant non-secret content. Send it only when the user explicitly requests sending.

Sources: [Sherlock support requests](https://www.sherlock.stanford.edu/docs/user-guide/troubleshoot/), [connection failures](https://www.sherlock.stanford.edu/docs/getting-started/connecting/), [job submission limits](https://www.sherlock.stanford.edu/docs/advanced-topics/job-management/), [GPU guide](https://www.sherlock.stanford.edu/docs/user-guide/gpu/), [Python buffering](https://www.sherlock.stanford.edu/docs/software/using/python/), [service status](https://status.sherlock.stanford.edu/).
