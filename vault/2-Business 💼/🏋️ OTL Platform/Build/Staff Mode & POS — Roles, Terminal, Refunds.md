---
type: note
tags:
  - otl-platform
  - pos
  - staff
  - build
---
# Staff Mode & POS — Roles, Terminal, Refunds

> [!success] 🟢 One app, role-gated — the right call
> PushPress splits this into the member OTL app and a separate staff app. Collapsing both into **one
> CrossFit OTL app** with staff features gated by role is better on every axis: one codebase, one auth
> system, one release cycle, one App Store listing, and staff stop carrying two apps. Same accounts
> already, so nothing is lost.

---

## 👤 Roles

Not a boolean. Permissions are per-capability, so a coach who programs isn't automatically someone who
can issue refunds.

| Role | Can do |
|---|---|
| `member` | Own profile, schedule, workouts, social |
| `staff` | Check members into classes, events and appointments; view member details; take POS sales |
| `programmer` | Create and edit workouts, publish CAP parses |
| `admin` | Member management, plans, enrollments, settings |
| `pos_admin` | **Issue refunds.** Explicitly assigned by an admin in the CRM |

Roles are additive and assigned in the CRM web admin, never self-served in the app. Every
role-gated action writes an audit log entry: who, what, when, which member, how much.

> [!warning] 🟠 Apple can't see gated features — supply a demo account
> A reviewer logging in as a plain member sees none of the staff surface, and "we were unable to
> locate the described functionality" is a routine rejection. **Include a staff demo account in App
> Review notes on every submission.** Consider a demo-mode flag that exposes staff UI against seeded
> data.

---

## 💳 POS

Three payment paths, all on the existing OTL Stripe account:

### 1. Card present — Tap to Pay on iPhone
Stripe Terminal, official React Native SDK (`stripe/stripe-terminal-react-native`). This replaces the
Stripe reader / Tap to Pay you already use through PushPress, on the same Stripe account.

> [!danger] 🔴 Tap to Pay has lead time — start the entitlement request early
> - **Apple entitlement required**: request the *development* entitlement, then a **separate
>   *distribution* entitlement** after internal testing. Neither is instant.
> - iPhone **XS or later**, iOS **15.1+**
> - Apple **mandates** a "How to Tap" instructional overlay via `ProximityReaderDiscovery` — must be
>   integrated **before** submitting for review
> - **Location services must be available** or Stripe disables payments outright
> - Supports Visa, Mastercard, Amex contactless plus Apple/Google/Samsung Pay

### 2. Card on file — charge a member's saved method
The big one for you: search a member by name, charge the card or bank account already on file.

Mechanically this is an **off-session PaymentIntent** against the member's saved `pm_...`. Because the
member isn't present to authenticate, it's a **merchant-initiated transaction** — it must be set up
correctly at save time or these charges fail authentication. Worth getting right early; it's the
single most-used POS path in a gym.

### 3. Manual card entry
Fallback for a member without a saved method. Stripe Elements / PaymentSheet — never a raw PAN in
your UI.

---

## ↩️ Refunds — the approval workflow you asked for

```
staff initiates  →  refund REQUEST (pending)  →  pos_admin reviews  →  Stripe refund  →  audit log
                                              ↘  declined, with reason
```

- Staff **cannot** issue a refund. They raise a request with an amount and a reason.
- Only `pos_admin` can approve. That role is assigned by an admin in the CRM.
- Approver gets a push notification; requester gets the outcome.
- Every request, approval and decline is logged immutably — who asked, who approved, why.
- Partial refunds supported. Refund amount can never exceed the original charge; enforce server-side.
- Idempotency keys on every Stripe refund call, so a double-tap can't double-refund.

> [!tip] 🟣 Make the request the only path, even for admins
> An admin refunding directly, bypassing the request record, is how audit trails develop holes. Let
> admins approve their own requests instantly if you like — but the record still gets written.

---

## 📦 Products, inventory and sales history

Everything currently in PushPress: Element drinks and electrolyte packets, body scans, drop-ins,
merch, services.

> [!success] 🟢 There is a supported export route — no scraping needed
> The v3 API has no products or sales endpoints, but Core's reporting does, as CSV/Excel:
> - **Retail Sales report** — "by Category" (summary) and "Detail" (every product purchase and
>   miscellaneous charge)
> - **Financial Details report** — every transaction including payments, **refunds**, discounts and fees
>
> Reports → Financial → the relevant report → ⋯ → **Download Data**.
> **Set Advanced Data Options → All Results** or you get a truncated subset.

Cross-check totals against Stripe, which is the real source of truth for money.

### Model to build
`Product` (name, category, price, taxable, active) · `InventoryItem` (stock, reorder point) ·
`Sale` → `SaleLineItem` · `Payment` → Stripe charge · `Refund` → Stripe refund + approval record

Sales tax is configured per product in PushPress today — carry that configuration across deliberately
rather than re-deriving it.

---

## ✏️ Editing workouts from the app

The pain point you named: changing a workout today means a computer and a Train login. In the new
system a `programmer` edits from the app or the CRM.

> [!danger] 🔴 Edits after results exist must version, not overwrite
> If members have already logged against a workout, a destructive edit silently invalidates their
> results and corrupts benchmark history.
>
> - `Workout` carries a version. An edit after the first logged result creates a new version.
> - Existing results stay bound to the version they were logged against.
> - Everyone who already logged gets a **push notification** that the workout changed, with what
>   changed, and a prompt to re-log.
> - Require re-authentication or a confirmation step for edits to a workout that already has results.
> - Show the programmer the logged-result count **before** they confirm: "14 members have logged this."

---

## 🔗 Related

- [[Build MOC]] — parent
- [[Member App — Feature Spec]] — the member-facing tabs
- [[Architecture — System Design]] — domain model and RLS
- [[Stripe & Payment Continuity]] — the Stripe account this all runs on
- [[Data Inventory & Extraction Routes]] — extracting products and sales history
