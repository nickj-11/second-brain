---
type: MOC
tags:
  - gym-app
  - pushpress
  - MOC
---
# 🏋️ Gym App — PushPress

Building our own gym software layer on top of PushPress: member data, attendance, and — once we can
reach it — workout scores and PRs.

> [!abstract] 🟡 Where this stands, 2026-09-19
> **Two questions, two different answers.**
> The workout sync from CrossFit Affiliate Programming into Train needs **no API key** — it's a
> built-in toggle. A **Platform API key** for our own app is self-serve at Settings → Security &
> Access. But the public API **does not expose workout results or PRs**, so tracking member scores
> from our own app is blocked pending an answer from PushPress.

---

## 📌 Hub Documents

| File | Purpose |
|------|---------|
| 📄 [[PushPress API — Keys & Auth]] | How to create our own key, auth header, base URLs, SDKs, rotation |
| 📄 [[PushPress Platform API — Endpoint Inventory]] | All 40 endpoints and 23 webhook events, verified from SDK source |
| 📄 [[CrossFit Affiliate Programming → Train Sync]] | The CAP → Train workout sync — native, no API needed |
| 📄 [[Workout & PR Data — Access Options]] | The blocker, and the four ways through it |

---

## 🛠️ Open tasks

> [!warning] 🟠 Unblock the results question before committing engineering time
- [ ] Mint a Core API key and smoke-test `GET /customers`
- [ ] Email `support@pushpress.com` about Train results API / partner access
- [ ] Confirm CAP programming and Core ↔ Train member sync are both live in Train
- [ ] Register a `checkin.created` webhook end-to-end
- [ ] Price the branded member app as an alternative to building

---

## 📚 Reference

- Platform API base: `https://api.pushpress.com/v3` · auth header `API-KEY`
- SDKs: `@pushpress/pushpress` (npm) · `pushpress/php-sdk` (Packagist)
- Developer portal: `developer.pushpress.com` · Help: `help.pushpress.com`

---

## 🔗 Related

- [[Projects MOC]] — parent
- [[Business MOC]] — the gym itself
