#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PROJECT_DIR="$(pwd)"

ROLE_REPO_URL_DEFAULT="${AGENCY_AGENTS_REPO_URL:-https://github.com/jnMetaCode/agency-agents-zh.git}"
ROLE_REPO_REF_DEFAULT="${AGENCY_AGENTS_REPO_REF:-main}"

usage() {
  cat <<'EOF'
Manage selected roles from agency-agents-zh without installing the full library.

Usage:
  ./scripts/agency-agents-zh-manage.sh find <query> [--repo <path>]
  ./scripts/agency-agents-zh-manage.sh pick <query> [--repo <path>] [--index <n>] [--action <action>]
  ./scripts/agency-agents-zh-manage.sh show <query> [--repo <path>] [--index <n>]
  ./scripts/agency-agents-zh-manage.sh codex <query> [--repo <path>] [--dest <dir>] [--index <n>]
  ./scripts/agency-agents-zh-manage.sh codex-install <query> [--repo <path>] [--scope project|user] [--dest <dir>] [--index <n>]
  ./scripts/agency-agents-zh-manage.sh codex-remove <query> [--repo <path>] [--scope project|user] [--dest <dir>] [--index <n>] [--yes]
  ./scripts/agency-agents-zh-manage.sh openclaw <query> [--repo <path>] [--dest <dir>] [--index <n>]
  ./scripts/agency-agents-zh-manage.sh openclaw-install <query> [--repo <path>] [--dest <dir>] [--index <n>] [--no-register]
  ./scripts/agency-agents-zh-manage.sh openclaw-remove <query> [--repo <path>] [--dest <dir>] [--index <n>] [--yes]
  ./scripts/agency-agents-zh-manage.sh list-installed [--tool all|codex|openclaw] [--scope project|user|all] [--repo <path>] [--dest <dir>]
  ./scripts/agency-agents-zh-manage.sh sync --tool codex|openclaw --manifest <file> [--repo <path>] [--scope project|user] [--dest <dir>] [--no-register]
  ./scripts/agency-agents-zh-manage.sh repo-install [--repo-dest <dir>] [--repo-url <url>] [--repo-ref <ref>] [--yes]
  ./scripts/agency-agents-zh-manage.sh repo-update [--repo-dest <dir>] [--repo-url <url>] [--repo-ref <ref>] [--yes]
  ./scripts/agency-agents-zh-manage.sh doctor [--repo <path>] [--repo-dest <dir>]

Actions for pick:
  show | codex | codex-install | codex-remove | openclaw | openclaw-install | openclaw-remove

Repository resolution order:
  1. --repo
  2. AGENCY_AGENTS_REPO
  3. ./vendor/agency-agents-zh
  4. ../agency-agents-zh
  5. ~/.agency/vendor/agency-agents-zh
  6. ~/.codex/vendor/agency-agents-zh
  7. ~/.openclaw/vendor/agency-agents-zh

Examples:
  ./scripts/agency-agents-zh-manage.sh repo-install
  ./scripts/agency-agents-zh-manage.sh doctor
  ./scripts/agency-agents-zh-manage.sh find "software-architect"
  ./scripts/agency-agents-zh-manage.sh codex-install "software-architect" --scope user
  ./scripts/agency-agents-zh-manage.sh sync --tool codex --manifest "./agents.txt" --scope user
EOF
}

err() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

note() {
  printf '%s\n' "$*" >&2
}

warn() {
  printf 'Warning: %s\n' "$*" >&2
}

