---
name: "agency-agents-zh-manage"
description: "Use when the task is to manage the `agency-agents-zh` role library without full installation, including finding roles, previewing role content, listing installed roles, installing or removing selected roles for Codex or OpenClaw, and syncing a small manifest of common roles."
---

# agency-agents-zh-manage

按需管理 `agency-agents-zh` 角色库，不做全量安装。

## 何时使用

- 需要搜索某个角色是否存在
- 需要查看角色原文再决定是否安装
- 需要把少量高频角色安装到 Codex 或 OpenClaw
- 需要列出已安装角色
- 需要删除某个已安装角色
- 需要按清单同步一小批常用角色

## 入口脚本

优先使用 skill 自带入口：

```bash
"$SKILL_DIR/scripts/agency-agents-zh-manage.sh" --help
```

这个入口会按顺序尝试找到实际脚本：

1. `AGENCY_AGENTS_ZH_MANAGE_SCRIPT`
2. 当前 skill 目录内的 `scripts/agency-agents-zh-manage.sh`

默认情况下，这个 skill 已经自包含，不依赖仓库根目录脚本，也不依赖本机 `~/.codex/tools` 或 `~/.openclaw/tools`。

## 前置检查

先确认 `agency-agents-zh` 素材库位置。优先顺序：

1. `--repo "/path/to/agency-agents-zh"`
2. `AGENCY_AGENTS_REPO`
3. `./vendor/agency-agents-zh`
4. `../agency-agents-zh`

如果角色库不存在，先定位仓库，再执行后续命令。

## 推荐工作流

1. 先 `find` 或 `pick`，不要全量安装。
2. 低频角色只 `show` 或临时导出。
3. 高频角色再执行 `codex-install` 或 `openclaw-install`。
4. 常用集合用 `sync --manifest` 管理。
5. 删除操作默认需要确认；非交互环境要传 `--yes`。

## 常用命令

查看帮助：

```bash
"$SKILL_DIR/scripts/agency-agents-zh-manage.sh" --help
```

搜索角色：

```bash
"$SKILL_DIR/scripts/agency-agents-zh-manage.sh" find "前端" --repo "/path/to/agency-agents-zh"
```

交互式选角色并执行动作：

```bash
"$SKILL_DIR/scripts/agency-agents-zh-manage.sh" pick "前端" --repo "/path/to/agency-agents-zh"
```

查看已安装角色：

```bash
"$SKILL_DIR/scripts/agency-agents-zh-manage.sh" list-installed
```

安装到 Codex：

```bash
"$SKILL_DIR/scripts/agency-agents-zh-manage.sh" codex-install "代码审查" --repo "/path/to/agency-agents-zh"
```

安装到 OpenClaw：

```bash
"$SKILL_DIR/scripts/agency-agents-zh-manage.sh" openclaw-install "安全工程师" --repo "/path/to/agency-agents-zh"
```

按清单同步：

```bash
"$SKILL_DIR/scripts/agency-agents-zh-manage.sh" sync --tool codex --manifest "./agents.txt" --repo "/path/to/agency-agents-zh"
```

## 适配建议

- 对支持 Skill/Command 的 agent，直接安装整个 `skills/agency-agents-zh-manage/` 目录。
- 对不支持 Skill 目录但支持 shell 的 agent，直接调用根脚本即可。
- 对 Codex/OpenClaw，优先把脚本放到各自工具目录，再通过 skill 入口调用。

## 边界

- 这个 skill 管的是“角色安装与选择”，不是 `agency-agents-zh` 本体。
- 默认策略是少装、按需装，不做全量覆盖。
- `sync` 只增量安装，不删除未列出的角色。
