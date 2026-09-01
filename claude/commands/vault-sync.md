---
description: Reconcile every MOC in the vault against what is actually on disk
---

Run the `vault-moc-sync` skill over `__VAULT_PATH__`.

Create MOCs for folders that don't have one, patch MOCs that have drifted from their folder's real
contents, and flag anything ambiguous rather than guessing.

$ARGUMENTS — if given, limit the sync to that branch or subfolder. If empty, sync the whole vault.

Report grouped by branch: Created / Updated / Flagged. Keep it under 30 lines.
