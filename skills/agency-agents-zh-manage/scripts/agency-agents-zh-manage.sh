#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PROJECT_DIR="$(pwd)"

usage() {
  cat <<'EOF'
按需使用 agency-agents-zh 角色库

用法:
  ./scripts/agency-agents-zh-manage.sh find <关键词> [--repo <角色库路径>]
  ./scripts/agency-agents-zh-manage.sh list-installed [--tool all|codex|openclaw] [--scope project|user] [--repo <角色库路径>] [--dest <目录>]
  ./scripts/agency-agents-zh-manage.sh sync --tool codex|openclaw --manifest <清单文件> [--repo <角色库路径>] [--scope project|user] [--dest <目录>] [--no-register]
  ./scripts/agency-agents-zh-manage.sh pick <关键词> [--repo <角色库路径>] [--index <候选序号>] [--action <动作>]
  ./scripts/agency-agents-zh-manage.sh show <关键词> [--repo <角色库路径>] [--index <候选序号>]
  ./scripts/agency-agents-zh-manage.sh codex <关键词> [--repo <角色库路径>] [--dest <输出目录>] [--index <候选序号>]
  ./scripts/agency-agents-zh-manage.sh codex-install <关键词> [--repo <角色库路径>] [--index <候选序号>] [--scope project|user] [--dest <安装目录>]
  ./scripts/agency-agents-zh-manage.sh codex-remove <关键词> [--repo <角色库路径>] [--index <候选序号>] [--scope project|user] [--dest <安装目录>] [--yes]
  ./scripts/agency-agents-zh-manage.sh openclaw <关键词> [--repo <角色库路径>] [--dest <输出目录>] [--index <候选序号>]
  ./scripts/agency-agents-zh-manage.sh openclaw-install <关键词> [--repo <角色库路径>] [--index <候选序号>] [--dest <安装目录>] [--no-register]
  ./scripts/agency-agents-zh-manage.sh openclaw-remove <关键词> [--repo <角色库路径>] [--index <候选序号>] [--dest <安装目录>] [--yes]

说明:
  1. 角色库默认从以下位置自动发现:
     - $AGENCY_AGENTS_REPO
     - ./vendor/agency-agents-zh
     - ../agency-agents-zh
  2. `codex` 只导出一个 .toml 到目标目录
  3. `openclaw` 只导出一个角色目录，不做全量安装
  4. `codex-install` / `openclaw-install` 会直接写入本机安装目录
  5. `openclaw-install` 默认尝试执行 `openclaw agents add`
  6. `pick` 会先列候选，再让你选择序号和动作
  7. 删除命令默认要求显式确认，非交互环境必须传 `--yes`
  8. `list-installed` 可查看当前已安装的 Codex / OpenClaw 角色
  9. `sync` 只按清单文件同步常用角色，不做全量覆盖

示例:
  ./scripts/agency-agents-zh-manage.sh find "前端"
  ./scripts/agency-agents-zh-manage.sh list-installed
  ./scripts/agency-agents-zh-manage.sh list-installed --tool codex --scope user
  ./scripts/agency-agents-zh-manage.sh sync --tool codex --manifest "./agents.txt"
  ./scripts/agency-agents-zh-manage.sh sync --tool openclaw --manifest "./agents.txt" --no-register
  ./scripts/agency-agents-zh-manage.sh pick "前端"
  ./scripts/agency-agents-zh-manage.sh pick "前端" --action codex-install --scope user
  ./scripts/agency-agents-zh-manage.sh show "小红书" --repo "/path/to/agency-agents-zh"
  ./scripts/agency-agents-zh-manage.sh codex "前端" --repo "/path/to/agency-agents-zh" --index 2
  ./scripts/agency-agents-zh-manage.sh codex "代码审查" --repo "/path/to/agency-agents-zh"
  ./scripts/agency-agents-zh-manage.sh codex-install "代码审查" --repo "/path/to/agency-agents-zh"
  ./scripts/agency-agents-zh-manage.sh codex-install "代码审查" --repo "/path/to/agency-agents-zh" --scope user
  ./scripts/agency-agents-zh-manage.sh codex-remove "代码审查" --repo "/path/to/agency-agents-zh" --scope user --yes
  ./scripts/agency-agents-zh-manage.sh openclaw "安全工程师" --repo "/path/to/agency-agents-zh" --dest "./.generated/openclaw"
  ./scripts/agency-agents-zh-manage.sh openclaw-install "安全工程师" --repo "/path/to/agency-agents-zh"
  ./scripts/agency-agents-zh-manage.sh openclaw-remove "安全工程师" --repo "/path/to/agency-agents-zh" --yes
EOF
}

