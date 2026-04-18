# Skill Registry (Prototype)

本仓库同时作为一个**最小可用的 Skill Registry 原型**。

## registry/skills.json

这是一个可被 Agent / CLI 自动读取的索引文件，包含：

- Skill 列表
- 每个 Skill 的仓库地址
- 版本号
- 安装方式
- 能力描述

示例：

```json
{
  "skills": [
    {
      "name": "agency-agents-zh-manage",
      "repo": "https://github.com/dengqixing/agency-agents-zh-manage",
      "version": "0.1.0"
    }
  ]
}
```

## 自动安装协议（约定）

Agent 或 CLI 可以按以下流程自动安装 Skill：

### 1. 获取 registry

```bash
curl -s https://raw.githubusercontent.com/dengqixing/agency-agents-zh-manage/main/registry/skills.json
```

### 2. 查找 skill

按 `slug` 或 `name` 匹配目标 Skill

### 3. 克隆仓库

```bash
git clone https://github.com/dengqixing/agency-agents-zh-manage
```

### 4. 安装 skill

```bash
cp -r skills/agency-agents-zh-manage ~/.codex/skills/
# 或
cp -r skills/agency-agents-zh-manage ~/.openclaw/skills/
```

## 演进方向

后续可以扩展：

- 多仓库 registry（聚合多个 Skill）
- 版本选择（v0.1.0 / latest）
- CLI 工具（agency install xxx）
- 企业内部 Skill 市场

---

这个文件的目标不是“完美设计”，而是提供一个**可运行的最小标准**，让生态可以逐步演进。
