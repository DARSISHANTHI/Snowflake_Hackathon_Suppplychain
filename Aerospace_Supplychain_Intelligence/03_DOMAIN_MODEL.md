# 03 - Domain Model

## Aerospace Supply Chain Ontology

---

## Overview

This document defines the formal domain model for the Aerospace Supply Chain platform. It establishes the canonical entities, their attributes, hierarchies, and relationships that form the foundation of governed conversational analytics. Every semantic view, metric, and natural language query resolves against this single authoritative model.

---

## Domain Boundaries

```
┌─────────────────────────────────────────────────────────────────────┐
│                     AEROSPACE SUPPLY CHAIN DOMAIN                     │
├────────────────┬────────────────┬──────────────┬────────────────────┤
│  PROCUREMENT   │ MANUFACTURING  │  LOGISTICS   │  CUSTOMER SERVICE  │
│                │                │              │                    │
│ • Suppliers    │ • Plants       │ • Shipments  │ • Sales Orders     │
│ • POs / PRs   │ • Work Centers │ • Carriers   │ • Customers        │
│ • Contracts    │ • Work Orders  │ • Tracking   │ • AOG Events       │
│ • Materials    │ • Quality      │ • Inventory  │ • Repair Orders    │
└────────────────┴────────────────┴──────────────┴────────────────────┘
```

---

## Entity Classification

### Dimension Entities (Master Data)

| Entity | Table | Grain | Business Role |
|--------|-------|-------|---------------|
| Supplier | DIM_SUPPLIER | One row per supplier version (SCD2) | Organizations providing parts and materials |
| Part | DIM_PART | One row per unique part | Aerospace components classified by ATA chapter |
| Plant | DIM_PLANT | One row per facility | Manufacturing, MRO, and warehouse sites |
| Warehouse | DIM_WAREHOUSE | One row per storage location | Physical inventory storage within plants |
| Customer | DIM_CUSTOMER | One row per customer | Airlines, MROs, defense organizations |
| Carrier | DIM_CARRIER | One row per logistics provider | Freight and logistics service providers |
| Work Center | DIM_WORK_CENTER | One row per machine/station | Manufacturing operation points within plants |
| Raw Material | DIM_RAW_MATERIAL | One row per material spec | Base materials (titanium, composites, alloys) |
| BOM | DIM_BOM | One row per parent-child relationship | Assembly structure defining part composition |
| Calendar | DIM_CALENDAR | One row per date | Fiscal and calendar periods for time intelligence |
| Certification | DIM_CERTIFICATION | One row per part certification | Regulatory compliance (FAA, EASA, AS9100, ITAR) |
| Supplier-Part | DIM_SUPPLIER_PART | One row per supplier-part contract | Cross-reference with pricing and lead times |
| Routing | DIM_ROUTING | One row per operation step | Manufacturing operation sequences |

### Fact Entities (Transactional/Event Data)

| Entity | Table | Grain | Business Role |
|--------|-------|-------|---------------|
| Purchase Order | FACT_PURCHASE_ORDER | One row per PO header | Supplier order commitments |
| PO Line | FACT_PURCHASE_ORDER_LINE | One row per PO line item | Part-level procurement detail |
| Purchase Requisition | FACT_PURCHASE_REQUISITION | One row per PR | Pre-order demand signals |
| Sales Order | FACT_SALES_ORDER | One row per SO header | Customer order commitments |
| SO Line | FACT_SALES_ORDER_LINE | One row per SO line item | Part-level sales detail |
| Shipment | FACT_SHIPMENT | One row per shipment | Goods movement between locations |
| Inventory | FACT_INVENTORY | One row per part-plant-warehouse | Current stock position snapshot |
| Inventory Movement | FACT_INVENTORY_MOVEMENT | One row per stock transaction | All receipts, issues, transfers, adjustments |
| Work Order | FACT_WORK_ORDER | One row per production order | Manufacturing execution tracking |
| Quality Event | FACT_QUALITY_EVENT | One row per quality incident | NCRs, CAPAs, inspections |
| IoT Sensor Data | FACT_IOT_SENSOR_DATA | One row per sensor reading | Equipment condition monitoring |
| AOG Event | FACT_AOG_EVENT | One row per AOG incident | Aircraft On Ground disruptions |
| Repair Order | FACT_REPAIR_ORDER | One row per MRO job | Component overhaul and repair |

### Metadata Entities

