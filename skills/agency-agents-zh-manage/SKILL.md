---
name: "agency-agents-zh-manage"
description: "Use when you need to find, preview, install, remove, or sync selected roles from the agency-agents-zh library for Codex or OpenClaw without installing the full library."
---

# agency-agents-zh-manage

Use this skill to manage a small working set of roles from `agency-agents-zh`.

## When To Use

- You want to check whether a role exists before installing it.
- You want to preview a role file before exporting it.
- You want to install a few high-frequency roles into Codex or OpenClaw.
- You want to list which generated roles are already installed.
- You want to manage a small manifest of common roles.
- You need to install or update the dependency repo itself.

## Primary Entry Points

macOS / Linux:

```bash
"$SKILL_DIR/scripts/agency-agents-zh-manage.sh" --help
```

Windows:

```bat
agency-agents-zh-manage.cmd --help
```

If `AGENCY_AGENTS_ZH_MANAGE_SCRIPT` is set, prefer that launcher first. This is especially useful on Windows because the installer can point it at the `.cmd` wrapper.

## Dependency Repo

The skill resolves the `agency-agents-zh` repository in this order:

1. `--repo`
2. `AGENCY_AGENTS_REPO`
3. `./vendor/agency-agents-zh`
4. `../agency-agents-zh`
5. `~/.agency/vendor/agency-agents-zh`
6. `~/.codex/vendor/agency-agents-zh`
7. `~/.openclaw/vendor/agency-agents-zh`

Install the dependency repo:

```bash
"$SKILL_DIR/scripts/agency-agents-zh-manage.sh" repo-install
```

Update the dependency repo:

```bash
"$SKILL_DIR/scripts/agency-agents-zh-manage.sh" repo-update
```

Run diagnostics:

```bash
"$SKILL_DIR/scripts/agency-agents-zh-manage.sh" doctor
```

## Common Commands

Find a role:

```bash
"$SKILL_DIR/scripts/agency-agents-zh-manage.sh" find "software-architect"
```

Preview a role:

```bash
"$SKILL_DIR/scripts/agency-agents-zh-manage.sh" show "software-architect"
```

Interactively choose a role and action:

```bash
"$SKILL_DIR/scripts/agency-agents-zh-manage.sh" pick "software-architect"
```

Install a role into Codex:

```bash
"$SKILL_DIR/scripts/agency-agents-zh-manage.sh" codex-install "software-architect" --scope user
```

Install a role into OpenClaw:

```bash
"$SKILL_DIR/scripts/agency-agents-zh-manage.sh" openclaw-install "software-architect"
```

Sync a manifest into Codex:

```bash
"$SKILL_DIR/scripts/agency-agents-zh-manage.sh" sync --tool codex --manifest "./agents.txt" --scope user
```

List installed exports:

```bash
"$SKILL_DIR/scripts/agency-agents-zh-manage.sh" list-installed
```

## Notes

- This skill manages exported role files, not the upstream `agency-agents-zh` project itself.
- The default strategy is selective installation, not full mirroring.
- `sync` installs missing roles from the manifest; it does not delete roles that are not listed.
