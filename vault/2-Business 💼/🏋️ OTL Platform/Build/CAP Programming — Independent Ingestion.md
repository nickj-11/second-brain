---
type: note
tags:
  - otl-platform
  - crossfit
  - programming
  - build
---
# CAP Programming — Independent Ingestion

> [!danger] 🔴 This note was rewritten 2026-09-19 — the earlier plan was wrong
> I had the pipeline running from a **Google Docs** delivery. CrossFit's own support documentation
> lists 15 CAP platforms and **Google Docs is not one of them.** That claim came from a search-result
> summary of a marketing page, not a primary source, and it was the centrepiece of the old plan.
> Corrected routes below. Primary-source facts in [[CAP — Official Facts & Platform List]].

> [!success] 🟢 The good news survives intact
> CAP is **included with affiliation** and belongs to the affiliation, not to PushPress. Leaving
> PushPress costs us nothing. And programming is released **every Friday, two weeks in advance** — a
> fortnight of slack for a parse-and-review pipeline, not a weekend scramble.

---

> [!success] 🟢 Decision, 2026-09-19: route 2 (the CAP email) is the interim path
> Confirmed viable — CAP programming can be sent to a Gmail account. We pull from there, parse, place on
> the right dates, and a `programmer` (Nick, Clay, Javier) confirms the logging and publishes to the
> member app. Full design in [[CAP Email Ingestion — Pipeline Design]].
>
> Route 1 below stays the candidate if we ever want structured data without writing a parser, and route
> 0 runs in parallel regardless — the answer may bless or replace all of this.

---

## 🥇 Alternative: ride a partner platform with an API

**Subscribe to CAP on SugarWOD, then pull it into our CRM through SugarWOD's documented API.**

```
CrossFit → SugarWOD (CAP subscription) → SugarWOD API → our CRM → OTL app
             nightly sync                (documented)     (typed)
```

Why this wins:
- **Supported on both ends.** CrossFit sanctions CAP delivery to SugarWOD; SugarWOD publishes a real
  developer API with self-serve keys. No scraping, no ToS grey area, nothing that breaks on a deploy.
- **The data arrives already structured.** SugarWOD exposes `GET /workouts?dates=&track_id=` and
  `GET /tracks` as typed objects, plus `/movements`, `/benchmarks` and `/barbelllifts` as a controlled
  vocabulary. That removes most of the parsing problem — we'd be mapping fields, not reading prose.
- **Cheap.** SugarWOD's own materials put CAP delivery at roughly **$20/month** (verify current
  pricing). Compare that against building and maintaining a prose parser.
- **It is not PushPress.** The requirement was independence from PushPress, not from all vendors.
  SugarWOD becomes a thin, replaceable ingestion pipe, not the system of record.

> [!warning] 🟠 One dependency traded for another — go in knowing it
> This swaps "dependent on PushPress" for "dependent on SugarWOD for programming delivery." The
> difference is that SugarWOD holds *only* the programming feed — no members, no billing, no results,
> no app — and it has a documented API with a published contract. If it ever goes away, any of the
> other 14 platforms, or route 2 below, replaces it.
>
> Also confirm SugarWOD's API actually returns the **CAP** track for a CAP subscriber. Its docs show a
> `Workouts HQ` group for CrossFit **mainsite** programming, which is not the same thing. **Verify
> before committing** — this is the one assumption the recommended route rests on.

### Setup
1. `/gyms/settings/developer-keys` → create a key
2. `GET /tracks` → find the CAP track's `track_id`
3. `GET /workouts?dates=YYYYMMDD-YYYYMMDD&track_id=<cap>` → the workouts
4. Map into our `Workout` / `Movement` / `ScoringType` model
5. Programmer reviews, then publishes to the OTL app

---

## 🥈 Route 2 — CHOSEN: the CAP weekly planning email

CrossFit's sharing guidance states coaches **can subscribe to CAP's weekly planning email.** A mailbox
we control is the cleanest ingestion point involving no third party.

```
CrossFit -> Gmail -> forward -> inbound webhook -> parse -> draft -> programmer confirms -> publish
```

Chosen because it is entirely under our control, costs nothing, needs no vendor's goodwill, and the
review step is where we wanted a human anyway.

**Two traps worth knowing, both verified:** the **Gmail API is out** — `gmail.readonly` is a restricted
scope, refresh tokens expire every 7 days in Testing status and production needs a CASA security
assessment. And **Cloudflare Email Routing is out** — root-domain only, cannot coexist with the
Microsoft 365 MX, so it would break staff email. Use Gmail auto-forward to an inbound webhook instead.

