---
type: note
tags:
  - pushpress
  - crossfit
  - programming
  - gym-app
---
# CrossFit Affiliate Programming → Train Sync

> [!success] 🟢 This one needs no API key at all
> The CAP → Train workout sync is a **native, built-in integration**, not an API build. It is a
> login-and-toggle setup inside Train. Any time spent hunting for a CAP API key is time wasted —
> there isn't one to find.

---

## 📋 What you need to qualify

Two requirements, both of which we already meet:

1. A **CrossFit affiliate in good standing**
2. A **Train by PushPress subscription**

CAP itself is **free** for eligible affiliates — no subscription fee, no setup fee. If a CAP
subscription is currently running through another platform, it can be transitioned over to Train
rather than paid twice.

---

## ⏱️ How the sync behaves

- CAP programming uploads into the Train account **automatically, every week**
- Next week's programming is released by **Friday at the latest**
- What lands: daily workouts, scaling options, and full class plans — coaching notes, warm-ups, timelines
- Setup is described by PushPress as minutes, done from inside the Train account

> [!info] 🟦 Member sync between Core and Train is a separate opt-in toggle
> Turn it on so the roster in Core is the roster in Train. Without it, results won't line up against
> member records — which is exactly what our app depends on.

---

## 🧭 What this means for the build

The programming half of the problem is already solved by a product feature. Our app does **not** need
to ingest or re-publish workouts. Where our build actually starts is one layer down: getting the
**results** members log against those workouts back out of PushPress. That's the open question —
see [[Workout & PR Data — Access Options]].

Other programming providers wired into Train the same way, if we ever want to switch or offer a
second track: Mayhem, HWPO, PRVN, Invictus, Brute, Misfit, Bolder.

---

## 🛠️ Next actions

- [ ] Log into Train, confirm CAP is switched on and this week's programming actually landed
- [ ] Confirm the Core ↔ Train **member sync** toggle is enabled
- [ ] Spot-check that a logged score in the member app shows against the right member in Core

---

## 🔗 Related

- [[🏋️ Gym App — PushPress MOC]] — parent
- [[Workout & PR Data — Access Options]] — the actual hard part
