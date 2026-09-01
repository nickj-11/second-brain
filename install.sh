#!/usr/bin/env bash
#
# second-brain installer
#
# Wires an Obsidian vault into Claude Code so Claude reads from it and writes to it on its own.
# Safe to re-run: never overwrites a file without backing it up first.
#
#   ./install.sh                        interactive
#   ./install.sh --vault "/path/to/Vault"
#   ./install.sh --vault "..." --no-scaffold      # config only, leave the vault contents alone
#   ./install.sh --vault "..." --with-daily-sync  # also install the daily MOC-sync task
#   ./install.sh --vault "..." --dry-run          # show what would happen, change nothing

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
STAMP="$(date +%Y%m%d-%H%M%S)"

VAULT=""
SCAFFOLD=1
DAILY_SYNC=0
DRY_RUN=0

bold=$'\033[1m'; dim=$'\033[2m'; green=$'\033[32m'; yellow=$'\033[33m'; red=$'\033[31m'; off=$'\033[0m'
say()  { printf '%s\n' "$*"; }
ok()   { printf '  %s✓%s %s\n' "$green" "$off" "$*"; }
skip() { printf '  %s·%s %s\n' "$dim" "$off" "$*"; }
warn() { printf '  %s!%s %s\n' "$yellow" "$off" "$*"; }
die()  { printf '%serror:%s %s\n' "$red" "$off" "$*" >&2; exit 1; }

while [ $# -gt 0 ]; do
  case "$1" in
    --vault)           VAULT="${2:-}"; shift 2 ;;
    --vault=*)         VAULT="${1#*=}"; shift ;;
    --no-scaffold)     SCAFFOLD=0; shift ;;
    --with-daily-sync) DAILY_SYNC=1; shift ;;
    --dry-run)         DRY_RUN=1; shift ;;
    -h|--help)         sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *)                 die "unknown option: $1" ;;
  esac
done

command -v python3 >/dev/null 2>&1 || die "python3 is required (used to edit settings.json safely)"

# ---------------------------------------------------------------- find the vault

detect_vaults() {
  local roots=(
    "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents"
    "$HOME/Documents"
    "$HOME/Obsidian"
    "$HOME"
  )
  for root in "${roots[@]}"; do
    [ -d "$root" ] || continue
    find "$root" -maxdepth 2 -name ".obsidian" -type d 2>/dev/null | while read -r m; do
      dirname "$m"
    done
  done | sort -u
}

if [ -z "$VAULT" ]; then
  # No arrays here on purpose: bash 3.2 (the macOS default) errors on an empty array under `set -u`.
  FOUND_LIST="$(mktemp)"
  trap 'rm -f "$FOUND_LIST"' EXIT
  detect_vaults > "$FOUND_LIST" || true
  COUNT="$(grep -c . "$FOUND_LIST" || true)"

  if [ "$COUNT" -eq 1 ]; then
    VAULT="$(cat "$FOUND_LIST")"
    say "Found one Obsidian vault: ${bold}${VAULT}${off}"
  elif [ "$COUNT" -gt 1 ]; then
    say "Obsidian vaults found:"
    i=1
    while IFS= read -r v; do say "  $i) $v"; i=$((i+1)); done < "$FOUND_LIST"
    [ -t 0 ] || die "multiple vaults found — re-run with --vault \"<path>\""
    printf 'Which one? [1-%s] ' "$COUNT"; read -r pick
    case "$pick" in ''|*[!0-9]*) die "invalid choice" ;; esac
    [ "$pick" -ge 1 ] && [ "$pick" -le "$COUNT" ] || die "invalid choice"
    VAULT="$(sed -n "${pick}p" "$FOUND_LIST")"
  else
    [ -t 0 ] || die "no vault found — re-run with --vault \"<path>\""
    say "No Obsidian vault found."
    printf 'Path to the vault to create or use: '; read -r VAULT
  fi
fi

[ -n "$VAULT" ] || die "no vault path"
VAULT="${VAULT/#\~/$HOME}"
VAULT="${VAULT%/}"