prompt() {
  printf '%s' "$*" >&2
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

default_role_repo_dest() {
  printf '%s\n' "${HOME}/.agency/vendor/agency-agents-zh"
}

repo_candidates() {
  if [[ -n "${REPO_PATH:-}" ]]; then
    printf '%s\n' "$REPO_PATH"
  fi
  if [[ -n "${AGENCY_AGENTS_REPO:-}" ]]; then
    printf '%s\n' "${AGENCY_AGENTS_REPO}"
  fi
  printf '%s\n' \
    "${PROJECT_DIR}/vendor/agency-agents-zh" \
    "${PROJECT_DIR}/../agency-agents-zh" \
    "${HOME}/.agency/vendor/agency-agents-zh" \
    "${HOME}/.codex/vendor/agency-agents-zh" \
    "${HOME}/.openclaw/vendor/agency-agents-zh"
}

resolve_repo_core() {
  local optional="$1"
  local candidate=""

  while IFS= read -r candidate; do
    [[ -n "$candidate" ]] || continue
    if [[ -d "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done < <(repo_candidates)

  if [[ "$optional" == "1" ]]; then
    printf '\n'
    return 0
  fi

  err "agency-agents-zh repository not found. Run repo-install, pass --repo, or set AGENCY_AGENTS_REPO."
}

resolve_repo() {
  resolve_repo_core 0
}

resolve_repo_optional() {
  resolve_repo_core 1
}

ensure_safe_remove_target() {
  local path="$1"
  [[ -n "$path" ]] || err "Refusing to operate on an empty path"
  [[ "$path" != "/" ]] || err "Refusing to operate on root"
}

normalize_repo_url() {
  local url="$1"
  printf '%s\n' "${url%.git}"
}

repo_archive_url() {
  local url
  local normalized
  normalized="$(normalize_repo_url "$1")"

  case "$normalized" in
    https://github.com/*/*)
      url="${normalized#https://github.com/}"
      ;;
    git@github.com:*)
      url="${normalized#git@github.com:}"
      ;;
    *)
      err "Unsupported GitHub repository URL: $1"
      ;;
  esac

  printf 'https://codeload.github.com/%s/tar.gz/refs/heads/%s\n' "$url" "$2"
}

replace_directory() {
  local source="$1"
  local dest="$2"

  ensure_safe_remove_target "$dest"
  mkdir -p "$(dirname "$dest")"
  rm -rf "$dest"
  mv "$source" "$dest"
}

download_repo_snapshot() {
  local repo_url="$1"
  local repo_ref="$2"
  local dest="$3"
  local archive_url=""
  local tmp_root=""
  local archive_file=""
  local unpacked_root=""
  local repo_basename=""

  require_cmd curl
  require_cmd tar

  archive_url="$(repo_archive_url "$repo_url" "$repo_ref")"
  tmp_root="$(mktemp -d)"
  archive_file="${tmp_root}/repo.tar.gz"

  curl -fsSL "$archive_url" -o "$archive_file"
  tar -xzf "$archive_file" -C "$tmp_root"

  repo_basename="$(basename "$(normalize_repo_url "$repo_url")")"
  unpacked_root="${tmp_root}/${repo_basename}-${repo_ref}"
  [[ -d "$unpacked_root" ]] || err "Unable to unpack repository snapshot from ${archive_url}"

  replace_directory "$unpacked_root" "$dest"
  rm -rf "$tmp_root"
}

install_or_update_repo() {
  local action="$1"
  local dest="$2"
  local repo_url="$3"
  local repo_ref="$4"

  [[ -n "$dest" ]] || dest="$(default_role_repo_dest)"

  if [[ ! -d "$dest" ]]; then
    if command -v git >/dev/null 2>&1; then
      note "Cloning ${repo_url}@${repo_ref} -> ${dest}"
      mkdir -p "$(dirname "$dest")"
      git clone --depth 1 --branch "$repo_ref" "$repo_url" "$dest"
    else
      note "git not found; downloading a snapshot of ${repo_url}@${repo_ref}"
      download_repo_snapshot "$repo_url" "$repo_ref" "$dest"
    fi
    printf '%s\n' "$dest"
    return 0
  fi

  if [[ "$action" == "install" ]]; then
    note "Dependency repository already exists: ${dest}"
    printf '%s\n' "$dest"
    return 0
  fi

  if [[ -d "${dest}/.git" ]] && command -v git >/dev/null 2>&1; then
    note "Updating ${dest} from ${repo_url}@${repo_ref}"
    git -C "$dest" remote set-url origin "$repo_url"
    git -C "$dest" fetch --depth 1 origin "$repo_ref"
    git -C "$dest" checkout -B "$repo_ref" FETCH_HEAD >/dev/null 2>&1
  else
    note "Refreshing ${dest} from a downloaded snapshot"
    download_repo_snapshot "$repo_url" "$repo_ref" "$dest"
  fi

  printf '%s\n' "$dest"
}

confirm_repo_action() {
  local action="$1"
  local dest="$2"

  if [[ "$FORCE_YES" == "1" || ! -t 0 ]]; then
    return 0
  fi

  prompt "${action} dependency repository at ${dest}? [Y/n] "
  local reply=""
  IFS= read -r reply || true
  reply="${reply:-Y}"
  case "$reply" in
    Y|y|yes|YES|'')
      return 0
      ;;
    *)
      err "Cancelled"
      ;;
  esac
}

