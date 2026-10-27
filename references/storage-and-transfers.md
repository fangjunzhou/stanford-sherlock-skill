# Storage and transfers

Reviewed: **2026-10-24**. Resolve locations in a Sherlock shell; local environment variables do not identify remote storage.

## Choose a filesystem

| Location | Use | Persistence considerations |
| --- | --- | --- |
| `$HOME` | Personal configuration, code, small persistent files | Snapshots and off-site replication; avoid active job I/O |
| `$GROUP_HOME` | Shared code and software installations | Group storage with snapshots and replication; avoid active job I/O |
| `$SCRATCH`, `$GROUP_SCRATCH` | Active inputs, outputs, checkpoints, intermediates | No backups; inactive files expire under the scratch policy |
| `$L_SCRATCH_JOB` | Per-job temporary files requiring local fast I/O | Node-local and removed when the job ends; copy needed results out |
| `$OAK` | Large datasets and curated results for groups with Oak access | Optional service; do not assume access or backup coverage |

The reviewed policy deletes scratch files whose **contents** have not changed for 90 days. Reads and metadata changes do not extend their lifetime. Do not refresh or rewrite data to evade expiration. Preserve important results on an appropriate persistent destination with an additional copy as needed. Consult the current policy before advising on retention.

**Sherlock login or compute shell, inspect actual paths and quotas:**

```bash
printf 'HOME=%s\nGROUP_HOME=%s\n' "$HOME" "${GROUP_HOME:-}"
printf 'SCRATCH=%s\nGROUP_SCRATCH=%s\nOAK=%s\n' "${SCRATCH:-}" "${GROUP_SCRATCH:-}" "${OAK:-}"
sh_quota
```

An unset group/Oak variable is not permission to invent a path. Use `sh_quota` for byte and inode limits instead of copying historical quotas from examples. Avoid recursive scans of whole shared filesystems when investigating usage.

## Stage a project

**Sherlock login shell, directly or through the authenticated SSH connection:**

```bash
project_dir="${SCRATCH:?Sherlock scratch is unset}/my-project"
mkdir -p "$project_dir/logs"
printf 'Remote project directory: %s\n' "$project_dir"
```

Choose the project name for the task. Record the printed absolute path. Create destination directories through the login host; DTNs cannot run this setup. Keep code's durable source copy separate from its scratch working copy.

**Local, after inspecting that output:**

```bash
remote_project='/absolute/path/reported/by/Sherlock/my-project'
rsync -av --partial --progress --dry-run -e 'ssh -o BatchMode=yes' \
    ./project/ "sherlock:${remote_project}/"
```

Replace the illustrative absolute path before running. This rsync pattern assumes an uncomplicated remote path without whitespace or shell metacharacters. Inspect the preview, then remove `--dry-run` to execute the transfer within the authorized task. The trailing slash on `./project/` copies its contents. Rsync can overwrite destination files; a preview is not a backup. Do not add `--delete` unless deletion is part of the requested synchronization.

For remote paths with spaces or special characters, use rsync's protected-argument option only after checking support on both ends, or use SFTP with quoted paths. Older rsync clients, including some macOS installations, lack modern argument-protection options. For example, the **user's local SFTP session** can use:

```text
sftp sherlock-dtn
sftp> cd "/resolved/remote/path with spaces"
sftp> put "local file.csv"
sftp> bye
```

The `sftp>` text indicates the client prompt, not part of the command. Validate filenames before incorporating them into remote shell programs.

## Large transfers and retrieval

Use `sherlock-dtn` for large SSH-based transfers. DTNs accept transfer protocols but do not offer a shell. Their default directory is scratch, so use explicit resolved absolute paths instead of assuming `~` means the login-node home directory.

The **user performs the first local DTN preview** without batch mode to complete authentication:

```bash
rsync -av --partial --progress --dry-run ./project/ "sherlock-dtn:${remote_project}/"
```

After authentication and a successful `ssh -O check sherlock-dtn`, an agent may rerun the transfer with `-e 'ssh -o BatchMode=yes'`. A login-host master cannot authenticate the DTN. If reuse is unavailable, hand the interactive transfer to the user.

**Local, retrieve an existing results directory using an authenticated DTN session:**

```bash
mkdir -p ./results
rsync -av --partial --progress --dry-run -e 'ssh -o BatchMode=yes' \
    "sherlock-dtn:${remote_project}/results/" ./results/
```

Verify the actual transfer status and required output files after removing the preview flag. For scheduled, unattended, or endpoint-to-endpoint transfers, use the documented Globus workflow. Discover collection identifiers and authorizations at use time; do not embed personal tokens or assume a collection UUID is permanent. See the official transfer guide for Globus, Oak, and cloud-storage options.

Sources: [Filesystems and expiration](https://www.sherlock.stanford.edu/docs/storage/filesystems/), [transfer protocols, DTNs, and Globus](https://www.sherlock.stanford.edu/docs/storage/data-transfer/), [rsync reference](https://download.samba.org/pub/rsync/rsync.1).
