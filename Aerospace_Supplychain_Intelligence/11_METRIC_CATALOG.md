# 11 - Metric Catalog

## Aerospace Supply Chain — Complete KPI & Metric Reference

---

## Overview

This catalog provides the authoritative reference for all governed metrics in the Aerospace Supply Chain platform. Each metric has a single formula, defined grain, target threshold, and semantic view encoding — ensuring consistent answers across all personas and query interfaces.

---

## Metric Classification

| Category | Description | Count |
|----------|-------------|-------|
| Procurement | Supplier and purchasing performance | 5 |
| Inventory | Stock health and utilization | 4 |
| Manufacturing | Production efficiency and quality | 4 |
| Logistics | Shipment and delivery performance | 4 |
| Financial | Cost and revenue metrics | 4 |
| Executive | Composite / cross-domain KPIs | 3 |

---

## Procurement Metrics

### MET-001: On-Time Delivery (Overall)

| Property | Value |
|----------|-------|
| **Definition** | Percentage of shipments delivered on or before promised date |
| **Formula** | `COUNT(CASE WHEN IS_ON_TIME = TRUE THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0)` |
| **Unit** | % |
| **Target** | ≥ 95% |
| **Grain** | Per Supplier, Per Month |
| **Source Tables** | FACT_SHIPMENT |
| **Semantic Views** | SV_PROCUREMENT, SHIPMENT_ANALYTICS_SV |
| **Business Rule** | Only completed shipments (Delivered/Closed). Excludes cancelled. |
| **Owner** | Supply Chain |

### MET-012: Supplier OTD

| Property | Value |
|----------|-------|
| **Definition** | On-time delivery performance by individual supplier |
| **Formula** | `ON_TIME_DELIVERY_PCT` from DIM_SUPPLIER or computed from FACT_SHIPMENT |
| **Unit** | % |
| **Target** | ≥ 95% |
| **Grain** | Per Supplier, Per Month |
| **Source Tables** | DIM_SUPPLIER, FACT_SHIPMENT |
| **Semantic Views** | SV_PROCUREMENT, SUPPLIER_PERFORMANCE_SV |
| **Business Rule** | Governed metric — single source of truth |
| **Owner** | Procurement |

### MET-014: Landed Cost

| Property | Value |
|----------|-------|
| **Definition** | Total cost including purchase price, freight, duties, and handling |
| **Formula** | `UNIT_PRICE + FREIGHT_PER_UNIT + (UNIT_PRICE * 0.03) + (UNIT_PRICE * 0.02)` |
| **Unit** | USD |
| **Target** | Minimize |
| **Grain** | Per Part, Per Supplier |
| **Source Tables** | FACT_PURCHASE_ORDER_LINE, FACT_SHIPMENT |
| **Semantic Views** | SV_PROCUREMENT, PROCUREMENT_ANALYTICS_SV |
| **Business Rule** | Duties = 3%, Handling = 2% of unit price |
| **Owner** | Finance |

### MET-015: Supplier Performance Index (SPI)

| Property | Value |
|----------|-------|
| **Definition** | Composite score combining quality, delivery, cost, and responsiveness |
| **Formula** | `(Quality*0.30) + (Delivery*0.30) + (Cost*0.20) + (Responsiveness*0.20)` |
| **Unit** | Score 0–100 |
| **Target** | ≥ 80 |
| **Grain** | Per Supplier, Per Quarter |
| **Source Tables** | DIM_SUPPLIER, FACT_SHIPMENT, FACT_QUALITY_EVENT |
| **Semantic Views** | SUPPLIER_PERFORMANCE_SV |
| **Business Rule** | Grade: A≥90, B≥80, C≥70, D<70 |
| **Owner** | Procurement |

### MET-005: Supplier Risk Score

| Property | Value |
|----------|-------|
| **Definition** | Composite risk metric (0–100, higher = riskier) |
| **Formula** | Based on OTD, quality, financial stability, geographic factors |
| **Unit** | Score 0–100 |
| **Target** | ≤ 50 |
| **Grain** | Per Supplier |
| **Source Tables** | DIM_SUPPLIER |
| **Semantic Views** | SV_PROCUREMENT, SUPPLIER_PERFORMANCE_SV |
| **Business Rule** | High Risk if OTD<85 OR quality<70 OR financial=High |
| **Owner** | Procurement |