is_agent_file() {
  local file="$1"
  local first_line=""

  IFS= read -r first_line < "$file" || true
  [[ "$first_line" == "---" ]] || return 1
  grep -qE '^name:[[:space:]]+' "$file" && grep -qE '^description:[[:space:]]+' "$file"
}

get_meta() {
  local file="$1"
  local key="$2"

  awk -F': *' -v key="$key" '
    $1 == key {
      sub("^[^:]+:[[:space:]]*", "", $0)
      print
      exit
    }
  ' "$file"
}

strip_frontmatter() {
  local file="$1"

  awk '
    NR == 1 && $0 == "---" {
      in_frontmatter = 1
      next
    }
    in_frontmatter && $0 == "---" {
      in_frontmatter = 0
      next
    }
    !in_frontmatter { print }
  ' "$file"
}

list_agent_files() {
  local repo="$1"
  local file=""

  while IFS= read -r file; do
    if is_agent_file "$file"; then
      printf '%s\n' "$file"
    fi
  done < <(find "$repo" -type f -name '*.md' | sort)
}

score_agent() {
  local query="$1"
  local file="$2"
  local repo="$3"
  local rel="${file#$repo/}"
  local slug=""
  local name=""
  local desc=""
  local score=0

  slug="$(basename "${file%.md}")"
  name="$(get_meta "$file" "name")"
  desc="$(get_meta "$file" "description")"

  [[ "$slug" == "$query" ]] && score=$((score + 200))
  [[ "$name" == "$query" ]] && score=$((score + 220))
  [[ "$rel" == *"$query"* ]] && score=$((score + 80))
  [[ "$slug" == *"$query"* ]] && score=$((score + 120))
  [[ "$name" == *"$query"* ]] && score=$((score + 150))
  [[ "$desc" == *"$query"* ]] && score=$((score + 40))

  printf '%s\t%s\t%s\t%s\n' "$score" "$file" "$name" "$desc"
}

find_matches() {
  local repo="$1"
  local query="$2"
  local file=""

  if [[ -f "$query" ]]; then
    is_agent_file "$query" || err "Specified file is not a role file: $query"
    printf '9999\t%s\t%s\t%s\n' "$query" "$(get_meta "$query" "name")" "$(get_meta "$query" "description")"
    return 0
  fi

  while IFS= read -r file; do
    score_agent "$query" "$file" "$repo"
  done < <(list_agent_files "$repo") | awk -F '\t' '$1 > 0' | sort -t "$(printf '\t')" -k1,1nr -k3,3
}

is_positive_integer() {
  [[ "$1" =~ ^[1-9][0-9]*$ ]]
}

pick_match() {
  local repo="$1"
  local query="$2"
  local index="${3:-1}"
  local matches=""
  local top_line=""
  local second_line=""
  local top_score=0
  local second_score=0
  local top_file=""
  local top_name=""
  local top_desc=""

  is_positive_integer "$index" || err "--index must be a positive integer"

  matches="$(find_matches "$repo" "$query")"
  [[ -n "$matches" ]] || err "No matching role found: $query"

  top_line="$(printf '%s\n' "$matches" | sed -n "${index}p")"
  [[ -n "$top_line" ]] || err "Candidate index out of range: $index"
  IFS="$(printf '\t')" read -r top_score top_file top_name top_desc <<EOF
$top_line
EOF

  note "Selected role #${index}: ${top_name}"
  note "Source file: ${top_file#$repo/}"

  if [[ "$index" == "1" ]]; then
    second_line="$(printf '%s\n' "$matches" | sed -n '2p')"
    if [[ -n "$second_line" ]]; then
      IFS="$(printf '\t')" read -r second_score _ _ _ <<EOF
$second_line
EOF
    fi
  fi

  if [[ "$index" == "1" && "$second_score" == "$top_score" && -n "$second_line" ]]; then
    warn "There is a tie for the top match. Run find first if you want to inspect alternatives."
  fi

  printf '%s\n' "$top_file"
}

print_matches() {
  local repo="$1"
  local query="$2"
  local matches=""
  local score=""
  local file=""
  local name=""
  local desc=""
  local count=0

  matches="$(find_matches "$repo" "$query")"
  [[ -n "$matches" ]] || err "No matching role found: $query"

  printf 'Matches:\n'
  while IFS="$(printf '\t')" read -r score file name desc; do
    count=$((count + 1))
    printf '%s. [%s] %s\n' "$count" "$score" "$name"
    printf '   Path: %s\n' "${file#$repo/}"
    printf '   Description: %s\n' "$desc"
    if [[ "$count" -ge 10 ]]; then
      break
    fi
  done <<EOF
$matches
EOF
}

