# Agents running on Sherlock

Reviewed: **2026-10-24**. The same skill can be installed on the workstation or in the cluster environment; it does not require launching another agent to use it.

## Start in a compute allocation

The user connects to Sherlock and runs `sh_dev` from the login shell before starting substantial agent activity. An already running agent on a login node may perform lightweight discovery/submission, then use an allocated persistent terminal or a batch job for computation. If its tools cannot follow an interactive allocation, explain the available handoff rather than claiming the agent moved to a compute node.

**Allocated compute shell, discover the chosen agent:**

```bash
module spider codex
```

Use the chosen package name, such as `claude-code`, when appropriate. Load an available module using its reported prerequisites/version and follow that vendor's current authentication instructions. The Sherlock login credentials and agent-provider credentials serve different systems. Do not copy vendor configuration examples from dated documentation without verifying current syntax.

Honor the user's chosen agent/provider. Most cloud-backed agents send supplied prompts and code outside the cluster. Keep secrets out of chat and versioned files, and follow the user's data handling requirements before supplying project content to an external provider. This skill does not change provider settings or set up a model service by default.

Install the skill directory where the chosen agent discovers skills on Sherlock. Store the skill's code on a persistent shared filesystem. A symlink to a workstation-only path will not work on a compute node. Run research I/O from scratch even when the skill and source repository live in persistent storage.

## Reconnect and resume

Record the project path, allocation/job ID, and node. Verify that the job is still running before reconnecting to a compute node through a login node. A compute-node SSH session requires an active job there. Do not create an SSH server, including one inside a container, to enable remote development.

For interactive agent continuity, use the vendor's current resume mechanism and a supported persistent terminal workflow. A tmux session on one load-balanced login node will not appear on another; a live multiplexed connection retains the same node. Account for allocation expiry: it can end the agent process, while an independent submitted batch job can continue.

## Specialized workflows

- [Sherlock coding agents](https://www.sherlock.stanford.edu/docs/software/ai/coding-agents/) describes available modules and usage.
- [Remote development](https://www.sherlock.stanford.edu/docs/software/ai/remote-dev/) describes editor access and SSH tunnels to allocated services.
- [Ollama](https://www.sherlock.stanford.edu/docs/software/using/ollama/) describes a local model service under Slurm. Discover the current job endpoint; do not assume an old node or port is still valid.
- Use [official Codex documentation](https://developers.openai.com/codex/) or the selected vendor's documentation for current CLI flags and authentication.

These links are conditional references. Set up editors, tunnels, containers, or model services only when relevant to the requested work.
