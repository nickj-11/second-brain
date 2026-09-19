---
type: MOC
tags:
  - otl-platform
  - migration
  - MOC
---
# 📦 Migration

Getting everything — members, money, history — out of PushPress and into the OTL platform without
breaking the gym.

> [!danger] 🔴 Phase 0 is urgent and independent of everything else
> Extract and verify all PushPress data **while still a paying customer**. Access dies with the
> account, and workout results have no supported export path. Days of work; protects years of member
> history.

---

## 📌 Hub Documents

| File | Purpose |
|------|---------|
| 📄 [[Data Inventory & Extraction Routes]] | Every dataset, its best extraction route, and the reconciliation checklist |
| 📄 [[Stripe & Payment Continuity]] | Why members likely never re-enter a card — and the fallback if they do |
| 📄 [[Cutover Plan & Comms Safety]] | Phased switch, and how to migrate without spamming everyone |
| 🐍 `pushpress_extract.py` | Read-only extractor for the documented v3 API |

---

## 🧰 Running the extractor

```bash
export PUSHPRESS_API_KEY=...        # Core → Settings → Security & Access → Add API Key
export PUSHPRESS_COMPANY_ID=...
python3 pushpress_extract.py --out ./extract
```

Pulls customers, enrollments, classes, class types, events, reservations, invitations and all four
check-in types to timestamped JSON, with a manifest of counts to reconcile against the Core UI.
Handles pagination and rate limits; safe to re-run. **Read-only — it never writes to PushPress.**

Not covered, by design: results/PRs (no endpoint), cards (Stripe), tags and campaigns (Grow),
profile photos and social content (app responses).

---

## ⏱️ Order of operations

1. **Verify Stripe account ownership** — 30 minutes, determines the whole payment plan. If it's ours,
   members re-enter **nothing** and there is no payment migration at all
2. **Ask PushPress in writing** what export they provide to departing customers
3. **Run the extractor**, reconcile counts against the UI
4. **Capture ACH authorization records** — the one realistic path to members having to re-enter bank
   details, and it is avoidable
5. **Solve results/PRs** — the only dataset with no supported route
6. Everything else waits on the build

---

## 🔗 Related

- [[🏋️ OTL Platform MOC]] — parent
- [[Build MOC]] — what we're migrating into
- [[Incumbent — PushPress MOC]] — what we're migrating out of