err() {
  printf '错误: %s\n' "$*" >&2
  exit 1
}

note() {
  printf '%s\n' "$*" >&2
}

warn() {
  printf '警告: %s\n' "$*" >&2
}

prompt() {
  printf '%s' "$*" >&2
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || err "缺少命令: $1"
}

resolve_repo() {
  if [[ -n "${REPO_PATH:-}" ]]; then
    [[ -d "$REPO_PATH" ]] || err "角色库不存在: $REPO_PATH"
    printf '%s\n' "$REPO_PATH"
    return 0
  fi

  if [[ -n "${AGENCY_AGENTS_REPO:-}" && -d "${AGENCY_AGENTS_REPO}" ]]; then
    printf '%s\n' "${AGENCY_AGENTS_REPO}"
    return 0
  fi

  if [[ -d "${PROJECT_DIR}/vendor/agency-agents-zh" ]]; then
    printf '%s\n' "${PROJECT_DIR}/vendor/agency-agents-zh"
    return 0
  fi

  if [[ -d "${PROJECT_DIR}/../agency-agents-zh" ]]; then
    printf '%s\n' "${PROJECT_DIR}/../agency-agents-zh"
    return 0
  fi

  err "找不到角色库。请通过 --repo 指定，或设置 AGENCY_AGENTS_REPO。"
}

resolve_repo_optional() {
  if [[ -n "${REPO_PATH:-}" ]]; then
    [[ -d "$REPO_PATH" ]] || err "角色库不存在: $REPO_PATH"
    printf '%s\n' "$REPO_PATH"
    return 0
  fi

  if [[ -n "${AGENCY_AGENTS_REPO:-}" && -d "${AGENCY_AGENTS_REPO}" ]]; then
    printf '%s\n' "${AGENCY_AGENTS_REPO}"
    return 0
  fi

  if [[ -d "${PROJECT_DIR}/vendor/agency-agents-zh" ]]; then
    printf '%s\n' "${PROJECT_DIR}/vendor/agency-agents-zh"
    return 0
  fi

  if [[ -d "${PROJECT_DIR}/../agency-agents-zh" ]]; then
    printf '%s\n' "${PROJECT_DIR}/../agency-agents-zh"
    return 0
  fi

  printf '%s\n' ""
}

is_agent_file() {
  local file="$1"
  local first_line=""
  IFS= read -r first_line < "$file" || true
  [[ "$first_line" == "---" ]] || return 1
  rg -q '^name ' "$file" && rg -q '^description ' "$file"
}

