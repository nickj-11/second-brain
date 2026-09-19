---
type: note
tags:
  - otl-platform
  - migration
  - stripe
  - payments
---
# Stripe & Payment Continuity

> [!success] 🟢 Yes — members almost certainly re-enter nothing
> Per PushPress's own documentation the gym connects its **own** Stripe account ("typically under the
> gym owner's email from when PushPress was set up"), with direct access at `dashboard.stripe.com`
> where the payout bank account is managed. If that holds for OTL, **this isn't a migration at all** —
> the new CRM points at the same Stripe account with our own API keys. Every `cus_` customer, every
> saved card, every bank account stays exactly where it is. **Zero member action.**

> [!danger] 🔴 The thing that could force re-entry is not card data — it's ACH authorization records
> Cards are portable tokens and move without issue. **Bank debits carry a mandate** — the member's
> recorded authorization — and Stripe requires the receiving account to attest it holds them. Details in
> the ACH section below. **Extract the authorization evidence from PushPress before leaving**, or those
> members may have to re-authorize.

---

## 🎯 The three scenarios

### A. We own the Stripe account — most likely
**Nothing moves.** Same account, same customers, same payment methods, same mandates, same merchant of
record. We swap API keys and revoke PushPress's access. Members do nothing and notice nothing.

### B. The account is platform-owned
Stripe's **self-serve PAN copy** moves the data to our own account:
- Copies **Customers, Cards, Sources, Payment Methods and Bank Accounts**
- **Preserves original Customer IDs** — our foreign keys survive
- **Subscriptions are NOT copied** — recreate via API
- Sender and recipient exchange `acct_` IDs from User settings; requires PushPress's cooperation
- Rate-limited per period; Stripe's Data Migration team handles larger jobs
- Variants: full copy, partial by customer selection, partial by CSV upload

Members still re-enter nothing **for cards**. ACH is conditional — see below.

### C. Neither works
Only if the account is platform-owned *and* PushPress won't cooperate with a copy. Then members re-add
payment methods. Unlikely, and worth knowing about early rather than late.

---

## 🏦 ACH / bank debits — the conditional part

Cards copy freely. Bank accounts don't, quite.

**Same account (scenario A):** mandates are untouched. Same merchant, same customers, same
authorizations. No issue at all.

**Different account (scenario B):** ACH *can* come across, but Stripe gates it:

> Before the copy begins, the **receiving account must acknowledge and agree that it holds the collected
> mandates.** If the receiving side doesn't agree, **the copy skips ACH payment methods entirely.**

And the standing obligation:

> You must hold your customer's authorization to debit their bank account, in a form complying with the
> **Nacha Operating Rules**, and **retain data sufficient to provide or reconstruct any ACH
> authorization**, producing evidence to Stripe on request.

> [!warning] 🟠 We can legitimately attest this — but only if we have the records
> The authorizations were given to **CrossFit OTL**, the same legal entity, so we genuinely do hold
> them. What we need is the *evidence*: for each member on bank debit, **when and how they authorized.**
> That lives in PushPress today.
>
> **This is an extraction requirement, and it's time-sensitive** — see [[Data Inventory & Extraction Routes]].
> Without it, ACH members get skipped and have to re-authorize. That is the single realistic path to
> "members had to re-enter their bank details," and it's avoidable.

**Migrating ACH from a non-Stripe processor** (not our case, but the mechanism shows what Stripe accepts):
a confirmed `SetupIntent` per account carrying `mandate_data[customer_acceptance][type]=offline` and
`accepted_at` set to **the original authorization date**, with `verification_method=skip` — a temporary
capability Stripe enables after reviewing how you collect authorization and verify accounts. Which
confirms the principle: **Stripe will honour an existing authorization if you can evidence its date.**

---

## ✅ Verify ownership first — 30 minutes, determines everything

1. Log into `dashboard.stripe.com` with the gym owner email. Can you see OTL's live payments?
2. Settings → note the account ID (`acct_...`).
3. Does the account show as a **connected account of a platform** (PushPress)? A Standard connected
   account is still *ours* — the platform merely holds API access we can revoke.
4. **Customers** → are there `cus_` records with saved payment methods? Roughly how many vs member count?
5. **Subscriptions** → live `sub_` objects, or only one-off PaymentIntents? (The next section.)
6. **How many members are on bank debit vs card?** Sizes the ACH question.
7. Settings → note PushPress's API access, to revoke after cutover.

---

## 🔴 The real risk isn't cards — it's the billing schedules

> [!danger] 🔴 "Nobody re-enters a card" is not the same as "billing keeps working"
> Saved payment methods survive trivially. The recurring billing **instruction** may not.

**If live Stripe `sub_` objects exist:** schedules live in Stripe and largely survive. We rebuild the
management UI, not the billing.

**If PushPress runs its own scheduler** — more likely, given its API models `/enrollments` and `/plans`
as first-class objects — then Stripe only ever saw individual charges, and **when we leave, recurring
billing simply stops.** The new CRM must recreate every schedule exactly: amount, interval, next charge
date, proration, discounts, comps, paused states, family plans, annual vs monthly.

Wrong in one direction, revenue stops. Wrong in the other, members get double-charged. This is the
highest-risk item in the project, and it has nothing to do with card data.

---

## 🔴 Hard rules

> [!danger] 🔴 Never let a PAN or bank account number touch our servers
> Not in a database, a log, a scraped blob, or "temporarily." Storing one puts us in **PCI-DSS scope** —
> an audited compliance programme. It's also why scraping can't solve payments: PushPress doesn't hold
> those numbers either. Only Stripe does, as tokens. New payment methods come in via Stripe Elements
> (web) and PaymentSheet (mobile); our backend only ever sees `pm_` and `cus_`.

**Statement descriptor:** if it changes, members see a charge they don't recognise and dispute it. Keep
it identical, or announce the change before the first charge.

**Merchant-initiated transactions:** recurring charges and POS "charge card on file" are off-session
MITs. Staying on the same account means we inherit whatever PushPress set up at save time — spot-test
several off-session charges during the first cycle rather than assuming.

**Card account updater:** Stripe can auto-update reissued and expired cards. Confirm it's enabled — it
quietly prevents a slow bleed of failed payments.

> [!danger] 🔴 Do not consolidate OTL into another entity's Stripe account
> Classic Pro, Longhorn Forge and the others have their own Stripe accounts. Keep **OTL's as OTL's.** A
> different legal entity is a different merchant of record: the card authorisations and ACH mandates
> members gave were given to CrossFit OTL. Moving them under another entity breaks that chain, invites
> disputes, and would genuinely require re-authorisation. **This is the one way to accidentally create
> the problem we're trying to avoid.**

---

## 🧪 Dry run before touching live money

Stripe test mode is free and complete. Rebuild the billing engine, load a full month of real schedules
as test data, run a simulated cycle end to end, reconcile every expected charge against what fired.
Only then go near live keys.

On cutover day: **confirm PushPress's biller is actually stopped before ours starts** — verified in
their UI, not assumed — and reconcile the first live cycle by hand, member by member. Budget a day.

---

## 👤 What members actually experience

Done properly: **nothing.** No new card, no new bank account, no re-authorisation, no interruption. The
app changes; the payment doesn't.

Still send one announcement before cutover — what's changing, that they need do nothing, what their
statement will say. People accept change they were told about.

---

## 🔗 Related

- [[Migration MOC]] — parent
- [[Data Inventory & Extraction Routes]] — including the ACH authorization evidence
- [[Cutover Plan & Comms Safety]] — sequencing the switch
- [[Staff Mode & POS — Roles, Terminal, Refunds]] — charging cards on file from the POS
