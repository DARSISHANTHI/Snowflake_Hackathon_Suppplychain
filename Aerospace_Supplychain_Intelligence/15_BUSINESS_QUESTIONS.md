# 15 - Business Questions

## Aerospace Supply Chain — Validated Question Catalog

---

## Purpose

This document catalogs business questions that the conversational analytics platform must answer correctly. Each question is mapped to the semantic view, metric, and expected SQL pattern that should be generated. These serve as validation test cases ensuring the ontology and semantic layer produce consistent, trustworthy answers.

---

## Question Categories

| Category | Count | Complexity |
|----------|-------|-----------|
| Procurement | 12 | Simple to moderate |
| Inventory | 10 | Simple to moderate |
| Manufacturing | 10 | Simple to moderate |
| Logistics | 10 | Simple to moderate |
| Sales & Customer | 8 | Simple to moderate |
| Quality | 8 | Moderate |
| Cross-Domain | 12 | Complex (multi-hop) |
| Executive | 8 | Moderate to complex |

---

## Procurement Questions

| # | Question | Semantic View | Key Metric | Expected Output |
|---|----------|---------------|-----------|-----------------|
| P1 | What is our total procurement spend this year? | SV_PROCUREMENT | Procurement Spend | SUM(TOTAL_VALUE) with date filter |
| P2 | Who are our top 10 suppliers by spend? | SV_PROCUREMENT | Spend by supplier | Ranked list with values |
| P3 | What is supplier on-time delivery this month? | SV_PROCUREMENT | MET-012 | Percentage with target comparison |
| P4 | Which suppliers are high risk? | SV_PROCUREMENT | MET-005 | List where RISK_SCORE > 70 |
| P5 | What is the average PO cycle time? | SV_PROCUREMENT | PO Cycle Time | AVG(RECEIVED_DATE - ORDER_DATE) |
| P6 | How many open purchase orders do we have? | SV_PROCUREMENT | — | COUNT where STATUS = 'Open' |
| P7 | What is our landed cost for titanium parts? | SV_PROCUREMENT | MET-014 | Cost breakdown by component |
| P8 | Which suppliers have expiring contracts? | SV_PROCUREMENT | — | EXPIRY_DATE approaching |
| P9 | Compare supplier performance: Tier 1 vs Tier 2 | SV_PROCUREMENT | MET-015 | SPI averages by tier |
| P10 | What is our single-source risk? | SV_PROCUREMENT | — | Parts with only 1 active supplier |
| P11 | Show PO volume trend by month this year | SV_PROCUREMENT | — | Monthly COUNT(PO_ID) |
| P12 | Which buyers have the most overdue POs? | SV_PROCUREMENT | — | GROUP BY BUYER_ID, overdue count |

---

## Inventory Questions

| # | Question | Semantic View | Key Metric | Expected Output |
|---|----------|---------------|-----------|-----------------|
| I1 | What is our total inventory value? | SV_INVENTORY | — | SUM(TOTAL_VALUE) |
| I2 | Which parts are below safety stock? | SV_INVENTORY | Stockout Rate | List where AVAILABLE < SAFETY_STOCK |
| I3 | What is the average days of inventory? | SV_INVENTORY | MET-003 | AVG(DOI) across parts |
| I4 | Which plants have the most excess inventory? | SV_INVENTORY | Excess Inventory % | Ranked by overstocked value |
| I5 | What is inventory turnover by part family? | SV_INVENTORY | MET-004 | Grouped by PART_FAMILY |
| I6 | Show me slow-moving parts (DOI > 90 days) | SV_INVENTORY | MET-003 | Filtered list |
| I7 | What is our dead stock value? | SV_INVENTORY | — | Parts with no movement in 180 days |
| I8 | How much inventory is in transit? | SV_INVENTORY | — | SUM(IN_TRANSIT_QTY) |
| I9 | Which warehouses are over 90% utilized? | SV_INVENTORY | — | UTILIZATION_PCT > 90 |
| I10 | What parts need reordering today? | SV_INVENTORY | — | AVAILABLE_QTY < REORDER_POINT |

---

## Manufacturing Questions

| # | Question | Semantic View | Key Metric | Expected Output |
|---|----------|---------------|-----------|-----------------|
| M1 | What is our production yield this month? | SV_MANUFACTURING | MET-006 | Percentage with target |
| M2 | Which plants have the highest scrap rate? | SV_MANUFACTURING | MET-007 | Ranked by plant |
| M3 | How many work orders are open? | SV_MANUFACTURING | — | COUNT by status |
| M4 | What is capacity utilization by plant? | SV_MANUFACTURING | Capacity Util | % by plant |
| M5 | Which work orders are behind schedule? | SV_MANUFACTURING | MET-009 | Where ACTUAL > PLANNED |
| M6 | Show production output trend by month | SV_MANUFACTURING | — | Monthly SUM(QTY_COMPLETED) |
| M7 | What is the average work order cycle time? | SV_MANUFACTURING | — | AVG(ACTUAL_END - ACTUAL_START) |
| M8 | Top 10 parts by scrap quantity this quarter | SV_MANUFACTURING | MET-007 | Ranked list |
| M9 | Which work centers are bottlenecks? | SV_MANUFACTURING | — | Highest utilization + queue |
| M10 | Production cost per unit by part family | SV_MANUFACTURING | — | TOTAL_COST / QTY_COMPLETED |

---

## Logistics Questions