pick_interactive_index() {
  local selected="${INDEX:-1}"
  local input=""

  if [[ -n "${INDEX_SET:-}" || ! -t 0 ]]; then
    printf '%s\n' "$selected"
    return 0
  fi

  prompt "Select candidate index [1]: "
  IFS= read -r input || true
  input="${input:-1}"
  is_positive_integer "$input" || err "Candidate index must be a positive integer"
  printf '%s\n' "$input"
}

pick_interactive_action() {
  local action="${ACTION:-show}"
  local input=""

  if [[ -n "${ACTION:-}" || ! -t 0 ]]; then
    printf '%s\n' "$action"
    return 0
  fi

  prompt "Select action [show]: "
  prompt "(show / codex / codex-install / codex-remove / openclaw / openclaw-install / openclaw-remove) "
  IFS= read -r input || true
  input="${input:-show}"
  case "$input" in
    show|codex|codex-install|codex-remove|openclaw|openclaw-install|openclaw-remove)
      ;;
    *)
      err "Unsupported action: $input"
      ;;
  esac
  printf '%s\n' "$input"
}

escape_toml_multiline() {
  sed -e 's/\\/\\\\/g' -e 's/"""/\\"""/g'
}

escape_toml_basic() {
  sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'
}

write_codex_agent() {
  local file="$1"
  local dest="$2"
  local slug=""
  local desc=""
  local escaped_body=""
  local escaped_desc=""
  local outfile=""

  slug="$(basename "${file%.md}")"
  desc="$(get_meta "$file" "description")"
  escaped_body="$(escape_toml_multiline < "$file")"
  escaped_desc="$(printf '%s' "$desc" | escape_toml_basic)"
  outfile="${dest}/${slug}.toml"

  mkdir -p "$dest"
  cat > "$outfile" <<EOF
name = "${slug}"
description = "${escaped_desc}"
developer_instructions = """
${escaped_body}
"""
EOF

  printf '%s\n' "$outfile"
}

