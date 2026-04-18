# agency-agents-zh-manage

![License](https://img.shields.io/badge/license-MIT-green)
![Type](https://img.shields.io/badge/type-agent--skill-blue)
![CLI](https://img.shields.io/badge/interface-CLI-orange)
![Registry](https://img.shields.io/badge/registry-enabled-purple)

中文 | [English](#english)

---

## ⚡ 一条命令安装（推荐）

```bash
curl -fsSL https://raw.githubusercontent.com/dengqixing/agency-agents-zh-manage/main/install.sh | bash
```

---

## 🚀 CLI 使用（核心入口）

```bash
agency install agency-agents-zh-manage
agency list
```

---

## 🧩 是什么

`agency-agents-zh-manage` 是一个用于**按需管理 `agency-agents-zh` 角色库**的 Agent Skill。

👉 同时也是一个 **可被 CLI / Agent 自动发现和安装的 Skill 单元**。

---

## 🎯 适用场景

- 不想安装完整角色库
- 只使用少量高频角色
- 使用 manifest 管理角色集合
- 跨 Codex / OpenClaw 复用能力
- 团队共享角色体系

---

## 🧠 核心能力

- 搜索角色（find）
- 预览角色（show / pick）
- 安装角色（codex / openclaw）
- 查看已安装角色
- 删除角色
- manifest 同步（sync）

---

## 📦 仓库结构

```text
skills/
  agency-agents-zh-manage/
    SKILL.md
    agents/openai.yaml
    scripts/agency-agents-zh-manage.sh

install.sh
agency
skill.json
registry/skills.json
```

---

## 🧠 架构

```text
agency CLI
   ↓
registry/skills.json
   ↓
skill.json
   ↓
install.sh
```

👉 形成完整闭环：

```text
Skill + Registry + Installer + CLI
```

---

## 📥 手动安装（备用）

```bash
cp -r skills/agency-agents-zh-manage ~/.codex/skills/
```

---

## ⚠️ 前提

需要本地存在 `agency-agents-zh` 仓库。

解析顺序：

1. `--repo`
2. 环境变量
3. vendor
4. 相对路径

---

## 🤝 Contributing

👉 [CONTRIBUTING.md](CONTRIBUTING.md)

---

## 📜 Changelog

👉 [CHANGELOG.md](CHANGELOG.md)

---

## 📄 License

MIT

---

# English

## ⚡ One-line install

```bash
curl -fsSL https://raw.githubusercontent.com/dengqixing/agency-agents-zh-manage/main/install.sh | bash
```

---

## 🚀 CLI Usage

```bash
agency install agency-agents-zh-manage
agency list
```

---

## 🧩 What is this

`agency-agents-zh-manage` is an **agent skill for on-demand management of the `agency-agents-zh` role library**.

👉 It is also a **machine-discoverable and installable skill unit** designed for CLI / agent ecosystems.

---

## 🎯 Use Cases

- Avoid installing the full role library
- Maintain a minimal set of frequently used roles
- Manage roles via a manifest
- Reuse roles across Codex and OpenClaw
- Share role sets within teams

---

## 🧠 Core Capabilities

- Role search
- Role preview
- Install roles
- List installed roles
- Remove roles
- Sync via manifest

---

## 📦 Repository Structure

```text
skills/
  agency-agents-zh-manage/
    SKILL.md
    agents/openai.yaml
    scripts/agency-agents-zh-manage.sh

install.sh
agency
skill.json
registry/skills.json
```

---

## 🧠 Architecture

```text
agency CLI
   ↓
registry/skills.json
   ↓
skill.json
   ↓
install.sh
```

👉 Full pipeline:

```text
Skill + Registry + Installer + CLI
```

---

## 📥 Manual Installation

```bash
cp -r skills/agency-agents-zh-manage ~/.codex/skills/
```

---

## ⚠️ Prerequisites

Requires a local `agency-agents-zh` repository.

Resolution order:

1. `--repo`
2. env var
3. vendor
4. relative path

---

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)

---

## 📜 Changelog

See [CHANGELOG.md](CHANGELOG.md)

---

## 📄 License

MIT
