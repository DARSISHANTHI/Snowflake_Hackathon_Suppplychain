# 17 - Executive KPIs

## Aerospace Supply Chain — Executive Dashboard Specification

---

## Overview

This document defines the executive-level KPIs, their calculation logic, visualization requirements, and RAG (Red/Amber/Green) thresholds for the leadership dashboard. All metrics are sourced from governed semantic views ensuring consistency with operational reporting.

---

## Executive Dashboard Layout

```
┌─────────────────────────────────────────────────────────────────────┐
│                  SUPPLY CHAIN HEALTH INDEX: 82/100                    │
│                        ████████████████░░░░                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐           │
│  │   OTD    │  │Fill Rate │  │   DOI    │  │  Yield   │           │
│  │  94.2%   │  │  97.8%   │  │ 42 days  │  │  97.5%   │           │
│  │  🟡 ↓    │  │  🟡 ↓    │  │  🟢 →    │  │  🟢 ↑    │           │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘           │
│                                                                       │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐           │
│  │  Spend   │  │Rev@Risk  │  │  Scrap   │  │   SPI    │           │
│  │  $45.2M  │  │  $2.1M   │  │  2.3%    │  │  78/100  │           │
│  │  → Budget│  │  🟡 ↑    │  │  🟢 →    │  │  🟡 ↓    │           │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘           │
│                                                                       │
├─────────────────────────────────────────────────────────────────────┤
│  TRENDS (6-month)          │  TOP RISKS                              │
│  [Line charts]             │  1. Supplier X OTD declining           │
│                            │  2. 3 parts below safety stock         │
│                            │  3. Quality spike at Plant Y           │
└─────────────────────────────────────────────────────────────────────┘
```

---

## KPI Definitions

### 1. Supply Chain Health Index

| Property | Value |
|----------|-------|
| **Definition** | Composite index of top supply chain KPIs |
| **Formula** | `(OTD_score + FillRate_score + DOI_score + Yield_score + (100-Risk_score)) / 5` |
| **Range** | 0–100 |
| **Target** | ≥ 80 |
| **RAG** | Green ≥ 80, Yellow 70–80, Red < 70 |
| **Frequency** | Daily |
| **Source** | EXECUTIVE_SUMMARY_SV |

### 2. On-Time Delivery (Customer-Facing)

| Property | Value |
|----------|-------|
| **Definition** | % of customer shipments delivered by promised date |
| **Formula** | `COUNT(IS_ON_TIME=TRUE) / COUNT(*) * 100` |
| **Target** | ≥ 95% |
| **RAG** | Green ≥ 95%, Yellow 90–95%, Red < 90% |
| **Trend** | Month-over-month comparison |
| **Drill-down** | By customer, by region, by carrier |
| **Source** | SV_PROCUREMENT, SHIPMENT_ANALYTICS_SV |

### 3. Fill Rate

| Property | Value |
|----------|-------|
| **Definition** | % of customer demand fulfilled from available stock |
| **Formula** | `SUM(QTY_SHIPPED) / NULLIF(SUM(QTY_ORDERED), 0) * 100` |
| **Target** | ≥ 98% |
| **RAG** | Green ≥ 98%, Yellow 95–98%, Red < 95% |
| **Trend** | Month-over-month |
| **Drill-down** | By customer type, by part family |
| **Source** | SV_SALES, CUSTOMER_ORDERS_SV |

### 4. Days of Inventory

| Property | Value |
|----------|-------|
| **Definition** | Days of supply based on current stock and demand rate |
| **Formula** | `AVG(ON_HAND_QTY / daily_demand)` |
| **Target** | 30–60 days (industry band) |
| **RAG** | Green 30–60, Yellow 15–30 or 60–90, Red <15 or >90 |
| **Trend** | Weekly |
| **Drill-down** | By part family, by plant, by criticality |
| **Source** | SV_INVENTORY, INVENTORY_MANAGEMENT_SV |

### 5. Production Yield

| Property | Value |
|----------|-------|
| **Definition** | First-pass yield from manufacturing |
| **Formula** | `SUM(QTY_COMPLETED) / NULLIF(SUM(QTY_ORDERED), 0) * 100` |
| **Target** | ≥ 97% |
| **RAG** | Green ≥ 97%, Yellow 95–97%, Red < 95% |
| **Trend** | Monthly |
| **Drill-down** | By plant, by part family, by work center |
| **Source** | SV_MANUFACTURING, MANUFACTURING_ANALYTICS_SV |

### 6. Procurement Spend

