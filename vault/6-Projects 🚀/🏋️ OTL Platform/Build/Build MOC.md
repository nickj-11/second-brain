---
type: MOC
tags:
  - otl-platform
  - build
  - MOC
---
# 🛠️ Build

The OTL platform itself: CRM backend, member web app, and the iOS app replacing the PushPress-hosted
OTL app.

> [!warning] 🟠 Honest scope: 12–24 months for a small experienced team
> Four products in one — CRM, billing, workout tracking, marketing automation — plus two front ends
> and a live migration. Achievable, because it only has to serve one gym. Not achievable in a weekend.

---

## 📌 Hub Documents

| File | Purpose |
|------|---------|
| 📄 [[Member App — Feature Spec]] | Every screen and feature, plus the Instagram and App Store constraints |
| 📄 [[Architecture — System Design]] | Stack, domain model, billing engine, security baseline |
| 📄 [[Scope & Phasing — Honest Estimate]] | What it really costs, phased so each step stands alone |

---

## 🧭 Decisions already made

- **Stack:** Supabase (Postgres + auth + storage + realtime) · Next.js on Vercel · React Native/Expo · Stripe
- **Billing:** prefer Stripe Subscriptions over a home-grown scheduler
- **Derived data:** streaks, Committed Club and all-time check-ins are computed from check-ins, never stored
- **Payments in-app:** Stripe, not Apple IAP — guideline 3.1.3(e) *prohibits* IAP for real-world services

## ❓ Decisions still open

- [ ] **Is this OTL-only, or a product to sell to other gyms?** Changes nearly every architectural call
- [ ] Rebuild marketing automation, or sync to an off-the-shelf tool?
- [ ] Is a member app on top of PushPress-as-system-of-record enough? (Phase 2 without 3–5)

---

## 🔗 Related

- [[🏋️ OTL Platform MOC]] — parent
- [[Migration MOC]] — getting the data in
- [[Incumbent — PushPress MOC]] — the system being replaced
