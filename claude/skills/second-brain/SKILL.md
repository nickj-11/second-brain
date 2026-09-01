---
name: second-brain
description: Save finished work into the user's Obsidian second-brain vault, and search the vault before answering questions about their life, projects, money, or people. Use whenever a piece of work is finished and worth keeping, whenever the user says "save this", "put this in my vault", "second brain", or when a question might already be answered by something in the vault.
---

# second-brain

The user keeps an Obsidian vault as their second brain. You read from it and write to it without
being asked.

**Vault:** `__VAULT_PATH__`

**Before you write anything into it, read `__VAULT_PATH__/CLAUDE.md`.** It defines the MOC
convention, the callout colors, and the note anatomy. Match it exactly — a note that doesn't match
is worse than no note, because it breaks the pattern the rest of the vault relies on.

---

## Read first

When a question touches the user's life, projects, money, documents, or people, search the vault
before asking them or guessing:

```bash
VAULT="__VAULT_PATH__"
grep -ril "<term>" "$VAULT" --include="*.md" | head -20
```

If you find a relevant note, read it and say what you found. Don't ask the user for something the
vault already knows.

---

## Save after

When a piece of work is finished and would be worth having in six months — research, a decision
plus its reasoning, a build or debug writeup, an analyzed document, a plan — file it. Don't ask
permission; do it and say where it landed.

**What counts:** conclusions, decisions, summaries, reference material, anything you'd otherwise
lose when the session ends.
**What doesn't:** work-in-progress, scratch output, or anything that lives better in the repo
(code, READMEs, migrations).

### The five steps, every time

1. **Pick the branch.** Match the topic to an existing folder. Personal → `1-Personal 👤`,
   work → `2-Business 💼`, an active build → `6-Projects 🚀`. If the right folder doesn't exist,
   create it *and* give it a `<Folder Name> MOC.md` from the template.
2. **Write the note.** Copy `3-Other 📦/Templates/Note Template.md` and fill it in. `# Title`
   matching the filename, an opening callout carrying the single most important fact, emoji `##`
   sections, absolute dates.
3. **Bring the attachments in.** Copy any PDF, image, or export *into the folder* and embed it with
   `![[filename.pdf]]`. Never link to a path outside the vault.
4. **Update the MOC.** Add the new note to that folder's `## 📌 Hub Documents` table as
   `[[Note Name]]` with a one-line purpose. This is not optional — an unlinked note is a lost note.
5. **Report the path.** Tell the user exactly where it went, vault-relative.

---

## Hard rules

- **No secrets.** Never write passwords, API keys, tokens, or full account/card numbers into the
  vault — it syncs to the cloud and to phones. Last 4 digits are fine.
- **Never delete** a note or MOC to tidy up. Flag it and let the user decide.
- **Never invent facts** to fill a template. Write a stub with a `> [!warning] 🟠 Needs content`
  callout instead.
- **Never edit source-of-truth files** (statements, contracts, exports). Summarize alongside them.
- **One folder = one MOC**, and structural changes update the MOC in the same edit.

---

## Related

- `vault-moc-sync` — reconcile every MOC in the vault against what's actually on disk.
