# Running Two Codex CLI Environments

Terminal 1 can use your normal Codex environment:

```bash
codex
```

Terminal 2 can use an isolated environment with a separate `CODEX_HOME`:

```bash
cd ~/code/codex-multi-env
./bin/codex-env doctor
./bin/codex-env init second
./bin/codex-env shell second --cd ~/code/my-project
codex login
codex
```

After logging in once, later sessions can skip `codex login`:

```bash
cd ~/code/codex-multi-env
./bin/codex-env shell second --cd ~/code/my-project
codex
```

Or use one-shot exec:

```bash
./bin/codex-env exec second --cd ~/code/my-project -- \
  "Do not edit files. Summarize the current repository in 5 bullet points."
```

If you explicitly want to copy an existing Codex home:

```bash
./bin/codex-env init second --seed
```

`--seed` copies files such as `auth.json` and `config.toml` from the source
Codex home. If that source is logged out, expired, misconfigured, or broken, the
new environment may inherit the same failure.

The second shell uses:

```text
CODEX_HOME=~/.codex-multi-env/envs/second/codex-home
TMPDIR=~/.codex-multi-env/envs/second/tmp
```

Your original `~/.codex` is not modified.
