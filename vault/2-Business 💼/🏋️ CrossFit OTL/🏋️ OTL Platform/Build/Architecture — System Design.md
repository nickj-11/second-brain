---
type: note
tags:
  - otl-platform
  - architecture
---
# Architecture — System Design

> [!tip] 🟣 Optimise for a small team, not for scale you don't have
> OTL is one gym with hundreds of members, not thousands of gyms with millions. Every hour spent on
> infrastructure is an hour not spent on the features members actually see. Pick boring, managed
> services and spend the time on the product.

---

## 🧱 Recommended stack

| Layer | Choice | Why |
|---|---|---|
| **Database** | Postgres via **Supabase** | Relational is right for this — members, enrollments, results are deeply relational. Supabase adds auth, row-level security, file storage and realtime on top. |
| **Auth** | Supabase Auth | Email, Apple and Google sign-in. Apple sign-in is effectively required for an iOS app with social login. |
| **File storage** | Supabase Storage | Profile pictures, post images |
| **Realtime** | Supabase Realtime | Comments, reactions and the social feed update live for free |
| **Web + admin** | **Next.js on Vercel** | Member web app and the staff/admin CRM |
| **Mobile** | **React Native + Expo** | One codebase for iOS and Android, shares TypeScript types with web. Expo handles App Store builds and over-the-air updates. |
| **Payments** | **Stripe** — Elements (web), PaymentSheet (mobile) | Already your processor; see [[Stripe & Payment Continuity]] |
| **Push** | Expo Push → APNs/FCM | |
| **Email / SMS** | Resend or Postmark; Twilio for SMS | Keep the sending layer swappable behind one interface |
| **GIFs** | Giphy or Tenor API | For workout comments |

You already have Supabase and Vercel connected, which makes this the path of least resistance rather
than a new set of accounts to manage.

> [!warning] 🟠 One caution on row-level security
> RLS is excellent and it is also easy to get subtly wrong. A member must never read another member's
> contact details, payment info or emergency contacts — but *must* read their workout results and
> comments. Write the policies deliberately, and test them with a real non-admin session, not from
> the service-role key.

---

## 🗂️ Core domain model

```
Member ──< Enrollment >── Plan
   │
   ├──< CheckIn >── ClassInstance >── ClassTemplate
   ├──< Reservation >── ClassInstance
   ├──< Result >── Workout >── WorkoutTrack   (CAP, Competition, …)
   ├──< PR >── Movement
   ├──< Appointment >── AppointmentType       (InBody, PT, …)
   ├──< Post / Comment / Reaction >
   ├──< MemberTag >── Tag
   └──< CampaignEnrollment >── Campaign
```

Design decisions worth making now, because they're expensive later:

- **`Result` needs `ScoringType`, `Division` and a scaling flag** — not a bare number. See the app spec.
- **`Movement` is a first-class entity**, so PRs and benchmarks resolve against a controlled
  vocabulary rather than free-text workout names.
- **Streaks, Committed Club and all-time counts are derived**, never stored as facts. Materialized
  view off `CheckIn`, refreshed nightly.
- **Keep external IDs on every record**: `pushpress_id`, `stripe_customer_id`. You will need to
  reconcile against both systems for months, and re-running an import without them creates duplicates.
- **`migrated_at` and `migration_source` on every imported row** — the guard that stops automations
  firing on historical events. See [[Cutover Plan & Comms Safety]].

---

## 💳 Billing engine

The part to get right, and the part to build least of.

**Prefer Stripe Subscriptions over your own scheduler.** Stripe handles retries, dunning, proration,
SCA and failed-payment recovery — all of which you would otherwise rebuild badly. Your CRM stores the
membership *policy*; Stripe executes the *billing*.

Where you do need custom logic — holds, comps, family plans, class packs — model it as your own
concept that *maps onto* a Stripe subscription, rather than replacing Stripe's scheduler.

Handle Stripe webhooks idempotently: `invoice.payment_failed`, `invoice.paid`,
`customer.subscription.updated`, `payment_method.attached`. Idempotency keys on everything you send.

---

## 🔐 Security baseline

Non-negotiable for a system holding member PII, minors' data (if you run kids' classes), emergency
contacts and payment tokens:

- Never store PANs or bank numbers. Stripe tokens only.
- Secrets in the platform's secret store, never in the repo. Separate keys per environment.
- Audit log on every staff action touching member data or billing.
- Encrypted, tested backups — a backup you haven't restored from is a hope, not a backup.
- MFA on every staff account.
- Consider what a member can request under privacy law: export and deletion paths, built early.

---

## 🔗 Related

- [[Build MOC]] — parent
- [[Member App — Feature Spec]] — what this serves
- [[Scope & Phasing — Honest Estimate]] — sequencing
- [[Stripe & Payment Continuity]] — payment specifics
