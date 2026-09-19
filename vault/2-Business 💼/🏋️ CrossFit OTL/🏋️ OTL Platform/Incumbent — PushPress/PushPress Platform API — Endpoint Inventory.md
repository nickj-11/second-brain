---
type: note
tags:
  - pushpress
  - api
  - gym-app
  - reference
---
# PushPress Platform API — Endpoint Inventory

> [!warning] 🟠 The API covers the business, not the whiteboard
> Every endpoint below was read straight out of the official SDK source. There are **40 paths and 0
> of them touch workouts, results, benchmarks, or PRs.** Members, attendance, scheduling and billing
> are fully available. Performance data is not.

Source of truth: `@pushpress/pushpress` v1.15.0 (`src/funcs/`, `src/lib/config.ts`), verified 2026-09-19.

---

## 📚 Endpoints by group

### Customers (members)
| Method | Path |
|---|---|
| GET | `/customers` — list |
| POST | `/customers` — create |
| GET | `/customers/{uuid}` |
| GET/POST | `/attributions/attributions`, `/attributions/attributions/{uuid}` — lead source attribution |

### Check-ins — this is our attendance spine
| Method | Path |
|---|---|
| GET | `/checkins/class`, `/checkins/class/{uuid}` |
| GET | `/checkins/appointment`, `/checkins/appointment/{uuid}` |
| GET | `/checkins/event`, `/checkins/event/{uuid}` |
| GET | `/checkins/open`, `/checkins/open/{uuid}` — open-gym check-ins |
| GET | `/checkins/count` |

### Scheduling
| Method | Path |
|---|---|
| GET | `/classes`, `/classes/{id}` |
| GET | `/classes/types`, `/classes/types/{id}` |
| GET | `/events`, `/events/{id}` |
| GET | `/appts/{id}` — appointments |
| GET | `/reservations`, `/reservations/{id}` |

### Membership & billing
| Method | Path |
|---|---|
| GET | `/enrollments`, `/enrollments/{uuid}` |
| GET | `/plans/{id}` |
| GET | `/company` |
| GET/POST/DELETE | `/invitations`, `/invitations/{id}` |

### Messaging — useful for PR celebrations
| Method | Path |
|---|---|
| POST | `/messages/email/send` |
| POST | `/messages/sms/send` |
| POST | `/messages/push/send` |
| POST | `/messages/notification/send` — in-app / realtime |

### Keys & webhooks
| Method | Path |
|---|---|
| GET/POST | `/keys`, `/keys/{id}`, `/keys/{id}/revoke` |
| CRUD | `/webhooks`, `/webhooks/{uuid}` |
| POST | `/webhooks/{uuid}/activate`, `/deactivate`, `/rotate-signing-secret` |

---

## 📡 Webhook events available

Real-time push instead of polling. The complete list:

`app.installed` · `app.uninstalled` · `appointment.canceled` · `appointment.noshowed` ·
`appointment.rescheduled` · `appointment.scheduled` · `checkin.created` · `checkin.deleted` ·
`checkin.failed` · `checkin.updated` · `class.canceled` · `customer.created` · `customer.deleted` ·
`customer.details.changed` · `customer.status.changed` · `enrollment.created` · `enrollment.deleted` ·
`enrollment.status.changed` · `memberapp.updated` · `reservation.canceled` · `reservation.created` ·
`reservation.noshowed` · `reservation.waitlisted`

> [!tip] 🟣 Build on `checkin.created` + `customer.*`
> Attendance streaks, retention flags and at-risk-member alerts are all reachable today with zero
> workout data. That's the half of the app we can ship immediately.

---

## 🔍 What is missing

No endpoint, model, or webhook event in the published SDK mentions workout, result, score,
benchmark, rep max, or PR. Train's performance data is not part of the public v3 surface as of
2026-09-19. See [[Workout & PR Data — Access Options]].

---

## 🔗 Related

- [[Incumbent — PushPress MOC]] — parent
- [[PushPress API — Keys & Auth]] — how to authenticate against all of the above
- [[Workout & PR Data — Access Options]] — closing the gap