write_openclaw_agent() {
  local file="$1"
  local dest="$2"
  local slug=""
  local name=""
  local desc=""
  local outdir=""
  local soul_file=""
  local agents_file=""
  local identity_file=""

  slug="$(basename "${file%.md}")"
  name="$(get_meta "$file" "name")"
  desc="$(get_meta "$file" "description")"
  outdir="${dest}/${slug}"
  soul_file="${outdir}/SOUL.md"
  agents_file="${outdir}/AGENTS.md"
  identity_file="${outdir}/IDENTITY.md"

  mkdir -p "$outdir"

  cat > "$identity_file" <<EOF
# ${name}

- ID: \`${slug}\`
- Description: ${desc}
- Source: \`${file}\`
EOF

  {
    printf '# %s Soul\n\n' "$name"
    strip_frontmatter "$file"
  } > "$soul_file"

  {
    printf '# %s Agents\n\n' "$name"
    strip_frontmatter "$file"
  } > "$agents_file"

  printf '%s\n' "$outdir"
}

get_slug() {
  basename "${1%.md}"
}

find_agent_file_by_slug() {
  local repo="$1"
  local slug="$2"
  local file=""

  [[ -n "$repo" && -d "$repo" ]] || return 1
  while IFS= read -r file; do
    if [[ "$(basename "${file%.md}")" == "$slug" ]] && is_agent_file "$file"; then
      printf '%s\n' "$file"
      return 0
    fi
  done < <(find "$repo" -type f -name '*.md')
  return 1
}

print_installed_entry() {
  local repo="$1"
  local path="$2"
  local slug="$3"
  local file=""
  local name=""
  local desc=""

  if [[ -n "$repo" ]]; then
    file="$(find_agent_file_by_slug "$repo" "$slug" || true)"
    if [[ -n "$file" ]]; then
      name="$(get_meta "$file" "name")"
      desc="$(get_meta "$file" "description")"
    fi
  fi

  if [[ -n "$name" ]]; then
    printf -- '- %s (`%s`)\n' "$name" "$slug"
  else
    printf -- '- `%s`\n' "$slug"
  fi
  printf '  Path: %s\n' "$path"
  if [[ -n "$desc" ]]; then
    printf '  Description: %s\n' "$desc"
  fi
}

list_codex_installed_in_dir() {
  local repo="$1"
  local dir="$2"
  local label="$3"
  local file=""
  local found=0

  printf 'Codex installed (%s): %s\n' "$label" "$dir"
  if [[ ! -d "$dir" ]]; then
    printf -- '- empty\n'
    return 0
  fi

  for file in "$dir"/*.toml; do
    [[ -e "$file" ]] || continue
    found=1
    print_installed_entry "$repo" "$file" "$(basename "${file%.toml}")"
  done

  if [[ "$found" == "0" ]]; then
    printf -- '- empty\n'
  fi
}

list_openclaw_installed_in_dir() {
  local repo="$1"
  local dir="$2"
  local path=""
  local found=0

  printf 'OpenClaw installed: %s\n' "$dir"
  if [[ ! -d "$dir" ]]; then
    printf -- '- empty\n'
    return 0
  fi

  for path in "$dir"/*; do
    [[ -d "$path" ]] || continue
    found=1
    print_installed_entry "$repo" "$path" "$(basename "$path")"
  done

  if [[ "$found" == "0" ]]; then
    printf -- '- empty\n'
  fi
}

list_installed() {
  local repo="$1"
  local tool="$2"
  local scope="$3"
  local custom_dest="${4:-}"

  case "$tool" in
    all)
      if [[ -n "$custom_dest" ]]; then
        err "--tool all does not support --dest"
      fi
      list_codex_installed_in_dir "$repo" "${PROJECT_DIR}/.codex/agents" "project"
      printf '\n'
      list_codex_installed_in_dir "$repo" "${HOME}/.codex/agents" "user"
      printf '\n'
      list_openclaw_installed_in_dir "$repo" "${HOME}/.openclaw/agency-agents"
      ;;
    codex)
      if [[ -n "$custom_dest" ]]; then
        list_codex_installed_in_dir "$repo" "$custom_dest" "custom"
        return 0
      fi
      case "$scope" in
        project)
          list_codex_installed_in_dir "$repo" "${PROJECT_DIR}/.codex/agents" "project"
          ;;
        user)
          list_codex_installed_in_dir "$repo" "${HOME}/.codex/agents" "user"
          ;;
        all)
          list_codex_installed_in_dir "$repo" "${PROJECT_DIR}/.codex/agents" "project"
          printf '\n'
          list_codex_installed_in_dir "$repo" "${HOME}/.codex/agents" "user"
          ;;
        *)
          err "--scope only supports project, user, or all"
          ;;
      esac
      ;;
    openclaw)
      if [[ -n "$custom_dest" ]]; then
        list_openclaw_installed_in_dir "$repo" "$custom_dest"
        return 0
      fi
      case "$scope" in
        project)
          warn "OpenClaw uses a user-level installation directory; falling back to user scope."
          ;;
        user|all)
          ;;
        *)
          err "OpenClaw only supports --scope user or --scope all"
          ;;
      esac
      list_openclaw_installed_in_dir "$repo" "${HOME}/.openclaw/agency-agents"
      ;;
    *)
      err "--tool only supports all, codex, or openclaw"
      ;;
  esac
}

normalize_manifest_line() {
  local line="$1"
  line="${line#"${line%%[![:space:]]*}"}"
  line="${line%"${line##*[![:space:]]}"}"
  printf '%s\n' "$line"
}

resolve_codex_install_dest() {
  local scope="$1"

  if [[ -n "$DEST" ]]; then
    printf '%s\n' "$DEST"
    return 0
  fi

  case "$scope" in
    project) printf '%s\n' "${PROJECT_DIR}/.codex/agents" ;;
    user) printf '%s\n' "${HOME}/.codex/agents" ;;
    *) err "Unknown scope: $scope" ;;
  esac
}

resolve_openclaw_install_dest() {
  if [[ -n "$DEST" ]]; then
    printf '%s\n' "$DEST"
    return 0
  fi

  printf '%s\n' "${HOME}/.openclaw/agency-agents"
}

register_openclaw_agent() {
  local slug="$1"
  local workspace="$2"
  local output=""

  if ! command -v openclaw >/dev/null 2>&1; then
    warn "openclaw command not found; skipping automatic registration."
    warn "Run manually: openclaw agents add \"$slug\" --workspace \"$workspace\" --non-interactive"
    return 0
  fi

  if output="$(openclaw agents add "$slug" --workspace "$workspace" --non-interactive 2>&1)"; then
    note "OpenClaw registered: $slug"
    return 0
  fi

  warn "OpenClaw registration failed; the files were still written."
  [[ -n "$output" ]] && warn "$output"
  warn "Run manually: openclaw agents add \"$slug\" --workspace \"$workspace\" --non-interactive"
}

confirm_dangerous_action() {
  local title="$1"
  local target="$2"
  local risk="$3"
  local reply=""

  if [[ "$FORCE_YES" == "1" ]]; then
    return 0
  fi

  if [[ ! -t 0 ]]; then
    err "This action needs explicit confirmation. Re-run with --yes."
  fi

  cat >&2 <<EOF
Dangerous action detected.
Action: ${title}
Target: ${target}
Risk: ${risk}

Type one of: yes / confirm / continue
EOF
  prompt "> "
  IFS= read -r reply || true

  case "$reply" in
    yes|confirm|continue)
      return 0
      ;;
    *)
      err "Cancelled"
      ;;
  esac
}

remove_path() {
  local path="$1"
  [[ -e "$path" ]] || err "Target does not exist: $path"
  ensure_safe_remove_target "$path"
  rm -rf -- "$path"
}

remove_codex_agent() {
  local file="$1"
  local install_dest=""
  local slug=""
  local target=""

  case "$SCOPE" in
    project|user) ;;
    *) err "--scope only supports project or user" ;;
  esac

  install_dest="$(resolve_codex_install_dest "$SCOPE")"
  slug="$(get_slug "$file")"
  target="${install_dest}/${slug}.toml"

  confirm_dangerous_action \
    "Remove Codex agent" \
    "$target" \
    "The generated Codex agent file will be deleted."

  remove_path "$target"
  printf 'Removed Codex agent: %s\n' "$target"
}

remove_openclaw_agent() {
  local file="$1"
  local install_dest=""
  local slug=""
  local target=""
  local output=""

  install_dest="$(resolve_openclaw_install_dest)"
  slug="$(get_slug "$file")"
  target="${install_dest}/${slug}"

  confirm_dangerous_action \
    "Remove OpenClaw agent" \
    "$target" \
    "The exported OpenClaw agent directory will be deleted."

  if [[ -d "$target" && -n "${DEST:-}" ]]; then
    remove_path "$target"
    printf 'Removed OpenClaw agent: %s\n' "$target"
    return 0
  fi

  if command -v openclaw >/dev/null 2>&1; then
    if output="$(openclaw agents delete "$slug" --force 2>&1)"; then
      note "OpenClaw deleted and deregistered: $slug"
    else
      warn "OpenClaw deregistration failed; deleting the local directory only."
      [[ -n "$output" ]] && warn "$output"
    fi
  fi

  if [[ -d "$target" ]]; then
    remove_path "$target"
  fi

  printf 'Removed OpenClaw agent: %s\n' "$target"
}

run_selected_action() {
  local action="$1"
  local file="$2"
  local install_dest=""
  local outfile=""
  local outdir=""

  case "$action" in
    show)
      cat "$file"
      ;;
    codex)
      install_dest="${DEST:-${PROJECT_DIR}/.codex/agents}"
      outfile="$(write_codex_agent "$file" "$install_dest")"
      printf 'Exported Codex agent: %s\n' "$outfile"
      ;;
    codex-install)
      case "$SCOPE" in
        project|user) ;;
        *) err "--scope only supports project or user" ;;
      esac
      install_dest="$(resolve_codex_install_dest "$SCOPE")"
      outfile="$(write_codex_agent "$file" "$install_dest")"
      printf 'Installed Codex agent: %s\n' "$outfile"
      ;;
    codex-remove)
      remove_codex_agent "$file"
      ;;
    openclaw)
      install_dest="${DEST:-${PROJECT_DIR}/.generated/openclaw}"
      outdir="$(write_openclaw_agent "$file" "$install_dest")"
      printf 'Exported OpenClaw agent: %s\n' "$outdir"
      ;;
    openclaw-install)
      install_dest="$(resolve_openclaw_install_dest)"
      outdir="$(write_openclaw_agent "$file" "$install_dest")"
      if [[ "$REGISTER" == "1" ]]; then
        register_openclaw_agent "$(basename "$outdir")" "$outdir"
      fi
      printf 'Installed OpenClaw agent: %s\n' "$outdir"
      ;;
    openclaw-remove)
      remove_openclaw_agent "$file"
      ;;
    *)
      err "Unsupported action: $action"
      ;;
  esac
}

sync_manifest() {
  local repo="$1"
  local tool="$2"
  local manifest="$3"
  local install_dest=""
  local line=""
  local query=""
  local file=""
  local slug=""
  local target=""
  local total=0
  local installed=0
  local skipped=0
  local failed=0

  [[ -f "$manifest" ]] || err "Manifest file not found: $manifest"

  case "$tool" in
    codex)
      case "$SCOPE" in
        project|user) ;;
        *) err "sync with codex only supports --scope project or --scope user" ;;
      esac
      install_dest="$(resolve_codex_install_dest "$SCOPE")"
      ;;
    openclaw)
      install_dest="$(resolve_openclaw_install_dest)"
      ;;
    *)
      err "sync only supports --tool codex or --tool openclaw"
      ;;
  esac

  note "Syncing ${tool} roles from ${manifest}"
  note "Destination: ${install_dest}"

  while IFS= read -r line || [[ -n "$line" ]]; do
    query="$(normalize_manifest_line "$line")"
    [[ -n "$query" ]] || continue
    [[ "$query" == \#* ]] && continue
    total=$((total + 1))

    if ! file="$(pick_match "$repo" "$query" "${INDEX:-1}" 2>/dev/null)"; then
      warn "Role not found, skipping: ${query}"
      failed=$((failed + 1))
      continue
    fi

    slug="$(get_slug "$file")"
    case "$tool" in
      codex)
        target="${install_dest}/${slug}.toml"
        if [[ -f "$target" ]]; then
          note "Already installed, skipping: ${slug}"
          skipped=$((skipped + 1))
          continue
        fi
        write_codex_agent "$file" "$install_dest" >/dev/null
        note "Installed Codex agent: ${slug}"
        installed=$((installed + 1))
        ;;
      openclaw)
        target="${install_dest}/${slug}"
        if [[ -d "$target" ]]; then
          note "Already installed, skipping: ${slug}"
          skipped=$((skipped + 1))
          continue
        fi
        write_openclaw_agent "$file" "$install_dest" >/dev/null
        if [[ "$REGISTER" == "1" ]]; then
          register_openclaw_agent "$slug" "$target"
        fi
        note "Installed OpenClaw agent: ${slug}"
        installed=$((installed + 1))
        ;;
    esac
  done < "$manifest"

  printf 'Sync complete: total=%s, installed=%s, skipped=%s, failed=%s\n' \
    "$total" "$installed" "$skipped" "$failed"
}

doctor() {
  local repo="$1"
  local dep_dest=""
  local cmd_name=""

  dep_dest="${REPO_DEST:-$(default_role_repo_dest)}"

  printf 'agency-agents-zh-manage doctor\n'
  printf '  OS: %s\n' "$(uname -s)"
  printf '  Shell: %s\n' "${SHELL:-unknown}"
  printf '  Script: %s\n' "$0"
  printf '  Skill dir: %s\n' "$SKILL_DIR"
  printf '  Project dir: %s\n' "$PROJECT_DIR"
  printf '  Repo env: %s\n' "${AGENCY_AGENTS_REPO:-<unset>}"
  printf '  Default dependency dir: %s\n' "$dep_dest"

  for cmd_name in bash git curl tar grep awk sed; do
    if command -v "$cmd_name" >/dev/null 2>&1; then
      printf '  %s: %s\n' "$cmd_name" "$(command -v "$cmd_name")"
    else
      printf '  %s: <missing>\n' "$cmd_name"
    fi
  done

  if [[ -n "$repo" ]]; then
    printf '  Resolved role repo: %s\n' "$repo"
    printf '  Role repo .git: %s\n' "$(if [[ -d "${repo}/.git" ]]; then printf 'yes'; else printf 'no'; fi)"
  else
    printf '  Resolved role repo: <not found>\n'
  fi

  if is_windows; then
    printf '  Windows wrapper: %s\n' "${SCRIPT_DIR}/agency-agents-zh-manage.cmd"
  fi
}

COMMAND="${1:-}"
[[ -n "$COMMAND" ]] || {
  usage
  exit 1
}
shift || true

QUERY=""
REPO_PATH=""
REPO_DEST=""
REPO_URL="$ROLE_REPO_URL_DEFAULT"
REPO_REF="$ROLE_REPO_REF_DEFAULT"
DEST=""
INDEX="1"
INDEX_SET=""
SCOPE="project"
REGISTER="1"
ACTION=""
FORCE_YES="0"
TOOL="all"
MANIFEST=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      REPO_PATH="${2:?--repo requires a value}"
      shift 2
      ;;
    --repo-dest)
      REPO_DEST="${2:?--repo-dest requires a value}"
      shift 2
      ;;
    --repo-url)
      REPO_URL="${2:?--repo-url requires a value}"
      shift 2
      ;;
    --repo-ref)
      REPO_REF="${2:?--repo-ref requires a value}"
      shift 2
      ;;
    --dest)
      DEST="${2:?--dest requires a value}"
      shift 2
      ;;
    --index)
      INDEX="${2:?--index requires a value}"
      INDEX_SET="1"
      shift 2
      ;;
    --scope)
      SCOPE="${2:?--scope requires a value}"
      shift 2
      ;;
    --tool)
      TOOL="${2:?--tool requires a value}"
      shift 2
      ;;
    --manifest)
      MANIFEST="${2:?--manifest requires a value}"
      shift 2
      ;;
    --no-register)
      REGISTER="0"
      shift
      ;;
    --yes)
      FORCE_YES="1"
      shift
      ;;
    --action)
      ACTION="${2:?--action requires a value}"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      if [[ -z "$QUERY" ]]; then
        QUERY="$1"
        shift
      else
        err "Unknown argument: $1"
      fi
      ;;
  esac
done

case "$COMMAND" in
  list-installed|repo-install|repo-update|doctor)
    ;;
  sync)
    [[ -n "$MANIFEST" ]] || err "Missing --manifest"
    ;;
  find|pick|show|codex|codex-install|codex-remove|openclaw|openclaw-install|openclaw-remove)
    [[ -n "$QUERY" ]] || err "Missing query"
    ;;
  *)
    usage
    exit 1
    ;;
esac

case "$COMMAND" in
  repo-install)
    REPO_DEST="${REPO_DEST:-$(default_role_repo_dest)}"
    confirm_repo_action "Install" "$REPO_DEST"
    install_or_update_repo "install" "$REPO_DEST" "$REPO_URL" "$REPO_REF"
    ;;
  repo-update)
    REPO_DEST="${REPO_DEST:-$(default_role_repo_dest)}"
    confirm_repo_action "Update" "$REPO_DEST"
    install_or_update_repo "update" "$REPO_DEST" "$REPO_URL" "$REPO_REF"
    ;;
  doctor)
    doctor "$(resolve_repo_optional)"
    ;;
  list-installed)
    list_installed "$(resolve_repo_optional)" "$TOOL" "$SCOPE" "$DEST"
    ;;
  sync)
    sync_manifest "$(resolve_repo)" "$TOOL" "$MANIFEST"
    ;;
  find)
    print_matches "$(resolve_repo)" "$QUERY"
    ;;
  pick)
    print_matches "$(resolve_repo)" "$QUERY"
    INDEX="$(pick_interactive_index)"
    ACTION="$(pick_interactive_action)"
    FILE="$(pick_match "$(resolve_repo)" "$QUERY" "$INDEX")"
    run_selected_action "$ACTION" "$FILE"
    ;;
  show)
    FILE="$(pick_match "$(resolve_repo)" "$QUERY" "$INDEX")"
    run_selected_action "show" "$FILE"
    ;;
  codex)
    FILE="$(pick_match "$(resolve_repo)" "$QUERY" "$INDEX")"
    run_selected_action "codex" "$FILE"
    ;;
  codex-install)
    FILE="$(pick_match "$(resolve_repo)" "$QUERY" "$INDEX")"
    run_selected_action "codex-install" "$FILE"
    ;;
  codex-remove)
    FILE="$(pick_match "$(resolve_repo)" "$QUERY" "$INDEX")"
    run_selected_action "codex-remove" "$FILE"
    ;;
  openclaw)
    FILE="$(pick_match "$(resolve_repo)" "$QUERY" "$INDEX")"
    run_selected_action "openclaw" "$FILE"
    ;;
  openclaw-install)
    FILE="$(pick_match "$(resolve_repo)" "$QUERY" "$INDEX")"
    run_selected_action "openclaw-install" "$FILE"
    ;;
  openclaw-remove)
    FILE="$(pick_match "$(resolve_repo)" "$QUERY" "$INDEX")"
    run_selected_action "openclaw-remove" "$FILE"
    ;;
esac
