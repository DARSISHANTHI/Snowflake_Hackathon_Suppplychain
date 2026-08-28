# 02 - Business Glossary

## Aerospace Supply Chain — Canonical Terms & Metrics

---

## Purpose

This glossary provides the **single source of truth** for business terminology used across the Aerospace Supply Chain platform. Every term and metric defined here is encoded into semantic views so that natural language queries resolve consistently regardless of which persona or team asks the question.

---

## Business Terms

| ID | Term | Definition | Source Table | Owner |
|----|------|-----------|--------------|-------|
| BG-001 | On-Time Delivery (OTD) | Percentage of shipments delivered on or before the promised delivery date. A shipment is on-time if actual_delivery_date <= promised_delivery_date. Only counts completed shipments (status Delivered or Closed). **Target: 95%.** | FACT_SHIPMENT | Supply Chain |
| BG-002 | Fill Rate | Percentage of customer demand fulfilled from available inventory on first attempt. Measures quantity shipped vs quantity ordered. Backorders count as unfilled. **Target: 98%.** | FACT_SALES_ORDER_LINE | Supply Chain |
| BG-003 | Days of Inventory (DOI) | Number of days current on-hand inventory can sustain the average daily demand. Calculated using trailing 90-day consumption. **Target: 45 days.** | FACT_INVENTORY | Planning |
| BG-004 | Inventory Turnover | Number of times inventory is consumed and replenished per year. Higher is better. **Target: 8 turns/year.** | FACT_INVENTORY | Finance |
| BG-005 | Supplier Performance Index (SPI) | Composite score (0–100) combining Quality (30%), Delivery (30%), Cost (20%), and Responsiveness (20%). **Target: 80.** | V_SUPPLIER_SCORECARD | Procurement |
| BG-006 | Critical Supplier | A supplier classified as Strategic category AND Tier Level 1 AND annual spend > $10M. Requires quarterly business reviews and alternate source development. | DIM_SUPPLIER | Procurement |
| BG-007 | Revenue At Risk | Total value of customer orders that may be impacted by supplier delays, quality issues, or inventory shortages. Calculated by summing order values where associated shipments are late or inventory is below safety stock. | FACT_SALES_ORDER + FACT_SHIPMENT | Executive |
| BG-008 | Landed Cost | Total cost to procure and deliver a part, including: purchase price + freight allocation + import duties (3%) + warehouse handling (2%). | FACT_PURCHASE_ORDER_LINE + FACT_SHIPMENT | Finance |
| BG-009 | Yield Rate | Percentage of production output meeting quality standards on first pass. Reworked parts are not counted as good. **Target: 97%.** | FACT_WORK_ORDER | Manufacturing |
| BG-010 | Defect Rate | Percentage of inspected parts found to be defective. Lower is better. | FACT_QUALITY_EVENT | Quality |
| BG-011 | Perfect Order Rate | Percentage of orders delivered complete, on-time, damage-free, with correct documentation. All four conditions must be met simultaneously. **Target: 90%.** | FACT_SHIPMENT + FACT_QUALITY_EVENT | Supply Chain |
| BG-012 | Capacity Utilization | Percentage of available production capacity actually used. Available hours = shifts × hours_per_shift × working_days. **Target: 85%.** | FACT_WORK_ORDER + DIM_WORK_CENTER | Manufacturing |
| BG-013 | Cash-to-Cash Cycle | Days between paying suppliers and receiving payment from customers. DIO + DSO − DPO. Lower is better. **Target: 60 days.** | FACT_INVENTORY + FACT_SALES_ORDER + FACT_PURCHASE_ORDER | Finance |
| BG-014 | AOG (Aircraft On Ground) | Highest priority event — aircraft cannot fly due to missing/failed part. Parts must ship within 4 hours. Triggers emergency procurement. | FACT_AOG_EVENT | Operations |
| BG-015 | Procurement Spend | Total value of all purchase orders placed with suppliers in a given period. Includes all currencies converted to USD. | FACT_PURCHASE_ORDER | Finance |
| BG-016 | Reorder Point | Inventory level at which a replenishment order must be placed. When available_qty < reorder_point, a purchase requisition or work order is triggered. | FACT_INVENTORY | Planning |
| BG-017 | Supplier Risk Score | Composite risk metric (0–100, higher = riskier). Supplier is High Risk if OTD < 85% OR quality_score < 70 OR financial_risk is High. | DIM_SUPPLIER | Procurement |
| BG-018 | Cost of Poor Quality (COPQ) | Total financial impact of quality failures including: scrap, rework, warranty claims, inspection costs, and customer returns. | FACT_QUALITY_EVENT | Quality |
| BG-019 | Overstocked | Inventory position where available quantity exceeds the maximum stock level. Indicates excess capital tied up and potential obsolescence risk. | FACT_INVENTORY | Planning |
| BG-020 | Delayed Shipment | A shipment where status is "In Transit" and promised_delivery_date has already passed. Indicates transportation failure. | FACT_SHIPMENT | Logistics |

