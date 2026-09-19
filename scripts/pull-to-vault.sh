#!/usr/bin/env bash
# Copy this repo's vault content into your real Obsidian vault.
#
# SAFE BY DEFAULT: a file that already exists in your vault is never touched,
# even if it differs — it is reported and left alone. This matters because the
# repo carries scaffold MOCs (Business MOC, Personal MOC, ...) that would
# otherwise overwrite the real ones in an established vault.
#
# Pass --force to update existing files. Each one is backed up to
# <name>.bak-<timestamp> first, so nothing you wrote is ever lost.
#
#   ./scripts/pull-to-vault.sh --only "6-Projects 🚀"           # copy one branch (recommended)
#   ./scripts/pull-to-vault.sh --only "..." --dry-run           # show what would happen
#   ./scripts/pull-to-vault.sh --only "..." --force             # also refresh files that changed
#   ./scripts/pull-to-vault.sh --vault "/path/to/Nick's Vault" --only "..."
#
# Unlike install.sh this touches only vault contents — no skills, commands or
# settings. Use install.sh when you want the Claude Code side wired up too.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
SRC="$REPO/vault"
VAULT=""
DRY_RUN=0
FORCE=0
ONLY=""

bold=$'\033[1m'; off=$'\033[0m'; dim=$'\033[2m'
say()  { printf '%s\n' "$*"; }
ok()   { printf '  \033[32m+\033[0m %s\n' "$*"; }
upd()  { printf '  \033[33m~\033[0m %s %s\n' "$1" "${dim}(yours backed up)${off}"; }
kept() { printf '  \033[34m!\033[0m %s %s\n' "$1" "${dim}(differs — yours kept)${off}"; }
skip() { printf '  \033[2m=\033[0m %s\n' "$*"; }
die()  { printf '\033[31merror:\033[0m %s\n' "$*" >&2; exit 1; }

while [ $# -gt 0 ]; do
  case "$1" in
    --vault)   VAULT="${2:-}"; shift 2 ;;
    --vault=*) VAULT="${1#*=}"; shift ;;
    --only)    ONLY="${2:-}"; shift 2 ;;
    --only=*)  ONLY="${1#*=}"; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    --force)   FORCE=1; shift ;;
    -h|--help) sed -n '2,30p' "${BASH_SOURCE[0]}" | sed -n '/^#/p' | sed 's/^# \{0,1\}//'; exit 0 ;;
    *)         die "unknown option: $1" ;;
  esac
done

[ -d "$SRC" ] || die "no vault/ directory in $REPO"

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
  FOUND="$(mktemp)"; trap 'rm -f "$FOUND"' EXIT
  detect_vaults > "$FOUND" || true
  n="$(wc -l < "$FOUND" | tr -d ' ')"
  case "$n" in
    0) die "no Obsidian vault found — re-run with --vault \"/path/to/vault\"" ;;
    1) VAULT="$(cat "$FOUND")"; say "Found vault: ${bold}${VAULT}${off}" ;;
    *)
      say "Obsidian vaults found:"
      i=1; while IFS= read -r v; do printf '  %d) %s\n' "$i" "$v"; i=$((i+1)); done < "$FOUND"
      [ -t 0 ] || die "multiple vaults found — re-run with --vault \"<path>\""
      printf 'Which one? [1-%s] ' "$n"; read -r pick
      case "$pick" in ''|*[!0-9]*) die "not a valid choice" ;; esac
      [ "$pick" -ge 1 ] && [ "$pick" -le "$n" ] || die "not a valid choice"
      VAULT="$(sed -n "${pick}p" "$FOUND")"
      ;;
  esac
fi

VAULT="${VAULT/#\~/$HOME}"; VAULT="${VAULT%/}"
[ -d "$VAULT" ] || die "vault does not exist: $VAULT"
VAULT="$(cd "$VAULT" && pwd -P)"

say ""
say "  ${bold}from${off}  $SRC${ONLY:+/$ONLY}"
say "  ${bold}to${off}    $VAULT"
[ "$DRY_RUN" -eq 1 ] && say "  ${bold}mode${off}  dry run — nothing will be written"
[ "$FORCE" -eq 1 ] && say "  ${bold}mode${off}  --force — existing files will be updated (backed up first)"
say ""

# ---------------------------------------------------------------- copy
stamp="$(date +%Y%m%d-%H%M%S)"
added=0; updated=0; same=0; left=0

while IFS= read -r -d '' f; do
  rel="${f#"$SRC"/}"
  case "$rel" in .gitkeep|*/.gitkeep) continue ;; esac
  dest="$VAULT/$rel"

  if [ ! -e "$dest" ]; then
    [ "$DRY_RUN" -eq 1 ] || { mkdir -p "$(dirname "$dest")"; cp "$f" "$dest"; }
    ok "$rel"; added=$((added+1))
  elif cmp -s "$f" "$dest"; then
    same=$((same+1))
  elif [ "$FORCE" -eq 1 ]; then
    [ "$DRY_RUN" -eq 1 ] || { cp "$dest" "$dest.bak-$stamp"; cp "$f" "$dest"; }
    upd "$rel"; updated=$((updated+1))
  else
    kept "$rel"; left=$((left+1))
  fi
done < <(find "$SRC${ONLY:+/$ONLY}" -type f -print0)

say ""
say "  ${bold}${added}${off} new   ${bold}${updated}${off} updated   ${bold}${same}${off} already current   ${bold}${left}${off} yours, left alone"
if [ "$updated" -gt 0 ] && [ "$DRY_RUN" -eq 0 ]; then
  say "  ${dim}updated files kept a copy at *.bak-${stamp}${off}"
fi
if [ "$left" -gt 0 ]; then
  say "  ${dim}re-run with --force to update the files listed above${off}"
fi
[ "$DRY_RUN" -eq 1 ] && say "" && say "  Re-run without --dry-run to apply."
say ""
