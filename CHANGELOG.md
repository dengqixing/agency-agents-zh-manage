# Changelog

All notable changes to this project are documented in this file.

本文档记录这个项目的重要变更。

## [Unreleased]

### Planned

- Keep upcoming changes here before the next release.

### 计划中

- 下一次发布前的变更先记录在这里。

## [0.2.0] - 2026-04-20

### Added

- Added first-class Windows support with `install.ps1`, `agency.cmd`, and `agency-agents-zh-manage.cmd`.
- Added dependency repository lifecycle commands: `repo-install`, `repo-update`, and `doctor`.
- Added installer support for installing or refreshing the `agency-agents-zh` dependency repository.
- Added mirrored Chinese and English release notes in the README.

### 新增

- 新增 Windows 一等支持，包括 `install.ps1`、`agency.cmd` 和 `agency-agents-zh-manage.cmd`。
- 新增依赖仓库生命周期命令：`repo-install`、`repo-update` 和 `doctor`。
- 新增安装器对 `agency-agents-zh` 依赖仓库的安装与更新支持。
- 新增 README 中英双语同步的发布说明。

### Changed

- Reworked the main skill script so role discovery works reliably across macOS and Windows.
- Expanded repository resolution order to include shared vendor locations under `~/.agency`, `~/.codex`, and `~/.openclaw`.
- Updated `skill.json` and `registry/skills.json` to reflect the new capabilities and release metadata.
- Aligned the README and skill documentation around the same cross-platform installation and dependency-management flow.

### 变更

- 重构主 skill 脚本，让角色搜索与导出在 macOS 和 Windows 下都更稳定。
- 扩展依赖仓库解析顺序，加入 `~/.agency`、`~/.codex` 和 `~/.openclaw` 下的共享 vendor 路径。
- 更新 `skill.json` 和 `registry/skills.json`，同步新的能力说明和版本信息。
- 对齐 README 与 skill 文档，使其围绕同一套跨平台安装和依赖管理流程。

### Fixed

- Fixed frontmatter parsing for role files so valid `name:` and `description:` fields are detected correctly.
- Fixed the CLI installer URL generation in `agency` so installs resolve the raw `install.sh` endpoint correctly.
- Fixed cross-platform command launching by providing Windows-friendly wrappers instead of assuming a Unix-only shell path.

### 修复

- 修复角色文件 frontmatter 解析问题，确保 `name:` 和 `description:` 能被正确识别。
- 修复 `agency` CLI 中安装脚本地址拼接问题，确保能正确命中原始 `install.sh` 地址。
- 修复跨平台命令启动路径问题，不再假设只存在 Unix 风格 shell 入口。

## [0.1.0] - 2026-04-18

### Added

- Initial public release of `agency-agents-zh-manage`.
- Added the skill package, registry metadata, and basic installer flow.
- Added initial README, CONTRIBUTING, and CHANGELOG documentation.

### 新增

- 发布 `agency-agents-zh-manage` 首个公开版本。
- 新增 skill 包本体、registry 元数据和基础安装流程。
- 新增 README、CONTRIBUTING 和 CHANGELOG 初始文档。

### Changed

- Clarified that this repository manages selected role installs and does not bundle the upstream `agency-agents-zh` library itself.
- Improved the README structure and project positioning for open-source use.

### 变更

- 明确说明本仓库管理的是角色的按需安装，而不是直接打包上游 `agency-agents-zh` 本体。
- 优化 README 结构和项目定位，使其更适合作为开源项目首页。
