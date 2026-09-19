---
type: note
tags:
  - otl-platform
  - infrastructure
  - dns
  - email
---
# Infrastructure — Domain, DNS & Email

> [!danger] 🔴 `crossfit-otl.com` has no SPF, no DKIM and no DMARC
> Verified by public DNS lookup 2026-09-19. Mail runs on Microsoft 365, but the domain publishes **no
> sender authentication of any kind.** Two consequences, one of them immediate:
> 1. Staff email today is already sending unauthenticated — weaker deliverability, and **anyone can
>    spoof `@crossfit-otl.com`.**
> 2. If the CRM starts sending from this domain as-is, **it will land in spam.** Gmail and Yahoo have
>    required authentication from bulk senders since early 2024.
>
> **Fix this before the CRM sends a single email.**

---

## 📍 Current state (public DNS, 2026-09-19)

| Record | Value | Meaning |
|---|---|---|
| `MX` | `crossfitotl-com02b.mail.protection.outlook.com` | Email on **Microsoft 365** |
| `NS` | `ns21/ns22.domaincontrol.com` | DNS still at **GoDaddy**, not yet Cloudflare |
| `TXT` | `google-site-verification=...` only | **No SPF** |
| `_dmarc` | *absent* | **No DMARC** |
| `selector1._domainkey` | *absent* | **No DKIM** (M365's default selector) |
| `www` | `...vercel-dns-017.com` | Website already on **Vercel** |

> [!success] 🟢 Two things already line up with the plan
> The site is on Vercel, and the domain is in hand at GoDaddy. Nothing to migrate there.

---

## ✉️ Email architecture

> [!tip] 🟣 Send CRM mail from a subdomain, never the root domain
> Transactional and campaign mail goes out from something like **`notify.crossfit-otl.com`** via
> Resend, with its own DKIM keys. This isolates sender reputation: if the CRM ever generates spam
> complaints — and any system sending to hundreds of members eventually does — it damages the
> subdomain's reputation, **not the root domain your staff email depends on.**
>
> Root domain (`crossfit-otl.com`) → Microsoft 365, human staff mail.
> Subdomain (`notify.`) → Resend, machine mail, do-not-reply.

### Setup order
1. **SPF on the root** for Microsoft 365 — fixes the existing gap
2. **DKIM on the root** for Microsoft 365 — both M365 selectors
3. **DMARC at `p=none`** with an aggregate report address — observe before enforcing
4. **Subdomain** delegated to Resend: its own SPF, DKIM and DMARC
5. Monitor DMARC reports for a few weeks, then move root policy to `quarantine`, then `reject`

> [!warning] 🟠 Don't jump straight to `p=reject`
> You will discover services legitimately sending as your domain that you'd forgotten about. `p=none`
> with reporting tells you who they are before you start bouncing their mail.

---

## ☁️ Moving DNS to Cloudflare

Consolidating alongside MyFleetOS, Classic Pro and Longhorn Forge makes sense. One caution:

> [!danger] 🔴 Carry MX, TXT and the Vercel CNAME across explicitly
> Cloudflare's import scan usually catches existing records, but **verify MX by hand before flipping
> nameservers.** A missed MX record means email silently stops — and you may not notice for hours.
>
> Checklist before the switch: MX → Outlook · the google-site-verification TXT · `www` → Vercel ·
> any Microsoft autodiscover/verification records · new SPF/DKIM/DMARC.
>
> Also: mail records must be **DNS-only (grey cloud)**, never proxied.

---

## 🧱 Target stack

| Concern | Service | Notes |
|---|---|---|
| Domain registrar | GoDaddy | Stays |
| DNS | **Cloudflare** | Alongside the other properties |
| Web + admin hosting | **Vercel** | Already live for `www` |
| Database, auth, storage, realtime | **Supabase** | New project |
| Staff / human email | **Microsoft 365** | Existing, on root domain |
| Machine email | **Resend** | Existing account; on `notify.` subdomain |
| Payments | **Stripe** | Existing OTL account — see [[Stripe & Payment Continuity]] |
| Mobile | React Native / Expo | iOS first |

---

## 🔗 Related

- [[Build MOC]] — parent
- [[Architecture — System Design]] — application architecture
- [[Cutover Plan & Comms Safety]] — the send kill switch and suppression rules
