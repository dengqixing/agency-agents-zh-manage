# agency-agents-zh-manage

![License](https://img.shields.io/badge/license-MIT-green)
![Type](https://img.shields.io/badge/type-agent--skill-blue)
![CLI](https://img.shields.io/badge/interface-CLI-orange)
![Platforms](https://img.shields.io/badge/platform-macOS%20%7C%20Windows-blue)

中文 | [English](#english)

---

## 中文

### 是什么

`agency-agents-zh-manage` 是一个按需管理 [`agency-agents-zh`](https://github.com/jnMetaCode/agency-agents-zh) 角色库的 skill。

它的目标是：

- 不必全量安装角色库
- 只安装你常用的角色到 Codex 或 OpenClaw
- 通过 `find / show / pick / sync` 做轻量管理
- 现在支持更完整的 `macOS` 与 `Windows` 工作流

---

### 现在支持什么

- macOS / Linux 下可直接使用 `install.sh`
- Windows 下提供 `install.ps1` 和 `.cmd` 入口
- 自动安装或更新前置依赖仓库 `agency-agents-zh`
- 主脚本内置 `repo-install` / `repo-update` / `doctor`
- 修复角色 frontmatter 解析，避免“仓库明明在，但搜不到角色”

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

先下载再运行：

```powershell
Invoke-WebRequest https://raw.githubusercontent.com/dengqixing/agency-agents-zh-manage/main/install.ps1 -OutFile install.ps1
.\install.ps1 -Tool codex
```

安装并更新依赖仓库：

```powershell
.\install.ps1 -Tool codex -UpdateRoleRepo
```

安装完成后，Windows 会自动写入：

- `AGENCY_AGENTS_REPO`
- `AGENCY_AGENTS_ZH_MANAGE_SCRIPT`

这样 Codex 后续会优先使用 `.cmd` 入口。

---

### CLI 用法

如果你在用仓库根目录的 CLI：

```bash
agency list
agency install agency-agents-zh-manage
agency list-installed
agency upgrade agency-agents-zh-manage
agency remove agency-agents-zh-manage
```

Windows 可用：

```bat
agency.cmd list
agency.cmd install agency-agents-zh-manage
```

---

### Skill 常用命令

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

同步 manifest：

```bash
"$SKILL_DIR/scripts/agency-agents-zh-manage.sh" sync --tool codex --manifest "./agents.txt" --scope user
```

---

### 依赖仓库位置

默认会优先在以下位置查找 `agency-agents-zh`：

1. `--repo`
2. `AGENCY_AGENTS_REPO`
3. `./vendor/agency-agents-zh`
4. `../agency-agents-zh`
5. `~/.agency/vendor/agency-agents-zh`
6. `~/.codex/vendor/agency-agents-zh`
7. `~/.openclaw/vendor/agency-agents-zh`

默认安装器会把依赖仓库放到：

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

### What This Is

`agency-agents-zh-manage` is a skill for managing the [`agency-agents-zh`](https://github.com/jnMetaCode/agency-agents-zh) role library on demand.

It is designed for teams or individuals who want to:

- avoid installing the full role library
- install only selected roles into Codex or OpenClaw
- manage role discovery with `find / show / pick / sync`
- use the project on both `macOS` and `Windows`

---

### What Changed

- first-class `macOS` / `Linux` install flow via `install.sh`
- first-class `Windows` install flow via `install.ps1` and `.cmd` launchers
- automatic install or update of the `agency-agents-zh` dependency repository
- new `repo-install`, `repo-update`, and `doctor` commands
- fixed role frontmatter parsing so valid roles can be discovered reliably

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

Install and refresh the dependency repo:

```bash
curl -fsSL https://raw.githubusercontent.com/dengqixing/agency-agents-zh-manage/main/install.sh | bash -s -- --tool codex --update-role-repo
```

#### Windows PowerShell

```powershell
Invoke-WebRequest https://raw.githubusercontent.com/dengqixing/agency-agents-zh-manage/main/install.ps1 -OutFile install.ps1
.\install.ps1 -Tool codex
```

Install and refresh the dependency repo:

```powershell
.\install.ps1 -Tool codex -UpdateRoleRepo
```

The Windows installer persists:

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

Install the dependency repo:

```bash
"$SKILL_DIR/scripts/agency-agents-zh-manage.sh" repo-install
```

Update the dependency repo:

```bash
"$SKILL_DIR/scripts/agency-agents-zh-manage.sh" repo-update
```

Run environment diagnostics:

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

Sync a manifest:

```bash
"$SKILL_DIR/scripts/agency-agents-zh-manage.sh" sync --tool codex --manifest "./agents.txt" --scope user
```

---

### Dependency Repo Resolution

The script resolves `agency-agents-zh` in this order:

1. `--repo`
2. `AGENCY_AGENTS_REPO`
3. `./vendor/agency-agents-zh`
4. `../agency-agents-zh`
5. `~/.agency/vendor/agency-agents-zh`
6. `~/.codex/vendor/agency-agents-zh`
7. `~/.openclaw/vendor/agency-agents-zh`

The default installer destination is:

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