| Property | Value |
|----------|-------|
| **Definition** | Total PO value placed in period |
| **Formula** | `SUM(TOTAL_VALUE)` |
| **Target** | Within budget (±5%) |
| **RAG** | Green ≤ budget, Yellow 100–105% of budget, Red > 105% |
| **Trend** | Monthly actual vs budget |
| **Drill-down** | By supplier, by category, by plant |
| **Source** | SV_PROCUREMENT, PROCUREMENT_ANALYTICS_SV |

### 7. Revenue at Risk

| Property | Value |
|----------|-------|
| **Definition** | Customer order value impacted by supply chain disruptions |
| **Formula** | `SUM(SO.TOTAL_VALUE) WHERE linked shipments late OR inventory below safety` |
| **Target** | $0 (minimize) |
| **RAG** | Green < $1M, Yellow $1M–$5M, Red > $5M |
| **Trend** | Weekly |
| **Drill-down** | By root cause (supplier/inventory/logistics), by customer |
| **Source** | EXECUTIVE_SUMMARY_SV, Cross-domain |

### 8. Scrap Rate

| Property | Value |
|----------|-------|
| **Definition** | % of production scrapped |
| **Formula** | `SUM(QTY_SCRAPPED) / NULLIF(SUM(QTY_ORDERED), 0) * 100` |
| **Target** | ≤ 3% |
| **RAG** | Green ≤ 2%, Yellow 2–5%, Red > 5% |
| **Trend** | Monthly |
| **Drill-down** | By plant, by part, by root cause |
| **Source** | SV_MANUFACTURING |

### 9. Supplier Performance Index (Avg)

| Property | Value |
|----------|-------|
| **Definition** | Average SPI across active strategic suppliers |
| **Formula** | `AVG(SPI) WHERE CATEGORY='Strategic'` |
| **Target** | ≥ 80 |
| **RAG** | Green ≥ 80, Yellow 70–80, Red < 70 |
| **Trend** | Quarterly |
| **Drill-down** | By supplier, by tier, by category |
| **Source** | SUPPLIER_PERFORMANCE_SV |

### 10. Perfect Order Rate

| Property | Value |
|----------|-------|
| **Definition** | % of orders complete + on-time + damage-free + docs-correct |
| **Formula** | All four conditions simultaneously met / total orders * 100 |
| **Target** | ≥ 90% |
| **RAG** | Green ≥ 90%, Yellow 85–90%, Red < 85% |
| **Trend** | Monthly |
| **Drill-down** | By failure component (which condition failed) |
| **Source** | ORDER_SHIPMENT_CUSTOMER_SV |

---

## Trend Analysis Specifications

| KPI | Trend Period | Comparison | Alert Trigger |
|-----|-------------|-----------|---------------|
| OTD | 6 months rolling | MoM change | Drop > 3 ppt in one month |
| Fill Rate | 6 months rolling | MoM change | Drop > 2 ppt in one month |
| DOI | 12 weeks rolling | WoW change | Outside 30–60 band for 2+ weeks |
| Yield | 6 months rolling | MoM change | Drop > 1 ppt in one month |
| Spend | 12 months YTD | vs Budget | > 105% of budget |
| Revenue at Risk | 4 weeks rolling | WoW change | Increase > 50% WoW |
| SPI | 4 quarters | QoQ change | Drop > 5 points |

---

## Executive Alert Rules

| Alert | Condition | Notification |
|-------|-----------|-------------|
| Critical | Any KPI moves to RED | Immediate (email + Slack) |
| Warning | Any KPI moves to YELLOW | Daily digest |
| Trend Alert | 3 consecutive periods of decline | Weekly report |
| AOG | New Aircraft On Ground event | Immediate |
| Supplier Failure | Strategic supplier > 30 days late | Immediate |

---

## Board Reporting Template

### Quarterly Executive Summary

```
SUPPLY CHAIN PERFORMANCE — Q3 2026

HEALTH INDEX: 82/100 (↑ 3 from Q2)

KEY WINS:
✓ Production yield improved to 97.5% (from 96.8%)
✓ Inventory days reduced to 42 (from 48) — $3.2M freed
✓ Zero AOG events for 45 consecutive days

KEY RISKS:
⚠ Supplier OTD declining: 94.2% (target 95%)
⚠ 3 single-source critical parts identified
⚠ Carrier ExpressAir OTD dropped to 82%

ACTIONS:
→ Alternate source qualification for 3 single-source parts
→ Supplier business review with bottom 5 performers
→ Carrier performance improvement plan for ExpressAir

FINANCIAL IMPACT:
• Revenue at Risk: $2.1M (down from $3.8M in Q2)
• COPQ: $1.2M (stable)
• Working capital opportunity: $8.4M identified
```
