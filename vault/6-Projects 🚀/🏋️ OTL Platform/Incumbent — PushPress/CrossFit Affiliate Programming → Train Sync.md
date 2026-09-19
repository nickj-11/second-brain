---
type: note
tags:
  - pushpress
  - crossfit
  - programming
  - gym-app
---
# CrossFit Affiliate Programming → Train Sync

> [!info] 🟦 There is a credential behind this sync — it just isn't ours
> Train pulls CAP server-side using a key that belongs to **PushPress the company**, held on their
> backend as part of a B2B content-distribution deal with CrossFit. It is never issued to an
> affiliate, never appears anywhere in Core or Train settings, and has no gym-level equivalent to
> generate. Our setup is "log in and toggle" precisely because the authentication already happened at
> the company level, before our account existed.

---

## 🔍 Why we know it's platform-level, not per-gym

CrossFit's support documentation lists **15 CAP platforms**, each with its own sign-up flow, its own
pricing and its own support queue: Boxmate, BoxPlanner (coming soon), BTWB, Chalk It Pro, Hustle Up,
Irontrack, Octiv, PushPress, StreamFit, Strivee, SugarWOD, TrainHeroic, WellnessLiving, WODboard and
Wodify.

Fifteen separate platform integrations means fifteen commercial arrangements — not one API key per gym.
CrossFit publishes **no API, no feed specification and no developer access** for CAP. So "create our own
key" would mean becoming a CAP delivery platform: a business conversation with CrossFit, not a
credential we can mint.

> [!info] 🟦 Correction, 2026-09-19
> An earlier version of this note said CAP is delivered to **Google Docs**, from a search summary of a
> marketing page. CrossFit's own platform table does not list Google Docs. See
> [[CAP — Official Facts & Platform List]].

---

## 📋 What we qualify for

- A **CrossFit affiliate in good standing** — CAP is **included with affiliation**, no extra
  subscription and no extra cost
- A **Train by PushPress subscription** for the Train-delivered version
- If CAP is currently running through another platform, that subscription can transition to Train

Tracks available: standard CAP (daily workouts, coaching notes, scaling), plus an optional **Compete
Track** adding volume and intensity pathways for the Open and competition season.

---

## ⏱️ How the sync behaves

- CAP programming uploads into the Train account **automatically, every week**
- CrossFit releases programming **every Friday, two weeks in advance**; platforms sync **nightly**
- What lands: daily workouts, scaling options, and full class plans — coaching notes, warm-ups, timelines

> [!warning] 🟠 Member sync between Core and Train is a separate opt-in toggle
> Turn it on so the roster in Core is the roster in Train. Without it, results won't line up against
> member records — which is exactly what our app depends on.

---

## 🧭 What this means for the build

Follow the direction of the data. CAP → Train already works, for free. **The workouts are already
inside PushPress.** Our app does not need to re-fetch them from CrossFit — it needs to read them
*out* of PushPress, along with the scores members log against them. That is the real blocker; see
[[Workout & PR Data — Access Options]].

If we want CAP in our own app, the routes are the Affiliate Toolkit (our own credentials), the **CAP
weekly planning email** coaches can subscribe to, or riding a partner platform that has a documented
API. See [[CAP Programming — Independent Ingestion]].

Other programming providers wired into Train the same way, if we want to switch or add a second
track: Mayhem, HWPO, PRVN, Invictus, Brute, Misfit, Bolder.

---

## 🛠️ Next actions

- [ ] Log into Train, confirm CAP is switched on and this week's programming actually landed
- [ ] Confirm the Core ↔ Train **member sync** toggle is enabled
- [ ] Spot-check that a logged score in the member app shows against the right member in Core
- [ ] Confirm Toolkit access is healthy: affiliate fees current, trainer credential current, Agreement signed

---

## 🔗 Related

- [[Incumbent — PushPress MOC]] — parent
- [[Workout & PR Data — Access Options]] — the actual hard part
- [[SugarWOD API — Industry Comparison]] — another CAP partner, same results wall
- [[CAP — Official Facts & Platform List]] — primary-source facts from CrossFit
