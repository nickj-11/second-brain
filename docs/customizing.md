# Customizing

Nothing here is fixed. Every part of the behavior is a markdown file you can edit, and Claude reads
your edits the next session.

---

## Change the branches

The six starter branches are a suggestion. Delete what you don't need, add what you do:

1. Create the folder in Obsidian, with a numeric prefix for sort order: `7-Health 🩺`.
2. Give it a MOC: copy `3-Other 📦/Templates/MOC Template.md` to `7-Health 🩺/Health MOC.md`, or
   just ask Claude to — *"add a Health branch to my vault"*.
3. Add a row for it to the "Where things go" table in the vault's `CLAUDE.md`, so Claude knows what
   belongs there.

Step 3 is the one people skip. Without it, Claude has a folder but no idea what it's for, and your
health notes end up in Personal.

## Change the writing style

Edit `3-Other 📦/Templates/Note Template.md` and `MOC Template.md`. Claude copies these when writing
anything new, so changing them changes every future note — no need to restyle old ones.

Don't like emoji headers? Take them out of the templates and out of the vault's `CLAUDE.md`. Want a
`status:` field in every note's frontmatter? Add it to the template. Want notes in a language other
than English? Say so in the vault's `CLAUDE.md`.

## Change what gets saved automatically

The default is "anything finished and worth having in six months." That's deliberately broad. Tune
it by editing the `<!-- BEGIN second-brain -->` block in `~/.claude/CLAUDE.md`:

**More conservative** — add:
> Only save to the vault when I explicitly ask. Offer to save when you think something belongs
> there, but wait for a yes.

**More aggressive** — add:
> Also save open questions, half-finished research, and things I said I'd come back to — file them
> under `5-Notes 📓` with a `> [!warning] 🟠 Unfinished` callout.

**Project-specific** — add:
> Anything related to <project> goes in `6-Projects 🚀/<project>/`, always, even when it also
> touches money.

## Per-project rules

A `CLAUDE.md` in a code repo applies only inside that repo, and stacks on top of the global one.
Useful for wiring a specific project to a specific vault branch:

```markdown
When work in this repo is finished, save the writeup to
`~/…/Vault/6-Projects 🚀/Acme API/` and link it from that folder's MOC.
```

## Turn on the daily index sync

If you move files around in Obsidian by hand, the indexes drift. A daily reconcile catches it:

```bash
./install.sh --vault "/path/to/vault" --with-daily-sync --no-scaffold
```

Then schedule it from a Claude Code session with `/schedule`. It's conservative by design — it
creates and patches indexes, and flags anything ambiguous rather than guessing.

## Use it from your phone

Obsidian's mobile app reads the same vault (via iCloud Drive, Obsidian Sync, or Dropbox — see
[syncing](syncing-across-devices.md)). Claude Code doesn't run on the phone, but everything it wrote
is there: MOCs are navigable, callouts render in color, wikilinks tap through. Capture on the phone,
let Claude file it later.
