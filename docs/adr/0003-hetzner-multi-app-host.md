# ADR-0003: Hetzner CX33 as the shared multi-app host

- **Date:** 2026-05-18
- **Status:** Accepted

## Context

PsyClinicAI's web app is a static Flutter bundle. We need a public host that:

1. is **EU-resident** (GDPR-friendly latency + jurisdiction),
2. is **cheap** at the solo-pilot stage (< €10 / month),
3. lets us **co-host** the founder's other side projects (TradeFlow bot,
   ilhanostranscript, kumarbazlar) without spinning up a new box per app.

## Decision

A single **Hetzner Cloud CX33** (4 vCPU / 8 GB RAM / 80 GB NVMe) in Nuremberg.
Layout:

- one shared `ilhanostranscript-nginx` container as the reverse proxy on
  ports 80 / 443,
- one container per app (`psyclinicai-web`, `ilhanostranscript-app`,
  `kumarbazlar-app`, `tradeflow_bot`) on an internal Docker network,
- shared Let's Encrypt + certbot volumes on the host,
- host-level systemd pulling updates weekly (`unattended-upgrades`).

## Consequences

**Pros**

- ~€8 / month total infrastructure spend for four production apps.
- Single SSH key, single backup target, single firewall to maintain.
- Frankfurt / Nuremberg latency to EU end users < 30 ms.

**Cons**

- Single point of failure. Acceptable at pilot scale; we will move to a
  managed PaaS (Fly.io, Cloudflare Pages) or a multi-AZ setup when MRR
  justifies it (target Sprint 12+, ~$5 k MRR).
- Multi-tenant container layout means a memory leak in one app can starve
  another. Mitigation: Docker resource limits (Sprint 5 hardening).
- Hetzner is German; not certified for US HIPAA-only environments. We
  document this explicitly in [`docs/legal/HIPAA-BAA.md`](../legal/HIPAA-BAA.md).

## Links

- `deploy/deploy-hetzner.sh`
- `deploy/security-hardening.sh`
- `deploy/system-update.sh`
- `ARCHITECTURE.md` section 5
