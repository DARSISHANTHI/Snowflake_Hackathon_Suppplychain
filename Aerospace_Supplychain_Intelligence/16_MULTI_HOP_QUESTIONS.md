# 16 - Multi-Hop Questions

## Aerospace Supply Chain — Complex Cross-Domain Query Patterns

---

## Overview

Multi-hop questions require the agent to reason across multiple semantic views, combine results, and synthesize answers that no single view can provide. These are the highest-value queries for the platform — proving that the ontology enables trustworthy cross-domain analytics.

---

## Complexity Levels

| Level | Hops | Description | Example |
|-------|------|-------------|---------|
| L1 | 2 | Two domains, direct relationship | Supplier OTD → affected parts |
| L2 | 3 | Three domains, chain reasoning | Supplier → Quality → Production |
| L3 | 4+ | Full supply chain traversal | Supplier → PO → Shipment → Inventory → Sales |

---

## Multi-Hop Query Catalog

### MH-01: Supplier Delivery → Inventory Impact

**Question:** "Which suppliers with declining OTD are causing inventory stockouts?"

```
HOP 1: SV_PROCUREMENT
  → Get suppliers where OTD < 90% (declining trend)
  → Output: List of underperforming supplier IDs

HOP 2: SV_INVENTORY
  → Get parts below reorder point
  → Filter: parts supplied by HOP 1 suppliers (via DIM_SUPPLIER_PART)
  → Output: Parts at risk with supplier attribution

SYNTHESIS:
  → Join results: supplier + affected parts + inventory status
  → Present: "3 suppliers with OTD below 90% supply 12 parts currently 
              below safety stock, representing $2.4M in revenue at risk"
```

| Property | Value |
|----------|-------|
| **Personas** | Procurement, Planning |
| **Difficulty** | L1 (2 hops) |
| **Key Relationship** | DIM_SUPPLIER → DIM_SUPPLIER_PART → DIM_PART → FACT_INVENTORY |
| **Metrics Used** | MET-012 (Supplier OTD), MET-003 (DOI), Stockout Rate |

---

### MH-02: Quality Issues → Revenue Impact

**Question:** "What is the revenue impact of supplier quality failures this quarter?"

```
HOP 1: SV_QUALITY
  → Get quality events with SEVERITY = 'critical' or 'major'
  → Group by SUPPLIER_ID, sum COST_OF_QUALITY
  → Output: Suppliers with quality costs

HOP 2: SV_PROCUREMENT
  → Get affected parts from quality events
  → Identify impacted purchase orders

HOP 3: SV_SALES
  → Find sales orders containing affected parts
  → Where delivery may be delayed due to quality holds
  → Sum TOTAL_VALUE for at-risk orders

SYNTHESIS:
  → "Quality failures from 5 suppliers this quarter:
     - Direct COPQ: $1.8M (scrap + rework)
     - Revenue at risk: $4.2M (delayed customer orders)
     - 3 customers may experience late delivery"
```

| Property | Value |
|----------|-------|
| **Personas** | Quality, Executive, Finance |
| **Difficulty** | L2 (3 hops) |
| **Key Relationship** | FACT_QUALITY_EVENT → DIM_PART → FACT_SALES_ORDER_LINE → FACT_SALES_ORDER |
| **Metrics Used** | COPQ, MET-008 (Revenue at Risk), MET-013 (Defect Rate) |

---

### MH-03: End-to-End Order Fulfillment

**Question:** "Why did Customer X not receive their order on time?"

```
HOP 1: SV_SALES
  → Find customer's late orders (SHIPPED_DATE > PROMISED_DATE)
  → Get SO line items and parts

HOP 2: SV_INVENTORY
  → Check if parts were in stock at promised date
  → Identify if stockout caused the delay

HOP 3: SV_PROCUREMENT (if stockout)
  → Check PO status for those parts
  → Was the supplier late? (RECEIVED_DATE > PROMISED_DATE)

HOP 4: SHIPMENT_ANALYTICS_SV
  → Check outbound shipment status
  → Was the carrier late? (transit delay)

SYNTHESIS:
  → "Order SO-12345 was 5 days late because:
     - Part P-789 was out of stock (depleted 3 days before SO)
     - Root cause: Supplier TitanForge delivered PO-4567 8 days late
     - Secondary: Carrier ExpressAir had 2-day transit delay
     Recommendation: Increase safety stock for P-789; 
     escalate TitanForge delivery issues"
```

