# codex-multi-env

[中文说明](README.zh-CN.md)

`codex-multi-env` creates isolated Codex CLI environments on one machine by
setting a per-environment `CODEX_HOME`.

This is useful when you want to run more than one Codex CLI client on the same
computer without sharing runtime state, shell snapshots, temporary files, or
per-environment config changes.

It does not bypass Codex authentication, usage limits, or account policy. Each
environment is just a separate local `CODEX_HOME`.

## Requirements

- Bash
- Codex CLI available as `codex` on `PATH`, or set `CODEX_BIN=/path/to/codex`

Check the current terminal before creating environments:

```bash
./bin/codex-env doctor
```

## Quick Start

The recommended first setup is to create a clean isolated environment and log in
inside it. This avoids copying a broken or expired global Codex state.

```bash
./bin/codex-env doctor
./bin/codex-env init second
./bin/codex-env shell second
```

Inside the shell:

```bash
echo "$CODEX_HOME"
codex --version
codex login
codex
```

After the isolated environment has been logged in once, later sessions can use:

```bash
./bin/codex-env shell second
codex
```

## Running Two Codex Clients

Terminal 1 can use your normal Codex environment:

```bash
codex
```

Terminal 2 can use an isolated environment:

```bash
cd ~/code/codex-multi-env
./bin/codex-env init second
./bin/codex-env shell second --cd ~/code/my-project
codex login
codex
```

The first terminal uses your normal Codex home, usually `~/.codex`. The second
terminal uses:

```text
~/.codex-multi-env/envs/second/codex-home
~/.codex-multi-env/envs/second/tmp
```

Open both terminals at the same time. They will use different local
`CODEX_HOME` and temporary directories.

Run a one-shot Codex exec command:

```bash
./bin/codex-env exec second --cd ~/code/my-project -- \
  "Do not edit files. Reply with exactly: OK"
```

## Commands

```bash
./bin/codex-env init <name> [--seed] [--seed-from <dir>]
./bin/codex-env shell <name> [--cd <dir>]
./bin/codex-env exec <name> [--cd <dir>] [--sandbox <mode>] -- <prompt>
./bin/codex-env status <name>
./bin/codex-env list
./bin/codex-env doctor
```

Environment variables:

```text
CODEX_MULTI_ENV_ROOT       Root directory for envs. Default: ~/.codex-multi-env
CODEX_MULTI_ENV_SEED_FROM  Default seed CODEX_HOME. Default: ~/.codex
CODEX_BIN                  Codex CLI path. Default: first codex on PATH
```

## Doctor Checks

`doctor` checks whether the current terminal can run Codex CLI and whether the
environment root is writable:

```bash
./bin/codex-env doctor
```

Example output:

```text
program: codex-env
root: /home/user/.codex-multi-env
default_seed_from: /home/user/.codex
codex: /usr/local/bin/codex
codex_version: codex-cli 0.0.0
root_writable: yes
default_seed_exists: yes
```

If Codex is installed somewhere else:

```bash
CODEX_BIN=/path/to/codex ./bin/codex-env doctor
```

## Storage

By default, environments are stored under:

```text
~/.codex-multi-env/envs/<name>/codex-home
~/.codex-multi-env/envs/<name>/tmp
```

Override the root directory:

```bash
CODEX_MULTI_ENV_ROOT=/path/to/envs ./bin/codex-env list
```

## Seeding Auth And Config

`--seed` copies a minimal set of files from `~/.codex` into the new environment
if they exist:

- `auth.json`
- `config.toml`
- `version.json`
- `installation_id`

This is convenient, but it also copies the current state of the source Codex
home. If the source Codex home is logged out, expired, misconfigured, or broken,
the new isolated environment may inherit the same failure.

For a clean independent environment, do not use `--seed`:

```bash
./bin/codex-env init work2
./bin/codex-env shell work2
codex login
```

Use a different source:

```bash
./bin/codex-env init work2 --seed-from /path/to/existing/codex-home
```

## Safety Notes

- Each shell exports `CODEX_HOME`, `TMPDIR`, `TMP`, and `TEMP`.
- The tool does not modify your original `~/.codex`.
- The tool does not start background workers.
- The tool does not run deployment commands.
- Removing an environment is intentionally not implemented in v1.
- This does not bypass account login, usage billing, approvals, network policy,
  or Codex service-side limits.
- Do not commit real Codex homes, `auth.json`, tokens, or machine-specific
  working directories to this repository.

## Test

```bash
./tests/smoke.sh
```

The smoke test validates environment creation, status output, listing, and
doctor output. It does not invoke the real Codex CLI or access the network.
