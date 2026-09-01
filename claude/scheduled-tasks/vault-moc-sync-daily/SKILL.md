---
name: vault-moc-sync-daily
description: Daily reconcile of the second-brain vault's MOCs
---

Run the `vault-moc-sync` skill against the vault at `__VAULT_PATH__`.

1. Read `__VAULT_PATH__/CLAUDE.md` to refresh the convention.
2. Read `3-Other 📦/Templates/MOC Template.md`.
3. Walk every folder, skipping `.obsidian`, `.trash`, dot-folders, and `5-Notes 📓/Daily Notes`.
4. Create any missing `<Folder Name> MOC.md`; patch any MOC that has drifted from its folder's
   real contents.
5. Be conservative: never delete a MOC or a source file. Flag anything ambiguous instead of
   guessing.

Report grouped by branch — Created / Updated / Flagged — under 30 lines.
