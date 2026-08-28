# 18 - Governance

## Aerospace Supply Chain — Data Governance Framework

---

## Overview

This document defines the governance framework ensuring data quality, consistency, security, and compliance across the Aerospace Supply Chain platform. Governance is enforced at every layer — from physical schema constraints through semantic views to conversational analytics responses.

---

## Governance Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                    GOVERNANCE PILLARS                                 │
├────────────────┬────────────────┬────────────────┬──────────────────┤
│   DATA         │   METRIC       │   ACCESS       │   COMPLIANCE     │
│   QUALITY      │   CONSISTENCY  │   CONTROL      │                  │
│                │                │                │                  │
│ • Freshness   │ • Single def   │ • RBAC         │ • ITAR           │
│ • Completeness│ • One formula  │ • Row-level    │ • AS9100         │
│ • Accuracy    │ • Governed SV  │ • Column mask  │ • Export control │
│ • Timeliness  │ • Audit trail  │ • Persona      │ • SOX            │
└────────────────┴────────────────┴────────────────┴──────────────────┘
```

---

## Data Quality Rules

### Schema-Level Constraints

| Rule | Enforcement | Tables |
|------|-------------|--------|
| NOT NULL on keys | DDL constraint | All _SK and _ID columns |
| UNIQUE on natural keys | DDL constraint | All _ID columns |
| Primary keys | DDL constraint | All tables |
| Boolean defaults | DEFAULT TRUE/FALSE | IS_ACTIVE, ITAR_CONTROLLED |
| Timestamp defaults | DEFAULT CURRENT_TIMESTAMP() | CREATED_TIMESTAMP |
| Auto-increment | AUTOINCREMENT | All _SK columns |

### Data Quality Monitors

| Monitor | Rule | Table | Threshold | Action |
|---------|------|-------|-----------|--------|
| Null check | PART_ID must not be null in facts | All FACT_* | 0% | Block load |
| Referential | SUPPLIER_ID must exist in DIM_SUPPLIER | FACT_PURCHASE_ORDER | 0% | Block load |
| Freshness | FACT_INVENTORY snapshot < 24h old | FACT_INVENTORY | 24 hours | Alert |
| Volume | Daily row count within ±30% of norm | FACT_INVENTORY_MOVEMENT | 30% variance | Alert |
| Range | RISK_SCORE between 0–100 | DIM_SUPPLIER | 0 violations | Alert |
| Range | YIELD_RATE between 0–100 | FACT_WORK_ORDER | 0 violations | Alert |
| Duplicate | No duplicate PO_ID in same day | FACT_PURCHASE_ORDER | 0% | Block load |
| Timeliness | IoT data < 5 min old | FACT_IOT_SENSOR_DATA | 5 minutes | Alert |

---

## Metric Governance

### Single Source of Truth

| Principle | Implementation |
|-----------|---------------|
| One definition per metric | META_METRIC_DEFINITION table |
| One formula per metric | FORMULA column — authoritative |
| Versioned changes | CREATED_TIMESTAMP + change log |
| Owner accountability | Each metric has a named OWNER |
| Governed by semantic view | Metrics only accessible through SV |

### Metric Change Control

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  REQUEST     │────▶│  REVIEW      │────▶│  APPROVE     │
│              │     │              │     │              │
│ • Who        │     │ • Impact     │     │ • Domain     │
│ • What       │     │ • Breaking?  │     │   owner      │
│ • Why        │     │ • Downstream │     │ • Data gov   │
│ • Formula    │     │   effects    │     │   council    │
└──────────────┘     └──────────────┘     └──────┬───────┘
                                                  │
                     ┌──────────────┐     ┌──────┴───────┐
                     │  VALIDATE    │◀────│  IMPLEMENT   │
                     │              │     │              │
                     │ • Test with  │     │ • Update META│
                     │   NL queries │     │ • Update SV  │
                     │ • Persona    │     │ • Deploy     │
                     │   consistency│     │              │
                     └──────────────┘     └──────────────┘
```

### Breaking Change Policy

| Change Type | Impact | Process |
|-------------|--------|---------|
| New metric | None (additive) | Standard approval |
| Formula change | High (changes historical values) | Council review + 30-day notice |
| Rename | Medium (breaks saved queries) | Alias for 90 days, then deprecate |
| Deprecation | High | 90-day notice + replacement |
| Threshold change | Low | Owner approval only |

---

## Access Control

### Role Hierarchy

```
ACCOUNTADMIN
└── SYSADMIN
    ├── SUPPLY_CHAIN_ADMIN
    │   ├── PROCUREMENT_ROLE
    │   ├── PLANNING_ROLE
    │   ├── MANUFACTURING_ROLE
    │   ├── LOGISTICS_ROLE
    │   ├── QUALITY_ROLE
    │   ├── SALES_ROLE
    │   └── FINANCE_ROLE
    └── EXECUTIVE_ROLE
        └── ANALYST_ROLE (read-only)
```

### Semantic View Access Matrix

