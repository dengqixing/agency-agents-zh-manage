#!/usr/bin/env bash
set -euo pipefail

REPO_OWNER="dengqixing"
REPO_NAME="agency-agents-zh-manage"
DEFAULT_BRANCH="main"
SKILL_SLUG="agency-agents-zh-manage"
SKILL_SOURCE_PATH="skills/${SKILL_SLUG}"
ROLE_REPO_URL_DEFAULT="https://github.com/jnMetaCode/agency-agents-zh.git"
ROLE_REPO_REF_DEFAULT="main"

TOOL="auto"
DEST=""
BRANCH="${DEFAULT_BRANCH}"
FORCE_YES="0"
ROLE_REPO_DEST="${HOME}/.agency/vendor/agency-agents-zh"
ROLE_REPO_URL="${ROLE_REPO_URL_DEFAULT}"
ROLE_REPO_REF="${ROLE_REPO_REF_DEFAULT}"
SKIP_ROLE_REPO="0"
UPDATE_ROLE_REPO="0"

usage() {
  cat <<EOF
Install ${SKILL_SLUG} for Codex or OpenClaw.

Usage:
  bash install.sh [--tool codex|openclaw|auto] [--dest <dir>] [--branch <branch>] [--yes]
                  [--role-repo-dest <dir>] [--role-repo-url <url>] [--role-repo-ref <ref>]
                  [--skip-role-repo] [--update-role-repo]

Examples:
  bash install.sh --tool codex
  bash install.sh --tool codex --update-role-repo
  curl -fsSL https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${DEFAULT_BRANCH}/install.sh | bash -s -- --tool codex

Options:
  --tool              Target tool: codex, openclaw, or auto
  --dest              Custom skill installation directory
  --branch            Git branch to download from
  --role-repo-dest    Where to install the agency-agents-zh dependency repository
  --role-repo-url     Override the dependency repository URL
  --role-repo-ref     Branch or ref for the dependency repository
  --skip-role-repo    Install only the skill, not the dependency repository
  --update-role-repo  Refresh the dependency repository if it already exists
  --yes               Skip confirmation prompts
  -h, --help          Show help
EOF
}

err() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

note() {
  printf '%s\n' "$*" >&2
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || err "Missing command: $1"
}

is_windows() {
  case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*) return 0 ;;
    *) return 1 ;;
  esac
}

resolve_tool() {
  if [[ "$TOOL" != "auto" ]]; then
    printf '%s\n' "$TOOL"
    return 0
  fi

  if [[ -d "${HOME}/.codex" || -d "${HOME}/.codex/skills" ]]; then
    printf 'codex\n'
    return 0
  fi

  if [[ -d "${HOME}/.openclaw" || -d "${HOME}/.openclaw/skills" ]]; then
    printf 'openclaw\n'
    return 0
  fi

  err "Unable to detect the target tool automatically. Pass --tool codex or --tool openclaw."
}

resolve_dest() {
  local tool="$1"

  if [[ -n "$DEST" ]]; then
    printf '%s\n' "$DEST"
    return 0
  fi

  case "$tool" in
    codex) printf '%s\n' "${HOME}/.codex/skills/${SKILL_SLUG}" ;;
    openclaw) printf '%s\n' "${HOME}/.openclaw/skills/${SKILL_SLUG}" ;;
    *) err "Unsupported tool: $tool" ;;
  esac
}

confirm_install() {
  local tool="$1"
  local dest="$2"

  if [[ "$FORCE_YES" == "1" || ! -t 0 ]]; then
    return 0
  fi

  printf 'Install %s to %s for %s? [Y/n] ' "$SKILL_SLUG" "$dest" "$tool" >&2
  local reply=""
  IFS= read -r reply || true
  reply="${reply:-Y}"
  case "$reply" in
    Y|y|yes|YES|'')
      return 0
      ;;
    *)
      err "Installation cancelled"
      ;;
  esac
}

normalize_repo_url() {
  printf '%s\n' "${1%.git}"
}

repo_archive_url() {
  local normalized=""
  local suffix=""

  normalized="$(normalize_repo_url "$1")"
  case "$normalized" in
    https://github.com/*/*)
      suffix="${normalized#https://github.com/}"
      ;;
    git@github.com:*)
      suffix="${normalized#git@github.com:}"
      ;;
    *)
      err "Unsupported GitHub repository URL: $1"
      ;;
  esac

  printf 'https://codeload.github.com/%s/tar.gz/refs/heads/%s\n' "$suffix" "$2"
}

replace_directory() {
  local source="$1"
  local dest="$2"

  [[ -n "$dest" && "$dest" != "/" ]] || err "Refusing to overwrite an invalid destination"
  mkdir -p "$(dirname "$dest")"
  rm -rf "$dest"
  mv "$source" "$dest"
}

download_repo_snapshot() {
  local repo_url="$1"
  local repo_ref="$2"
  local dest="$3"
  local tmp_root=""
  local archive_file=""
  local unpacked_root=""
  local repo_basename=""

  require_cmd curl
  require_cmd tar

  tmp_root="$(mktemp -d)"
  archive_file="${tmp_root}/repo.tar.gz"
  curl -fsSL "$(repo_archive_url "$repo_url" "$repo_ref")" -o "$archive_file"
  tar -xzf "$archive_file" -C "$tmp_root"

  repo_basename="$(basename "$(normalize_repo_url "$repo_url")")"
  unpacked_root="${tmp_root}/${repo_basename}-${repo_ref}"
  [[ -d "$unpacked_root" ]] || err "Unable to unpack ${repo_url}@${repo_ref}"

  replace_directory "$unpacked_root" "$dest"
  rm -rf "$tmp_root"
}

