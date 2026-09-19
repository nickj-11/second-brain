---
type: MOC
tags:
  - otl-platform
  - pushpress
  - MOC
---
# 🏋️ OTL Platform

Replacing PushPress with our own system for CrossFit OTL: a CRM backend, a member web app, and an
iOS app to replace the PushPress-hosted OTL app.

> [!abstract] 🟡 Where this stands, 2026-09-19
> **Three things worth knowing before any code gets written.**
> 🟢 Members almost certainly **never re-enter a card** — PushPress connects *your own* Stripe
> account, so the new CRM just points at it.
> 🔴 **Workout results, benchmarks and PRs have no export path** — the one dataset at real risk, and
> the one to solve while still a paying customer.
> 🟠 Honest scope is **12–24 months** for a small team. Phased so each step stands alone.
> 🔴 And one to fix this week: **`crossfit-otl.com` has no SPF, DKIM or DMARC** — CRM email sent from
> it today would go straight to spam. See [[Infrastructure — Domain, DNS & Email]].

---

## 📌 Hub Documents

> [!abstract] 🟡 One file that contains everything
> | File | Purpose |
> |---|---|
> | 📄 [[OTL Platform — Master Brief]] | **Start here.** Full conversation verbatim, every research finding with sources, and the complete plan |
> | 📕 `OTL Platform — Master Brief.pdf` | Same document, 29 pages, paginated with contents — for reading away from Obsidian |

---

## 🗂️ Subfolders

- 📁 [[Incumbent — PushPress MOC]] — what PushPress exposes, what it hides, and how CAP programming reaches it
- 📁 [[Migration MOC]] — extracting members, money and history without breaking the gym
- 📁 [[Build MOC]] — architecture, feature spec, and an honest estimate

---

## 🔴 Do these first

> [!danger] 🔴 Two of these are time-sensitive and cheap
- [ ] **Verify Stripe account ownership** at `dashboard.stripe.com` — 30 min, determines the entire payment plan
- [ ] **Run the extractor** and reconcile counts — days, protects years of member history
- [ ] **Ask PushPress in writing** what export departing customers get
- [ ] **Do not cancel anything** until extracts are verified complete
- [ ] **Add SPF, DKIM and DMARC** to the domain — cheap, and blocks all CRM email until done
- [ ] **Request the Apple Tap to Pay entitlement** — development then distribution; has real lead time
- [ ] **Email `affiliatesupport@crossfit.com`** about structured CAP delivery for affiliates

---

## 🧭 The decision that shapes everything else

> [!warning] 🟠 Is this OTL's own tool, or a product to sell to other gyms?
> Multi-tenancy, configurability and per-gym billing are most of what makes gym software expensive.
> Building for one gym strips them out and is the reason this is achievable at all. Answer this
> before committing to an architecture.

---

## 📚 Quick reference

- PushPress API: `https://api.pushpress.com/v3` · header `API-KEY` · key at Settings → Security & Access
- Stripe: gym owns its own account · self-serve PAN copy exists as fallback · never store PANs
- Apple: guideline **3.1.3(e)** *prohibits* IAP for real-world services — Stripe is required, no 30% cut
- Instagram: Basic Display API dead since 2024-12-04 · Graph API + Business account · stories need app review
- CAP into our CRM: **Google Docs delivery**, our own credentials, parse then human-review
- Domain: GoDaddy registrar + NS · Microsoft 365 mail · `www` on Vercel · **no SPF/DKIM/DMARC yet**
- POS: Stripe Terminal + Tap to Pay on iPhone (Apple entitlement required) · refunds gated to `pos_admin`
- Products & sales history: Core → Reports → Financial → Download Data (**All Results**)

---

## 🔗 Related

- [[Projects MOC]] — parent
- [[Business MOC]] — CrossFit OTL itself
