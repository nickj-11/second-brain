# second-brain

An Obsidian vault that Claude Code keeps for you — it reads your notes before answering, and files
finished work back into them without being asked.

Obsidian is just markdown folders on disk. Claude Code can read and write files on disk. The only
thing missing between them is a **convention** — a structure consistent enough that Claude can find
things again six months later, and a standing instruction to actually use it. That's this repo.

```
you  ▸ "we're refinancing the truck — what rate did we lock last time?"
claude ▸ searched the vault, found 2-Business 💼/🚚 Fleet/Loans/Bandit — Loan Terms.md
         14.9% APR, 48 months, opened 2026-03-11. Payoff quote as of last month: $18,204.

you  ▸ "ok, work out what refinancing at 9% saves us"
claude ▸ [does the math]
         Saved to 2-Business 💼/🚚 Fleet/Loans/Refi Analysis — Bandit 2026-09.md
         and linked it from the Loans MOC.
```

Nobody asked it to search. Nobody asked it to save. That's the point.

---

## What you get

| | |
|---|---|
| **A vault skeleton** | Six numbered branches, each with a folder index, plus note templates |
| **A written convention** | `CLAUDE.md` inside the vault — the house rules Claude follows |
| **Two skills** | `second-brain` (read + save) and `vault-moc-sync` (keep the indexes honest) |
| **Three commands** | `/vault-save`, `/vault-find`, `/vault-sync` |
| **A standing instruction** | A block in `~/.claude/CLAUDE.md` that makes all of it automatic |
| **Vault access** | Your vault added to Claude Code's allowed directories, so it stops asking |

No Obsidian community plugins. No paid Obsidian sync. No database. Just markdown.

---

## Install

Requires macOS or Linux, [Obsidian](https://obsidian.md), [Claude
Code](https://claude.com/claude-code), and `python3` (already on macOS).

```bash
git clone https://github.com/nickj-11/second-brain.git
cd second-brain
./install.sh
```

It finds your Obsidian vault (or asks where to put a new one), shows you exactly what it's about to
do, and does it. **It never overwrites a file without backing it up first**, and re-running it is
safe — files you've since edited are left alone.

Already have a vault full of notes and just want the Claude side?

```bash
./install.sh --vault "/path/to/your vault" --no-scaffold
```

Other flags: `--dry-run` (change nothing, just show), `--with-daily-sync` (also install a daily
index-reconcile task), `--help`.

Then **start a new Claude Code session** — config is read at startup — and try:

> *"what's in my second brain about ___?"*
> *"save this to my vault"*

---

## The convention, in 30 seconds

**Every folder has a MOC** — a Map of Content, named `<Folder Name> MOC.md`. It's the folder's front
page: it lists the subfolders (linked to *their* MOCs) and the files at that level. Every note in
the vault is therefore reachable from the root by clicking down. When Claude adds a file, it updates
that folder's MOC in the same edit, so the index never drifts from reality.

**Callout color carries meaning.** 🟢 done · 🟦 reference · 🟣 strategy · 🟠 needs attention ·
🔴 critical or money · 🟡 summary. Every note opens with one callout holding the single most
important fact, so skimming a folder tells you where things stand.

**Notes are dated absolutely, linked with wikilinks, and attachments live inside the vault** —
PDFs get copied in and embedded, never linked to some path that'll break.

The full rules land in your vault at `CLAUDE.md`. Edit them; Claude follows whatever they say.

---

## Daily use

| You say | What happens |
|---|---|
| *"save this to my vault"* or `/vault-save` | Files the current work in the right branch, updates the MOC, tells you the path |
| *"what do I have on ___?"* or `/vault-find` | Searches the vault before answering from anywhere else |
| `/vault-sync` | Walks every folder, creates missing indexes, patches stale ones |
| *nothing* | Finished work gets saved anyway — that's the standing instruction |

Mostly you don't run the commands. You work, and things end up filed.

---

## Safety

- **Claude will not write secrets into the vault** — no passwords, keys, tokens, or full account
  numbers. It's a rule in both the vault's `CLAUDE.md` and the standing instruction, because vaults
  sync to phones and clouds. Last 4 digits are fine.
- **Claude won't delete your notes.** Cleanup gets flagged for you, not performed.
- **Claude won't edit source-of-truth files** — statements, contracts, exports. It summarizes
  alongside them.
- **The installer backs up** anything it replaces, as `<file>.bak-<timestamp>`.

Everything installed is plain markdown you can read in a minute. Read it before you trust it.

---

## Docs

- [How it works](docs/how-it-works.md) — the four moving parts, and why it's built this way
- [Customizing](docs/customizing.md) — your own branches, your own style, your own rules
- [Syncing across devices](docs/syncing-across-devices.md) — iCloud, phones, and a second Mac
- [Troubleshooting](docs/troubleshooting.md) — when Claude ignores the vault

## Uninstall

```bash
rm -rf ~/.claude/skills/second-brain ~/.claude/skills/vault-moc-sync
rm -f  ~/.claude/commands/vault-{save,sync,find}.md
rm -rf ~/.claude/scheduled-tasks/vault-moc-sync-daily
```

Then delete the `<!-- BEGIN second-brain -->` … `<!-- END second-brain -->` block from
`~/.claude/CLAUDE.md`, and your vault path from `permissions.additionalDirectories` in
`~/.claude/settings.json`. Your notes are untouched — they're just markdown, and they were always
yours.

## License

MIT