install_or_update_role_repo() {
  local dest="$1"
  local repo_url="$2"
  local repo_ref="$3"

  if [[ ! -d "$dest" ]]; then
    if command -v git >/dev/null 2>&1; then
      note "Cloning dependency repository to ${dest}"
      mkdir -p "$(dirname "$dest")"
      git clone --depth 1 --branch "$repo_ref" "$repo_url" "$dest"
    else
      note "git not found; downloading a snapshot of the dependency repository"
      download_repo_snapshot "$repo_url" "$repo_ref" "$dest"
    fi
    return 0
  fi

  if [[ "$UPDATE_ROLE_REPO" != "1" ]]; then
    note "Dependency repository already exists: ${dest}"
    return 0
  fi

  if [[ -d "${dest}/.git" ]] && command -v git >/dev/null 2>&1; then
    note "Updating dependency repository in ${dest}"
    git -C "$dest" remote set-url origin "$repo_url"
    git -C "$dest" fetch --depth 1 origin "$repo_ref"
    git -C "$dest" checkout -B "$repo_ref" FETCH_HEAD >/dev/null 2>&1
  else
    note "Refreshing dependency repository from a snapshot"
    download_repo_snapshot "$repo_url" "$repo_ref" "$dest"
  fi
}

download_and_install_skill() {
  local tool="$1"
  local dest="$2"
  local archive_url="https://codeload.github.com/${REPO_OWNER}/${REPO_NAME}/tar.gz/refs/heads/${BRANCH}"
  local tmp_root=""
  local archive_file=""
  local extracted_root=""
  local source_dir=""

  require_cmd curl
  require_cmd tar

  tmp_root="$(mktemp -d)"
  archive_file="${tmp_root}/repo.tar.gz"

  note "Downloading ${REPO_OWNER}/${REPO_NAME}@${BRANCH}"
  curl -fsSL "$archive_url" -o "$archive_file"
  tar -xzf "$archive_file" -C "$tmp_root"

  extracted_root="${tmp_root}/${REPO_NAME}-${BRANCH}"
  source_dir="${extracted_root}/${SKILL_SOURCE_PATH}"
  [[ -d "$source_dir" ]] || err "Skill source not found in archive: ${SKILL_SOURCE_PATH}"

  mkdir -p "$(dirname "$dest")"
  rm -rf "$dest"
  cp -R "$source_dir" "$dest"

  printf 'Installed %s to %s\n' "$SKILL_SLUG" "$dest"
  printf 'Target tool: %s\n' "$tool"
  rm -rf "$tmp_root"
}

persist_windows_env() {
  local skill_dest="$1"
  local role_repo_dest="$2"
  local wrapper_path=""
  local wrapper_windows=""
  local repo_windows=""

  is_windows || return 0
  command -v powershell.exe >/dev/null 2>&1 || return 0

  wrapper_path="${skill_dest}/scripts/agency-agents-zh-manage.cmd"
  [[ -f "$wrapper_path" ]] || return 0

  if command -v cygpath >/dev/null 2>&1; then
    wrapper_windows="$(cygpath -w "$wrapper_path")"
    repo_windows="$(cygpath -w "$role_repo_dest")"
  else
    wrapper_windows="$wrapper_path"
    repo_windows="$role_repo_dest"
  fi

  powershell.exe -NoProfile -Command "[Environment]::SetEnvironmentVariable('AGENCY_AGENTS_ZH_MANAGE_SCRIPT', '$wrapper_windows', 'User'); [Environment]::SetEnvironmentVariable('AGENCY_AGENTS_REPO', '$repo_windows', 'User')" >/dev/null
  note "Saved AGENCY_AGENTS_ZH_MANAGE_SCRIPT and AGENCY_AGENTS_REPO for future Windows sessions."
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tool)
      TOOL="${2:?--tool requires a value}"
      shift 2
      ;;
    --dest)
      DEST="${2:?--dest requires a value}"
      shift 2
      ;;
    --branch)
      BRANCH="${2:?--branch requires a value}"
      shift 2
      ;;
    --role-repo-dest)
      ROLE_REPO_DEST="${2:?--role-repo-dest requires a value}"
      shift 2
      ;;
    --role-repo-url)
      ROLE_REPO_URL="${2:?--role-repo-url requires a value}"
      shift 2
      ;;
    --role-repo-ref)
      ROLE_REPO_REF="${2:?--role-repo-ref requires a value}"
      shift 2
      ;;
    --skip-role-repo)
      SKIP_ROLE_REPO="1"
      shift
      ;;
    --update-role-repo)
      UPDATE_ROLE_REPO="1"
      shift
      ;;
    --yes)
      FORCE_YES="1"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      err "Unknown argument: $1"
      ;;
  esac
done

case "$TOOL" in
  auto|codex|openclaw) ;;
  *) err "--tool only supports auto, codex, or openclaw" ;;
esac

TOOL="$(resolve_tool)"
DEST="$(resolve_dest "$TOOL")"
confirm_install "$TOOL" "$DEST"
download_and_install_skill "$TOOL" "$DEST"

if [[ "$SKIP_ROLE_REPO" != "1" ]]; then
  install_or_update_role_repo "$ROLE_REPO_DEST" "$ROLE_REPO_URL" "$ROLE_REPO_REF"
  persist_windows_env "$DEST" "$ROLE_REPO_DEST"
fi

printf 'Next step: %s/scripts/agency-agents-zh-manage.sh --help\n' "$DEST"
if [[ "$SKIP_ROLE_REPO" != "1" ]]; then
  printf 'Dependency repo: %s\n' "$ROLE_REPO_DEST"
fi
