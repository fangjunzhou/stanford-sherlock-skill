# Sherlock skill

A portable skill for working with [Stanford Sherlock](https://www.sherlock.stanford.edu/docs/): connect over SSH, transfer files, prepare environments, and run CPU/GPU research jobs through Slurm. It supports agents on a local workstation and agents running inside Sherlock.

The repository contains one installable skill, [sherlock](skills/sherlock/SKILL.md). It uses native SSH, rsync/SFTP, Lmod, and Slurm commands, with focused references and adaptable templates. There is no custom automation CLI or credential store.

## Install

Copy the **entire** `skills/sherlock` directory into a location supported by your agent. Keep its references and assets alongside `SKILL.md`.

| Agent | Personal installation | Project installation |
| --- | --- | --- |
| Codex | `~/.agents/skills/sherlock/` | `.agents/skills/sherlock/` in the research repository |
| Claude Code | `~/.claude/skills/sherlock/` | `.claude/skills/sherlock/` in the research repository |
| Other Agent Skills clients | The client's documented skill directory | The client's documented skill directory |

For a fresh personal Codex installation, run **locally from this repository root**. For Claude Code, change `skill_parent` to `$HOME/.claude/skills` first:

```bash
skill_parent="$HOME/.agents/skills"
mkdir -p "$skill_parent"
if [ -e "$skill_parent/sherlock" ] || [ -L "$skill_parent/sherlock" ]; then
    printf 'Existing installation: %s; review it before updating.\n' "$skill_parent/sherlock"
else
    cp -R skills/sherlock "$skill_parent/sherlock"
fi
```

On Sherlock, install into the agent's skill location on persistent shared storage so compute nodes can read it. A workstation installation is not automatically available there. For an update, review and replace the installed skill deliberately; copying only `SKILL.md` leaves references/templates outdated.

Codex supports normal automatic skill selection and explicit `$sherlock` invocation. If the skill does not appear after installation, restart the client. Claude Code can invoke it as `/sherlock`. `agents/openai.yaml` supplies optional Codex UI metadata; core instructions use portable `SKILL.md` frontmatter and relative resources.

Installation locations were checked on **2026-10-24** against the [official Codex skills guide](https://developers.openai.com/codex/skills/) and [Claude Code skills guide](https://code.claude.com/docs/en/skills). Follow your installed client's current documentation if its discovery locations differ.

## Prerequisites and first use

Operating Sherlock requires an active SUNet ID, a provisioned Sherlock account, and Duo. See the [official account prerequisites](https://www.sherlock.stanford.edu/docs/getting-started/). Local examples use a Unix-like shell (macOS, Linux, or WSL) and SSH client; transfers also need a suitable transfer client. The account's current permissions determine accessible storage and compute resources.

Example requests:

- `Use $sherlock to help me establish a reusable SSH session. I will complete Duo in my terminal.`
- `Use $sherlock to preview a transfer of this project into scratch and prepare a CPU job. Do not submit it yet.`
- `Use $sherlock to prepare and submit a small GPU visibility check using a partition I can access.`
- `Use $sherlock to investigate why job 123456 failed and explain the relevant logs.`
- `I am on a Sherlock compute allocation. Use $sherlock to prepare this project's Python environment within it.`

The skill obtains account/project details when needed. Passwords, Duo codes, and provider API keys belong in the user's terminal or supported credential mechanism, never in chat or versioned files. SSH key authentication is not supported by Sherlock; interactive login plus connection reuse is the default access workflow.

## Contents

| Resource | Purpose |
| --- | --- |
| [Skill entrypoint](skills/sherlock/SKILL.md) | Detect execution context and select the relevant workflow |
| [Access](skills/sherlock/references/access.md) | User-operated authentication and SSH connection reuse |
| [Storage and transfers](skills/sherlock/references/storage-and-transfers.md) | Filesystem selection, staging, DTNs, retrieval, and retention |
| [Environments](skills/sherlock/references/environments.md) | Module discovery, Python environments, and builds |
| [Jobs](skills/sherlock/references/jobs.md) | Interactive work, batch submission, monitoring, arrays, and completion |
| [GPUs](skills/sherlock/references/gpu.md) | Resource discovery, GPU requests, and application checks |
| [Troubleshooting](skills/sherlock/references/troubleshooting.md) | Focused diagnostics and support evidence |
| [Agents on Sherlock](skills/sherlock/references/agents-on-sherlock.md) | Allocations, installation, reconnection, and specialized links |
| [SSH configuration](skills/sherlock/assets/ssh_config) | Separate login/DTN aliases with short-lived connection reuse |
| [CPU](skills/sherlock/assets/cpu.sbatch), [GPU](skills/sherlock/assets/gpu.sbatch), [array](skills/sherlock/assets/array.sbatch) | Small Slurm smoke jobs to adapt to real workloads |

The job templates request five minutes, one CPU, and 4 GB host RAM. The GPU template additionally requests one GPU; the array template runs four items with at most two concurrently. Confirm accessible partitions and limits before use. Submit from a scratch project directory with `logs/` already created. The CPU/array templates print hostnames; the GPU template queries visible devices. Load version-pinned modules and substitute the real application when adapting them.

## Validate without Sherlock access

From the repository root, check shell syntax and inspect both SSH aliases without connecting:

```bash
(
    for job in skills/sherlock/assets/*.sbatch; do
        bash -n "$job" || exit 1
    done
)
ssh -G -F skills/sherlock/assets/ssh_config sherlock
ssh -G -F skills/sherlock/assets/ssh_config sherlock-dtn
git diff --check
```

`ssh -G` prints effective configuration; it does not connect or authenticate. The username in the asset is an intentional replacement marker. Running a job template directly without Slurm variables fails before its smoke command.

If Codex's skill-creator tooling and its PyYAML dependency are available, also run:

```bash
python3 "${CODEX_HOME:-$HOME/.codex}/skills/.system/skill-creator/scripts/quick_validate.py" skills/sherlock
```

Review relative links, YAML metadata, command locations, and remote quoting when changing the package. Walk through these scenarios against the instructions:

| Scenario | Expected behavior |
| --- | --- |
| First login or expired cached connection | User completes authentication in their terminal; no automated credential retries |
| Local and Sherlock home/scratch paths differ | Cluster variables expand remotely; transfers use resolved remote paths |
| Large transfer with an authenticated login session | DTN authentication is handled separately; no DTN shell setup |
| Agent starts on a login node | Computation and substantial agent activity use a compute allocation |
| Unknown module version or GPU model | Query the live cluster rather than copy documentation examples |
| Submission connection drops | Inspect existing jobs before another submission |
| Pending, failed, or absent job | Inspect scheduler/accounting/logs and distinguish submission from successful execution |
| Array tasks or paths containing spaces | Preserve distinct array outputs and correctly quoted job working directories; select a compatible transfer method |

## Optional cluster smoke checks

These are user-run live checks after authentication; local validation cannot prove scheduler acceptance or GPU availability.

1. Follow [access](skills/sherlock/references/access.md) to establish a session and inspect `sh_part`.
2. Create a scratch project and `logs/`, then copy the CPU template there. Follow [jobs](skills/sherlock/references/jobs.md) to syntax-check, run `sbatch --test-only`, and submit it. Record the returned job ID.
3. Verify terminal accounting state/exit code and hostname output. Retrieve the logs to the intended local destination.
4. If relevant, repeat with the bounded array template and verify all four task logs. For a GPU check, discover available features, review the request, and use the GPU template; visibility is not an application-level CUDA test.

Each reference lists official sources and a review date. Refresh source guidance when authentication, storage policies, scheduling behavior, or installation conventions change. Discover account-specific limits, module versions, and hardware at use time.
