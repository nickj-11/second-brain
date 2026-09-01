# Vault Rules — read this before touching anything

This folder is a **second brain**: an Obsidian vault that Claude reads from and writes to on its
own. These are the house rules. Follow them exactly — consistency is the whole point, because it's
what lets Claude find things again months later.

---

## 1. The one structural rule: every folder has a MOC

MOC = **Map of Content**. It's the folder's front page.

- Every folder contains a file named `<Folder Name> MOC.md`.
  The trailing ` MOC` is part of the filename: `House/House MOC.md`, `Clients/Clients MOC.md`.
- The MOC lists **everything** in that folder: subfolders (as links to their MOCs) and root-level
  files (in a Hub Documents table).
- The MOC links back up to its parent MOC. Every note is therefore reachable from the vault root by
  clicking down through MOCs.
- **When you add, rename, move, or delete a file, update that folder's MOC in the same edit.**
  Never leave drift for a later sync to clean up.

Scaffold to copy from: `3-Other 📦/Templates/MOC Template.md`.

**Exempt from needing their own MOC:** `.obsidian/`, `.trash/`, any dot-folder, and
`5-Notes 📓/Daily Notes/` (indexed once at its parent, not per-day).

---

## 2. Callouts are color-coded, and the color carries meaning

Obsidian renders `> [!type]` callouts in a fixed color. Use the color that matches the *meaning*,
and **lead every callout headline with the matching emoji** so it reads correctly on mobile, in
search results, and in plain text.

| Callout | Color | Emoji | Use it for |
|---|---|---|---|
| `> [!success]` | green | 🟢 | Done, confirmed, locked in |
| `> [!info]` | blue | 🟦 | Reference, neutral state |
| `> [!tip]` | purple | 🟣 | Strategy, plans, recommendations |
| `> [!warning]` | orange | 🟠 | Caution, needs attention |
| `> [!danger]` | red | 🔴 | Critical, urgent, money or safety |
| `> [!abstract]` | gray | 🟡 | Overview, summary, TL;DR |

```markdown
> [!success] 🟢 Closed on the house — May 7
> $275,000 · 100% financed · nothing owed back
```

---

## 3. Note anatomy

Every note:

- Starts with a single `# Title` (matching the filename).
- Uses emoji `##` section headers — 📋 contract · 🔍 inspection · 🛡️ insurance · 💸 finance ·
  🛠️ tasks · 👥 people · ⏱️ timeline · 📚 reference · 🧭 strategy · 🔗 related.
- Opens with one callout that gives the single most important fact at a glance. If someone reads
  only that callout, they should still know where things stand.
- Ends with a `## 🔗 Related` section linking the parent MOC and any sibling notes.
- Links with wikilinks and **no extension**: `[[Our House — Purchase Details]]`.
- Writes dates absolutely — "2026-05-07", never "last Tuesday".

Attachments (PDF, image, spreadsheet): **copy the actual file into the folder**, then embed it with
`![[filename.pdf]]` and add it to the MOC's Hub Documents table. Never link to a path outside
the vault — it will break.

---

## 4. Where things go

| Branch | What lives there |
|---|---|
| `1-Personal 👤` | Home, health, family, personal finance |
| `2-Business 💼` | Companies, products, clients, contracts |
| `3-Other 📦` | Templates, reference, anything that fits nowhere else |
| `4-People 👥` | One note per person worth remembering |
| `5-Notes 📓` | Daily notes and loose captures |
| `6-Projects 🚀` | Active projects, one folder each |

Rename or add branches freely — just keep the numeric prefix (it controls sort order) and give the
new folder a MOC.

---

## 5. What Claude does here, unprompted

- **Reads before asking.** If the answer might already be in the vault, search the vault first.
- **Saves finished work.** When a piece of work is done — research, a decision and its reasoning, a
  build writeup, an analyzed document — write it into the right branch, update that folder's MOC,
  and say where it landed.
- **Keeps the index honest.** Structural change to a folder → its MOC changes in the same breath.

## 6. What Claude never does here

- **Never write secrets** — passwords, API keys, tokens, full account or card numbers. The vault
  syncs to a cloud and to phones. Last 4 digits are fine; the full number is not.
- **Never delete a note or a MOC** to tidy up. Flag it and let the human decide.
- **Never rewrite source-of-truth files** (statements, contracts, exports). Summarize alongside them.
- **Never invent facts** to fill a template. Write the stub, add a
  `> [!warning] 🟠 Needs content` callout, move on.