---

## Metric Definitions (KPIs)

| ID | Metric Name | Description | Formula | Unit | Target | Grain | Business Rule |
|----|-------------|-------------|---------|------|--------|-------|---------------|
| MET-001 | On-Time Delivery | Percentage of shipments delivered on or before promised date | `COUNT(CASE WHEN IS_ON_TIME = TRUE THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0)` | % | 95.0 | Per Supplier, Per Month | Only completed shipments (Delivered/Closed). Excludes cancelled. |
| MET-002 | Fill Rate | Percentage of customer demand fulfilled from stock | `SUM(QUANTITY_SHIPPED) * 100.0 / NULLIF(SUM(QUANTITY_ORDERED), 0)` | % | 98.0 | Per Customer, Per Month | First-pass fill only. Backorders = unfilled. |
| MET-003 | Inventory Days | Days current inventory sustains average demand | `ON_HAND_QTY / AVG_DAILY_DEMAND` | Days | 45.0 | Per Part, Per Plant | AVG_DAILY_DEMAND = 90-day issue qty / 90 |
| MET-004 | Inventory Turnover | Times inventory consumed and replenished per year | `COST_OF_GOODS / AVG_INVENTORY_VALUE` | Turns | 8.0 | Per Part Family, Per Year | AVG = (beginning + ending) / 2 |
| MET-005 | Supplier Risk Score | Composite risk metric (0–100, higher is riskier) | Based on OTD, quality, financial, geographic factors | Score | 50.0 | Per Supplier | High Risk if OTD<85 OR quality<70 OR financial=High |
| MET-006 | Production Yield | First-pass production output meeting quality | `QUANTITY_COMPLETED / NULLIF(QUANTITY_ORDERED, 0) * 100` | % | 97.0 | Per Part, Per Plant, Per Month | Reworked parts not counted as good |
| MET-007 | Scrap Rate | Percentage of production scrapped | `QUANTITY_SCRAPPED / NULLIF(QUANTITY_ORDERED, 0) * 100` | % | 3.0 | Per Part, Per Plant | Lower is better |
| MET-008 | Revenue At Risk | Revenue impacted by supply chain disruptions | `SUM(SO.TOTAL_VALUE)` for affected orders | USD | 0.0 | Per Supplier, Per Period | Orders linked to late shipments or stockouts |
| MET-009 | Work Order Completion Rate | Percentage of work orders completed on time | `COUNT(completed on time) / COUNT(total) * 100` | % | 90.0 | Per Plant, Per Month | On time = ACTUAL_END_DATE <= PLANNED_END_DATE |
| MET-010 | Freight Cost Per Unit | Average freight cost per unit shipped | `SUM(FREIGHT_COST) / NULLIF(SUM(QUANTITY), 0)` | USD | — | Per Carrier, Per Route | Includes all modes |
| MET-011 | Carrier OTD | On-time delivery performance by carrier | `COUNT(on_time) / COUNT(total) * 100` | % | 90.0 | Per Carrier, Per Month | Same logic as OTD but grouped by carrier |
| MET-012 | Supplier OTD | On-time delivery performance by supplier | `OTD_PERCENTAGE` from V_ON_TIME_DELIVERY_METRIC | % | 95.0 | Per Supplier, Per Month | Governed metric — single source of truth |
| MET-013 | Quality Defect Rate | Defective parts as percentage of inspected | `SUM(QUANTITY_DEFECTIVE) / NULLIF(SUM(QUANTITY_INSPECTED), 0) * 100` | % | 2.0 | Per Supplier, Per Part, Per Month | Lower is better |
| MET-014 | Landed Cost | Total cost including purchase, freight, duties, handling | `UNIT_PRICE + FREIGHT_PER_UNIT + DUTIES + HANDLING` | USD | — | Per Part, Per Supplier | Duties=3%, Handling=2% of unit price |
| MET-015 | Supplier Performance Index | Composite SPI score | `(Quality*0.30) + (Delivery*0.30) + (Cost*0.20) + (Responsiveness*0.20)` | Score 0–100 | 80.0 | Per Supplier, Per Quarter | Grade: A≥90, B≥80, C≥70, D<70 |

