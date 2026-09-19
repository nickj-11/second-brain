#!/usr/bin/env python3
"""
Extract everything the documented PushPress Platform API v3 exposes, to JSON.

Endpoints and auth verified against the official SDK source (@pushpress/pushpress
v1.15.0), not marketing docs. Auth is the custom `API-KEY` header, NOT Bearer.
Pagination is 1-based `page` plus `limit`.

Usage:
    export PUSHPRESS_API_KEY=...        # Core > Settings > Security & Access
    export PUSHPRESS_COMPANY_ID=...
    python3 pushpress_extract.py --out ./extract

Writes one JSON file per collection plus a manifest with counts, so the results
can be reconciled against what the Core UI reports. Re-running is safe: finished
collections are skipped unless --force is passed.

Deliberately read-only. Nothing here writes to PushPress.
"""

import argparse
import json
import os
import pathlib
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from datetime import datetime, timezone

BASE = os.environ.get("PUSHPRESS_BASE", "https://api.pushpress.com/v3")
PAGE_LIMIT = 100          # SDK defaults to 10; raise it and back off on 429
MAX_RETRIES = 5

# Paginated list endpoints. Everything else is fetched by id off the back of these.
COLLECTIONS = {
    "customers":              "/customers",
    "enrollments":            "/enrollments",
    "classes":                "/classes",
    "class_types":            "/classes/types",
    "events":                 "/events",
    "reservations":           "/reservations",
    "invitations":            "/invitations",
    "checkins_class":         "/checkins/class",
    "checkins_appointment":   "/checkins/appointment",
    "checkins_event":         "/checkins/event",
    "checkins_open":          "/checkins/open",
}

SINGLETONS = {
    "company": "/company",
}


def request(path, params, api_key):
    """GET with retry and 429 backoff. Returns parsed JSON."""
    url = f"{BASE}{path}"
    if params:
        url += "?" + urllib.parse.urlencode(
            {k: v for k, v in params.items() if v is not None}
        )
    for attempt in range(MAX_RETRIES):
        req = urllib.request.Request(url, headers={
            "API-KEY": api_key,
            "Accept": "application/json",
            "User-Agent": "otl-migration-extract/1.0",
        })
        try:
            with urllib.request.urlopen(req, timeout=60) as resp:
                return json.loads(resp.read().decode())
        except urllib.error.HTTPError as e:
            # Respect Retry-After; back off on rate limits and 5xx.
            if e.code in (429, 500, 502, 503, 504):
                wait = int(e.headers.get("Retry-After") or (2 ** attempt))
                print(f"  {e.code} on {path} — retrying in {wait}s", file=sys.stderr)
                time.sleep(wait)
                continue
            body = e.read().decode(errors="replace")[:400]
            raise SystemExit(f"HTTP {e.code} on {url}\n{body}")
        except urllib.error.URLError as e:
            wait = 2 ** attempt
            print(f"  network error on {path} ({e.reason}) — retrying in {wait}s",
                  file=sys.stderr)
            time.sleep(wait)
    raise SystemExit(f"gave up on {path} after {MAX_RETRIES} attempts")


def unwrap(payload):
    """The API wraps lists in an envelope; find the actual array."""
    if isinstance(payload, list):
        return payload
    if isinstance(payload, dict):
        for key in ("data", "results", "items"):
            if isinstance(payload.get(key), list):
                return payload[key]
    return []


def fetch_all(path, api_key, company_id):
    """Walk every page. Stops when a short page comes back."""
    rows, page = [], 1
    while True:
        payload = request(path, {
            "companyId": company_id,
            "page": page,
            "limit": PAGE_LIMIT,
        }, api_key)
        batch = unwrap(payload)
        rows.extend(batch)
        print(f"  page {page}: +{len(batch)} (total {len(rows)})")
        if len(batch) < PAGE_LIMIT:
            return rows
        page += 1
        time.sleep(0.2)          # be a good citizen


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default="./extract")
    ap.add_argument("--force", action="store_true",
                    help="re-fetch collections already on disk")
    args = ap.parse_args()

    api_key = os.environ.get("PUSHPRESS_API_KEY")
    company_id = os.environ.get("PUSHPRESS_COMPANY_ID")
    if not api_key or not company_id:
        raise SystemExit(
            "Set PUSHPRESS_API_KEY and PUSHPRESS_COMPANY_ID.\n"
            "Key: Core > Settings > Security & Access > Add API Key"
        )

    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    out = pathlib.Path(args.out) / stamp
    out.mkdir(parents=True, exist_ok=True)
    manifest = {"extracted_at": stamp, "base": BASE, "counts": {}, "errors": {}}

    for name, path in SINGLETONS.items():
        print(f"{name} {path}")
        try:
            data = request(path, {"companyId": company_id}, api_key)
            (out / f"{name}.json").write_text(json.dumps(data, indent=2))
            manifest["counts"][name] = 1
        except SystemExit as e:
            print(f"  FAILED: {e}", file=sys.stderr)
            manifest["errors"][name] = str(e)

    for name, path in COLLECTIONS.items():
        target = out / f"{name}.json"
        if target.exists() and not args.force:
            print(f"{name} — already present, skipping")
            continue
        print(f"{name} {path}")
        try:
            rows = fetch_all(path, api_key, company_id)
            target.write_text(json.dumps(rows, indent=2))
            manifest["counts"][name] = len(rows)
        except SystemExit as e:
            print(f"  FAILED: {e}", file=sys.stderr)
            manifest["errors"][name] = str(e)

    (out / "_manifest.json").write_text(json.dumps(manifest, indent=2))

    print(f"\nWrote {out}")
    for k, v in sorted(manifest["counts"].items()):
        print(f"  {k:24} {v:>7}")
    if manifest["errors"]:
        print("\nErrors:")
        for k, v in manifest["errors"].items():
            print(f"  {k}: {v}")

    print("\nNOT covered by this API — separate routes required:")
    print("  workout results, benchmarks, PRs   (no endpoint; export/scrape)")
    print("  cards and bank accounts            (Stripe, never PushPress)")
    print("  tags, campaigns, leads             (Grow — separate product and key)")
    print("  profile photos, social posts       (app responses)")
    print("\nReconcile these counts against the Core UI before trusting them.")


if __name__ == "__main__":
    main()
