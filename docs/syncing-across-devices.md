# Syncing across devices

The vault is a folder of markdown files, so any file-sync service works. What matters is picking
one and understanding its failure mode.

| Option | Cost | Notes |
|---|---|---|
| **iCloud Drive** | free with iCloud | Obsidian mobile reads it natively on iOS. Files can be *evicted* — present as tiny `.icloud` placeholders — until opened. Claude reads a placeholder as an empty file. |
| **Obsidian Sync** | paid | Built for this. End-to-end encrypted, handles conflicts properly, version history. |
| **Dropbox / Drive** | free tier | Fine on desktop; the mobile apps don't expose files to Obsidian as cleanly. |
| **Git** | free | Great history and conflict handling, but you're committing your private life to a repo — if you do, make it **private**, and remember Claude is told not to write secrets precisely because copies spread. |

## The one rule, whichever you pick

**Work on one machine at a time, and let it finish syncing before switching.** Two devices writing
the same vault produces conflicted copies, and a conflicted MOC is worse than a stale one — Claude
will read one, you'll read the other, and you'll disagree about reality.

## A second computer

Install the vault sync (so the notes arrive), then run the installer again on that machine:

```bash
git clone https://github.com/nickj-11/second-brain.git
cd second-brain
./install.sh --vault "/path/to/the synced vault" --no-scaffold
```

`--no-scaffold` matters: the vault contents already exist, and you only want the Claude-side config.

## What does *not* sync

Claude Code's own configuration — `~/.claude/` — is per-machine. It holds your login, your session
history, and machine-specific paths. Re-running the installer is the intended way to bring a second
machine up to parity, not symlinking `~/.claude` into a cloud folder.

That's worth stating plainly because the symlink idea is tempting and it fails badly: cloud
services deliver folders lazily, so an empty-looking `~/.claude` can leave Claude Code with no
commands and confused permissions until the sync catches up.
