# agency-agents-zh-manage

![License](https://img.shields.io/badge/license-MIT-green)
![Type](https://img.shields.io/badge/type-agent--skill-blue)
![CLI](https://img.shields.io/badge/interface-CLI-orange)
![Platforms](https://img.shields.io/badge/platform-macOS%20%7C%20Windows-blue)

中文 | [English](#english)

---

## 中文

### 项目简介

`agency-agents-zh-manage` 是一个用于按需管理 [`agency-agents-zh`](https://github.com/jnMetaCode/agency-agents-zh) 角色库的 skill。

它适合这些场景：

- 不想全量安装整个角色库
- 只想把少量常用角色安装到 Codex 或 OpenClaw
- 想用 `find / show / pick / sync` 做轻量管理
- 需要兼顾 `macOS` 和 `Windows` 的使用环境

---

### 当前能力

- 提供 `macOS / Linux` 安装入口 `install.sh`
- 提供 `Windows` 安装入口 `install.ps1`
- 提供 `Windows` 命令包装入口 `.cmd`
- 支持安装或更新依赖仓库 `agency-agents-zh`
- 提供 `repo-install`、`repo-update`、`doctor`
- 支持角色搜索、预览、导出、安装、删除、清单同步

---

### Changelog

当前版本：`v0.2.0`

最新版本摘要：

- 新增 Windows 安装器 `install.ps1` 和 `.cmd` 入口
- 新增 `repo-install`、`repo-update`、`doctor`
- 新增依赖仓库 `agency-agents-zh` 的安装和更新流程
- 修复角色 frontmatter 解析与跨平台启动问题

完整变更请见 [CHANGELOG.md](./CHANGELOG.md)。

---

### 快速安装

#### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/dengqixing/agency-agents-zh-manage/main/install.sh | bash
```

安装到 Codex：

```bash
curl -fsSL https://raw.githubusercontent.com/dengqixing/agency-agents-zh-manage/main/install.sh | bash -s -- --tool codex
```

安装并更新依赖仓库：

```bash
curl -fsSL https://raw.githubusercontent.com/dengqixing/agency-agents-zh-manage/main/install.sh | bash -s -- --tool codex --update-role-repo
```

#### Windows PowerShell

```powershell
Invoke-WebRequest https://raw.githubusercontent.com/dengqixing/agency-agents-zh-manage/main/install.ps1 -OutFile install.ps1
.\install.ps1 -Tool codex
```

安装并更新依赖仓库：

```powershell
.\install.ps1 -Tool codex -UpdateRoleRepo
```

安装完成后，Windows 安装器会写入：

- `AGENCY_AGENTS_REPO`
- `AGENCY_AGENTS_ZH_MANAGE_SCRIPT`

这样后续 Codex 会优先使用 `.cmd` 包装入口。

---

### CLI 用法

仓库级 CLI：

```bash
agency list
agency install agency-agents-zh-manage
agency list-installed
agency upgrade agency-agents-zh-manage
agency remove agency-agents-zh-manage
```

Windows：

```bat
agency.cmd list
agency.cmd install agency-agents-zh-manage
```

---

### Skill 命令

查看帮助：

```bash
"$SKILL_DIR/scripts/agency-agents-zh-manage.sh" --help
```

Windows：

```bat
agency-agents-zh-manage.cmd --help
```

安装依赖仓库：

```bash
"$SKILL_DIR/scripts/agency-agents-zh-manage.sh" repo-install
```

更新依赖仓库：

```bash
"$SKILL_DIR/scripts/agency-agents-zh-manage.sh" repo-update
```

环境检查：

```bash
"$SKILL_DIR/scripts/agency-agents-zh-manage.sh" doctor
```

搜索角色：

```bash
"$SKILL_DIR/scripts/agency-agents-zh-manage.sh" find "software-architect"
```

安装到 Codex：

```bash
"$SKILL_DIR/scripts/agency-agents-zh-manage.sh" codex-install "software-architect" --scope user
```

按清单同步：

```bash
"$SKILL_DIR/scripts/agency-agents-zh-manage.sh" sync --tool codex --manifest "./agents.txt" --scope user
```

---

### 依赖仓库解析顺序

脚本会按以下顺序查找 `agency-agents-zh`：

1. `--repo`
2. `AGENCY_AGENTS_REPO`
3. `./vendor/agency-agents-zh`
4. `../agency-agents-zh`
5. `~/.agency/vendor/agency-agents-zh`
6. `~/.codex/vendor/agency-agents-zh`
7. `~/.openclaw/vendor/agency-agents-zh`

默认安装位置：

```text
~/.agency/vendor/agency-agents-zh
```

---

### 仓库结构

```text
skills/
  agency-agents-zh-manage/
    SKILL.md
    agents/openai.yaml
    scripts/
      agency-agents-zh-manage.sh
      agency-agents-zh-manage.cmd

agency
agency.cmd
install.sh
install.ps1
skill.json
registry/skills.json
```

---

### License

MIT

---

# English

### Overview

`agency-agents-zh-manage` is a skill for managing the [`agency-agents-zh`](https://github.com/jnMetaCode/agency-agents-zh) role library on demand.

It is a good fit when you want to:

- avoid installing the full role library
- install only a small set of roles into Codex or OpenClaw
- manage roles through `find / show / pick / sync`
- support both `macOS` and `Windows`

---

### Current Capabilities

- provides the `macOS / Linux` installer `install.sh`
- provides the `Windows` installer `install.ps1`
- provides `.cmd` launchers for Windows
- installs or updates the `agency-agents-zh` dependency repository
- includes `repo-install`, `repo-update`, and `doctor`
- supports role search, preview, export, install, removal, and manifest sync

---

### Changelog

Current version: `v0.2.0`

Latest release highlights:

- added the Windows installer `install.ps1` and `.cmd` launchers
- added `repo-install`, `repo-update`, and `doctor`
- added install and update flows for the `agency-agents-zh` dependency repository
- fixed role frontmatter parsing and cross-platform launch behavior

See [CHANGELOG.md](./CHANGELOG.md) for the full history.

---

### Quick Install

#### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/dengqixing/agency-agents-zh-manage/main/install.sh | bash
```

Install for Codex:

```bash
curl -fsSL https://raw.githubusercontent.com/dengqixing/agency-agents-zh-manage/main/install.sh | bash -s -- --tool codex
```

Install and update the dependency repository:

```bash
curl -fsSL https://raw.githubusercontent.com/dengqixing/agency-agents-zh-manage/main/install.sh | bash -s -- --tool codex --update-role-repo
```

#### Windows PowerShell

```powershell
Invoke-WebRequest https://raw.githubusercontent.com/dengqixing/agency-agents-zh-manage/main/install.ps1 -OutFile install.ps1
.\install.ps1 -Tool codex
```

Install and update the dependency repository:

```powershell
.\install.ps1 -Tool codex -UpdateRoleRepo
```

After installation, the Windows installer persists:

- `AGENCY_AGENTS_REPO`
- `AGENCY_AGENTS_ZH_MANAGE_SCRIPT`

This lets Codex prefer the `.cmd` launcher in later sessions.

---

### CLI Usage

Repository-level CLI:

```bash
agency list
agency install agency-agents-zh-manage
agency list-installed
agency upgrade agency-agents-zh-manage
agency remove agency-agents-zh-manage
```

Windows:

```bat
agency.cmd list
agency.cmd install agency-agents-zh-manage
```

---

### Skill Commands

Show help:

```bash
"$SKILL_DIR/scripts/agency-agents-zh-manage.sh" --help
```

Windows:

```bat
agency-agents-zh-manage.cmd --help
```

Install the dependency repository:

```bash
"$SKILL_DIR/scripts/agency-agents-zh-manage.sh" repo-install
```

Update the dependency repository:

```bash
"$SKILL_DIR/scripts/agency-agents-zh-manage.sh" repo-update
```

Run diagnostics:

```bash
"$SKILL_DIR/scripts/agency-agents-zh-manage.sh" doctor
```

Find a role:

```bash
"$SKILL_DIR/scripts/agency-agents-zh-manage.sh" find "software-architect"
```

Install a role into Codex:

```bash
"$SKILL_DIR/scripts/agency-agents-zh-manage.sh" codex-install "software-architect" --scope user
```

Sync from a manifest:

```bash
"$SKILL_DIR/scripts/agency-agents-zh-manage.sh" sync --tool codex --manifest "./agents.txt" --scope user
```

---

### Dependency Repository Resolution

The script resolves `agency-agents-zh` in this order:

1. `--repo`
2. `AGENCY_AGENTS_REPO`
3. `./vendor/agency-agents-zh`
4. `../agency-agents-zh`
5. `~/.agency/vendor/agency-agents-zh`
6. `~/.codex/vendor/agency-agents-zh`
7. `~/.openclaw/vendor/agency-agents-zh`

Default installation location:

```text
~/.agency/vendor/agency-agents-zh
```

---

### Repository Layout

```text
skills/
  agency-agents-zh-manage/
    SKILL.md
    agents/openai.yaml
    scripts/
      agency-agents-zh-manage.sh
      agency-agents-zh-manage.cmd

agency
agency.cmd
install.sh
install.ps1
skill.json
registry/skills.json
```

---

### License

MIT
