# Access and authenticated sessions

Reviewed: **2026-10-24**. Commands marked **local** run on the user's workstation, under the same OS account as the agent. The SSH aliases below come from the bundled configuration.

## First connection

An active SUNet ID and a separately provisioned Sherlock account are required. Link the [account prerequisites](https://www.sherlock.stanford.edu/docs/getting-started/) if either is missing. Do not try to create an account as part of a login attempt.

For initial access, the **user runs locally in their terminal**:

```bash
ssh YOUR_SUNET_ID@login.sherlock.stanford.edu
```

Replace `YOUR_SUNET_ID` with the user's supplied ID. Before accepting an unfamiliar host key, compare its fingerprint with the current [official host-key table](https://www.sherlock.stanford.edu/docs/getting-started/connecting/#host-keys). A changed key requires verification too; do not disable checking or remove known-host entries as an automatic fix.

The user enters their SUNet password and completes Duo directly in the terminal. Never use `sshpass`, an expect script, command-line passwords, or agent-managed Duo retries. Public-key authentication is not supported. An existing Kerberos/GSSAPI setup can be reused; link the official instructions if the user wants to configure it rather than changing system Kerberos files by default.

## Reuse the authenticated connection

When SSH configuration is part of the request, merge [the SSH configuration asset](../assets/ssh_config) into local `~/.ssh/config`, replacing the username. Keep the file private and preserve unrelated entries. Put specific entries before broad defaults because OpenSSH generally keeps the first value obtained for each setting. `%C` keeps the control socket name short, including on macOS. The template retains idle connections for ten minutes; this is a convenience default, not a Sherlock requirement.

**Local, configuration inspection only; no connection:**

```bash
ssh -G sherlock
```

Check `hostname`, `user`, `controlpath`, and `controlpersist`. If there is no usable master, the **user runs locally**:

```bash
ssh -MNf sherlock
```

This authenticates interactively and then backgrounds a connection without a remote command. The user must verify the host key and complete Duo before the agent proceeds. An agent's terminal may not share the user's sockets or network access; test reuse rather than assuming it.

**Local agent, after authentication:**

```bash
ssh -O check sherlock
ssh -o BatchMode=yes -o ConnectTimeout=15 sherlock 'hostname -f'
```

If either command fails, diagnose the failure once and return interactive authentication to the user when needed. `BatchMode=yes` prevents credential prompting on a new connection if the cached session has expired. It does not authenticate the user. Do not keep retrying failed authentication.

Multiplexing keeps subsequent commands on the same login node while the master lasts. Losing the connection does not terminate an already submitted batch job. Before repeating a submission after a disconnect, inspect the queue/accounting and logs to avoid duplicate work.

When the user wants to end this cached session, **local**:

```bash
ssh -O exit sherlock
```

Closing a shared master also closes channels using it; inspect active work first.

## Run remote commands with the right environment

**Local agent, lightweight discovery on Sherlock:**

```bash
ssh -T -o BatchMode=yes -o ConnectTimeout=15 sherlock 'bash -l -s' <<'SHERLOCK'
hostname -f
printf 'HOME=%s\nSCRATCH=%s\n' "$HOME" "${SCRATCH:-}"
sh_part
SHERLOCK
```

The quoted heredoc expands cluster variables remotely. Do not substitute a double-quoted remote command containing local `$HOME` or `$SCRATCH`. Each invocation has its own shell; module loads and `cd` changes do not persist across invocations. Initialize modules in a remote login shell or in the job script.

For an interactive allocation, the **user runs locally** `ssh -t sherlock`, then runs `sh_dev` in that login shell. An agent with a persistent terminal can use the same pattern when authorized. If the tooling cannot maintain the interactive session, use a batch job for the workload; a one-shot `ssh 'sh_dev'` call is not a durable allocation.

## Transfer endpoint

`sherlock-dtn` points to `dtn.sherlock.stanford.edu`. Its authentication is separate from the login host. Let the user complete a first file-transfer operation interactively; a client honoring the template's multiplexing settings may retain that authenticated connection. Check reuse before an agent uses batch mode. Do not run `hostname`, a shell, or a remote setup script through the DTN. See [storage and transfers](storage-and-transfers.md).

Sources: [Connecting](https://www.sherlock.stanford.edu/docs/getting-started/connecting/), [connection options](https://www.sherlock.stanford.edu/docs/advanced-topics/connection/), [DTNs](https://www.sherlock.stanford.edu/docs/storage/data-transfer/#data-transfer-nodes-dtns), [OpenSSH client configuration](https://man.openbsd.org/ssh_config).
