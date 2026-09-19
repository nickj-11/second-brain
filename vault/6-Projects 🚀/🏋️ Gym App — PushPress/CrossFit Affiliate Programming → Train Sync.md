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

CrossFit's own CAP page states programming is delivered to **Google Docs, SugarWOD, Wodify,
PushPress, STREAMFIT, BTWB, Strivee, WODBoard and Chalk It Pro**.

Nine separate platform integrations means nine commercial arrangements — not one API key per gym.
CrossFit publishes **no API, no feed specification, and no developer access** for CAP anywhere. So
"create our own key" would mean becoming a CAP distribution partner: a business conversation with
CrossFit, not a credential we can mint.

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
- Next week's programming is released by **Friday at the latest**
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

If we ever do want CAP content directly in our own app, the route we actually control is the one
CrossFit gives affiliates: **CAP is delivered to Google Docs** and lives in the Affiliate Toolkit.
Pulling from our own copy via the Google Docs API uses our credentials, not anyone's partner key.

Other programming providers wired into Train the same way, if we want to switch or add a second
track: Mayhem, HWPO, PRVN, Invictus, Brute, Misfit, Bolder.

---

## 🛠️ Next actions

- [ ] Log into Train, confirm CAP is switched on and this week's programming actually landed
- [ ] Confirm the Core ↔ Train **member sync** toggle is enabled
- [ ] Spot-check that a logged score in the member app shows against the right member in Core
- [ ] Locate our CAP Google Docs delivery in the Affiliate Toolkit as a fallback content source

---

## 🔗 Related

- [[🏋️ Gym App — PushPress MOC]] — parent
- [[Workout & PR Data — Access Options]] — the actual hard part
- [[SugarWOD API — Industry Comparison]] — another CAP partner, same results wall