---

## Term-to-Metric Mapping

| Business Term (BG) | Metric (MET) | Relationship |
|---------------------|--------------|--------------|
| BG-001 On-Time Delivery | MET-001, MET-012 | Term defines concept; metrics implement measurement |
| BG-002 Fill Rate | MET-002 | Direct 1:1 mapping |
| BG-003 Days of Inventory | MET-003 | Direct 1:1 mapping |
| BG-004 Inventory Turnover | MET-004 | Direct 1:1 mapping |
| BG-005 Supplier Performance Index | MET-015 | Direct 1:1 mapping |
| BG-007 Revenue At Risk | MET-008 | Direct 1:1 mapping |
| BG-008 Landed Cost | MET-014 | Direct 1:1 mapping |
| BG-009 Yield Rate | MET-006 | Direct 1:1 mapping |
| BG-010 Defect Rate | MET-013 | Direct 1:1 mapping |
| BG-017 Supplier Risk Score | MET-005 | Direct 1:1 mapping |

---

## Domain Ownership

| Domain | Owner | Terms Owned | Metrics Owned |
|--------|-------|-------------|---------------|
| Supply Chain | VP Supply Chain | BG-001, BG-002, BG-011 | MET-001, MET-002 |
| Procurement | Director Procurement | BG-005, BG-006, BG-017 | MET-005, MET-012, MET-014, MET-015 |
| Planning | Planning Manager | BG-003, BG-016, BG-019 | MET-003, MET-004 |
| Manufacturing | Plant Director | BG-009, BG-012 | MET-006, MET-007, MET-009 |
| Quality | Quality Director | BG-010, BG-018 | MET-013 |
| Logistics | Logistics Manager | BG-020 | MET-010, MET-011 |
| Finance | CFO | BG-004, BG-008, BG-013, BG-015 | MET-008, MET-014 |
| Operations | COO | BG-014 | — |
| Executive | CEO | BG-007 | MET-008 |

---

## Disambiguation Rules

These rules ensure the conversational analytics layer resolves ambiguous terms correctly:

| Ambiguous Phrase | Context: Procurement | Context: Logistics | Context: Manufacturing |
|-----------------|---------------------|--------------------|-----------------------|
| "on-time delivery" | MET-012 (Supplier OTD) | MET-001 (Customer OTD) | MET-009 (WO Completion Rate) |
| "cost" | MET-014 (Landed Cost) | MET-010 (Freight Cost) | Scrap + Rework Cost |
| "quality" | MET-013 (Defect Rate by supplier) | — | MET-006 (Production Yield) |
| "performance" | MET-015 (SPI) | MET-011 (Carrier OTD) | MET-006 (Yield) + MET-009 (WO Rate) |
| "risk" | MET-005 (Supplier Risk) | Delayed Shipment count | Quality event severity |
| "inventory" | PO pipeline coverage | In-transit qty | MET-003 (Days of Inventory) |

---

## Formula Standards

All metric formulas follow these conventions:

| Convention | Rule | Example |
|------------|------|---------|
| Division by zero | Always use `NULLIF(denominator, 0)` | `SUM(x) / NULLIF(COUNT(*), 0)` |
| Percentage | Multiply by 100.0 (not 100) for decimal precision | `* 100.0` |
| Date difference | Use `DATEDIFF('day', start, end)` | `DATEDIFF('day', ORDER_DATE, RECEIVED_DATE)` |
| Averaging period | Trailing 90 days unless specified | `WHERE date >= DATEADD('day', -90, CURRENT_DATE())` |
| Currency | All monetary values in USD | Convert at daily rate if multi-currency |
| Null handling | NULLs excluded from aggregations | Standard SQL behavior |
| Status filters | Only count completed/closed records | `WHERE STATUS IN ('Delivered', 'Closed')` |

---

## Change Log

| Version | Date | Change | Author |
|---------|------|--------|--------|
| 1.0 | 2026-08-11 | Initial glossary with 20 terms and 15 metrics | Platform Team |
| 1.1 | 2026-08-18 | Documented in markdown with disambiguation rules | CoCo Hackathon |
