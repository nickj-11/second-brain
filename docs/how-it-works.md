# How it works

There's no server, no plugin, and no magic. Four small pieces, each of which you can read in a
minute.

---

## 1. The standing instruction — `~/.claude/CLAUDE.md`

Claude Code reads this file at the start of every session, in every project. The installer adds a
block to it (between `<!-- BEGIN second-brain -->` markers, so re-running updates it in place rather
than duplicating it):

> **Read from it.** When a question touches my life, projects, money, documents, or people, search
> the vault before asking me or answering from general knowledge.
>
> **Write to it.** When a piece of work is finished and worth having in six months, file it into the
> vault without being asked, then tell me where it landed.

This is the part that makes it automatic. Without it, everything else here is a set of tools nobody
picks up.

## 2. The house rules — `CLAUDE.md` inside the vault

The standing instruction points at this file. It defines the MOC convention, the callout colors, the
note anatomy, and the hard "never" list. Claude reads it before writing anything into the vault.

Keeping the rules *inside* the vault matters: the vault is portable, so the rules travel with it —
to another machine, another person, or a future version of Claude Code that knows nothing about this
repo. It's also the file you edit when you want the style changed. You're not editing a program;
you're editing a description of how you like your notes.

## 3. The skills — `~/.claude/skills/`

Skills are procedures Claude loads on demand, by matching the situation against their description.

- **`second-brain`** — the read-first / save-after procedure. Which branch to pick, how to write the
  note, how to bring in attachments, how to update the folder index, what never to write down.
- **`vault-moc-sync`** — walks the vault, finds folders missing an index and indexes that have
  drifted from their folder's real contents, and fixes them conservatively.

The commands `/vault-save`, `/vault-find`, and `/vault-sync` are thin wrappers that invoke these
explicitly, for when you want to be deliberate about it.

## 4. Directory access — `~/.claude/settings.json`

Your vault usually lives outside whatever project directory you're working in, so Claude would
normally have to ask permission every time it touched it. The installer adds the vault path to
`permissions.additionalDirectories`, which grants standing access to that one folder.

---

## Why MOCs instead of tags or search

Search finds what you remember to look for. An index tells you what's there.

A Map of Content is a per-folder front page listing everything in it — subfolders linked to their
own MOCs, files listed with a one-line purpose. Because every MOC links to its parent, the whole
vault is a tree you can walk from the root, and every note has exactly one place it belongs.

That structure buys three things:

1. **Claude can navigate without searching.** Reading three small index files beats grepping a
   thousand notes, and it produces better answers because the index says what each note is *for*.
2. **Drift is detectable.** A file on disk that no MOC mentions is a bug you can find mechanically.
   That's exactly what `/vault-sync` does.
3. **It stays useful without Claude.** MOCs are just markdown with links. Open the vault on your
   phone and it's still navigable.

Tags and search still work — they're Obsidian features and nothing here breaks them. The MOC is the
backbone; tags are the shortcuts.

## Why the numbered emoji folders

The number controls sort order in Obsidian's sidebar. The emoji makes the branch recognizable at a
glance — you stop reading folder names and start recognizing shapes, which matters a lot more on a
phone than it sounds.

Neither is load-bearing. Rename the branches to whatever fits your life; just give each one a MOC
and mention it in the vault's `CLAUDE.md` so Claude files things in the right place.