---

## Inventory Metrics

### MET-003: Inventory Days (Days of Supply)

| Property | Value |
|----------|-------|
| **Definition** | Days current inventory can sustain average demand |
| **Formula** | `ON_HAND_QTY / AVG_DAILY_DEMAND` |
| **Unit** | Days |
| **Target** | 45 days |
| **Grain** | Per Part, Per Plant |
| **Source Tables** | FACT_INVENTORY |
| **Semantic Views** | SV_INVENTORY, INVENTORY_MANAGEMENT_SV |
| **Business Rule** | AVG_DAILY_DEMAND = 90-day issue qty / 90 |
| **Owner** | Planning |

### MET-004: Inventory Turnover

| Property | Value |
|----------|-------|
| **Definition** | Times inventory consumed and replenished per year |
| **Formula** | `COST_OF_GOODS / AVG_INVENTORY_VALUE` |
| **Unit** | Turns |
| **Target** | ≥ 8 |
| **Grain** | Per Part Family, Per Year |
| **Source Tables** | FACT_INVENTORY, FACT_WORK_ORDER |
| **Semantic Views** | SV_INVENTORY, INVENTORY_MANAGEMENT_SV |
| **Business Rule** | AVG = (beginning + ending) / 2 |
| **Owner** | Planning |

### Stockout Rate

| Property | Value |
|----------|-------|
| **Definition** | Percentage of parts with zero available inventory |
| **Formula** | `COUNT(PART WHERE AVAILABLE_QTY = 0) / COUNT(PART) * 100` |
| **Unit** | % |
| **Target** | ≤ 1% |
| **Grain** | Per Plant, Per Day |
| **Source Tables** | FACT_INVENTORY |
| **Semantic Views** | SV_INVENTORY, INVENTORY_MANAGEMENT_SV |
| **Owner** | Planning |

### Excess Inventory %

| Property | Value |
|----------|-------|
| **Definition** | Value of inventory above max stock as % of total |
| **Formula** | `SUM(VALUE WHERE ON_HAND > MAX_STOCK) / SUM(TOTAL_VALUE) * 100` |
| **Unit** | % |
| **Target** | ≤ 5% |
| **Grain** | Per Plant |
| **Source Tables** | FACT_INVENTORY |
| **Semantic Views** | SV_INVENTORY, INVENTORY_MANAGEMENT_SV |
| **Owner** | Planning |

---

## Manufacturing Metrics

### MET-006: Production Yield

| Property | Value |
|----------|-------|
| **Definition** | First-pass production output meeting quality standards |
| **Formula** | `QUANTITY_COMPLETED / NULLIF(QUANTITY_ORDERED, 0) * 100` |
| **Unit** | % |
| **Target** | ≥ 97% |
| **Grain** | Per Part, Per Plant, Per Month |
| **Source Tables** | FACT_WORK_ORDER |
| **Semantic Views** | SV_MANUFACTURING, MANUFACTURING_ANALYTICS_SV |
| **Business Rule** | Reworked parts not counted as good |
| **Owner** | Manufacturing |

### MET-007: Scrap Rate

| Property | Value |
|----------|-------|
| **Definition** | Percentage of production output scrapped |
| **Formula** | `QUANTITY_SCRAPPED / NULLIF(QUANTITY_ORDERED, 0) * 100` |
| **Unit** | % |
| **Target** | ≤ 3% |
| **Grain** | Per Part, Per Plant |
| **Source Tables** | FACT_WORK_ORDER |
| **Semantic Views** | SV_MANUFACTURING, MANUFACTURING_ANALYTICS_SV |
| **Business Rule** | Lower is better |
| **Owner** | Manufacturing |

### MET-009: Work Order Completion Rate

| Property | Value |
|----------|-------|
| **Definition** | Percentage of work orders completed on time |
| **Formula** | `COUNT(ACTUAL_END_DATE <= PLANNED_END_DATE) / COUNT(*) * 100` |
| **Unit** | % |
| **Target** | ≥ 90% |
| **Grain** | Per Plant, Per Month |
| **Source Tables** | FACT_WORK_ORDER |
| **Semantic Views** | SV_MANUFACTURING, MANUFACTURING_ANALYTICS_SV |
| **Business Rule** | On time = ACTUAL_END_DATE <= PLANNED_END_DATE |
| **Owner** | Manufacturing |