get_meta() {
  local file="$1"
  local key="$2"

  awk -v key="$key" '
    $1 == key {
      sub("^" key "[[:space:]]+", "", $0)
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

  while IFS= read -r file; do
    if is_agent_file "$file"; then
      printf '%s\n' "$file"
    fi
  done < <(rg --files "$repo" -g '*.md')
}

score_agent() {
  local query="$1"
  local file="$2"
  local rel="${file#$3/}"
  local slug
  local name
  local desc
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
  local file

  if [[ -f "$query" ]]; then
    is_agent_file "$query" || err "指定文件不是角色文件: $query"
    printf '9999\t%s\t%s\t%s\n' "$query" "$(get_meta "$query" "name")" "$(get_meta "$query" "description")"
    return 0
  fi

  while IFS= read -r file; do
    score_agent "$query" "$file" "$repo"
  done < <(list_agent_files "$repo") | awk -F '\t' '$1 > 0' | sort -t $'\t' -k1,1nr -k3,3
}

is_positive_integer() {
  [[ "$1" =~ ^[1-9][0-9]*$ ]]
}

pick_match() {
  local repo="$1"
  local query="$2"
  local index="${3:-1}"
  local matches
  local top_line
  local top_score
  local top_file
  local second_line
  local second_score=0
  local top_name
  local top_desc

  is_positive_integer "$index" || err "--index 必须是大于 0 的整数"

  matches="$(find_matches "$repo" "$query")"
  [[ -n "$matches" ]] || err "没有找到匹配角色: $query"

  top_line="$(printf '%s\n' "$matches" | sed -n "${index}p")"
  [[ -n "$top_line" ]] || err "候选序号超出范围: $index"

  IFS=$'\t' read -r top_score top_file top_name top_desc <<< "$top_line"

  note "选中角色 #${index}: $top_name"
  note "来源文件: ${top_file#$repo/}"

  if [[ "$index" == "1" ]]; then
    second_line="$(printf '%s\n' "$matches" | sed -n '2p')"
    if [[ -n "$second_line" ]]; then
      IFS=$'\t' read -r second_score _ _ _ <<< "$second_line"
    fi
  fi

  if [[ "$index" == "1" && "$second_score" == "$top_score" && -n "$second_line" ]]; then
    note "提示: 存在并列匹配，当前取第一条。可先运行 find 查看候选。"
  fi

  printf '%s\n' "$top_file"
}

print_matches() {
  local repo="$1"
  local query="$2"
  local matches
  local count=0

  matches="$(find_matches "$repo" "$query")"
  [[ -n "$matches" ]] || err "没有找到匹配角色: $query"

  printf '匹配结果:\n'
  while IFS=$'\t' read -r score file name desc; do
    count=$((count + 1))
    printf '%s. [%s] %s\n' "$count" "$score" "$name"
    printf '   路径: %s\n' "${file#$repo/}"
    printf '   简介: %s\n' "$desc"
    if [[ "$count" -ge 10 ]]; then
      break
    fi
  done <<< "$matches"
}

pick_interactive_index() {
  local selected="${INDEX:-1}"
  local input=""

  if [[ -n "${INDEX_SET:-}" ]]; then
    printf '%s\n' "$selected"
    return 0
  fi

  if [[ ! -t 0 ]]; then
    printf '%s\n' "$selected"
    return 0
  fi

  prompt "选择候选序号 [1]: "
  IFS= read -r input || true
  input="${input:-1}"
  is_positive_integer "$input" || err "候选序号必须是大于 0 的整数"
  printf '%s\n' "$input"
}

pick_interactive_action() {
  local action="${ACTION:-show}"
  local input=""
  local valid='show|codex|codex-install|codex-remove|openclaw|openclaw-install|openclaw-remove'

  if [[ -n "${ACTION:-}" ]]; then
    printf '%s\n' "$action"
    return 0
  fi

  if [[ ! -t 0 ]]; then
    printf '%s\n' "$action"
    return 0
  fi

  prompt "选择动作 [show]: "
  prompt "(可选: show / codex / codex-install / codex-remove / openclaw / openclaw-install / openclaw-remove) "
  IFS= read -r input || true
  input="${input:-show}"
  [[ "$input" =~ ^($valid)$ ]] || err "动作不支持: $input"
  printf '%s\n' "$input"
}

escape_toml_multiline() {
  sed -e 's/\\/\\\\/g' -e 's/"""/\\"""/g'
}

escape_toml_basic() {
  sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'
}

extract_sections() {
  local file="$1"
  local pattern="$2"

  strip_frontmatter "$file" | awk -v pattern="$pattern" '
    BEGIN {
      keep = 0
      found = 0
    }
    /^##+[[:space:]]+/ {
      keep = ($0 ~ pattern)
      if (keep) {
        found = 1
      }
    }
    keep { print }
    END {
      if (!found) {
        exit 1
      }
    }
  '
}

