---
type: note
tags:
  - otl-platform
  - migration
  - stripe
  - payments
---
# Stripe & Payment Continuity

> [!success] 🟢 Your instinct was right — and the news is better than you think
> Per PushPress's own documentation, **the gym owns its own Stripe account** ("typically under the
> gym owner's email from when PushPress was set up"), with direct access at `dashboard.stripe.com`
> where the payout bank account is managed. If that holds for CrossFit OTL, there is **no card or
> bank migration to perform at all.** You keep the Stripe account. The new CRM points at the same
> account with your own API keys. Every saved card and bank account stays exactly where it is, and
> **no member re-enters anything.**

---

## ✅ Verify this first — before any other migration work

Thirty minutes, and it determines the entire payment plan.

1. Log into `dashboard.stripe.com` with the gym owner email. Can you see OTL's live payments?
2. Settings → note the account ID (`acct_...`).
3. Check whether the account appears as a **connected account of a platform** (PushPress). A Standard
   connected account is still *yours* — the platform merely holds API access you can revoke.
4. **The critical question:** open the Subscriptions tab. Are there live Stripe `sub_...` objects for
   your members, or is it all one-off PaymentIntents?

### Scenario A — Stripe Subscriptions exist
Billing schedules live in Stripe and largely survive the move. You rebuild the management UI, not the
billing engine. Much easier.

### Scenario B — PushPress runs its own recurring biller
More likely, given their API models enrollments and plans as first-class objects (`/enrollments`,
`/plans/{id}`) rather than deferring to Stripe. In this case Stripe only ever sees individual charges
against saved payment methods, and **when you leave PushPress, recurring billing simply stops.**

> [!danger] 🔴 Scenario B is the single highest-risk item in the whole project
> Your new CRM must recreate every schedule exactly: amount, interval, next charge date, proration,
> discounts, comped and paused states, family plans, annual vs monthly. Get it wrong in one direction
> and you stop collecting revenue. Get it wrong in the other and you double-charge your members. Both
> cost you members.

---

## 🔁 Fallback: if the Stripe account turns out to be platform-owned

Stripe supports a **self-serve PAN copy** between Stripe accounts, right in the Dashboard.

- Copies **Customers, Cards, Sources, Payment Methods and Bank Accounts**
- **Preserves the original Customer IDs** — your foreign keys survive
- **Subscriptions are NOT copied** — recreate them via the API
- Sender and recipient exchange `acct_` IDs from User settings
- Accounts are rate-limited on copies per period; Stripe's Data Migration team handles larger jobs
- Requires the sending account's cooperation

Stripe's position: they will move PAN data securely and PCI-compliantly between accounts, or from
another processor, provided the request includes **both customer records and the associated payment
data**.

---

## 🔴 Hard rules

> [!danger] 🔴 Never let a card number or bank account number touch your servers
> Not in a database, not in a log, not in a scraped JSON blob, not "temporarily." The moment you
> store a PAN you are in **PCI-DSS scope**, which is a compliance program with audits — not a
> checkbox. This is also why scraping cannot solve payments: PushPress doesn't hold those numbers
> either. Only Stripe does, as tokens.
>
> New cards get collected by **Stripe Elements** (web) and **PaymentSheet** (mobile). Your backend
> only ever sees `pm_...` and `cus_...`.

### ACH / bank debit mandates
Bank debits carry a **mandate** — the member's recorded authorization, tied to a specific merchant
and statement descriptor. Confirm with Stripe that existing mandates remain valid if anything about
the merchant of record or descriptor changes. If the descriptor on their statement changes, expect
disputes from members who don't recognize it. Tell them before the first charge under the new name.

### Do not consolidate into another entity's Stripe account
You mentioned Stripe accounts across Classic Pro, Longhorn Forge Holdings and others. Keep **OTL's
Stripe account as OTL's**. A different legal entity is a different merchant of record: the card
authorizations and ACH mandates your members gave were given to CrossFit OTL. Moving them under
another entity breaks that chain and invites disputes.

---

## 🧪 Dry run before you touch live money

Stripe test mode is free and complete. Rebuild the billing engine, load a full month of real
schedules as test data, and let it run a simulated cycle end to end. Reconcile every expected charge
against what actually fired. Only then go near live keys.

On cutover day: **confirm PushPress's biller is actually stopped before yours starts**, and reconcile
the first live cycle by hand, member by member. Budget a full day for that reconciliation.

---

## 🔗 Related

- [[Migration MOC]] — parent
- [[Data Inventory & Extraction Routes]] — everything that isn't payments
- [[Cutover Plan & Comms Safety]] — sequencing the switch