| Entity | Table | Grain | Business Role |
|--------|-------|-------|---------------|
| Business Glossary | META_BUSINESS_GLOSSARY | One row per business term | Canonical term definitions |
| Metric Definition | META_METRIC_DEFINITION | One row per KPI | Standardized metric formulas and targets |

---

## Entity Relationship Diagram

### Full Ontology

```
                              ┌─────────────┐
                              │ DIM_CALENDAR│
                              │  (DATE_KEY) │
                              └──────┬──────┘
                                     │ Referenced by all date columns
                                     │ in fact tables
         ┌───────────────────────────┼───────────────────────────┐
         │                           │                           │
         ▼                           ▼                           ▼
┌─────────────────┐         ┌───────────────┐         ┌─────────────────┐
│  DIM_SUPPLIER   │         │   DIM_PART    │         │  DIM_CUSTOMER   │
│                 │         │               │         │                 │
│ • SUPPLIER_ID   │         │ • PART_ID     │         │ • CUSTOMER_ID   │
│ • TIER_LEVEL    │◀───┐    │ • ATA_CHAPTER │    ┌───▶│ • CUSTOMER_TYPE │
│ • RISK_SCORE    │    │    │ • CRITICALITY │    │    │ • REVENUE_TIER  │
│ • QUALITY_RATING│    │    │ • MAKE_BUY    │    │    │                 │
└────────┬────────┘    │    └───────┬───────┘    │    └────────┬────────┘
         │             │            │            │             │
         │    ┌────────┴────────┐   │   ┌────────┴────────┐   │
         │    │DIM_SUPPLIER_PART│   │   │ FACT_SALES_ORDER │   │
         │    │                 │◀──┤   │                  │◀──┘
         │    │ • CONTRACT_PRICE│   │   │ • ORDER_DATE     │
         │    │ • LEAD_TIME_DAYS│   │   │ • TOTAL_VALUE    │
         │    │ • MOQ           │   │   │ • STATUS         │
         │    └─────────────────┘   │   └────────┬─────────┘
         │                          │            │
         ▼                          │            ▼
┌─────────────────┐                 │   ┌─────────────────────┐
│FACT_PURCHASE_   │                 │   │FACT_SALES_ORDER_LINE│
│ORDER            │                 ├──▶│                     │
│                 │                 │   │ • QUANTITY_ORDERED   │
│ • ORDER_DATE    │                 │   │ • UNIT_PRICE         │
│ • TOTAL_VALUE   │                 │   └─────────────────────┘
│ • STATUS        │                 │
└────────┬────────┘                 │
         │                          │
         ▼                          ▼
┌─────────────────────┐    ┌───────────────┐    ┌─────────────────┐
│FACT_PURCHASE_       │    │  DIM_PLANT    │    │  DIM_WAREHOUSE  │
│ORDER_LINE           │    │               │    │                 │
│                     │    │ • PLANT_ID    │◀───│ • WAREHOUSE_ID  │
│ • QUANTITY_ORDERED  │───▶│ • PLANT_TYPE  │    │ • WAREHOUSE_TYPE│
│ • UNIT_PRICE        │    │ • REGION      │    │ • CAPACITY      │
└─────────────────────┘    └───────┬───────┘    └────────┬────────┘
                                   │                     │
                           ┌───────┴───────┐             │
                           ▼               ▼             ▼
                  ┌──────────────┐ ┌──────────────┐ ┌──────────────────┐
                  │DIM_WORK_     │ │FACT_WORK_    │ │ FACT_INVENTORY   │
                  │CENTER        │ │ORDER         │ │                  │
                  │              │ │              │ │ • ON_HAND_QTY    │
                  │• MACHINE_TYPE│ │• YIELD_RATE  │ │ • REORDER_POINT  │
                  │• HOURLY_RATE │ │• STATUS      │ │ • SAFETY_STOCK   │
                  └──────────────┘ └──────────────┘ └──────────────────┘
```

### Shipment & Logistics Subgraph

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│ DIM_SUPPLIER │────▶│              │◀────│ DIM_CUSTOMER │
└──────────────┘     │              │     └──────────────┘
                     │ FACT_SHIPMENT│
┌──────────────┐     │              │     ┌──────────────┐
│  DIM_PLANT   │────▶│ • SHIP_DATE  │◀────│ DIM_CARRIER  │
│ (origin/dest)│     │ • STATUS     │     │              │
└──────────────┘     │ • FREIGHT    │     │ • ON_TIME_PCT│
                     │ • IS_ON_TIME │     │ • COST_PER_KG│