write_codex_agent() {
  local file="$1"
  local dest="$2"
  local slug
  local desc
  local escaped_body
  local escaped_desc
  local outfile

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
  local slug
  local name
  local desc
  local outdir
  local soul_file
  local agents_file
  local identity_file
  local soul_pattern='身份|记忆|关键规则|沟通风格|个性|必须遵循|成功标准'
  local agents_pattern='核心使命|核心任务|技术交付物|工作流程|交付物|使命'

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
- 描述: ${desc}
- 来源: \`${file}\`
EOF

  {
    printf '# %s Soul\n\n' "$name"
    printf '> 由源角色文件按需导出，保留身份、规则与风格相关内容。\n\n'
    if ! extract_sections "$file" "$soul_pattern"; then
      strip_frontmatter "$file"
    fi
  } > "$soul_file"

  {
    printf '# %s Agents\n\n' "$name"
    printf '> 由源角色文件按需导出，保留使命、交付与流程相关内容。\n\n'
    if ! extract_sections "$file" "$agents_pattern"; then
      strip_frontmatter "$file"
    fi
  } > "$agents_file"

  printf '%s\n' "$outdir"
}

get_slug() {
  local file="$1"
  basename "${file%.md}"
}

find_agent_file_by_slug() {
  local repo="$1"
  local slug="$2"

  [[ -n "$repo" && -d "$repo" ]] || return 1
  rg --files "$repo" -g "${slug}.md" | sed -n '1p'
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
      if [[ "$file" != /* ]]; then
        file="${repo}/${file}"
      fi
      name="$(get_meta "$file" "name")"
      desc="$(get_meta "$file" "description")"
    fi
  fi

  if [[ -n "$name" ]]; then
    printf -- '- %s (`%s`)\n' "$name" "$slug"
  else
    printf -- '- `%s`\n' "$slug"
  fi
  printf '  路径: %s\n' "$path"
  if [[ -n "$desc" ]]; then
    printf '  简介: %s\n' "$desc"
  fi
}

list_codex_installed_in_dir() {
  local repo="$1"
  local dir="$2"
  local label="$3"
  local found=0
  local file=""
  local slug=""

  printf 'Codex 已安装 (%s): %s\n' "$label" "$dir"

  if [[ ! -d "$dir" ]]; then
    printf -- '- 空\n'
    return 0
  fi

  while IFS= read -r file; do
    found=1
    slug="$(basename "${file%.toml}")"
    print_installed_entry "$repo" "$file" "$slug"
  done < <(find "$dir" -maxdepth 1 -type f -name '*.toml' | sort)

  if [[ "$found" == "0" ]]; then
    printf -- '- 空\n'
  fi
}

list_openclaw_installed_in_dir() {
  local repo="$1"
  local dir="$2"
  local found=0
  local path=""
  local slug=""

  printf 'OpenClaw 已安装: %s\n' "$dir"

  if [[ ! -d "$dir" ]]; then
    printf -- '- 空\n'
    return 0
  fi

  while IFS= read -r path; do
    found=1
    slug="$(basename "$path")"
    print_installed_entry "$repo" "$path" "$slug"
  done < <(find "$dir" -mindepth 1 -maxdepth 1 -type d | sort)

  if [[ "$found" == "0" ]]; then
    printf -- '- 空\n'
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
        err "--tool all 时不支持 --dest，请分别调用 codex/openclaw。"
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
          err "--scope 只支持 project / user / all"
          ;;
      esac
      ;;
    openclaw)
      local normalized_scope="$scope"
      if [[ -n "$custom_dest" ]]; then
        list_openclaw_installed_in_dir "$repo" "$custom_dest"
        return 0
      fi
      if [[ "$normalized_scope" == "project" ]]; then
        normalized_scope="user"
      fi
      if [[ "$normalized_scope" != "all" && "$normalized_scope" != "user" ]]; then
        err "OpenClaw 仅支持 --scope user 或省略"
      fi
      list_openclaw_installed_in_dir "$repo" "${HOME}/.openclaw/agency-agents"
      ;;
    *)
      err "--tool 只支持 all / codex / openclaw"
      ;;
  esac
}

normalize_manifest_line() {
  local line="$1"

  line="${line#"${line%%[![:space:]]*}"}"
  line="${line%"${line##*[![:space:]]}"}"
  printf '%s\n' "$line"
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

  [[ -f "$manifest" ]] || err "清单文件不存在: $manifest"

  case "$tool" in
    codex)
      case "$SCOPE" in
        project|user) ;;
        *) err "sync 到 Codex 时，--scope 只支持 project 或 user" ;;
      esac
      install_dest="$(resolve_codex_install_dest "$SCOPE")"
      ;;
    openclaw)
      install_dest="$(resolve_openclaw_install_dest)"
      ;;
    *)
      err "sync 仅支持 --tool codex 或 openclaw"
      ;;
  esac

  note "开始同步: tool=${tool}, manifest=${manifest}"
  note "目标目录: ${install_dest}"

  while IFS= read -r line || [[ -n "$line" ]]; do
    query="$(normalize_manifest_line "$line")"
    [[ -n "$query" ]] || continue
    [[ "$query" == \#* ]] && continue
    total=$((total + 1))

    if ! file="$(pick_match "$repo" "$query" "${INDEX:-1}" 2>/dev/null)"; then
      warn "未找到角色，已跳过: ${query}"
      failed=$((failed + 1))
      continue
    fi

    slug="$(get_slug "$file")"

    case "$tool" in
      codex)
        target="${install_dest}/${slug}.toml"
        if [[ -f "$target" ]]; then
          note "已存在，跳过: ${slug}"
          skipped=$((skipped + 1))
          continue
        fi
        write_codex_agent "$file" "$install_dest" >/dev/null
        note "已安装 Codex agent: ${slug}"
        installed=$((installed + 1))
        ;;
      openclaw)
        target="${install_dest}/${slug}"
        if [[ -d "$target" ]]; then
          note "已存在，跳过: ${slug}"
          skipped=$((skipped + 1))
          continue
        fi
        write_openclaw_agent "$file" "$install_dest" >/dev/null
        if [[ "$REGISTER" == "1" ]]; then
          register_openclaw_agent "$slug" "$target"
        fi
        note "已安装 OpenClaw agent: ${slug}"
        installed=$((installed + 1))
        ;;
    esac
  done < "$manifest"

  printf '同步完成: total=%s, installed=%s, skipped=%s, failed=%s\n' \
    "$total" "$installed" "$skipped" "$failed"
}

resolve_codex_install_dest() {
  local scope="$1"

  if [[ -n "$DEST" ]]; then
    printf '%s\n' "$DEST"
    return 0
  fi

  case "$scope" in
    project)
      printf '%s\n' "${PROJECT_DIR}/.codex/agents"
      ;;
    user)
      printf '%s\n' "${HOME}/.codex/agents"
      ;;
    *)
      err "未知 scope: $scope"
      ;;
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
    warn "未检测到 openclaw 命令，已跳过自动注册。"
    warn "可手动执行: openclaw agents add \"$slug\" --workspace \"$workspace\" --non-interactive"
    return 0
  fi

  if output="$(openclaw agents add "$slug" --workspace "$workspace" --non-interactive 2>&1)"; then
    note "OpenClaw 已注册: $slug"
    return 0
  fi

  warn "OpenClaw 自动注册失败，文件已写入。"
  warn "可手动执行: openclaw agents add \"$slug\" --workspace \"$workspace\" --non-interactive"
  [[ -n "$output" ]] && warn "$output"
  return 0
}

confirm_dangerous_action() {
  local action_type="$1"
  local scope_desc="$2"
  local risk_desc="$3"
  local reply=""

  if [[ "$FORCE_YES" == "1" ]]; then
    return 0
  fi

  if [[ ! -t 0 ]]; then
    err "危险操作需要显式确认。请重新执行并传入 --yes。"
  fi

  cat >&2 <<EOF
⚠️ 危险操作检测！
操作类型：${action_type}
影响范围：${scope_desc}
风险评估：${risk_desc}

请确认是否继续？[需要明确的"是"、"确认"、"继续"]
EOF
  prompt "> "
  IFS= read -r reply || true

  case "$reply" in
    是|确认|继续)
      return 0
      ;;
    *)
      err "已取消操作"
      ;;
  esac
}

remove_path() {
  local path="$1"

  [[ -e "$path" ]] || err "目标不存在: $path"
  rm -rf "$path"
}

remove_codex_agent() {
  local file="$1"
  local install_dest
  local slug
  local target

  case "$SCOPE" in
    project|user) ;;
    *) err "--scope 只支持 project 或 user" ;;
  esac

  install_dest="$(resolve_codex_install_dest "$SCOPE")"
  slug="$(get_slug "$file")"
  target="${install_dest}/${slug}.toml"

  confirm_dangerous_action \
    "删除 Codex agent" \
    "${target}" \
    "删除后该角色会从 Codex 安装目录移除，需要重新安装才能恢复。"

  remove_path "$target"
  printf '已删除 Codex agent: %s\n' "$target"
}

remove_openclaw_agent() {
  local file="$1"
  local install_dest
  local slug
  local target
  local output=""

  install_dest="$(resolve_openclaw_install_dest)"
  slug="$(get_slug "$file")"
  target="${install_dest}/${slug}"

  confirm_dangerous_action \
    "删除 OpenClaw agent" \
    "${target}" \
    "删除后该角色目录会被移除；如果已注册到 OpenClaw，也会尝试一并注销。"

  if [[ -d "$target" && -n "${DEST:-}" ]]; then
    remove_path "$target"
    printf '已删除 OpenClaw agent: %s\n' "$target"
    return 0
  fi

  if command -v openclaw >/dev/null 2>&1; then
    if output="$(openclaw agents delete "$slug" --force 2>&1)"; then
      note "OpenClaw 已删除并注销: $slug"
    else
      warn "OpenClaw 注销失败，尝试仅删除目录。"
      [[ -n "$output" ]] && warn "$output"
      remove_path "$target"
    fi
  else
    remove_path "$target"
  fi

  if [[ -d "$target" ]]; then
    remove_path "$target"
  fi

  printf '已删除 OpenClaw agent: %s\n' "$target"
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
      printf '已导出 Codex agent: %s\n' "$outfile"
      ;;
    codex-install)
      case "$SCOPE" in
        project|user) ;;
        *) err "--scope 只支持 project 或 user" ;;
      esac
      install_dest="$(resolve_codex_install_dest "$SCOPE")"
      outfile="$(write_codex_agent "$file" "$install_dest")"
      printf '已安装 Codex agent: %s\n' "$outfile"
      ;;
    codex-remove)
      remove_codex_agent "$file"
      ;;
    openclaw)
      install_dest="${DEST:-${PROJECT_DIR}/.generated/openclaw}"
      outdir="$(write_openclaw_agent "$file" "$install_dest")"
      printf '已导出 OpenClaw agent: %s\n' "$outdir"
      ;;
    openclaw-install)
      install_dest="$(resolve_openclaw_install_dest)"
      outdir="$(write_openclaw_agent "$file" "$install_dest")"
      if [[ "$REGISTER" == "1" ]]; then
        register_openclaw_agent "$(basename "$outdir")" "$outdir"
      fi
      printf '已安装 OpenClaw agent: %s\n' "$outdir"
      ;;
    openclaw-remove)
      remove_openclaw_agent "$file"
      ;;
    *)
      err "动作不支持: $action"
      ;;
  esac
}

COMMAND="${1:-}"
[[ -n "$COMMAND" ]] || {
  usage
  exit 1
}
shift || true

QUERY=""
REPO_PATH=""
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
      REPO_PATH="${2:?--repo 需要一个值}"
      shift 2
      ;;
    --dest)
      DEST="${2:?--dest 需要一个值}"
      shift 2
      ;;
    --index)
      INDEX="${2:?--index 需要一个值}"
      INDEX_SET="1"
      shift 2
      ;;
    --scope)
      SCOPE="${2:?--scope 需要一个值}"
      shift 2
      ;;
    --tool)
      TOOL="${2:?--tool 需要一个值}"
      shift 2
      ;;
    --manifest)
      MANIFEST="${2:?--manifest 需要一个值}"
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
      ACTION="${2:?--action 需要一个值}"
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
        err "未知参数: $1"
      fi
      ;;
  esac
done

case "$COMMAND" in
  list-installed)
    ;;
  sync)
    [[ -n "$MANIFEST" ]] || err "缺少 --manifest"
    ;;
  find|pick|show|codex|codex-install|codex-remove|openclaw|openclaw-install|openclaw-remove)
    [[ -n "$QUERY" ]] || err "缺少关键词"
    ;;
  *)
    usage
    exit 1
    ;;
esac

require_cmd rg
case "$COMMAND" in
  list-installed)
    REPO="$(resolve_repo_optional)"
    ;;
  sync)
    REPO="$(resolve_repo)"
    ;;
  *)
    REPO="$(resolve_repo)"
    ;;
esac

case "$COMMAND" in
  list-installed)
    list_installed "$REPO" "$TOOL" "$SCOPE" "$DEST"
    ;;
  sync)
    sync_manifest "$REPO" "$TOOL" "$MANIFEST"
    ;;
  find)
    print_matches "$REPO" "$QUERY"
    ;;
  pick)
    print_matches "$REPO" "$QUERY"
    INDEX="$(pick_interactive_index)"
    ACTION="$(pick_interactive_action)"
    FILE="$(pick_match "$REPO" "$QUERY" "$INDEX")"
    run_selected_action "$ACTION" "$FILE"
    ;;
  show)
    FILE="$(pick_match "$REPO" "$QUERY" "$INDEX")"
    run_selected_action "show" "$FILE"
    ;;
  codex)
    FILE="$(pick_match "$REPO" "$QUERY" "$INDEX")"
    run_selected_action "codex" "$FILE"
    ;;
  codex-install)
    FILE="$(pick_match "$REPO" "$QUERY" "$INDEX")"
    run_selected_action "codex-install" "$FILE"
    ;;
  codex-remove)
    FILE="$(pick_match "$REPO" "$QUERY" "$INDEX")"
    run_selected_action "codex-remove" "$FILE"
    ;;
  openclaw)
    FILE="$(pick_match "$REPO" "$QUERY" "$INDEX")"
    run_selected_action "openclaw" "$FILE"
    ;;
  openclaw-install)
    FILE="$(pick_match "$REPO" "$QUERY" "$INDEX")"
    run_selected_action "openclaw-install" "$FILE"
    ;;
  openclaw-remove)
    FILE="$(pick_match "$REPO" "$QUERY" "$INDEX")"
    run_selected_action "openclaw-remove" "$FILE"
    ;;
esac
