# Troubleshooting

## Claude ignores the vault entirely

**Start a new session.** `~/.claude/CLAUDE.md`, skills, and commands are read at startup — an
already-running session won't pick up a fresh install.

Then check the block actually landed:

```bash
grep -c "BEGIN second-brain" ~/.claude/CLAUDE.md   # should print 1
```

If it prints `0`, re-run `./install.sh`. If your Claude Code config lives somewhere other than
`~/.claude`, set `CLAUDE_CONFIG_DIR` and re-run.

## It asks permission every time it touches the vault

The vault isn't in the allowed directories:

```bash
python3 -c "import json;print(json.load(open('$HOME/.claude/settings.json'))['permissions']['additionalDirectories'])"
```

Your vault path should be in that list, spelled **exactly** as it is on disk — emoji, spaces, and
all. iCloud vault paths contain `Library/Mobile Documents/iCloud~md~obsidian/Documents/`; a path
under `~/Documents/` won't match. Re-run the installer with the right `--vault`, or add it by hand.

## `/vault-save` and friends don't exist

```bash
ls ~/.claude/commands/vault-*.md
```

Missing → re-run the installer. Present but unlisted → restart the session.

## Notes get saved, but in the wrong branch

Claude picks the branch from the "Where things go" table in the vault's `CLAUDE.md`. If you renamed
or added folders without updating that table, it's guessing. Update the table.

For a rule that's about you rather than the folders ("fleet stuff always goes under Business, never
Personal"), put it in the vault's `CLAUDE.md` too — that file is the place for anything you'd have
to explain twice.

## The indexes don't match what's in the folders

Run `/vault-sync`. If it keeps drifting, you're probably moving files in Obsidian a lot — turn on
the [daily sync](customizing.md#turn-on-the-daily-index-sync).

## Obsidian shows "conflicted copy" files

Two devices wrote the vault at the same time and the sync service couldn't merge. Prevention: let
one device finish and sync before working on another. Cleanup: open both versions, keep the right
content, delete the conflicted copy, then run `/vault-sync`.

## The installer can't find my vault

Point it directly, and quote the path — vault paths usually contain spaces and emoji:

```bash
./install.sh --vault "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/My Vault"
```

Auto-detection looks two levels deep under `~/Library/Mobile Documents/iCloud~md~obsidian/Documents`,
`~/Documents`, `~/Obsidian`, and `~`. A vault nested deeper than that needs `--vault`.

## I want to undo the install

The installer never destroys anything — everything it replaced is beside the original as
`<file>.bak-<timestamp>`:

```bash
ls ~/.claude/*.bak-* ~/.claude/**/*.bak-* 2>/dev/null
```

Full removal steps are at the bottom of the [README](../README.md).