| Property | Value |
|----------|-------|
| **Personas** | Customer Service, Logistics, Executive |
| **Difficulty** | L3 (4 hops) |
| **Key Relationship** | Full chain: Customer → SO → Part → Inventory → PO → Supplier → Shipment |
| **Metrics Used** | MET-001 (OTD), MET-003 (DOI), MET-012 (Supplier OTD) |

---

### MH-04: Supplier Failure Scenario

**Question:** "If Supplier X goes offline, what is the total business impact?"

```
HOP 1: SV_PROCUREMENT
  → Get all parts supplied exclusively by Supplier X
  → Get all open POs with Supplier X
  → Calculate outstanding PO value

HOP 2: SV_INVENTORY
  → For each affected part, calculate days of supply remaining
  → Identify parts that will stockout within lead time

HOP 3: SV_MANUFACTURING
  → Find open work orders consuming affected parts
  → Calculate production impact (units that cannot be completed)

HOP 4: SV_SALES
  → Find customer orders depending on affected parts
  → Calculate revenue at risk

SYNTHESIS:
  → "If Supplier X (TitanForge) goes offline:
     - 23 parts affected (8 are single-source)
     - Inventory runway: 12-45 days depending on part
     - 5 parts will stockout within 2 weeks
     - Production impact: 340 work orders at risk
     - Revenue at risk: $12.8M in customer orders
     - Mitigation: 15 parts have alternate suppliers (4-6 week qualification)"
```

| Property | Value |
|----------|-------|
| **Personas** | Procurement, Executive, Risk Management |
| **Difficulty** | L3 (4 hops) |
| **Key Relationship** | DIM_SUPPLIER → DIM_SUPPLIER_PART → DIM_PART → (Inventory + WO + SO) |
| **Metrics Used** | MET-003 (DOI), MET-008 (Revenue at Risk), Single-source count |

---

### MH-05: IoT → Quality → Supplier Root Cause

**Question:** "Are equipment anomalies linked to specific supplier material batches?"

```
HOP 1: FACT_IOT_SENSOR_DATA
  → Get work centers with ALERT_FLAG = TRUE (anomalies)
  → Identify time windows of anomalies

HOP 2: SV_MANUFACTURING
  → Find work orders running on those work centers during anomaly windows
  → Get parts being produced

HOP 3: SV_QUALITY
  → Find quality events linked to those work orders
  → Check if defect rate correlates with anomaly periods

HOP 4: SV_PROCUREMENT
  → Trace parts back to supplier batches (via PO and lot number)
  → Identify common supplier

SYNTHESIS:
  → "Analysis found correlation:
     - Work Center WC-15 showed 3 vibration anomalies in July
     - All 3 coincide with processing Part P-234 (titanium bracket)
     - Quality events: 2 NCRs during same period (surface finish defects)
     - Common supplier: MetalPro Corp (batch lots ML-2026-07-*)
     - Recommendation: Incoming inspection hold on MetalPro titanium stock"
```

| Property | Value |
|----------|-------|
| **Personas** | Manufacturing, Quality, Procurement |
| **Difficulty** | L3 (4 hops) |
| **Key Relationship** | IoT → Work Center → Work Order → Part → Quality Event → Supplier |
| **Metrics Used** | Alert rate, MET-013 (Defect Rate), MET-006 (Yield) |

---

### MH-06: Working Capital Optimization

**Question:** "Where can we free up working capital without risking service levels?"