┌──────────────┐     │              │     └──────────────┘
│   DIM_PART   │────▶│              │
└──────────────┘     └──────────────┘
```

### Manufacturing Subgraph

```
┌──────────────┐     ┌──────────────┐     ┌──────────────────┐
│   DIM_PART   │────▶│ FACT_WORK_   │◀────│ DIM_WORK_CENTER  │
└──────────────┘     │ ORDER        │     └──────────────────┘
                     │              │              ▲
┌──────────────┐     │ • YIELD_RATE │              │
│  DIM_PLANT   │────▶│ • QTY_COMP   │     ┌──────────────────┐
└──────────────┘     │ • TOTAL_COST │     │  DIM_ROUTING     │
                     └──────┬───────┘     │ • OPERATION_SEQ  │
                            │             │ • STANDARD_TIME  │
                            ▼             └──────────────────┘
                     ┌──────────────┐
                     │FACT_QUALITY_ │     ┌──────────────────┐
                     │EVENT         │◀────│ FACT_IOT_SENSOR  │
                     │              │     │ _DATA            │
                     │ • DEFECT_TYPE│     │ • TEMPERATURE    │
                     │ • SEVERITY   │     │ • VIBRATION      │
                     │ • DISPOSITION│     │ • ALERT_FLAG     │
                     └──────────────┘     └──────────────────┘
