---
description: Search the second brain before looking anywhere else
---

Search the vault at `__VAULT_PATH__` for: $ARGUMENTS

```bash
VAULT="__VAULT_PATH__"
grep -ril "$ARGUMENTS" "$VAULT" --include="*.md" | head -20
```

Also try obvious variants — singular/plural, a person's first name alone, an acronym spelled out.

Then read the most promising hits and answer the actual question. Report each source as its
vault-relative path so it's clickable in Obsidian. If nothing turns up, say so plainly rather than
answering from general knowledge and letting it look like a vault fact.