### MET-013: Quality Defect Rate

| Property | Value |
|----------|-------|
| **Definition** | Defective parts as percentage of inspected |
| **Formula** | `SUM(QUANTITY_DEFECTIVE) / NULLIF(SUM(QUANTITY_INSPECTED), 0) * 100` |
| **Unit** | % |
| **Target** | ≤ 2% |
| **Grain** | Per Supplier, Per Part, Per Month |
| **Source Tables** | FACT_QUALITY_EVENT |
| **Semantic Views** | SV_QUALITY, SUPPLIER_QUALITY_PRODUCTION_SV |
| **Business Rule** | Lower is better |
| **Owner** | Quality |

---

## Logistics Metrics

### MET-002: Fill Rate

| Property | Value |
|----------|-------|
| **Definition** | Percentage of customer demand fulfilled from stock |
| **Formula** | `SUM(QUANTITY_SHIPPED) * 100.0 / NULLIF(SUM(QUANTITY_ORDERED), 0)` |
| **Unit** | % |
| **Target** | ≥ 98% |
| **Grain** | Per Customer, Per Month |
| **Source Tables** | FACT_SALES_ORDER_LINE |
| **Semantic Views** | SV_SALES, CUSTOMER_ORDERS_SV |
| **Business Rule** | First-pass fill only. Backorders = unfilled. |
| **Owner** | Supply Chain |

### MET-010: Freight Cost Per Unit

| Property | Value |
|----------|-------|
| **Definition** | Average freight cost per unit shipped |
| **Formula** | `SUM(FREIGHT_COST) / NULLIF(SUM(QUANTITY), 0)` |
| **Unit** | USD |
| **Target** | Minimize |
| **Grain** | Per Carrier, Per Route |
| **Source Tables** | FACT_SHIPMENT |
| **Semantic Views** | SHIPMENT_ANALYTICS_SV |
| **Business Rule** | Includes all transport modes |
| **Owner** | Logistics |

### MET-011: Carrier OTD

| Property | Value |
|----------|-------|
| **Definition** | On-time delivery performance by carrier |
| **Formula** | `COUNT(IS_ON_TIME=TRUE) / COUNT(*) * 100` |
| **Unit** | % |
| **Target** | ≥ 90% |
| **Grain** | Per Carrier, Per Month |
| **Source Tables** | FACT_SHIPMENT |
| **Semantic Views** | SHIPMENT_ANALYTICS_SV |
| **Business Rule** | Same logic as OTD but grouped by carrier |
| **Owner** | Logistics |

### AOG Response Time

| Property | Value |
|----------|-------|
| **Definition** | Average hours to resolve Aircraft On Ground events |
| **Formula** | `AVG(DURATION_HOURS)` |
| **Unit** | Hours |
| **Target** | ≤ 4 hours |
| **Grain** | Per Event |
| **Source Tables** | FACT_AOG_EVENT |
| **Semantic Views** | EXECUTIVE_SUMMARY_SV |
| **Owner** | Operations |

---

## Financial Metrics

### MET-008: Revenue at Risk

| Property | Value |
|----------|-------|
| **Definition** | Revenue impacted by supply chain disruptions |
| **Formula** | `SUM(SO.TOTAL_VALUE)` for orders linked to late shipments or stockouts |
| **Unit** | USD |
| **Target** | $0 (minimize) |
| **Grain** | Per Supplier, Per Period |
| **Source Tables** | FACT_SALES_ORDER, FACT_SHIPMENT |
| **Semantic Views** | EXECUTIVE_SUMMARY_SV |
| **Owner** | Executive |

### Procurement Spend

| Property | Value |
|----------|-------|
| **Definition** | Total value of purchase orders placed |
| **Formula** | `SUM(TOTAL_VALUE)` |
| **Unit** | USD |
| **Target** | Budget adherence |
| **Grain** | Per Supplier, Per Period |
| **Source Tables** | FACT_PURCHASE_ORDER |
| **Semantic Views** | SV_PROCUREMENT, PROCUREMENT_ANALYTICS_SV |
| **Owner** | Finance |

