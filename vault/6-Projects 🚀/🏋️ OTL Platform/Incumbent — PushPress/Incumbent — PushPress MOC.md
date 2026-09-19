---
type: MOC
tags:
  - otl-platform
  - pushpress
  - MOC
---
# 🔍 Incumbent — PushPress

Research on the system OTL runs today: what it exposes, what it doesn't, and what that means for
replacing it.

> [!abstract] 🟡 The headline finding
> PushPress's public API covers the **business** — members, check-ins, scheduling, enrollments — and
> **none of the performance data**. No workouts, results, benchmarks or PRs, confirmed from SDK
> source. SugarWOD, the most open API among CAP partners, has the same gap. That single fact shapes
> both the migration and the build.

---

## 📌 Hub Documents

| File | Purpose |
|------|---------|
| 📄 [[PushPress API — Keys & Auth]] | Minting our own key, auth header, base URLs, SDKs, rotation |
| 📄 [[PushPress Platform API — Endpoint Inventory]] | All 40 endpoints and 23 webhook events, from SDK source |
| 📄 [[CrossFit Affiliate Programming → Train Sync]] | The CAP sync: whose credential it is, and why we can't have it |
| 📄 [[Workout & PR Data — Access Options]] | The results gap and the four ways through it |
| 📄 [[SugarWOD API — Industry Comparison]] | Control case — another CAP partner, same wall |

---

## 🔗 Related

- [[🏋️ OTL Platform MOC]] — parent
- [[Migration MOC]] — extracting from this system
- [[Build MOC]] — what replaces it
