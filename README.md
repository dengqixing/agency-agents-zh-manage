# agency-agents-zh-manage

中文 | [English](#english)

`agency-agents-zh-manage` 是一个用于**按需管理 `agency-agents-zh` 角色库**的 Skill。

它适合这样的场景：

- 你不想把整个 `agency-agents-zh` 角色库一次性装进工具
- 你只想维护一小组常用角色
- 你希望通过清单（manifest）稳定管理角色集合
- 你需要同时兼容 Codex 和 OpenClaw

这个 Skill 主要提供以下能力：

- 搜索角色
- 预览角色内容
- 安装单个角色到 Codex 或 OpenClaw
- 列出已安装角色
- 删除已安装角色
- 按 manifest 同步常用角色

## 仓库内容

核心文件：

- [skills/agency-agents-zh-manage/SKILL.md](skills/agency-agents-zh-manage/SKILL.md)
- [skills/agency-agents-zh-manage/agents/openai.yaml](skills/agency-agents-zh-manage/agents/openai.yaml)
- [skills/agency-agents-zh-manage/scripts/agency-agents-zh-manage.sh](skills/agency-agents-zh-manage/scripts/agency-agents-zh-manage.sh)

## 快速开始

1. 准备本地 `agency-agents-zh` 角色库
2. 把 [skills/agency-agents-zh-manage](skills/agency-agents-zh-manage) 复制到目标 agent 的 skills 目录
3. 运行帮助命令确认脚本可用

```bash
./skills/agency-agents-zh-manage/scripts/agency-agents-zh-manage.sh --help
```

常见起步命令：

```bash
./skills/agency-agents-zh-manage/scripts/agency-agents-zh-manage.sh find "前端" --repo "/path/to/agency-agents-zh"
./skills/agency-agents-zh-manage/scripts/agency-agents-zh-manage.sh list-installed
./skills/agency-agents-zh-manage/scripts/agency-agents-zh-manage.sh codex-install "代码审查" --repo "/path/to/agency-agents-zh"
```

## 安装

### 通用 Skill 目录

把整个 [skills/agency-agents-zh-manage](skills/agency-agents-zh-manage) 目录复制到目标 agent 的 skills 目录。

### Codex

复制到：

```bash
~/.codex/skills/agency-agents-zh-manage/
```

### OpenClaw

复制到：

```bash
~/.openclaw/skills/agency-agents-zh-manage/
```

## 前提与路径解析

本仓库**不包含** `agency-agents-zh` 角色库本体。
你需要在本地准备好该角色库，脚本会按以下顺序解析仓库路径：

1. `--repo "/path/to/agency-agents-zh"`
2. `AGENCY_AGENTS_REPO`
3. `./vendor/agency-agents-zh`
4. `../agency-agents-zh`

推荐优先使用 `--repo` 或环境变量，以减少对本地目录结构的依赖。

## 用法

查看帮助：

```bash
./skills/agency-agents-zh-manage/scripts/agency-agents-zh-manage.sh --help
```

查找角色：

```bash
./skills/agency-agents-zh-manage/scripts/agency-agents-zh-manage.sh find "前端" --repo "/path/to/agency-agents-zh"
```

查看已安装角色：

```bash
./skills/agency-agents-zh-manage/scripts/agency-agents-zh-manage.sh list-installed
```

安装到 Codex：

```bash
./skills/agency-agents-zh-manage/scripts/agency-agents-zh-manage.sh codex-install "代码审查" --repo "/path/to/agency-agents-zh"
```

安装到 OpenClaw：

```bash
./skills/agency-agents-zh-manage/scripts/agency-agents-zh-manage.sh openclaw-install "安全工程师" --repo "/path/to/agency-agents-zh"
```

按清单同步：

```bash
./skills/agency-agents-zh-manage/scripts/agency-agents-zh-manage.sh sync --tool codex --manifest "./agents.txt" --repo "/path/to/agency-agents-zh"
```

## 示例清单

见 [agents.txt](agents.txt)：

```text
# 每行一个关键词或 slug
前端开发者
代码审查
安全工程师
小红书运营专家
```

## 适用场景

- 用最小安装集合维护常用角色
- 避免把完整角色库全部装入工具
- 用 manifest 管理团队或个人的稳定角色列表
- 在 Codex 和 OpenClaw 之间保持一致的角色管理方式

## Contributing

欢迎提交 issue 或 pull request。贡献说明见 [CONTRIBUTING.md](CONTRIBUTING.md)。

## Changelog

变更记录见 [CHANGELOG.md](CHANGELOG.md)。

## License

[MIT](LICENSE)

---

## English

`agency-agents-zh-manage` is a skill for managing the `agency-agents-zh` role library on demand.

It is designed for users who:

- do not want to install the full `agency-agents-zh` role library
- only want to keep a small set of frequently used roles
- want to manage a stable role set with a manifest
- need compatibility with both Codex and OpenClaw

Main capabilities:

- search roles
- preview role content
- install a single role into Codex or OpenClaw
- list installed roles
- remove installed roles
- sync common roles from a manifest

## Repository Contents

Core files:

- [skills/agency-agents-zh-manage/SKILL.md](skills/agency-agents-zh-manage/SKILL.md)
- [skills/agency-agents-zh-manage/agents/openai.yaml](skills/agency-agents-zh-manage/agents/openai.yaml)
- [skills/agency-agents-zh-manage/scripts/agency-agents-zh-manage.sh](skills/agency-agents-zh-manage/scripts/agency-agents-zh-manage.sh)

## Quick Start

1. Prepare a local copy of `agency-agents-zh`
2. Copy [skills/agency-agents-zh-manage](skills/agency-agents-zh-manage) into your target agent's skills directory
3. Run the help command to verify the script works

```bash
./skills/agency-agents-zh-manage/scripts/agency-agents-zh-manage.sh --help
```

Typical starting commands:

```bash
./skills/agency-agents-zh-manage/scripts/agency-agents-zh-manage.sh find "frontend" --repo "/path/to/agency-agents-zh"
./skills/agency-agents-zh-manage/scripts/agency-agents-zh-manage.sh list-installed
./skills/agency-agents-zh-manage/scripts/agency-agents-zh-manage.sh codex-install "code review" --repo "/path/to/agency-agents-zh"
```

## Installation

### Generic skill directory

Copy [skills/agency-agents-zh-manage](skills/agency-agents-zh-manage) into your target agent's skills directory.

### Codex

Copy to:

```bash
~/.codex/skills/agency-agents-zh-manage/
```

### OpenClaw

Copy to:

```bash
~/.openclaw/skills/agency-agents-zh-manage/
```

## Prerequisites and Repository Resolution

This repository does **not** include the `agency-agents-zh` role library itself.
You need a local copy of that repository. The script resolves it in the following order:

1. `--repo "/path/to/agency-agents-zh"`
2. `AGENCY_AGENTS_REPO`
3. `./vendor/agency-agents-zh`
4. `../agency-agents-zh`

Using `--repo` or the environment variable is recommended to avoid depending on a specific local directory layout.

## Usage

Show help:

```bash
./skills/agency-agents-zh-manage/scripts/agency-agents-zh-manage.sh --help
```

Find roles:

```bash
./skills/agency-agents-zh-manage/scripts/agency-agents-zh-manage.sh find "frontend" --repo "/path/to/agency-agents-zh"
```

List installed roles:

```bash
./skills/agency-agents-zh-manage/scripts/agency-agents-zh-manage.sh list-installed
```

Install into Codex:

```bash
./skills/agency-agents-zh-manage/scripts/agency-agents-zh-manage.sh codex-install "code review" --repo "/path/to/agency-agents-zh"
```

Install into OpenClaw:

```bash
./skills/agency-agents-zh-manage/scripts/agency-agents-zh-manage.sh openclaw-install "security engineer" --repo "/path/to/agency-agents-zh"
```

Sync from a manifest:

```bash
./skills/agency-agents-zh-manage/scripts/agency-agents-zh-manage.sh sync --tool codex --manifest "./agents.txt" --repo "/path/to/agency-agents-zh"
```

## Example Manifest

See [agents.txt](agents.txt):

```text
# one keyword or slug per line
前端开发者
代码审查
安全工程师
小红书运营专家
```

## Best Fit

- maintain a minimal set of frequently used roles
- avoid installing the full role library into your tool
- manage a stable role set with a manifest
- keep a consistent workflow across Codex and OpenClaw

## Contributing

Issues and pull requests are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for notable project changes.

## License

[MIT](LICENSE)
