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
- [skill.json](skill.json)

## Registry Metadata

本仓库包含一个轻量的 [skill.json](skill.json)，用于让其他 Agent / 工具自动识别：

- Skill 名称、版本与描述
- 脚本入口位置
- 支持的工具（Codex / OpenClaw）
- 能力标签（capabilities）
- 依赖的角色库解析方式

## 快速开始

1. 准备本地 `agency-agents-zh` 角色库
2. 把 [skills/agency-agents-zh-manage](skills/agency-agents-zh-manage) 复制到目标 agent 的 skills 目录
3. 运行帮助命令确认脚本可用

```bash
./skills/agency-agents-zh-manage/scripts/agency-agents-zh-manage.sh --help
```

## Contributing

欢迎提交 issue 或 pull request。贡献说明见 [CONTRIBUTING.md](CONTRIBUTING.md)。

## Changelog

变更记录见 [CHANGELOG.md](CHANGELOG.md)。

## License

[MIT](LICENSE)