### Cost of Poor Quality (COPQ)

| Property | Value |
|----------|-------|
| **Definition** | Total financial impact of quality failures |
| **Formula** | `SUM(COST_OF_QUALITY)` |
| **Unit** | USD |
| **Target** | Minimize |
| **Grain** | Per Supplier, Per Plant, Per Month |
| **Source Tables** | FACT_QUALITY_EVENT |
| **Semantic Views** | SV_QUALITY |
| **Owner** | Quality |

### Cash-to-Cash Cycle

| Property | Value |
|----------|-------|
| **Definition** | Days between paying suppliers and receiving customer payment |
| **Formula** | `DIO + DSO - DPO` |
| **Unit** | Days |
| **Target** | ≤ 60 days |
| **Grain** | Monthly |
| **Source Tables** | FACT_INVENTORY, FACT_SALES_ORDER, FACT_PURCHASE_ORDER |
| **Semantic Views** | PROCUREMENT_INVENTORY_FINANCE_SV |
| **Owner** | Finance |

---

## Executive Composite KPIs

### Perfect Order Rate

| Property | Value |
|----------|-------|
| **Definition** | Orders delivered complete + on-time + damage-free + correct docs |
| **Formula** | `(on_time AND in_full AND no_damage AND docs_correct) / total * 100` |
| **Unit** | % |
| **Target** | ≥ 90% |
| **Source Tables** | FACT_SHIPMENT, FACT_QUALITY_EVENT |
| **Semantic Views** | EXECUTIVE_SUMMARY_SV, ORDER_SHIPMENT_CUSTOMER_SV |
| **Owner** | Supply Chain |

### Capacity Utilization

| Property | Value |
|----------|-------|
| **Definition** | Percentage of available production capacity used |
| **Formula** | `ACTUAL_PRODUCTION_HOURS / AVAILABLE_CAPACITY_HOURS * 100` |
| **Unit** | % |
| **Target** | 85% |
| **Source Tables** | FACT_WORK_ORDER, DIM_WORK_CENTER |
| **Semantic Views** | SV_MANUFACTURING, MANUFACTURING_ANALYTICS_SV |
| **Owner** | Manufacturing |

### Supply Chain Health Index

| Property | Value |
|----------|-------|
| **Definition** | Composite index of OTD, Fill Rate, DOI, Yield, and Risk |
| **Formula** | `(OTD_norm + FillRate_norm + DOI_norm + Yield_norm + (100-Risk_norm)) / 5` |
| **Unit** | Score 0–100 |
| **Target** | ≥ 80 |
| **Source Tables** | Cross-domain aggregation |
| **Semantic Views** | EXECUTIVE_SUMMARY_SV |
| **Owner** | Executive |

---

## Metric Dependency Graph

```
                    ┌────────────────────┐
                    │ Supply Chain Health │
                    │      Index         │
                    └─────────┬──────────┘
                              │
          ┌───────┬───────┬───┴───┬───────┐
          ▼       ▼       ▼       ▼       ▼
       ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐
       │ OTD │ │Fill │ │ DOI │ │Yield│ │Risk │
       │     │ │Rate │ │     │ │     │ │Score│
       └──┬──┘ └──┬──┘ └──┬──┘ └──┬──┘ └──┬──┘
          │       │       │       │       │
          ▼       ▼       ▼       ▼       ▼
     SHIPMENT  SO_LINE  INVENTORY  WORK   SUPPLIER
                                   ORDER
```

---

## Threshold Alerting

| Metric | Green | Yellow | Red |
|--------|-------|--------|-----|
| OTD | ≥ 95% | 90–95% | < 90% |
| Fill Rate | ≥ 98% | 95–98% | < 95% |
| DOI | 30–60 days | 15–30 or 60–90 | < 15 or > 90 |
| Yield | ≥ 97% | 95–97% | < 95% |
| Scrap Rate | ≤ 2% | 2–5% | > 5% |
| Supplier Risk | ≤ 40 | 40–70 | > 70 |
| SPI | ≥ 80 | 70–80 | < 70 |
| Defect Rate | ≤ 1% | 1–3% | > 3% |
