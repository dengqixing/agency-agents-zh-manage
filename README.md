# agency-agents-zh-manage

中文 | [English](#english)

`agency-agents-zh-manage` 是一个用于**按需管理 `agency-agents-zh` 角色库**的 Skill。

它适合这样的场景：

- 不想把整个 `agency-agents-zh` 角色库一次性装进工具
- 只维护一小组高频角色
- 用 manifest（清单）管理稳定角色集合
- 同时兼容 Codex 和 OpenClaw

## 核心能力

- 搜索角色（find）
- 预览角色内容（show / pick）
- 安装角色（codex / openclaw）
- 查看已安装角色
- 删除角色
- 按 manifest 同步角色

---

## 📦 仓库结构

核心文件：

- `skills/agency-agents-zh-manage/SKILL.md`
- `skills/agency-agents-zh-manage/agents/openai.yaml`
- `skills/agency-agents-zh-manage/scripts/agency-agents-zh-manage.sh`
- `skill.json`（机器可读元数据）
- `registry/skills.json`（registry 原型）

---

## 🚀 快速开始

```bash
./skills/agency-agents-zh-manage/scripts/agency-agents-zh-manage.sh --help
```

示例：

```bash
# 搜索角色
./skills/.../agency-agents-zh-manage.sh find "前端"

# 安装到 Codex
./skills/.../agency-agents-zh-manage.sh codex-install "代码审查"
```

---

## 🧠 Registry Metadata

本仓库提供：

- `skill.json` → Skill 描述（单体）
- `registry/skills.json` → Skill 索引（聚合）

👉 Agent / CLI 可以自动发现并安装 Skill，而不依赖 README。

---

## 📥 安装

```bash
cp -r skills/agency-agents-zh-manage ~/.codex/skills/
# 或
cp -r skills/agency-agents-zh-manage ~/.openclaw/skills/
```

---

## ⚠️ 前提

本仓库 **不包含** `agency-agents-zh` 角色库。

路径解析优先级：

1. `--repo`
2. `AGENCY_AGENTS_REPO`
3. `./vendor/agency-agents-zh`
4. `../agency-agents-zh`

---

## 🤝 Contributing

👉 见 [CONTRIBUTING.md](CONTRIBUTING.md)

---

## 📜 Changelog

👉 见 [CHANGELOG.md](CHANGELOG.md)

---

## 📄 License

MIT

---

# English

`agency-agents-zh-manage` is a lightweight skill for **on-demand management of the `agency-agents-zh` role library**.

## Use Cases

- Avoid installing the full role library
- Maintain a minimal set of frequently used roles
- Manage roles via a manifest
- Work across Codex and OpenClaw

---

## Core Capabilities

- Search roles
- Preview role content
- Install roles into Codex / OpenClaw
- List installed roles
- Remove roles
- Sync roles from a manifest

---

## Repository Structure

- `SKILL.md` → behavior & usage
- `openai.yaml` → agent interface
- `script` → execution entry
- `skill.json` → machine-readable metadata
- `registry/skills.json` → registry index

---

## Quick Start

```bash
./skills/.../agency-agents-zh-manage.sh --help
```

---

## Registry Metadata

This repository includes:

- `skill.json` → defines the skill
- `registry/skills.json` → enables discovery

👉 Allows automatic discovery and installation by agents

---

## Installation

```bash
cp -r skills/agency-agents-zh-manage ~/.codex/skills/
```

---

## Prerequisites

Requires a local `agency-agents-zh` repository.

Resolution order:

1. `--repo`
2. env var
3. local vendor
4. relative path

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)

---

## Changelog

See [CHANGELOG.md](CHANGELOG.md)

---

## License

MIT
