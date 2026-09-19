---
type: note
tags:
  - otl-platform
  - migration
  - pushpress
---
# Data Inventory & Extraction Routes

> [!danger] 🔴 Do this before anything else, and before giving PushPress any notice
> The moment the account lapses, access goes — and with it your members' entire PR and benchmark
> history. **Extract and verify everything while you are still a paying customer in good standing.**
> This is pure insurance, it's cheap, and it's valuable no matter what you end up building.

---

## 🗺️ Route for every dataset

Scraping is the *last* route for each row, not the first — a documented API gives you typed, complete,
repeatable data; a scrape gives you rendered strings that break on their next deploy.

| Data | Best route | Notes |
|---|---|---|
| Member profiles, contact info | API `GET /customers` | Richer and repeatable; Core's "Download Members" CSV is the cross-check |
| Emergency contacts | ❓ Verify — may be CSV-only or app-only | Confirm early; likely a scrape target |
| Profile pictures | ❓ Check if the API returns URLs | Else pull from the app's own JSON responses |
| Tags / segments | Grow API or CSV export | **Critical** — drives campaign safety on import |
| Leads / prospects | Grow CRM (separate product, separate API key) | Don't forget these; they're future revenue |
| Enrollments & plans | API `GET /enrollments`, `GET /plans/{id}` | The billing schedule source |
| Check-in history | API `/checkins/class`, `/appointment`, `/event`, `/open` | Supports `after`/`before` date filters |
| Classes, events, appointments | API `/classes`, `/events`, `/appts/{id}` | Includes class types |
| Reservations & no-shows | API `/reservations` | |
| Committed Club, streaks, all-time check-ins | **Derive — do not scrape** | Recompute from check-in history; more reliable than copying a number |
| Cards & bank accounts | **Stripe — never PushPress** | See [[Stripe & Payment Continuity]] |
| 🔴 **ACH authorization records** — when/how each bank-debit member authorized | PushPress — ❓ verify where it lives | **Time-sensitive.** Without this evidence ACH members may have to re-authorize |
| Payment / invoice history | Stripe API | Stripe is the source of truth, not the CRM |
| **Products & services** (Element, scans, merch) | ✅ Core → Reports → Financial → **Retail Sales** → Download Data | Supported CSV/Excel. Set **Advanced Data Options → All Results** |
| **Sales & POS transaction history** | ✅ Core → Reports → Financial → **Financial Details** | Every payment, refund, discount and fee. Best report for audit |
| Sales tax configuration | Core settings — carry across deliberately | Per-product; don't re-derive it |
| Programming / WODs | CAP via a partner platform API, the weekly email, or the Toolkit | Included with affiliation; see [[CAP Programming — Independent Ingestion]] |
| **Workout results, benchmarks, PRs** | 🔴 **No supported export** | Leaderboard export + app scrape only |
| Comments, reactions, social posts | Almost certainly no export | Decide: migrate, archive, or start fresh |

---

## 🔴 The one that will bite you

> [!danger] 🔴 Results, benchmarks and PRs have no API and no documented bulk export
> Confirmed across both PushPress and SugarWOD — nobody in this space publishes athlete results.
> And this is the dataset with the most emotional weight for members: years of PR history is the
> thing they will be angriest to lose, and the thing most likely to make them resist the move.
>
> **Solve this first.** Before you cancel anything, before you write a line of the new CRM. Your
> leverage with PushPress support is at its maximum while you are still a customer.

Order of attack:
1. **Ask PushPress for a full data export, in writing.** They run a migration team that imports data
   *in* — ask what they provide going *out*. Get the answer documented.
2. **Leaderboard export** from Core (browser) — check whether rows carry member, workout, date, score
   and input type. If structured, it may be enough on its own.
3. **Capture the app's own API responses** — see below. Last resort, but the cleanest form of it.

---

## 📱 On scraping — do it well or not at all

It's your gym's data and extracting it is legitimate. Two practical cautions, not moral ones:

- **Check PushPress's terms on automated access** before running anything at scale, and prefer the
  documented export you asked for in step 1. A supported export you waited a week for beats a scraper
  you maintain forever.
- **Capture JSON, not HTML.** The OTL iOS app talks to a backend in JSON. Pointing a proxy
  (mitmproxy / Charles) at the app on your iPhone and recording its API responses gives you clean,
  typed, structured data — dates as dates, scores with units and scaling intact. DOM scraping the web
  UI gives you formatted strings you then have to re-parse, and it breaks on every deploy.

When you're at the Mac mini, the setup is: Playwright or Chrome DevTools Protocol driving your
already-logged-in Chrome profile for Core, and mitmproxy against the mirrored iPhone app for Train
and the member-app surfaces.

> [!warning] 🟠 Don't paste passwords into chat
> Chat history persists. Point automation at an **already-authenticated browser profile**, and pass
> API keys as environment variables. I never need to see a password to drive a logged-in session.

---

## 🧰 Tooling

`pushpress_extract.py` in this folder pulls everything the documented v3 API exposes to timestamped
JSON — pagination handled, rate limits respected, resumable. It runs the moment you hand it a key
and a company ID. See [[Migration MOC]] for usage.

That covers the top two-thirds of the table above. The scrape-only rows are the remaining work.

---

> [!danger] 🔴 The ACH authorization evidence deserves its own line on this list
> Stripe requires whoever debits a bank account to hold the member's authorization and be able to
> **reconstruct it on request**, per Nacha rules. If payment methods ever need moving to a *different*
> Stripe account, ACH methods are **skipped entirely** unless the receiving account attests it holds
> those mandates. The authorizations were given to CrossFit OTL, so we do hold them — but the *records*
> are in PushPress. Get them out while we're still a customer.

---

## ✅ Definition of done

Not "the script ran." Reconcile before you trust it:

- [ ] Member count in extract == member count in Core UI
- [ ] Active enrollment count == active member count in Core billing
- [ ] Check-in totals per member == the all-time number the app shows them
- [ ] Spot-check 10 members by hand across every field
- [ ] Every extract archived off the working machine, encrypted
- [ ] ACH authorization dates captured for every bank-debit member

---

## 🔗 Related

- [[Migration MOC]] — parent
- [[Stripe & Payment Continuity]] — the payments half
- [[Cutover Plan & Comms Safety]] — what happens after extraction
- [[Workout & PR Data — Access Options]] — the results gap in detail
- [[Staff Mode & POS — Roles, Terminal, Refunds]] — what the products and sales data feeds
