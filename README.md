# agency-agents-zh-manage

`agency-agents-zh-manage` 是一个用于按需管理 `agency-agents-zh` 角色库的 Skill。

它的目标不是全量安装角色，而是让你只在需要时执行这些动作：

- 搜索角色
- 预览角色原文
- 安装少量高频角色到 Codex 或 OpenClaw
- 列出已安装角色
- 删除已安装角色
- 按清单同步常用角色

这个仓库现在是一个**可独立分发的 Skill 仓库**，核心内容在：

- [skills/agency-agents-zh-manage/SKILL.md](skills/agency-agents-zh-manage/SKILL.md)
- [skills/agency-agents-zh-manage/agents/openai.yaml](skills/agency-agents-zh-manage/agents/openai.yaml)
- [skills/agency-agents-zh-manage/scripts/agency-agents-zh-manage.sh](skills/agency-agents-zh-manage/scripts/agency-agents-zh-manage.sh)

## 特性

- 按关键词查找角色
- 查看最佳匹配角色原文
- 单角色安装到 Codex
- 单角色安装到 OpenClaw
- 列出已安装角色
- 删除已安装角色
- 按 manifest 批量同步常用角色

## 适用场景

- 你不想把 `agency-agents-zh` 里所有角色都装进工具
- 你只想保留少量高频角色
- 你需要用 manifest 管理一组稳定角色
- 你需要同时兼容 Codex 和 OpenClaw

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

## 前提

你需要本地有 `agency-agents-zh` 素材库，脚本会按以下顺序查找：

1. `--repo "/path/to/agency-agents-zh"`
2. `AGENCY_AGENTS_REPO`
3. `./vendor/agency-agents-zh`
4. `../agency-agents-zh`

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

## 发布建议

- 发布前确认 `gh auth status` 正常
- 发布前确认仓库中没有 `.DS_Store`
- 如果要公开发布，优先保证 skill 自包含，不依赖个人本机路径
