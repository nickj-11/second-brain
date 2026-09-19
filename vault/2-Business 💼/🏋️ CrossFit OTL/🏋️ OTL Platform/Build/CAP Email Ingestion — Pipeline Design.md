---
type: note
tags:
  - otl-platform
  - crossfit
  - programming
  - build
  - architecture
---
# CAP Email Ingestion — Pipeline Design

> [!success] 🟢 This is the chosen interim path
> CAP's **weekly planning email** into a mailbox we control, parsed into draft workouts, placed on the
> right dates, then confirmed and published by a `programmer` — Nick, Clay, Javier, or whoever the
> admin assigns. Runs independently of PushPress and of any future CrossFit integration. If an official
> integration ever arrives, it swaps in behind the same review-and-publish flow.

> [!danger] 🔴 Verify this before building anything: what is actually IN the email?
> Everything below assumes the weekly planning email carries the **programming itself**. It might
> instead be a summary with links back to the Affiliate Toolkit, or a PDF attachment. Those need very
> different parsers, and the link-only case means email alone is not enough.
>
> **Subscribe a mailbox this week and read Friday's email before a line of parser gets written.** It
> costs nothing and it is the one thing that could invalidate this design.

---

## 🚫 Two approaches that look obvious and are traps

### ❌ Gmail API — don't
`gmail.readonly` is a Google **restricted** scope. Consequences:
- With the OAuth app in **Testing** status, refresh tokens **expire every 7 days**. The pipeline would
  break silently, weekly, and you'd find out from an empty whiteboard.
- Moving to production with a restricted scope requires **full Google verification including a
  third-party CASA security assessment.** That is a slow, expensive process — to read one email a week.

### ❌ Cloudflare Email Routing on `crossfit-otl.com` — would break your staff email
Email Routing works on the **root domain only** and **cannot coexist with another MX**. Your root MX
points at Microsoft 365. Pointing it at Cloudflare would stop staff email dead.

> [!warning] 🟠 If anyone suggests Cloudflare Email Workers for this, that's why not
> It's genuinely the elegant tool for inbound email — just not on a domain already running Microsoft
> 365 on its root MX.

---

## ✅ The route that works

```
CrossFit  ->  Gmail  ->  auto-forward  ->  inbound webhook  ->  our API
             (human                        (provider)          |
              copy)                                            v
                                              parse -> draft on calendar
                                                            |
                                          programmer confirms + fixes logging
                                                            |
                                                         publish
                                                            |
                                              member app + push notification
```

**Why a forward rather than reading the mailbox:** no OAuth, no restricted scopes, no token expiry, no
Google verification. A POST arrives when mail arrives. And Gmail keeps a human-readable copy, so
coaches can still just read it.

### Inbound provider
- **Postmark inbound** gives you an address like `<hash>@inbound.postmarkapp.com` with **zero DNS
  changes** — no risk whatsoever to Microsoft 365. Fastest and safest way to start.
- You already have a **Resend** account for MyFleetOS — check whether it now offers inbound email; if
  so, one fewer vendor.
- Later, for a tidy address like `cap@in.crossfit-otl.com`, point a **subdomain** MX at the provider.
  Unlike Cloudflare Email Routing, these providers support subdomain MX, so the root stays on M365.

### Gmail setup
- A **dedicated** account (e.g. `otl.programming@…`), not anyone's personal inbox
- MFA on it, credentials in the password manager
- Settings → Forwarding → forward to the inbound address, **keep a copy in the inbox**
- A filter so only CAP mail forwards, not everything

---

## 🗃️ Data model

```
cap_email
  id · provider_message_id (UNIQUE) · received_at · subject · from_address
  raw_mime_ref (object storage) · week_of (date) · status

workout_draft
  id · cap_email_id · track · workout_date (DATE) · title
  body_raw (verbatim source text) · parsed (jsonb)
  scoring_type · scoring_type_confidence · divisions[] · tiebreak
  overall_confidence · status · reviewed_by · reviewed_at

workout            <- created on publish, versioned (see the edit rules)
```

### States
`received` → `parsed` → `needs_review` → `confirmed` → `published` → `superseded`
plus `parse_failed` and `ignored`.

> [!danger] 🔴 Three rules that prevent the expensive bugs
> **1. Idempotency.** `provider_message_id` is UNIQUE. Inbound webhooks retry — a redelivery must be a
> no-op, never a duplicate week of workouts.
>
> **2. `workout_date` is a DATE, in gym-local time.** Never a UTC timestamp. A WOD belongs to a day, not
> an instant, and timestamp storage produces off-by-one days for anyone whose device is in another
> timezone.
>
> **3. Keep `body_raw` verbatim on every draft.** When a parse turns out wrong months later, you re-run
> it against the original instead of hunting for an email that has moved on.

