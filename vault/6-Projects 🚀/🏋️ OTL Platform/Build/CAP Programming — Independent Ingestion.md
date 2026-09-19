---
type: note
tags:
  - otl-platform
  - crossfit
  - programming
  - build
---
# CAP Programming — Independent Ingestion

> [!success] 🟢 The route is Google Docs, and it's the one we already control
> CrossFit delivers CAP to nine targets: **Google Docs**, SugarWOD, Wodify, PushPress, STREAMFIT,
> BTWB, Strivee, WODBoard and Chalk It Pro. Eight are platforms we're replacing. Google Docs is the
> ninth — the affiliate-facing channel with **no platform in between.** We read our own document with
> our own credentials. No partner deal, no PushPress, no borrowed key.

> [!info] 🟦 Leaving PushPress does not cost us CAP
> CAP is **included with affiliation** — no extra subscription, no extra cost — and lives in the
> Affiliate Toolkit. It belongs to the affiliation, not to PushPress.

---

## 🔁 The pipeline

```
CrossFit  →  our Google Doc  →  Drive/Docs API  →  parser  →  staff review  →  published Workout
              (CAP delivery)      (our OAuth)      (LLM)      (programmer)     (CRM + app)
```

1. **Detect** — poll the Drive folder / document for the weekly drop (released by Friday at the latest)
2. **Fetch** — Google Docs API with our own OAuth credentials, service account or delegated
3. **Parse** — doc text → typed records against our schema
4. **Review** — a programmer confirms before it goes live
5. **Publish** — becomes a `Workout` on the CAP `WorkoutTrack`, visible in app

---

## 🧩 Parsing is the actual work

CAP arrives as **prose written for coaches** — workout, scaling options, coaching notes, warm-up,
timeline — not as structured data. We need `Workout`, `Movement`, `ScoringType` and `Division`
records out of it.

> [!tip] 🟣 This is a genuinely good use of LLM structured extraction
> Feed the document text, get typed JSON back against our schema. Far more robust than regex against
> prose that changes format week to week.

> [!danger] 🔴 Never auto-publish an unreviewed parse
> A misparsed rep scheme or time cap goes straight onto the whiteboard and into members' logged
> results. **Human review is a required step, not a nicety.** Show the parsed result beside the
> original text so the programmer can eyeball it in seconds.

Keep the raw source text on every workout record. When a parse turns out wrong, you want to re-parse
from the original rather than re-fetch a doc that may have moved on.

---

## ❓ To verify at the Mac mini

- [ ] **Exact Google Docs delivery mechanism** — a single shared doc? A Drive folder? A new doc weekly?
      This determines whether we poll a file or watch a folder.
- [ ] Whether the Affiliate Toolkit offers anything more machine-readable than a doc
- [ ] Whether all four tracks (Affiliate, At Home, Compete, Lifting) come through the same channel
- [ ] **Email `affiliatesupport@crossfit.com`** and ask directly what structured or API delivery
      exists for affiliates. Costs nothing; might remove the parser entirely.

---

## 🚫 Routes that don't work

| Route | Why not |
|---|---|
| Use PushPress's CAP credential | It's theirs, server-side, never issued to affiliates |
| Become a CAP distribution partner | A business deal with CrossFit; unrealistic for one gym and unnecessary |
| Scrape Train for the programming | Works, but keeps us dependent on the system we're leaving |

> [!info] 🟦 Interim option during Phases 1–3
> While PushPress still runs the gym, scraping Train for programming is a legitimate *bridge* — it
> gets the app working before the Google Docs pipeline is built. Just don't let it become the
> permanent answer; it's a dependency on the thing we're removing.

---

## ⚖️ Licensing

CAP is CrossFit's intellectual property, licensed to us as an affiliate in good standing. Ingesting it
into our own system to show **our own members** is the intended use. Don't republish it publicly, and
don't expose it to non-members through the app.

---

## 🔗 Related

- [[Build MOC]] — parent
- [[CrossFit Affiliate Programming → Train Sync]] — how it reaches PushPress today, and whose key that is
- [[Member App — Feature Spec]] — the workouts tab this feeds
- [[Architecture — System Design]] — where Workout and Movement live
