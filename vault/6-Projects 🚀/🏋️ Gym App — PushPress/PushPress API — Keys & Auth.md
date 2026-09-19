---
type: note
tags:
  - pushpress
  - api
  - gym-app
---
# PushPress API — Keys & Auth

> [!success] 🟢 There is no key to hunt for — you mint your own
> The PushPress Platform API key is self-serve. In Core: **Settings → Security & Access → Add API Key**
> (admin-level access required). Nothing has to be requested from PushPress support, and there is no
> pre-existing key buried in the account that needs finding.

---

## 🔑 The three different "PushPress API keys"

Easy to conflate these. They are not interchangeable.

| Key | Where it comes from | What it's for |
|---|---|---|
| **Core Platform API key** | Core → Settings → Security & Access → Add API Key | The real one. Members, check-ins, classes, billing plans, webhooks. This is what our app uses. |
| **Grow API key** | Grow account settings | Grow CRM only (marketing automation side). Separate product, separate key. |
| **Developer portal key** | `developer.pushpress.com` (login-walled dashboard) | Same Platform API, managed from a developer dashboard instead of the gym's Core settings. Also mintable programmatically via the `/keys` endpoints. |

---

## 🔌 Connection details

> [!info] 🟦 Confirmed against the official TypeScript SDK source (`@pushpress/pushpress` v1.15.0, published 2026-04-15), not just the docs site

- **Base URL (production):** `https://api.pushpress.com/v3`
- **Staging:** `https://api.pushpressstage.com/v3`
- **Development:** `https://api.pushpressdev.com/v3`
- **Auth header:** `API-KEY: <your key>` — note this is a custom header, **not** `Authorization: Bearer`
- **Company scoping:** most operations take a `companyId`; the SDK lets you set it once on the client
- **Env var the SDKs look for:** `PUSHPRESS_API_KEY`

```bash
curl -s "https://api.pushpress.com/v3/customers?companyId=$PP_COMPANY_ID" \
  -H "API-KEY: $PUSHPRESS_API_KEY"
```

```ts
import { PushPress } from "@pushpress/pushpress";

const pushPress = new PushPress({
  apiKey: process.env.PUSHPRESS_API_KEY!,
  companyId: process.env.PP_COMPANY_ID!,
});
```

---

## 📦 Official SDKs

| SDK | Package | Notes |
|---|---|---|
| TypeScript | `@pushpress/pushpress` on npm | 47 versions published, actively maintained, Speakeasy-generated |
| PHP | `pushpress/php-sdk` on Packagist | Same generated surface |

API reference lives at `ppe.apidocumentation.com` (Scalar-hosted). The root URL 404s from a plain
fetch — reach it from the links in the SDK README or the developer portal.

---

## 🔄 Key rotation & management via API

Once you hold one key, you can manage the rest programmatically:

- `POST /keys` — create a key (takes `name`, `description`, `expiresAt`)
- `GET /keys` — list
- `GET /keys/{id}` — retrieve
- `POST /keys/{id}/revoke` — revoke
- `DELETE /keys/{id}` — delete

Keys support an `expiresAt` timestamp, so build rotation in from day one rather than retrofitting it.

---

## 🔴 Security

> [!danger] 🔴 A Core API key is the whole gym
> This key reads and writes member PII, enrollments, and billing plan data. Treat it like a database
> root password.
> - Store it in a secret manager or platform env vars — **never in this vault, never in git**
> - One key per environment and per consumer, so a leak can be revoked without breaking everything
> - Set `expiresAt` and rotate on a schedule
> - Webhook consumers: verify the signing secret and rotate it via `/webhooks/{uuid}/rotate-signing-secret`

---

## 🔗 Related

- [[🏋️ Gym App — PushPress MOC]] — parent
- [[PushPress Platform API — Endpoint Inventory]] — what the key actually unlocks
- [[Workout & PR Data — Access Options]] — the part the API does *not* cover