### Date anchoring — the subtle one
The email covers a week or two, and may name days rather than dates ("Monday"). Anchor every draft to
the explicit `week_of` the email refers to, derive dates from that, and **make the reviewer confirm the
date mapping.** A parser that silently shifts a week puts Thursday's workout on Wednesday's board.

---

## 👤 The review step — where the "double-check the logging" lives

This is the part you specifically asked for, and it's the part that protects member data.

> [!danger] 🔴 ScoringType must be explicitly confirmed. Never auto-accepted.
> Scoring type — For Time, AMRAP, load, distance, calories — determines **how members log** and **how
> the leaderboard sorts**. Get it wrong and you corrupt results that are painful to fix retroactively,
> and you poison automatic PR detection. So the parser's guess is a *suggestion* with a confidence
> score, and publish is blocked until a human clicks it.

The review screen shows, side by side:
- **Raw email text** | **parsed result**
- Scoring type + parser confidence → **requires explicit confirmation**
- Divisions (Male RX, Female RX, Scaled, Masters…) → confirm the set
- Tiebreak field, where applicable
- Date and track → confirm
- Low-confidence fields highlighted so the eye goes to them first

**Confirm** and **Publish** are separate actions. Both audit-logged with the user id — you want to know
who put Thursday's workout on the board.

### Who can do it
The `programmer` capability, assigned by an admin in the CRM — Nick, Clay, Javier, or whoever else.
A capability, not a job title: someone can be an admin without being a programmer, and vice versa.
Editable from the app or the web CRM, which was the whole point of moving off Train's desktop-only flow.

### Don't let silence become an empty whiteboard
If nothing is published for tomorrow, alert the programmers. A missed parse is recoverable; a missed
parse nobody noticed is a class with no workout on the screen.

---

## 👁️ Member-visible vs staff-only

CAP ships more than the workout: lesson plans, whiteboard briefs, stimulus and coaching notes,
logistics, cool-downs, coaching resources, daily videos.

| Content | Visible to |
|---|---|
| Workout, scaling options | **Members** |
| Warm-up | Members (probably — your call) |
| Whiteboard brief, stimulus notes, coaching notes, logistics, coach resources, daily videos | **Staff only** |

Two reasons to draw this line deliberately: coaching notes are written for coaches and confuse members,
and limiting CAP exposure keeps us comfortably inside the licence.

> [!warning] 🟠 CAP must never be publicly reachable
> Gate all CAP content behind member authentication — no public URLs, no unauthenticated API responses,
> not in a share link. CrossFit permits sharing with *our members*, not with the internet.

---

## 🔁 After publish

- Members get the workout for its date, plus a push notification
- **Edits after results exist create a new version**, never an overwrite, and everyone who already
  logged gets notified with what changed — see [[Staff Mode & POS — Roles, Terminal, Refunds]]
- The four tracks (Affiliate, Compete, At-Home, Masters 55+) are separate `WorkoutTrack` records, so a
  member on the Compete track sees theirs

---

## 🛠️ Build order

1. [ ] **Subscribe a dedicated Gmail to the CAP weekly planning email** — this week, free
2. [ ] **Read Friday's email.** Full programming, or links, or an attachment? Everything else depends on this
3. [ ] In parallel: **email `programming@crossfit.com`** — CAP access for an affiliate building its own
       app, and whether that app counts as "another platform" under their sharing terms
4. [ ] Stand up inbound: Postmark inbound address → Gmail auto-forward → webhook endpoint
5. [ ] Store `cap_email` rows with raw MIME. **Ingestion before parsing** — start the archive early so
       the parser has real material to develop against
6. [ ] Write the parser against 3–4 real emails, not one
7. [ ] Build the review screen. Ship this before automating anything else — a human plus a mediocre
       parser beats a great parser with no review
8. [ ] Publish flow, push notifications, the "nothing published for tomorrow" alert
9. [ ] Only then consider trusting high-confidence parses further

> [!tip] 🟣 Ingest before you parse
> Getting emails stored, deduped and archived is a day's work and immediately valuable. The parser can
> be terrible at first — the review step catches it, and every real email improves it.

---

## 🔗 Related

- [[CAP Programming — Independent Ingestion]] — all four routes and how this one was chosen
- [[CAP — Official Facts & Platform List]] — primary-source CAP facts from CrossFit
- [[Build MOC]] — parent
- [[Member App — Feature Spec]] — the workouts tab this feeds
- [[Staff Mode & POS — Roles, Terminal, Refunds]] — the `programmer` role and workout versioning
- [[Infrastructure — Domain, DNS & Email]] — why Cloudflare Email Routing is out
