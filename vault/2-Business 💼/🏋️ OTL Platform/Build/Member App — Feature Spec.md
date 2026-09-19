---
type: note
tags:
  - otl-platform
  - product
  - mobile
---
# Member App — Feature Spec

Rebuild of what the OTL app does today (PushPress-hosted, so it cannot come with us), plus the
Instagram feed you want that it doesn't have.

> [!info] 🟦 Captured from your description 2026-09-19 — to be refined against the live app
> When you're at the Mac mini with the iPhone mirrored, walking the real app screen by screen will
> surface the details this misses. Treat this as the skeleton, not the final spec.

---

## 📱 Tab 1 — Home / Dashboard

- Profile picture, member name, gym identity (CrossFit OTL)
- ⚙️ Settings: appearance, **card and bank management** (Stripe PaymentSheet), notification prefs,
  emergency contacts, phone, email
- KPI tiles: **all-time check-ins**, **Committed Club**, **current streak**
- Access to personal history: past benchmarks, past workouts, PR history

> [!tip] 🟣 Compute the KPI tiles, don't store them
> Streaks, Committed Club and all-time counts are **derived** from check-in history. Store the
> check-ins as facts and compute the rest in a materialized view refreshed nightly. Storing them as
> numbers means they drift, and a drifted streak is a support ticket from an annoyed member.

---

## 📅 Tab 2 — Schedule

- Class calendar; reserve, cancel, join waitlist
- Check in for class
- Events: view, reserve, check in
- Appointments: view, reserve, check in
- **Buy appointments** — e.g. InBody body-composition scan — then schedule it

Capacity, waitlist promotion, late-cancel windows and no-show handling are all policy logic. Write
those rules down explicitly before building; they're where scheduling systems get messy.

---

## 🏋️ Tab 3 — Workouts

- Workout of the day, from the CAP track
- **Log a result** — scored by type: time, rounds+reps, load, distance, calories
- **Divisions**: Male RX, Female RX, Scaled, Masters, etc. Leaderboard filters by division.
- See everyone else's results for that workout
- React to results
- **Comment**, including **GIFs** (Giphy or Tenor API)
- **@mentions** — tagging a member notifies them, including when they aren't the result's author
- Personal benchmark and PR history; automatic PR detection

> [!warning] 🟠 Scoring model is the hard part of this tab
> A result is not a number. It's a value **plus** a scoring type, a division, a scaling flag, and
> sometimes a tiebreak. Model `Movement`, `ScoringType` and `Division` as first-class entities up
> front — retrofitting them across historical results is miserable.

---

## 💬 Tab 4 — Social

- Any logged-in member can post
- Gym announcements posted here
- Reactions and comments, same engine as workout comments
- **Embedded CrossFit OTL Instagram feed** — so members without Instagram stay in the loop

### 🟠 The Instagram feature has a real constraint
> [!warning] 🟠 Posts are achievable. Stories are the risky half.
> - Instagram's **Basic Display API was permanently shut down on 4 December 2024.** Anything built
>   against it is dead. The path now is the **Instagram Graph API**.
> - Requires a **Business or Creator** account linked to a Facebook Page. Personal accounts are not
>   supported. Confirm OTL's account type before promising this.
> - Your **own posts and reels** are readable via Graph API — this part is fine.
> - **Stories** need elevated permissions and Meta **app review**, and are only available for 24h.
>   Meta's Platform Terms also restrict caching and storing content.
>
> Plan: ship the posts feed. Treat stories as a phase-2 maybe, contingent on app review. Don't
> announce stories to members until Meta has actually approved it.

---

## 🔔 Cross-cutting

- Push notifications: @mentions, comments on your result, class reminders, waitlist promotion,
  payment failures
- Notification preferences that members actually control — per category, not one global toggle
- Deep links from notification into the exact result or post

---

## 🍎 App Store: the payments rule matters here

> [!success] 🟢 Good news — you must NOT use Apple's in-app purchase for gym services
> App Review Guideline **3.1.3(e)**, verbatim: *"If your app enables people to purchase physical
> goods or services that will be consumed outside of the app, you must use purchase methods other
> than in-app purchase to collect those payments, such as Apple Pay or traditional credit card
> entry."*
>
> Memberships, in-person classes and InBody scans are consumed in the real world at your gym. Stripe
> is not merely allowed — it's required. **No 30% cut.**

> [!danger] 🔴 Where the 30% does apply: anything digital
> Guideline **3.1.1** requires IAP to unlock features or content *inside* the app. If you ever sell
> an on-demand video library, remote programming, or a premium app tier, that's IAP at Apple's rates.
> Keep digital-only products out of the app, or price them knowing the cut.
>
> Also note **3.1.3(d)**: one-to-one remote personal training may use outside payment, but
> *one-to-many real-time* (virtual group classes) must use IAP. In-person classes aren't affected.

---

## 🔗 Related

- [[Build MOC]] — parent
- [[Architecture — System Design]] — how this gets built
- [[Scope & Phasing — Honest Estimate]] — what it costs to build it