**Full design, data model, review-screen spec and build order:
[[CAP Email Ingestion — Pipeline Design]].**

> [!danger] 🔴 One thing to verify before building the parser
> We don't yet know whether the weekly email carries the **programming itself** or just links back to
> the Toolkit. Subscribe now, read Friday's email, then write the parser.

---

## 🥉 Route 3: the Affiliate Toolkit directly

The Toolkit is the primary CAP delivery surface and we log into it with our own credentials. Ingestion
would be an authenticated pull from our own account.

- Content is all there: daily programming, lesson plans, scaling, videos, all four tracks
- It's our own licensed content in our own account
- **But:** a web app not built for machine access. Brittle, no contract, and automated access against
  CrossFit's own portal is worth asking about before doing at scale — which the next section covers.

---

## ✅ Route 0: just ask — do this first

The access article says verbatim: *"Need help with access or integration? Email
programming@crossfit.com."* That is an explicit invitation.

**Send this before building anything:**
- We're a CrossFit affiliate in good standing building our own member-facing app and CRM. What CAP
  access exists for that? Is there a feed, an export, or a documented integration path?
- `How-to-Use-and-Share-CAP` says we may share CAP with members via "SugarWOD, BTWB, Wodify, **or
  another platform**." Does our own purpose-built affiliate app qualify as "another platform"?
- Is there a route to becoming a CAP delivery platform, or an affiliate-scoped equivalent?
- Any restriction on ingesting CAP into our own system for our own members?

> [!tip] 🟣 Get the licensing answer in writing before you build the feature
> CAP is CrossFit's IP. Sharing it with our own members through a platform is explicitly permitted;
> whether our own app counts is a reasonable reading but not a documented one. A written answer costs
> one email and removes the only real legal question in this project.

---

## 🚫 Routes that don't work

| Route | Why not |
|---|---|
| ~~Google Docs delivery~~ | **Not a CAP platform.** My error — corrected above |
| Use PushPress's CAP credential | Theirs, server-side, never issued to affiliates. 15 separate platform deals confirm no per-gym key exists |
| Become a CAP platform | A commercial arrangement with CrossFit. Ask (route 0), but don't plan on it |
| Scrape Train permanently | Works, but keeps us dependent on the system we're leaving |

**Interim bridge:** during Phases 1–3, while PushPress still runs the gym, pulling programming from
Train is legitimate and gets the app working early. Just don't let it become the permanent answer.

---

## 🧩 Parsing — still required for routes 2 and 3

CAP arrives as prose written for coaches: workout, scaling, whiteboard brief, coaching notes, warm-up,
logistics, cool-down. We need `Workout`, `Movement`, `ScoringType` and `Division` records.

LLM structured extraction is the right tool — document or email text in, typed JSON out against our
schema. Far more robust than regex against prose whose format shifts.

> [!danger] 🔴 Never auto-publish an unreviewed parse
> A misparsed rep scheme or time cap goes onto the whiteboard and into members' logged results. Human
> review is required. Show the parse beside the original so a programmer can check it in seconds, and
> **keep the raw source text on every workout record** so a bad parse can be re-run without re-fetching.

Route 1 largely sidesteps this: SugarWOD hands over structured objects, so the work becomes field
mapping rather than language parsing. That is the strongest argument for route 1.

---

## 🛠️ Next actions

- [ ] **Subscribe a dedicated Gmail to the CAP weekly planning email** — this week, free
- [ ] **Read Friday's email**: full programming, links, or an attachment? Everything else depends on it
- [ ] **Email `programming@crossfit.com`** with the four questions above (route 0) — in parallel
- [ ] Trial SugarWOD, add CAP, mint a developer key, and **verify `GET /tracks` exposes the CAP track**
- [ ] Confirm current SugarWOD CAP pricing
- [ ] Confirm Toolkit access is healthy: fees current, trainer credential current, Agreement signed
- [ ] Model the four tracks — Affiliate, Compete, At-Home, Masters 55+ — as `WorkoutTrack` records
- [ ] Decide whether to support the imperial/metric toggle at ingestion or display time

---

## 🔗 Related

- [[CAP Email Ingestion — Pipeline Design]] — the chosen route, built out in full
- [[CAP — Official Facts & Platform List]] — the primary-source facts this plan rests on
- [[Build MOC]] — parent
- [[SugarWOD API — Industry Comparison]] — the API behind route 1
- [[CrossFit Affiliate Programming → Train Sync]] — how CAP reaches PushPress today
- [[Member App — Feature Spec]] — the workouts tab this feeds