if [ ! -d "$VAULT" ]; then
  [ -t 0 ] || die "vault does not exist: $VAULT"
  printf 'Create %s ? [y/N] ' "$VAULT"; read -r yn
  case "$yn" in [yY]*) [ "$DRY_RUN" -eq 1 ] || mkdir -p "$VAULT" ;; *) die "aborted" ;; esac
fi

# Normalize: a relative path or one with ".." would get baked into settings.json as-is.
[ -d "$VAULT" ] && VAULT="$(cd "$VAULT" && pwd -P)"

say ""
say "${bold}second-brain${off}"
say "  vault        $VAULT"
say "  claude dir   $CLAUDE_DIR"
say "  scaffold     $([ $SCAFFOLD -eq 1 ] && echo yes || echo 'no (config only)')"
say "  daily sync   $([ $DAILY_SYNC -eq 1 ] && echo yes || echo no)"
[ "$DRY_RUN" -eq 1 ] && say "  ${yellow}dry run — nothing will be written${off}"
say ""

run() { [ "$DRY_RUN" -eq 1 ] && return 0; "$@"; }

# Copy a file, substituting __VAULT_PATH__, backing up anything it would replace.
install_file() {
  local src="$1" dest="$2" rel="$3"
  if [ -f "$dest" ] && cmp -s <(VAULT="$VAULT" python3 -c '
import os,sys
sys.stdout.write(open(sys.argv[1],encoding="utf-8").read().replace("__VAULT_PATH__", os.environ["VAULT"]))
' "$src") "$dest"; then
    skip "$rel (already current)"
    return 0
  fi
  if [ -f "$dest" ]; then
    warn "$rel exists — backed up to $(basename "$dest").bak-$STAMP"
    run cp "$dest" "$dest.bak-$STAMP"
  fi
  [ "$DRY_RUN" -eq 1 ] || {
    mkdir -p "$(dirname "$dest")"
    VAULT="$VAULT" python3 -c '
import os,sys
src,dest=sys.argv[1],sys.argv[2]
open(dest,"w",encoding="utf-8").write(
    open(src,encoding="utf-8").read().replace("__VAULT_PATH__", os.environ["VAULT"]))
' "$src" "$dest"
  }
  ok "$rel"
}

# ---------------------------------------------------------------- 1. vault contents

if [ "$SCAFFOLD" -eq 1 ]; then
  say "${bold}1. Vault structure${off}"
  ( cd "$REPO/vault" && find . -type f ! -name ".gitkeep" -print0 ) | \
  while IFS= read -r -d '' f; do
    rel="${f#./}"
    dest="$VAULT/$rel"
    if [ -e "$dest" ]; then
      skip "$rel (yours — left alone)"
    else
      [ "$DRY_RUN" -eq 1 ] || { mkdir -p "$(dirname "$dest")"; cp "$REPO/vault/$rel" "$dest"; }
      ok "$rel"
    fi
  done
  # Daily Notes folder carries no file of its own
  [ "$DRY_RUN" -eq 1 ] || mkdir -p "$VAULT/5-Notes 📓/Daily Notes"
  say ""
else
  say "${bold}1. Vault structure${off}"; skip "skipped (--no-scaffold)"; say ""
fi

# ---------------------------------------------------------------- 2. skills + commands

say "${bold}2. Claude skills and commands${off}"
install_file "$REPO/claude/skills/second-brain/SKILL.md"   "$CLAUDE_DIR/skills/second-brain/SKILL.md"   "skills/second-brain"
install_file "$REPO/claude/skills/vault-moc-sync/SKILL.md" "$CLAUDE_DIR/skills/vault-moc-sync/SKILL.md" "skills/vault-moc-sync"
for c in vault-save vault-sync vault-find; do
  install_file "$REPO/claude/commands/$c.md" "$CLAUDE_DIR/commands/$c.md" "commands/$c"
done
if [ "$DAILY_SYNC" -eq 1 ]; then
  install_file "$REPO/claude/scheduled-tasks/vault-moc-sync-daily/SKILL.md" \
               "$CLAUDE_DIR/scheduled-tasks/vault-moc-sync-daily/SKILL.md" "scheduled-tasks/vault-moc-sync-daily"
fi
say ""

# ---------------------------------------------------------------- 3. standing instructions

say "${bold}3. Standing instructions (~/.claude/CLAUDE.md)${off}"
GLOBAL_MD="$CLAUDE_DIR/CLAUDE.md"
if [ "$DRY_RUN" -eq 1 ]; then
  skip "would add the second-brain block"
else
  mkdir -p "$CLAUDE_DIR"
  VAULT="$VAULT" SNIPPET="$REPO/claude/CLAUDE.snippet.md" TARGET="$GLOBAL_MD" STAMP="$STAMP" python3 <<'PY'
import os, pathlib, re
target = pathlib.Path(os.environ["TARGET"])
block = pathlib.Path(os.environ["SNIPPET"]).read_text(encoding="utf-8").replace(
    "__VAULT_PATH__", os.environ["VAULT"]).strip()
begin, end = "<!-- BEGIN second-brain -->", "<!-- END second-brain -->"
new = f"{begin}\n{block}\n{end}"
original = target.read_text(encoding="utf-8") if target.exists() else ""
if begin in original and end in original:
    text = re.sub(re.escape(begin) + r".*?" + re.escape(end), lambda _: new, original, flags=re.S)
    action = "updated"
else:
    text = (original.rstrip() + "\n\n" + new + "\n") if original.strip() else new + "\n"
    action = "added"
if text == original:
    print("  \033[2m·\033[0m second-brain block already current")
else:
    if original:
        target.with_suffix(target.suffix + ".bak-" + os.environ["STAMP"]).write_text(
            original, encoding="utf-8")
    target.write_text(text, encoding="utf-8")
    print(f"  \033[32m✓\033[0m second-brain block {action}")
PY
fi
say ""

# ---------------------------------------------------------------- 4. directory access

say "${bold}4. Vault access (~/.claude/settings.json)${off}"
SETTINGS="$CLAUDE_DIR/settings.json"
if [ "$DRY_RUN" -eq 1 ]; then
  skip "would add the vault to permissions.additionalDirectories"
else
  VAULT="$VAULT" TARGET="$SETTINGS" STAMP="$STAMP" python3 <<'PY'
import json, os, pathlib, sys
target = pathlib.Path(os.environ["TARGET"]); vault = os.environ["VAULT"]
original = target.read_text(encoding="utf-8") if target.exists() else ""
if original:
    try:
        data = json.loads(original)
    except json.JSONDecodeError as e:
        # Don't fail the whole install over a settings file we didn't write.
        print(f"  \033[33m!\033[0m settings.json is not valid JSON ({e}) — "
              f'add "{vault}" to permissions.additionalDirectories by hand')
        raise SystemExit(0)
else:
    data = {}
perms = data.setdefault("permissions", {})
dirs = perms.setdefault("additionalDirectories", [])
if vault in dirs:
    print("  \033[2m·\033[0m vault already allowed")
else:
    dirs.append(vault)
    target.parent.mkdir(parents=True, exist_ok=True)
    if original:
        target.with_suffix(target.suffix + ".bak-" + os.environ["STAMP"]).write_text(
            original, encoding="utf-8")
    target.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
    print("  \033[32m✓\033[0m vault added to permissions.additionalDirectories")
PY
fi

# ---------------------------------------------------------------- done

say ""
say "${bold}Done.${off}"
say ""
say "Next:"
say "  1. Open the vault in Obsidian (Open folder as vault → pick it). No plugins needed."
say "  2. Start a ${bold}new${off} Claude Code session — config is read at startup."
say "  3. Try it:"
say "       ${dim}\"what's in my second brain about the house?\"${off}   → /vault-find"
say "       ${dim}\"save this to my vault\"${off}                        → /vault-save"
say "       ${dim}/vault-sync${off}                                     → rebuild every folder index"
if [ "$DAILY_SYNC" -eq 1 ]; then
  say ""
  say "  The daily sync task is installed at ${dim}$CLAUDE_DIR/scheduled-tasks/vault-moc-sync-daily${off}."
  say "  Schedule it from Claude Code with: ${dim}/schedule${off}"
fi
say ""
say "Backups of anything replaced end in ${dim}.bak-$STAMP${off}."
