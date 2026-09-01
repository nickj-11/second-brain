---
type: MOC
tags:
  - home
  - MOC
---
# 🏡 Home

The front door of the vault. Every note is reachable from here by clicking down through MOCs.

> [!tip] 🟣 Set this as your start page: Obsidian → Settings → Appearance is not it —
> use the **Bookmarks** core plugin, or just pin this tab.

---

## 🗂️ Branches

| Branch | What lives there |
|---|---|
| 👤 [[Personal MOC]] | Home, health, family, personal finance |
| 💼 [[Business MOC]] | Companies, products, clients, contracts |
| 📦 [[Other MOC]] | Templates and reference |
| 👥 [[People MOC]] | One note per person worth remembering |
| 📓 [[Notes MOC]] | Daily notes and loose captures |
| 🚀 [[Projects MOC]] | Active projects, one folder each |

---

## 🤖 How this vault maintains itself

> [!info] 🟦 Claude reads the rules in the vault's `CLAUDE.md` and follows them without being asked

- Finished work gets written into the right branch and linked from that folder's MOC.
- `/vault-sync` reconciles every MOC against what's actually on disk.
- `/vault-save` files the thing you just worked on.
- `/vault-find` searches the vault before you go looking anywhere else.
