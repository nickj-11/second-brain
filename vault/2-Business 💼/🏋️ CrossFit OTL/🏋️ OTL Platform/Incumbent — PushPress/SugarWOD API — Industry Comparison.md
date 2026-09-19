---
type: note
tags:
  - sugarwod
  - crossfit
  - api
  - gym-app
  - reference
---
# SugarWOD API — Industry Comparison

> [!abstract] 🟡 Why this note exists
> SugarWOD is another CAP distribution partner and has the most openly documented API in this space.
> It's the control case: if *they* don't expose athlete scores either, then the results gap blocking
> our app is an industry norm, not a PushPress quirk we can route around by switching platforms.

**Verdict: they don't.** Same wall.

---

## 🔌 Connection details

- **Base URL:** `https://api.sugarwod.com/v2`
- **Auth header:** `Authorization: <YOUR-API-KEY>` — note: the bare key, no `Bearer` prefix
- **Alternative:** `?apiKey=<key>` query parameter
- **Key creation:** self-serve in the SugarWOD portal at `/gyms/settings/developer-keys`

---

## 📚 What it exposes

| Group | Endpoints |
|---|---|
| **Affiliates** | `GET /box`, `GET /box/account-owner`, `PATCH /box` |
| **Athletes** | `GET /athletes?role=`, `GET /athletes/{id}`, `GET /athletes/find?email=`, `POST /athletes`, `PATCH /athletes/{id}`, `PATCH /athletes/{id}/remove` |
| **Workouts** | `GET /workouts?dates=&track_id=`, `GET /workouts/{id}`, `GET /workouts/{id}/athletes` |
| **Workouts HQ** | CrossFit mainsite programming — same shape as Workouts |
| **Benchmarks** | `GET /benchmarks/{id}`, `GET /benchmarks/category/{category}` |
| **Barbell lifts** | `GET /barbelllifts/{id}` |
| **Movements** | `GET /movements`, `GET /movements/{id}` |
| **Tracks** | `GET /tracks`, `POST /tracks` |
| **Webhooks** | `event.affiliate.ATHLETE_JOINED` |

---

## 🔴 The same gap

> [!danger] 🔴 Nobody in this space publishes athlete results
> - `GET /workouts/{id}/athletes` returns **which athletes logged** a workout — not what they scored
> - `GET /athletes/{id}/summary/performance` and `/summary/participation` are published but marked
>   **"not yet available"**
> - No CAP/mainsite athlete results at all
>
> Conclusion for our build: switching platforms does not solve the results problem. The only real
> paths are a partner-level data agreement or a supported export. See
> [[Workout & PR Data — Access Options]].

One genuine advantage over PushPress's API: SugarWOD exposes **workout programming** (including a
CrossFit mainsite group), **benchmarks**, **barbell lifts** and **movements** as first-class objects.
PushPress v3 exposes none of those. Useful if we ever need a structured movement/benchmark
vocabulary to model our own schema against.

---

## 🔗 Related

- [[Incumbent — PushPress MOC]] — parent
- [[PushPress Platform API — Endpoint Inventory]] — our platform's surface, for contrast
- [[CrossFit Affiliate Programming → Train Sync]] — the CAP partner network
- [[Workout & PR Data — Access Options]] — the decision this feeds
