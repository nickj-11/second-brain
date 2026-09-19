---
type: note
tags:
  - otl-platform
  - planning
---
# Scope & Phasing — Honest Estimate

> [!danger] 🔴 The honest number first
> What you described — full gym CRM, billing engine, scheduling, workout tracking with leaderboards
> and PRs, a social feed with reactions and comments and mentions, marketing automation, a web app,
> a native iOS app, an admin console, **and** a zero-downtime migration of live members and live
> billing — is a **12–24 month build for a small experienced team.** It is not a Mac mini weekend.
>
> That isn't a reason not to do it. It's a reason to sequence it so that every phase is useful on its
> own, and so that nothing irreversible happens early.

---

## 📊 What you're actually replacing

PushPress is four products in a trench coat: Core (CRM, billing, scheduling), Train (programming and
results), Grow (marketing automation), and a member app. You're proposing to rebuild all four, plus
add an Instagram integration they don't have.

Each of those is a company. Wodify, SugarWOD and PushPress each took years and funded teams.

> [!tip] 🟣 The leverage is that you only have to serve one gym
> No multi-tenancy, no per-gym configurability, no migration tooling for other people's data, no
> billing-plan flexibility beyond what OTL actually sells, no enterprise support. That strips out
> most of what makes gym software expensive. It's the reason this is achievable at all — and the
> reason you should resist every urge to build it "properly" for gyms in general.

---

## 🚦 Phasing, with what each phase buys you

| Phase | Deliverable | Rough effort | Value if you stop here |
|---|---|---|---|
| **0** | Extract + verify all PushPress data | Days | Insurance. Your data is yours regardless. |
| **1** | Read-only mirror in your own schema | 2–4 weeks | Proves the data model against live data. Zero risk. |
| **2** | Member app v1 — schedule view + workout logging | 2–4 months | Members using your app daily. The real adoption test. |
| **3** | Scheduling + check-in cutover | 1–2 months | PushPress becomes billing-only |
| **4** | Billing cutover | 1–2 months + reconciliation | PushPress cancelled |
| **5** | Social feed, Instagram, appointments, marketing automation | 3–6 months | Feature parity and beyond |

> [!success] 🟢 Phase 0 is urgent and independent
> Do it now, this week, regardless of everything else. It costs days, it protects years of member PR
> history, and your access to it disappears the moment the PushPress account lapses.

---

## 🎯 The decisions that matter most

**1. Don't cancel PushPress until Phase 4 is reconciled.** Running both in parallel costs a few
hundred dollars a month. That is the cheapest insurance you will ever buy on this project.

**2. Phase 2 is the real test, and it's a test of members, not code.** If members won't adopt your
app for workout logging while PushPress still works, they certainly won't after you've moved their
billing. Find that out early and cheaply.

**3. Billing is the only phase that can genuinely damage the business.** Everything else is a bad
week. Billing failure is lost revenue, angry members, and cancellations. Treat it accordingly.

**4. Resist rebuilding marketing automation.** Grow's replacement is the least differentiated and
most fiddly piece. Consider keeping a third-party tool for campaigns and just syncing members to it,
rather than building sequences, templates and deliverability from scratch.

---

## ❓ Open questions to resolve before committing

- [ ] Is this a business you intend to sell to other gyms, or strictly OTL's own tool? **Changes
      almost every architectural decision.** Answer this first.
- [ ] Who maintains it at 6am when billing fails and you're coaching a class?
- [ ] What's the actual driver — cost, missing features, control, or frustration with PushPress? If
      it's cost, compare against 12–24 months of build time honestly.
- [ ] Is there a lighter path that solves 80% of it? PushPress's API already covers members,
      attendance and scheduling — a custom app on top of their data may get you most of what you
      want for a fraction of the effort.

> [!warning] 🟠 That last question deserves a real answer before Phase 2
> You can build the member app you want — Instagram feed, better social, better workout UX — on top
> of PushPress as the system of record, and never touch billing. That's Phase 2 without Phases 3, 4
> or 5. Whether that's enough depends on the driver, which is why it's worth naming.
> The blocker is the same one already documented: no results/PR API. See
> [[Workout & PR Data — Access Options]].

---

## 🔗 Related

- [[Build MOC]] — parent
- [[Architecture — System Design]] — the how
- [[Member App — Feature Spec]] — the what
- [[Cutover Plan & Comms Safety]] — the migration sequencing
