# GPU allocations

Reviewed: **2026-10-24**. Resource discovery runs in a **Sherlock shell**; GPU diagnostics and applications run within the corresponding allocation.

## Discover and request

```bash
sh_part
node_feat -p gpu
```

Discover other accessible partitions when relevant. Select a feature reported by `node_feat` only when the application needs that GPU model, memory size, or capability. Do not copy old hardware names from examples. An unnecessary constraint can make a request unsatisfiable or increase queue time.

Start from [the GPU template](../assets/gpu.sbatch). A GPU partition request must explicitly request GPUs, for example with `--gpus=1`; the partition name alone is insufficient. `--mem` requests host RAM, not GPU memory. Use observed GPU features to choose GPU memory requirements.

For an interactive GPU session, the **user or an agent with a persistent terminal** can run from the login shell:

```bash
salloc --partition=gpu --gpus=1 --cpus-per-task=1 --mem=4G --time=00:10:00
```

Those are illustrative resources for a short check. `sh_dev -g 1` offers a lightweight development GPU instance under the reviewed configuration. Such instances may be MIG slices; do not assume a full GPU or the memory capacity of a production allocation.

## Verify the application, not just visibility

**Allocated GPU compute shell:**

```bash
nvidia-smi -L
nvidia-smi --query-gpu=name,memory.total --format=csv,noheader
```

The template runs the query through `srun`. Successful output verifies visibility, not that the project's framework can initialize CUDA or execute a kernel. Load the chosen application environment and run its smallest real GPU check before a longer workload. Respect Slurm's device visibility; do not overwrite `CUDA_VISIBLE_DEVICES` to access unallocated devices.

The reviewed Sherlock GPU default is Exclusive Process mode. Some applications require shared mode; use the documented `--gpu_cmode=shared` option only when the application requires it. For multi-GPU/MPI work, match ranks, CPUs, GPUs, and binding to the application's launch model. Avoid conflicting per-task and per-GPU resource flags.

If allocation fails, inspect accessible partitions, requested features, QOS/queue limits, and the exact scheduler error before changing anything. Distinguish host OOM from device-memory exhaustion; increasing `--mem` alone does not increase GPU VRAM. See [troubleshooting](troubleshooting.md).

Sources: [Sherlock GPU nodes, instances, and compute modes](https://www.sherlock.stanford.edu/docs/user-guide/gpu/), [Slurm resource requests](https://slurm.schedmd.com/sbatch.html).
