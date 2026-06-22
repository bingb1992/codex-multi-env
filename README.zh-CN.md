# codex-multi-env

[English](README.md)

`codex-multi-env` 是一个很小的 Bash 脚本工具，用来在同一台机器上创建多个相互隔离的 Codex CLI 环境。它的核心做法是为每个环境设置独立的 `CODEX_HOME`。

当你想同时打开两个 Codex CLI 客户端，并且不希望它们共享运行状态、临时文件、shell 快照或局部配置时，这个工具会有用。

它不会绕过 Codex 的登录、额度、账号策略或服务端限制。每个环境只是一个独立的本地 `CODEX_HOME`。

## 环境要求

- Bash
- 当前终端可以直接运行 `codex`，或者设置 `CODEX_BIN=/path/to/codex`

创建环境前，建议先检查当前终端：

```bash
./bin/codex-env doctor
```

## 快速开始

推荐首次使用时创建一个干净的隔离环境，然后在这个环境里单独登录。这样可以避免把全局 Codex 中已经失效或损坏的状态复制过来。

```bash
./bin/codex-env doctor
./bin/codex-env init second
./bin/codex-env shell second
```

进入 shell 后运行：

```bash
echo "$CODEX_HOME"
codex --version
codex login
codex
```

这个隔离环境登录过一次之后，以后可以直接这样启动：

```bash
./bin/codex-env shell second
codex
```

## 同时运行两个 Codex

终端 1 使用正常的全局 Codex 环境：

```bash
codex
```

终端 2 使用隔离环境：

```bash
cd ~/code/codex-multi-env
./bin/codex-env init second
./bin/codex-env shell second --cd ~/code/my-project
codex login
codex
```

终端 1 通常使用默认的 `~/.codex`。终端 2 使用：

```text
~/.codex-multi-env/envs/second/codex-home
~/.codex-multi-env/envs/second/tmp
```

这两个终端可以同时打开，它们会使用不同的 `CODEX_HOME` 和临时目录。

也可以直接运行一次性 `codex exec`：

```bash
./bin/codex-env exec second --cd ~/code/my-project -- \
  "Do not edit files. Reply with exactly: OK"
```

## 命令

```bash
./bin/codex-env init <name> [--seed] [--seed-from <dir>]
./bin/codex-env shell <name> [--cd <dir>]
./bin/codex-env exec <name> [--cd <dir>] [--sandbox <mode>] -- <prompt>
./bin/codex-env status <name>
./bin/codex-env list
./bin/codex-env doctor
```

环境变量：

```text
CODEX_MULTI_ENV_ROOT       环境存储根目录，默认是 ~/.codex-multi-env
CODEX_MULTI_ENV_SEED_FROM  默认复制来源，默认是 ~/.codex
CODEX_BIN                  Codex CLI 路径，默认使用 PATH 中的 codex
```

## doctor 检查

`doctor` 会检查当前终端是否能运行 Codex CLI，以及环境根目录是否可写：

```bash
./bin/codex-env doctor
```

示例输出：

```text
program: codex-env
root: /home/user/.codex-multi-env
default_seed_from: /home/user/.codex
codex: /usr/local/bin/codex
codex_version: codex-cli 0.0.0
root_writable: yes
default_seed_exists: yes
```

如果 Codex 安装在其他位置：

```bash
CODEX_BIN=/path/to/codex ./bin/codex-env doctor
```

## 存储位置

默认情况下，环境会存储在：

```text
~/.codex-multi-env/envs/<name>/codex-home
~/.codex-multi-env/envs/<name>/tmp
```

可以通过环境变量改根目录：

```bash
CODEX_MULTI_ENV_ROOT=/path/to/envs ./bin/codex-env list
```

## 关于 --seed

`--seed` 会从 `~/.codex` 复制一组最小文件到新环境中，前提是这些文件存在：

- `auth.json`
- `config.toml`
- `version.json`
- `installation_id`

这很方便，但它也会复制来源 Codex home 的当前状态。如果来源环境已经登出、登录过期、配置错误或处于损坏状态，新环境也可能继承同样的问题。

如果你想要一个干净且独立的环境，不要使用 `--seed`：

```bash
./bin/codex-env init work2
./bin/codex-env shell work2
codex login
```

也可以指定其他复制来源：

```bash
./bin/codex-env init work2 --seed-from /path/to/existing/codex-home
```

## 安全说明

- 每个 shell 会导出 `CODEX_HOME`、`TMPDIR`、`TMP` 和 `TEMP`。
- 这个工具不会修改原始的 `~/.codex`。
- 这个工具不会启动后台 worker。
- 这个工具不会执行部署命令。
- v1 中有意没有实现删除环境的命令。
- 这个工具不会绕过账号登录、用量计费、审批、网络策略或 Codex 服务端限制。
- 不要把真实的 Codex home、`auth.json`、token 或本机专属工作目录提交到这个仓库。

## 测试

```bash
./tests/smoke.sh
```

smoke test 会验证环境创建、状态输出、列表输出和 doctor 输出。它不会调用真实的 Codex CLI，也不会访问网络。