```

---

## Hierarchies

### Geographic Hierarchy

```
Region → Country → City → Plant → Warehouse / Work Center
```

### Part Hierarchy

```
ATA Chapter → Part Family → Part → BOM (Parent-Child Assembly)
```

### Supplier Hierarchy

```
Tier Level → Category → Supplier → Supplier-Part (Contract)
```

### Customer Hierarchy

```
Region → Country → Customer Type → Revenue Tier → Customer
```

### Time Hierarchy

```
Fiscal Year → Fiscal Quarter → Month → Week → Date
```

### Order Hierarchy

```
Purchase Order → PO Line Items
Sales Order → SO Line Items
Work Order → Routing Operations
```

---

## Canonical Metrics (Governed Definitions)

### Procurement Domain

| Metric | ID | Formula | Unit | Target |
|--------|----|---------|------|--------|
| Supplier On-Time Delivery | M001 | `COUNT(PO WHERE RECEIVED_DATE <= PROMISED_DATE) / COUNT(PO) * 100` | % | ≥ 95% |
| Purchase Order Cycle Time | M002 | `AVG(RECEIVED_DATE - ORDER_DATE)` | Days | ≤ 14 |
| Landed Cost | M003 | `SUM(line_value + freight_cost) / SUM(quantity)` | $/unit | Minimize |
| Supplier Risk Index | M004 | `WEIGHTED_AVG(risk_score, spend_amount)` | Score | ≤ 3.0 |

### Manufacturing Domain

| Metric | ID | Formula | Unit | Target |
|--------|----|---------|------|--------|
| Production Yield | M005 | `SUM(qty_completed) / SUM(qty_ordered) * 100` | % | ≥ 98% |
| Scrap Rate | M006 | `SUM(qty_scrapped) / SUM(qty_ordered) * 100` | % | ≤ 2% |
| Work Order Completion Rate | M007 | `COUNT(WO WHERE STATUS='Completed') / COUNT(WO) * 100` | % | ≥ 95% |
| Quality PPM | M008 | `SUM(qty_defective) / SUM(qty_inspected) * 1000000` | PPM | ≤ 500 |

### Logistics Domain

| Metric | ID | Formula | Unit | Target |
|--------|----|---------|------|--------|
| On-Time Delivery (Customer) | M009 | `COUNT(SHIPMENT WHERE IS_ON_TIME=TRUE) / COUNT(SHIPMENT) * 100` | % | ≥ 97% |
| Fill Rate | M010 | `SUM(qty_shipped) / SUM(qty_ordered) * 100` | % | ≥ 98% |
| Freight Cost per KG | M011 | `SUM(freight_cost) / SUM(weight_kg)` | $/kg | Minimize |
| AOG Response Time | M012 | `AVG(duration_hours)` | Hours | ≤ 4 |

### Inventory Domain

| Metric | ID | Formula | Unit | Target |
|--------|----|---------|------|--------|
| Days of Inventory | M013 | `AVG(on_hand_qty) / AVG(daily_usage)` | Days | 15-30 |
| Inventory Turnover | M014 | `COGS / AVG(inventory_value)` | Turns | ≥ 6 |
| Stockout Rate | M015 | `COUNT(part WHERE available_qty = 0) / COUNT(part) * 100` | % | ≤ 1% |
| Excess Inventory % | M016 | `SUM(VALUE WHERE on_hand > max_stock) / SUM(total_value) * 100` | % | ≤ 5% |

---

## Cross-Domain Query Patterns

These patterns demonstrate how the ontology enables consistent cross-domain analytics:

### Pattern 1: Supplier → Quality → Inventory Impact

```
Question: "Which suppliers have quality issues affecting my inventory?"
Path:     DIM_SUPPLIER → FACT_QUALITY_EVENT → DIM_PART → FACT_INVENTORY
Metrics:  Supplier Quality PPM, Days of Inventory for affected parts
```

### Pattern 2: Customer Order → Shipment → AOG

```
Question: "Which customers are at risk of AOG due to late shipments?"
Path:     DIM_CUSTOMER → FACT_SALES_ORDER → FACT_SHIPMENT → FACT_AOG_EVENT
Metrics:  Customer OTD, AOG Response Time, Fill Rate
```

### Pattern 3: Work Order → Inventory → Purchase Order

```
Question: "Do I have enough stock to complete open work orders?"
Path:     FACT_WORK_ORDER → DIM_PART → FACT_INVENTORY → FACT_PURCHASE_ORDER
Metrics:  Days of Inventory, WO Completion Rate, PO Cycle Time
```

### Pattern 4: IoT → Quality → Supplier Root Cause

```
Question: "Are equipment anomalies linked to specific supplier batches?"
Path:     FACT_IOT_SENSOR_DATA → DIM_WORK_CENTER → FACT_QUALITY_EVENT → DIM_SUPPLIER
Metrics:  Sensor Alerts, Quality PPM by Supplier, Scrap Rate
```

---

## Governance Rules

| Rule | Description |
|------|-------------|
| **Single Metric Definition** | Each metric has exactly one formula defined in META_METRIC_DEFINITION |
| **Entity Ownership** | Each entity has a designated business owner (Procurement, Manufacturing, Logistics) |
| **SCD Strategy** | DIM_SUPPLIER uses Type 2 (versioned); all others use Type 1 (overwrite) |
| **Surrogate Keys** | All dimensions use auto-increment `_SK` surrogate keys; natural keys (`_ID`) are unique |
| **Naming Convention** | Dimensions prefixed `DIM_`, facts prefixed `FACT_`, metadata prefixed `META_` |
| **Date Conformance** | All date columns join to DIM_CALENDAR.DATE_KEY |
| **Null Handling** | Surrogate keys and natural keys are NOT NULL; measures default to 0 where applicable |
| **Audit Columns** | All tables include CREATED_TIMESTAMP; mutable tables include UPDATED_TIMESTAMP |

---

## Persona-Metric Resolution Matrix

This matrix proves that the same metric resolves identically regardless of which persona asks the question:

| Question (Natural Language) | Planning | Procurement | Logistics | Manufacturing |
|-----------------------------|----------|-------------|-----------|---------------|
| "What's my on-time delivery?" | M009 (Customer OTD) | M001 (Supplier OTD) | M009 (Customer OTD) | M007 (WO Completion) |
| "What's the fill rate?" | M010 | M010 | M010 | M010 |
| "How much inventory do I have?" | M013 (DOI) | M013 (DOI) | M013 (DOI) | M013 (DOI) |
| "What's my quality performance?" | M008 (PPM) | M008 (PPM) | M008 (PPM) | M008 (PPM) |

> **Note:** "On-time delivery" resolves to different metrics based on context (supplier vs customer), but the semantic layer disambiguates via persona context. All other shared metrics resolve identically.

---

## Data Flow

```
SOURCE SYSTEMS          RAW SCHEMA              GOLD SCHEMA           SEMANTIC LAYER
─────────────          ──────────              ───────────           ──────────────
ERP (SAP/Oracle) ───▶  Raw tables    ───▶  DIM_SUPPLIER     ───▶  Semantic View:
Logistics TMS    ───▶  (1:1 source   ───▶  DIM_PART              "Supplier
Supplier Portal  ───▶   aligned)     ───▶  FACT_PURCHASE_         Performance"
IoT Platform     ───▶               ───▶  FACT_SHIPMENT     ───▶  Semantic View:
Quality MES      ───▶               ───▶  FACT_QUALITY_          "Inventory
                                          EVENT                    Health"
                                                              ───▶  Semantic View:
                                                                   "Order
                                                                    Fulfillment"
```