```
HOP 1: SV_INVENTORY
  → Identify overstocked parts (AVAILABLE > MAX_STOCK)
  → Calculate excess value

HOP 2: SV_SALES
  → Check demand patterns for overstocked parts
  → Verify low/no customer demand

HOP 3: SV_PROCUREMENT
  → Check if there are reducible open POs
  → Identify parts with reliable suppliers (high OTD)

SYNTHESIS:
  → "Working capital opportunity: $8.4M
     - $5.2M in excess stock (23 parts above max level)
     - $2.1M in slow-moving inventory (DOI > 120 days)
     - $1.1M in open POs that can be deferred
     Safe to reduce: 18 parts have DOI > 90 days AND demand < 1 unit/week
     Risk: 5 overstocked parts supply critical programs — maintain buffer"
```

| Property | Value |
|----------|-------|
| **Personas** | Finance, Planning, Executive |
| **Difficulty** | L2 (3 hops) |
| **Metrics Used** | MET-003 (DOI), MET-004 (Turnover), Excess Inventory %, Fill Rate impact |

---

### MH-07: Perfect Order Decomposition

**Question:** "Why is our perfect order rate below target and what's driving it?"

```
HOP 1: SHIPMENT_ANALYTICS_SV
  → Calculate: orders that were on-time, in-full, damage-free, docs-correct
  → Identify which component is failing most

HOP 2: SV_QUALITY
  → Get damage/quality events linked to shipments
  → Quantify damage-related failures

HOP 3: SV_SALES
  → Identify incomplete orders (partial fills)
  → Calculate in-full failure rate

SYNTHESIS:
  → "Perfect Order Rate: 84% (Target: 90%)
     Failure decomposition:
     - On-time: 94% (6% failure → 3.6 ppt impact)
     - In-full: 97% (3% failure → 1.8 ppt impact)
     - Damage-free: 98% (2% failure → 1.2 ppt impact)
     - Correct docs: 99% (1% failure → 0.6 ppt impact)
     
     Biggest lever: Improve on-time delivery (carrier performance)
     Quick win: Fix documentation errors (process issue)"
```

---

### MH-08: Demand-Supply Balancing

**Question:** "Will we be able to fulfill next month's demand with current inventory and pipeline?"

```
HOP 1: SV_SALES
  → Get next month's demand (open SO lines with REQUESTED_DATE in next 30 days)
  → Group by part

HOP 2: SV_INVENTORY
  → Get current available qty per part
  → Calculate: demand vs available

HOP 3: SV_PROCUREMENT
  → Get incoming supply (open PO lines with PROMISED_DATE in next 30 days)
  → Add to available

HOP 4: SV_MANUFACTURING
  → Get planned production (open WOs completing in next 30 days)
  → Add to supply

SYNTHESIS:
  → "Next 30-day demand-supply balance:
     - Total demand: 45,000 units across 340 parts
     - Current stock can fulfill: 78%
     - With PO pipeline: 92%
     - With production completions: 97%
     - Gap: 12 parts with unfulfilled demand (need expediting)
     Critical: 3 parts with zero pipeline — immediate PO required"
```

---

## Agent Reasoning Pattern

For all multi-hop queries, the agent follows this reasoning framework:

```
┌─────────────────┐
│ 1. DECOMPOSE    │ Break question into sub-queries
└────────┬────────┘
         ▼
┌─────────────────┐
│ 2. PLAN         │ Identify which views answer each sub-query
└────────┬────────┘
         ▼
┌─────────────────┐
│ 3. EXECUTE      │ Run each sub-query via appropriate tool
└────────┬────────┘
         ▼
┌─────────────────┐
│ 4. CORRELATE    │ Join/cross-reference results via shared keys
└────────┬────────┘
         ▼
┌─────────────────┐
│ 5. SYNTHESIZE   │ Combine into coherent answer with insight
└────────┬────────┘
         ▼
┌─────────────────┐
│ 6. RECOMMEND    │ Provide actionable next steps
└─────────────────┘
```

---

## Validation Criteria

Each multi-hop answer must meet these standards:

| Criterion | Requirement |
|-----------|-------------|
| **Traceability** | Every number cites its source view and metric |
| **Consistency** | Shared dimensions (Part, Supplier) use same IDs across hops |
| **Completeness** | All relevant hops explored, no blind spots |
| **Actionability** | Answer includes "so what" — recommendation or next step |
| **Confidence** | Agent flags uncertainty when data is incomplete |