| # | Question | Semantic View | Key Metric | Expected Output |
|---|----------|---------------|-----------|-----------------|
| L1 | What is our customer on-time delivery rate? | SHIPMENT_ANALYTICS_SV | MET-001 | Percentage |
| L2 | Which carriers have the best performance? | SHIPMENT_ANALYTICS_SV | MET-011 | Ranked by OTD |
| L3 | What is our average freight cost per shipment? | SHIPMENT_ANALYTICS_SV | MET-010 | AVG(FREIGHT_COST) |
| L4 | How many shipments are currently delayed? | SHIPMENT_ANALYTICS_SV | — | COUNT where delayed |
| L5 | What is average transit time by carrier? | SHIPMENT_ANALYTICS_SV | — | AVG days by carrier |
| L6 | Show shipment volume by type (in/out/transfer) | SHIPMENT_ANALYTICS_SV | — | COUNT by SHIPMENT_TYPE |
| L7 | Which routes have the most delays? | SHIPMENT_ANALYTICS_SV | — | Origin→Dest delay rate |
| L8 | Total freight spend this quarter | SHIPMENT_ANALYTICS_SV | — | SUM(FREIGHT_COST) |
| L9 | On-time delivery trend by month | SHIPMENT_ANALYTICS_SV | MET-001 | Monthly OTD % |
| L10 | Shipments at risk of missing delivery date | SHIPMENT_ANALYTICS_SV | — | In-transit + past promised |

---

## Sales & Customer Questions

| # | Question | Semantic View | Key Metric | Expected Output |
|---|----------|---------------|-----------|-----------------|
| S1 | What is our fill rate this month? | SV_SALES | MET-002 | Percentage |
| S2 | Who are our top customers by revenue? | SV_SALES | — | Ranked by TOTAL_VALUE |
| S3 | How many open sales orders do we have? | SV_SALES | — | COUNT by status |
| S4 | What is the order backlog value? | SV_SALES | — | SUM(VALUE) for open orders |
| S5 | Revenue by customer type (airline/MRO/defense) | SV_SALES | — | SUM grouped by type |
| S6 | Which customers have declining fill rate? | SV_SALES | MET-002 | Trend comparison |
| S7 | Average order-to-ship cycle time | SV_SALES | — | AVG(SHIPPED_DATE - ORDER_DATE) |
| S8 | Orders at risk of missing delivery date | SV_SALES | — | Open + past PROMISED_DATE |

---

## Quality Questions

| # | Question | Semantic View | Key Metric | Expected Output |
|---|----------|---------------|-----------|-----------------|
| Q1 | What is our overall defect rate? | SV_QUALITY | MET-013 | Percentage |
| Q2 | Top defect types this quarter | SV_QUALITY | — | Ranked by count |
| Q3 | Which suppliers have the most quality issues? | SV_QUALITY | — | Grouped by supplier |
| Q4 | What is cost of poor quality this year? | SV_QUALITY | COPQ | SUM(COST_OF_QUALITY) |
| Q5 | How many open NCRs do we have? | SV_QUALITY | — | COUNT by status |
| Q6 | Average time to resolve quality events | SV_QUALITY | — | AVG(RESOLUTION - EVENT) |
| Q7 | Critical defects by plant | SV_QUALITY | — | COUNT where SEVERITY=critical |
| Q8 | Root cause Pareto (top causes) | SV_QUALITY | — | COUNT by ROOT_CAUSE |

---

## Cross-Domain Questions (Multi-Hop)

| # | Question | Views Required | Complexity |
|---|----------|---------------|-----------|
| X1 | Which suppliers with declining OTD are causing stockouts? | SV_PROCUREMENT + SV_INVENTORY | High |
| X2 | What is the revenue impact of late supplier deliveries? | SV_PROCUREMENT + SV_SALES | High |
| X3 | Are quality issues linked to specific supplier batches? | SV_QUALITY + SV_PROCUREMENT | High |
| X4 | Which plants have both low yield AND high supplier defects? | SV_MANUFACTURING + SV_QUALITY | Medium |
| X5 | Do stockouts correlate with sales order delays? | SV_INVENTORY + SV_SALES | High |
| X6 | What is the end-to-end cost from PO to customer delivery? | SV_PROCUREMENT + SHIPMENT_ANALYTICS_SV | Medium |
| X7 | Which customers are at risk of AOG due to inventory gaps? | SV_SALES + SV_INVENTORY | High |
| X8 | How does carrier choice affect customer satisfaction? | SHIPMENT_ANALYTICS_SV + SV_SALES | Medium |
| X9 | What parts have both quality issues AND are below safety stock? | SV_QUALITY + SV_INVENTORY | Medium |
| X10 | Compare procurement lead time vs manufacturing cycle time | SV_PROCUREMENT + SV_MANUFACTURING | Medium |
| X11 | Total cost of a part: procurement + freight + quality + storage | Multiple views | Very High |
| X12 | If supplier X fails, what orders are impacted? | SV_PROCUREMENT + SV_SALES + SV_INVENTORY | Very High |

---

## Executive Questions

| # | Question | Views Required | Expected Output |
|---|----------|---------------|-----------------|
| E1 | Give me a supply chain health dashboard | EXECUTIVE_SUMMARY_SV | All KPIs with RAG status |
| E2 | What is our revenue at risk right now? | Cross-domain | Dollar value + root causes |
| E3 | Top 3 supply chain risks this month | Multiple | Prioritized risk list |
| E4 | Compare this quarter vs last quarter performance | Multiple | KPI comparison table |
| E5 | Where should we focus improvement efforts? | Multiple | Prioritized by impact |
| E6 | What is our perfect order rate? | Cross-domain | Percentage + breakdown |
| E7 | Cash-to-cash cycle time trend | Cross-domain | Monthly trend |
| E8 | Board-ready summary: 3 wins, 3 risks, 3 actions | Multiple | Structured executive brief |
