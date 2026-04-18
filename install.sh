#!/usr/bin/env bash
set -euo pipefail

REPO_OWNER="dengqixing"
REPO_NAME="agency-agents-zh-manage"
DEFAULT_BRANCH="main"
SKILL_SLUG="agency-agents-zh-manage"
SKILL_SOURCE_PATH="skills/${SKILL_SLUG}"

TOOL="auto"
DEST=""
BRANCH="${DEFAULT_BRANCH}"
FORCE_YES="0"

usage() {
  cat <<EOF
Install ${SKILL_SLUG} with one command.

Usage:
  bash install.sh [--tool codex|openclaw|auto] [--dest <dir>] [--branch <branch>] [--yes]

Examples:
  bash install.sh --tool codex
  bash install.sh --tool openclaw
  curl -fsSL https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${DEFAULT_BRANCH}/install.sh | bash -s -- --tool codex

Options:
  --tool    Target tool: codex, openclaw, or auto (default)
  --dest    Custom install directory
  --branch  Git branch to download from (default: ${DEFAULT_BRANCH})
  --yes     Skip confirmation prompt
  -h, --help  Show help
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

  err "Unable to detect target tool automatically. Please pass --tool codex or --tool openclaw."
}

resolve_dest() {
  local tool="$1"

  if [[ -n "$DEST" ]]; then
    printf '%s\n' "$DEST"
    return 0
  fi

  case "$tool" in
    codex)
      printf '%s\n' "${HOME}/.codex/skills/${SKILL_SLUG}"
      ;;
    openclaw)
      printf '%s\n' "${HOME}/.openclaw/skills/${SKILL_SLUG}"
      ;;
    *)
      err "Unsupported tool: $tool"
      ;;
  esac
}

confirm_install() {
  local tool="$1"
  local dest="$2"

  if [[ "$FORCE_YES" == "1" ]]; then
    return 0
  fi

  if [[ ! -t 0 ]]; then
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

download_and_install() {
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
  trap 'rm -rf "${tmp_root}"' EXIT

  note "Downloading ${REPO_OWNER}/${REPO_NAME}@${BRANCH} ..."
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
  printf 'Next step: %s/scripts/agency-agents-zh-manage.sh --help\n' "$dest"
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
download_and_install "$TOOL" "$DEST"
