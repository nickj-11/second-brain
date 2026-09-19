---
type: note
tags:
  - pushpress
  - api
  - gym-app
  - decision
---
# Workout & PR Data — Access Options

> [!danger] 🔴 This is the one blocker on the whole project
> Members' scores, benchmark history and PRs live in Train. The public Platform API **does not expose
> them** — no endpoint, no data model, no webhook event, confirmed against the official SDK source on
> 2026-09-19. Every other piece of the app is buildable today; this piece needs a decision.

---

## 🧭 Options, ranked

### 1. Ask PushPress directly for Train/results API access — do this first
Cheapest possible move and it unblocks the best version of the app. The v3 API is clearly still
growing (webhooks, messaging and an Integrations Hub all shipped recently), so results endpoints may
be on the roadmap, in private beta, or grantable per-partner.

Ask `support@pushpress.com`, and push for a developer/partner contact rather than tier-1 support:
- Are there Train workout/result/PR endpoints, documented or in beta?
- Is there a webhook for a result being logged or a PR being hit?
- Is there a partner/app program that grants broader data access?
- Any supported bulk export of historical results beyond the leaderboard export?

> [!tip] 🟣 Frame it as "we're building on top of PushPress, not away from it"
> They have a self-serve API, an app store and a branded-app product — they're courting builders.
> A gym that wants to build *more* on the platform is the easy yes.

### 2. Ship the half that works now, in parallel
Do not let the results question hold the project. Available through the API today, with a key we can
mint in five minutes: members, attendance and check-in history, class and appointment schedules,
reservations and no-shows, enrollments and plans, plus email/SMS/push messaging.

That already supports attendance streaks, retention and at-risk-member flagging, coach dashboards,
capacity and schedule analytics, and automated member comms. Scores plug in later as a data source
swap, not a rewrite. Build the schema now with a `results` table the API doesn't yet fill.

### 3. Leaderboard export as a stopgap
Core can export class and client scores and results from the browser (Train → leaderboard results).
Manual and unscheduled, but good enough to prove out the analytics and PR logic on real data while
option 1 is in flight. Treat it as a seed load, never as the sync mechanism.

> [!info] 🟦 Verified 2026-09-19: this is an industry norm, not a PushPress gap
> SugarWOD — another CAP partner, with the most openly documented API in the space — also exposes no
> athlete scores. Its performance-summary endpoints are published but marked "not yet available."
> **Switching platforms does not solve this.** See [[SugarWOD API — Industry Comparison]].

### 4. Branded member app
PushPress sells a white-label branded member app (their docs cover the Apple Developer account
setup). If the goal is mostly "our gym's name on the app our members already use", this may beat
building from scratch — it ships with results and PR tracking already working. Worth pricing before
committing engineering time.

### ❌ Not on the table
Scraping the member app or reverse-engineering Train's private endpoints. It breaks on their next
deploy, almost certainly violates the terms we're already paying under, and puts member PII through
an unsanctioned path. Not worth it when option 1 is an email.

---

## 🛠️ Next actions

- [ ] Mint a Core API key: Settings → Security & Access → Add API Key — store in the secret manager, **not here**
- [ ] `GET /customers` and `GET /checkins/class` against production to confirm the key and `companyId` work
- [ ] Email PushPress with the four questions above
- [ ] Register a webhook on `checkin.created` and confirm delivery + signature verification
- [ ] Pull one leaderboard export to seed the results schema
- [ ] Price the branded app option for comparison
- [ ] Locate our CAP Google Docs delivery in the Affiliate Toolkit — the one content route we control outright

---

## 🔗 Related

- [[Incumbent — PushPress MOC]] — parent
- [[PushPress API — Keys & Auth]] — minting the key
- [[PushPress Platform API — Endpoint Inventory]] — the full surface, and the gap
- [[CrossFit Affiliate Programming → Train Sync]] — programming side, already solved
- [[SugarWOD API — Industry Comparison]] — the control case proving this gap is industry-wide