| Role | SV_PROCUREMENT | SV_INVENTORY | SV_MANUFACTURING | SV_QUALITY | SV_SALES | EXECUTIVE_SV |
|------|:-:|:-:|:-:|:-:|:-:|:-:|
| PROCUREMENT_ROLE | ✓ | ○ | ○ | ○ | ○ | ✗ |
| PLANNING_ROLE | ○ | ✓ | ○ | ○ | ○ | ✗ |
| MANUFACTURING_ROLE | ○ | ○ | ✓ | ✓ | ○ | ✗ |
| LOGISTICS_ROLE | ○ | ○ | ○ | ○ | ✓ | ✗ |
| QUALITY_ROLE | ○ | ○ | ○ | ✓ | ○ | ✗ |
| EXECUTIVE_ROLE | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| ANALYST_ROLE | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |

✓ = Full access | ○ = Read-only | ✗ = No access

### Data Masking Rules

| Column | Masking | Roles Exempt | Reason |
|--------|---------|-------------|--------|
| SUPPLIER.ANNUAL_REVENUE | Redacted | PROCUREMENT_ROLE, EXECUTIVE_ROLE | Commercially sensitive |
| CUSTOMER.CREDIT_LIMIT | Redacted | SALES_ROLE, FINANCE_ROLE | Financially sensitive |
| PO.TOTAL_VALUE (>$1M) | Range bucket | All except FINANCE_ROLE | Cost visibility control |
| ITAR parts detail | Full mask | ITAR_AUTHORIZED_ROLE | Export control |

---

## Compliance Framework

### ITAR (International Traffic in Arms Regulations)

| Requirement | Implementation |
|-------------|---------------|
| Part classification | ITAR_CONTROLLED boolean on DIM_PART |
| Access restriction | Row-level security on ITAR parts |
| Export control | Shipment validation against embargoed countries |
| Audit trail | All access to ITAR data logged |
| Agent behavior | Copilot flags ITAR parts in responses |

### AS9100 (Aerospace Quality Management)

| Requirement | Implementation |
|-------------|---------------|
| Traceability | Full lot/batch tracking in FACT_INVENTORY_MOVEMENT |
| Document control | Certification records in DIM_CERTIFICATION |
| Non-conformance | Quality events tracked in FACT_QUALITY_EVENT |
| Corrective action | CAPA tracking with resolution dates |
| Supplier approval | CERTIFICATION_STATUS in DIM_SUPPLIER |

### Data Retention

| Data Type | Retention Period | Archive Strategy |
|-----------|-----------------|-----------------|
| Transactional facts | 7 years | Time-travel (90 days) + archive |
| Dimension history (SCD2) | Indefinite | Active + historical versions |
| IoT sensor data | 2 years | Hot (90 days) + cold storage |
| Quality events | 10 years | Regulatory requirement |
| Audit logs | 7 years | Immutable log |

---

## Audit Trail

### Query Audit

| Field | Description |
|-------|-------------|
| QUERY_ID | Snowflake query ID |
| USER_NAME | Who asked the question |
| TIMESTAMP | When |
| SEMANTIC_VIEW | Which view was queried |
| GENERATED_SQL | SQL produced by Cortex Analyst |
| RESULT_ROWS | How many rows returned |
| RESPONSE_TIME | Latency |

### Agent Interaction Audit

| Field | Description |
|-------|-------------|
| SESSION_ID | Conversation thread ID |
| USER_NAME | Who is chatting |
| QUESTION | Natural language input |
| TOOLS_USED | Which tools the agent invoked |
| SEMANTIC_VIEWS_QUERIED | Views accessed |
| METRICS_REFERENCED | Metric IDs cited |
| RESPONSE | Agent's answer |
| FEEDBACK | User thumbs up/down |

---

## Data Lineage

```
SOURCE SYSTEM          RAW SCHEMA         GOLD SCHEMA        SEMANTIC VIEW
─────────────          ──────────         ───────────        ─────────────
ERP.PO_HEADER    ───▶  RAW.PO_HEADER  ──▶ GOLD.FACT_PO  ──▶ SV_PROCUREMENT
                       (1:1 copy)        (transformed)      (governed)
                            │                  │                  │
                            ▼                  ▼                  ▼
                       Lineage tag:       Lineage tag:      Lineage tag:
                       source=ERP         transform=gold    semantic=governed
                       load_time=T        business_key=Y    metric=MET-xxx
```

### Lineage Metadata

Every table carries lineage metadata via tags:

| Tag | Values | Purpose |
|-----|--------|---------|
| DATA_SOURCE | ERP, TMS, IoT, QMS, Manual | Origin system |
| DATA_CLASSIFICATION | Public, Internal, Confidential, Restricted | Security tier |
| DATA_OWNER | Role name | Accountability |
| REFRESH_FREQUENCY | Real-time, Hourly, Daily, Weekly | Freshness expectation |
| CERTIFICATION_STATUS | Certified, Pending, Draft | Trust level |

---

## Governance KPIs

| Governance Metric | Target | Measurement |
|-------------------|--------|-------------|
| Metric consistency score | 100% | Same question → same answer across views |
| Data freshness SLA | 99.5% | Tables refreshed within documented lag |
| Access control coverage | 100% | All tables have appropriate RBAC |
| Lineage completeness | 100% | All tables tagged with source and owner |
| Glossary coverage | 100% | All metrics in META_METRIC_DEFINITION |
| Query audit coverage | 100% | All agent interactions logged |
| ITAR compliance | 100% | Zero unauthorized access to ITAR data |
