# Software environments

Reviewed: **2026-10-24**. Discovery can run in a **Sherlock login shell**. Run compilation, dependency installation that may compile code, and application tests inside a **compute allocation**.

## Discover before installing

```bash
module spider python
module keyword numpy
module list
```

Use `module spider PACKAGE` to discover versions and prerequisite categories, including modules not currently visible in `module avail`. Follow the returned loading instructions instead of assuming a category. `ml` is the Lmod shorthand. Select exact installed versions for reproducible job scripts; historical documentation examples are not an inventory.

Honor the project's existing lockfiles, environment definitions, and build instructions. Prefer an available suitable module before building another copy. Do not replace an existing Conda/container workflow with venv simply because this reference uses it as an example.

## Python environment

Use a persistent, user-specific, writable environment directory, preferably under `$GROUP_HOME` when available. A small individual environment can live under `$HOME` after checking quota. Do not install reusable environments into node-local scratch or copy a workstation's virtual environment to Sherlock.

In the following **compute-shell example**, replace `python/SELECTED_VERSION` with an exact version found above. Choose the persistent environment path for the project before running:

```bash
module load python/SELECTED_VERSION
project_dir="${SCRATCH:?}/my-project"
env_dir="${GROUP_HOME:?Choose an available persistent location}/$USER/envs/my-project"
mkdir -p "$(dirname "$env_dir")"
python3 -m venv "$env_dir"
source "$env_dir/bin/activate"
python3 -m pip install -r "$project_dir/requirements.txt"
python3 -c 'import sys; print(sys.executable); print(sys.version)'
```

This is a new-environment example. Inspect an existing environment before reusing or modifying it. Use the project's actual dependency file or lockfile. Run `python3 -m pip` against the selected interpreter; do not rely on an unrelated system `pip`. Package modules can load their matching Python automatically; inspect them before mixing incompatible interpreter/module stacks. Use venv's system-site-packages option only when intentionally consuming compatible module-provided packages.

Add the selected module and environment activation to the batch script, after the directives, for example:

```bash
module load python/SELECTED_VERSION
source "$GROUP_HOME/$USER/envs/my-project/bin/activate"
export PYTHONUNBUFFERED=1
srun python3 -u main.py
```

Replace the module and path consistently with the validated environment. The working directory and staged inputs come from the job setup. Unbuffered output helps when diagnosing apparently missing logs. Check required imports in the allocation before a long run; GPU frameworks need an allocated-GPU check too.

## Builds and other environments

Load discovered compiler/library modules first. Build on a compute node, cap parallelism to allocated CPUs, and install with an explicit prefix on persistent shared storage. Avoid `sudo`, system-wide installation paths, and using the whole physical node's core count when the allocation is smaller. Record compiler/module versions with the project.

For R, MPI, Conda, Apptainer, or specialized applications, follow the project's setup and the relevant Sherlock guide rather than inventing application defaults. Module loads in a previous SSH invocation do not persist into a later one; use a login shell or initialize the environment within the script as described in [access](access.md).

Sources: [Modules](https://www.sherlock.stanford.edu/docs/software/modules/), [Python](https://www.sherlock.stanford.edu/docs/software/using/python/), [software installation](https://www.sherlock.stanford.edu/docs/software/install/), [software guides](https://www.sherlock.stanford.edu/docs/software/), [Python venv](https://docs.python.org/3/library/venv.html).
