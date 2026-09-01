---
name: vault-moc-sync
description: Scan the Obsidian second-brain vault for missing or stale MOCs (Maps of Content), create the missing ones, and reconcile existing ones against what is actually on disk. Use when the user says "sync my vault", "update the MOCs", "check the vault index", after any batch of file or folder changes in Obsidian, or at the start of a session whose work will touch the vault.
---

# vault-moc-sync

Keep every folder's Map of Content honest — so the vault's index always matches its contents.

**Vault:** `__VAULT_PATH__`

**Read `__VAULT_PATH__/CLAUDE.md` first.** It defines the convention this skill enforces.

---

## What counts as a problem

- **Missing MOC** — a folder with no `<Folder Name> MOC.md` in it.
- **Stale MOC** — one that links to a file that no longer exists, or fails to mention a file or
  subfolder that does.

**Skip:** `.obsidian/`, `.trash/`, any dot-folder, `5-Notes 📓/Daily Notes/` (indexed once at its
parent), and anything the user has told you is app-managed.

---

## Discovery pass — always start here

```bash
VAULT="__VAULT_PATH__"

# Every folder that should have a MOC
find "$VAULT" -type d \
  -not -path "*/.*" \
  -not -path "*/Daily Notes*" | sort

# Which ones don't
find "$VAULT" -type d -not -path "*/.*" -not -path "*/Daily Notes*" | while read -r dir; do
  ls "$dir"/*\ MOC.md >/dev/null 2>&1 || echo "MISSING: ${dir#$VAULT/}"
done
```

Drift check for an existing MOC — compare what it links to against what's there:

```bash
grep -oE '\[\[[^]]+\]\]' "$moc" | sort -u   # what the MOC claims
ls "$dir"                                    # what actually exists
```

---

## Fixing

**Missing MOC:** read the folder's files first so the MOC says something true, then write it from
`3-Other 📦/Templates/MOC Template.md`. If you genuinely can't tell what the folder is for, write
the stub with a `> [!warning] 🟠 Needs content` callout and move on — don't invent a purpose.

**Stale MOC:** patch it in place.
- Wikilink to a deleted file → remove it, or repoint it if the file clearly moved.
- File in the folder, missing from the MOC → add it to `## 📌 Hub Documents`.
- Subfolder with no link → add it to `## 🗂️ Subfolders` as `[[<Child> MOC]]`.

Preserve everything the human wrote. You're reconciling the index, not rewriting their prose.

---

## Style (must match the vault CLAUDE.md)

- Frontmatter `type: MOC`, `tags: [<topic>, MOC]`.
- H1 is emoji + folder name, without the numeric prefix.
- Every callout headline leads with its color emoji: `[!success]` 🟢 · `[!info]` 🟦 · `[!tip]` 🟣 ·
  `[!warning]` 🟠 · `[!danger]` 🔴 · `[!abstract]` 🟡.
- Required sections: `## 🗂️ Subfolders` (if any), `## 📌 Hub Documents` (if any), `## 🔗 Related`.
- Wikilinks carry no `.md` extension.
- Every non-root MOC links to its parent at the bottom.

---

## Don'ts

- **Never delete a MOC.** If the folder is gone but the MOC remains, flag it for the user.
- **Never touch source files** — only MOCs.
- Don't prefix MOC filenames with `_` or `0-` unless the user asked for that sort order.

---

## Report

Short, grouped by branch:

- **Created** — new MOCs.
- **Updated** — patched MOCs, one line of reason each.
- **Flagged** — stale or ambiguous references that need a human call.

Under ~30 lines. Counts per branch, not a file-by-file enumeration.
