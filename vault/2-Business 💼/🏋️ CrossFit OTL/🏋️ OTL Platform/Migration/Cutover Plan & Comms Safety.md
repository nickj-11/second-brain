---
type: note
tags:
  - otl-platform
  - migration
  - comms
---
# Cutover Plan & Comms Safety

> [!warning] 🟠 Never cut over billing and the app on the same day
> Every other mistake here is recoverable. A botched billing cutover either stops your revenue or
> double-charges your members — and both cost you members. Billing moves **alone**, on a quiet week,
> with nothing else changing.

---

## 📧 The "don't hammer them with emails" problem

You flagged this and you're right to. It's the most common way a migration burns member trust, and
it's entirely preventable. The rule: **import suppressed, verify, then enable.**

### 1. A global kill switch, not per-contact flags
One system-level feature flag that blocks **all** outbound email, SMS and push. Off by default on the
new system. Per-contact flags get missed on one code path and that's all it takes.

### 2. Preserve state, not just membership
An import that carries tags but loses *position* will restart sequences from step one. Carry across:
- tag membership
- which campaigns each member is enrolled in
- **their current step/position** in each sequence
- consent and opt-out status

> [!danger] 🔴 Opt-outs are legally load-bearing
> Someone who unsubscribed and gets re-subscribed by your migration is a CAN-SPAM problem for email
> and a **TCPA** problem for SMS — the latter carries statutory damages per message. Opt-out status
> migrates first and is verified by hand.

### 3. Never let "contact created" fire on import
Every welcome and onboarding sequence triggers on contact creation. Importing 400 members will fire
all of it at once. Either disable those automations during import, or gate every trigger as
`created AND source != 'migration'`.

### 4. Stamp every record
Set `migrated_at` and `migration_source` on import. Then guard every automation: **don't fire for
events that predate `migrated_at`.** This one rule catches most of what the others miss — it stops
you re-celebrating three years of old PRs and re-sending two years of birthday emails.

### 5. Ramp the test, don't big-bang it
- Import into staging with **5 real staff accounts**. Flip sends on. Watch exactly what fires.
- Then 50 members. Watch again.
- Then everyone.

### 6. Quiet period
Sends stay off for 24–48h after go-live while you reconcile. Nothing automated goes out during the
window where you're most likely to find a problem.

### 7. One deliberate announcement, from you
Before cutover, not after. People accept change they were warned about and resent change that just
happens to them. Tell them: what's changing, what they need to do (ideally nothing), what their
statement will say, and that their PR history came with them.

---

## 🚦 Phased cutover

Each phase is independently valuable and independently reversible. Do not skip ahead.

| Phase | What moves | Risk | Reversible? |
|---|---|---|---|
| **0. Extract** | Nothing. Pull and verify all data. | None | n/a |
| **1. Mirror** | New CRM ingests PushPress on a schedule, read-only | None | Yes |
| **2. App v1** | Members log workouts + view schedule in your app | Low | Yes |
| **3. Scheduling** | Reservations and check-in move to you | Medium | Yes, painfully |
| **4. Billing** | Recurring charges move to you. **Alone.** | 🔴 High | Barely |
| **5. Extras** | Social feed, Instagram, appointments | Low | Yes |

> [!tip] 🟣 Phase 1 is the unlock and it's nearly free
> Mirroring live data into your schema, read-only, while PushPress still runs the gym, is how you
> find out your data model is wrong *before* it matters. Cheap to build, catches the expensive
> mistakes, zero operational risk.

---

## 🔴 Cutover day checklist (Phase 4)

- [ ] PushPress recurring billing **confirmed stopped** — verified in their UI, not assumed
- [ ] New biller's first run executed in **test mode** against real schedules, reconciled line by line
- [ ] Every active enrollment matched: amount, interval, next charge date, discounts, paused/comped
- [ ] Statement descriptor checked — members must recognise the charge
- [ ] Sends still suppressed
- [ ] Rollback decided in advance: what "abort" looks like, and who calls it
- [ ] First live cycle reconciled **by hand**, member by member. Budget a full day.

---

## 🗓️ Timing

Cut over billing **immediately after** a billing cycle completes, not before one. That gives you a
full cycle of runway to find problems before money is due again. Avoid the week of the Open, avoid
holidays, avoid anything that spikes attendance.

---

## 🔗 Related

- [[Migration MOC]] — parent
- [[Stripe & Payment Continuity]] — the billing mechanics
- [[Data Inventory & Extraction Routes]] — Phase 0
- [[Scope & Phasing — Honest Estimate]] — how long this really takes
