# 10 - Semantic Views

## Aerospace Supply Chain — Governed Semantic Layer Specification

---

## Purpose

Semantic views are the governed interface between raw data and conversational analytics. They encode business meaning — entity names, metric formulas, join paths, and access rules — so that Cortex Analyst can translate natural language questions into correct, consistent SQL without exposing physical schema complexity to users.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                    CORTEX ANALYST / AGENTS                            │
│              (Natural Language → SQL via Semantic Views)              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │              SEMANTIC VIEW LAYER                              │    │
│  │                                                              │    │
│  │  ┌─────────────┐ ┌────────────┐ ┌────────────────────────┐ │    │
│  │  │  Domain SVs │ │ Cross-Domain│ │   Executive Summary    │ │    │
│  │  │ (single     │ │ SVs (multi- │ │   SV (aggregated KPIs) │ │    │
│  │  │  subject)   │ │  subject)   │ │                        │ │    │
│  │  └─────────────┘ └────────────┘ └────────────────────────┘ │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                      │
├─────────────────────────────────────────────────────────────────────┤
│                        GOLD SCHEMA (Star Schema)                     │
│              DIM_* (dimensions) + FACT_* (transactions)              │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Semantic View Inventory

### Domain Semantic Views (Single Subject Area)

| Semantic View | Database.Schema | Description | Cortex Extensions |
|--------------|-----------------|-------------|-------------------|
| SV_PROCUREMENT | AEROSPACE_SUPPLY_CHAIN.SEMANTIC | Procurement and supplier performance: POs, supplier scorecards, OTD, freight, carriers | CA |
| SV_INVENTORY | AEROSPACE_SUPPLY_CHAIN.SEMANTIC | Inventory management: stock levels, movements, warehouse utilization, DOI, reorder | CA |
| SV_MANUFACTURING | AEROSPACE_SUPPLY_CHAIN.SEMANTIC | Manufacturing: production scheduling, work center capacity, yield rates, costs | CA |
| SV_QUALITY | AEROSPACE_SUPPLY_CHAIN.SEMANTIC | Quality: defect tracking, COPQ, root cause, supplier quality, resolution times | CA |
| SV_SALES | AEROSPACE_SUPPLY_CHAIN.SEMANTIC | Sales and orders: order book, revenue, fill rates, customer analysis, delivery | CA |
| SUPPLIER_PERFORMANCE_SV | SUPPLY_CHAIN_RAW_DB.SEMANTIC_VIEWS | Supplier OTD, quality scores, risk, certification, spend | CA, AI |
| PROCUREMENT_ANALYTICS_SV | SUPPLY_CHAIN_RAW_DB.SEMANTIC_VIEWS | Procurement spend, PO cycle time, cost variance, savings | CA, AI |
| INVENTORY_MANAGEMENT_SV | SUPPLY_CHAIN_RAW_DB.SEMANTIC_VIEWS | Stock levels, days of supply, turnover, stockout tracking | CA, AI |
| SHIPMENT_ANALYTICS_SV | SUPPLY_CHAIN_RAW_DB.SEMANTIC_VIEWS | Transit times, delay rates, shipping costs, carrier performance | CA, AI |
| MANUFACTURING_ANALYTICS_SV | SUPPLY_CHAIN_RAW_DB.SEMANTIC_VIEWS | OEE, yield rates, capacity utilization, scrap, machine performance | CA, AI |
| CUSTOMER_ORDERS_SV | SUPPLY_CHAIN_RAW_DB.SEMANTIC_VIEWS | Fulfillment rates, customer OTD, revenue by segment, backorders | CA, AI |
| GOVERNANCE_COMPLIANCE_SV | SUPPLY_CHAIN_RAW_DB.SEMANTIC_VIEWS | Regulatory adherence, audit findings, certification gaps | CA |

### Cross-Domain Semantic Views (Multi-Subject)

| Semantic View | Database.Schema | Description | Cortex Extensions |
|--------------|-----------------|-------------|-------------------|
| SUPPLIER_QUALITY_PRODUCTION_SV | SUPPLY_CHAIN_RAW_DB.SEMANTIC_VIEWS | Supplier quality → production outcomes for root cause analysis | CA, AI |
| SUPPLIER_SHIPMENT_WAREHOUSE_SV | SUPPLY_CHAIN_RAW_DB.SEMANTIC_VIEWS | Suppliers → shipments → warehouses for end-to-end logistics | CA, AI |
| PROCUREMENT_INVENTORY_FINANCE_SV | SUPPLY_CHAIN_RAW_DB.SEMANTIC_VIEWS | Procurement spend → inventory positions → working capital | CA, AI |
| ORDER_SHIPMENT_CUSTOMER_SV | SUPPLY_CHAIN_RAW_DB.SEMANTIC_VIEWS | Customer orders → shipment → delivery for perfect order analysis | CA |

### Executive Semantic View

| Semantic View | Database.Schema | Description | Cortex Extensions |
|--------------|-----------------|-------------|-------------------|
| EXECUTIVE_SUMMARY_SV | SUPPLY_CHAIN_RAW_DB.SEMANTIC_VIEWS | High-level KPIs across all domains: OTD, quality, spend, inventory, production, risk | CA, AI |

---

## Workspace Semantic View Definition

### SUPPLY_CHAIN_ANALYTICS (cortex_project/SUPPLY_CHAIN_ANALYTICS.sv.yaml)

This is the primary workspace-managed semantic view covering the core supply chain star schema:

**Tables Included:**

| Table | Type | Key Dimensions | Key Facts |
|-------|------|----------------|-----------|
| DIM_SUPPLIER | Dimension | SUPPLIER_ID, SUPPLIER_NAME, TIER_LEVEL, COUNTRY, REGION, CATEGORY | RISK_SCORE, QUALITY_RATING, ON_TIME_DELIVERY_PCT, ANNUAL_REVENUE |
| DIM_PART | Dimension | PART_ID, PART_NUMBER, PART_NAME, PART_FAMILY, ATA_CHAPTER, CRITICALITY | STANDARD_COST |
| DIM_PLANT | Dimension | PLANT_ID, PLANT_NAME, COUNTRY, REGION, PLANT_TYPE, CAPACITY_UNITS | — |
| DIM_CUSTOMER | Dimension | CUSTOMER_ID, CUSTOMER_NAME, COUNTRY, REGION, CUSTOMER_TYPE, REVENUE_TIER | ANNUAL_REVENUE |
| FACT_PURCHASE_ORDER | Fact | PO_ID, SUPPLIER_ID, PLANT_ID, STATUS, PRIORITY_CODE | TOTAL_VALUE |
| FACT_PURCHASE_ORDER_LINE | Fact | PO_LINE_ID, PO_ID, PART_ID, STATUS | QUANTITY_ORDERED, QUANTITY_RECEIVED, UNIT_PRICE, LINE_VALUE |
| FACT_SALES_ORDER | Fact | SO_ID, CUSTOMER_ID, PLANT_ID, STATUS, PRIORITY | TOTAL_VALUE |
| FACT_SHIPMENT | Fact | SHIPMENT_ID, SHIPMENT_TYPE, SUPPLIER_ID, CUSTOMER_ID, CARRIER_ID, PART_ID, IS_ON_TIME | QUANTITY, FREIGHT_COST, WEIGHT_KG |
| FACT_INVENTORY | Fact | INVENTORY_ID, PART_ID, PLANT_ID, WAREHOUSE_ID | ON_HAND_QTY, AVAILABLE_QTY, RESERVED_QTY, IN_TRANSIT_QTY, REORDER_POINT, SAFETY_STOCK, UNIT_COST, TOTAL_VALUE |

**Relationships Defined:**

| Relationship Name | Left Table | Right Table | Join Column | Type |
|-------------------|-----------|-------------|-------------|------|
| PO_TO_SUPPLIER | FACT_PURCHASE_ORDER | DIM_SUPPLIER | SUPPLIER_ID | many_to_one |
| PO_TO_PLANT | FACT_PURCHASE_ORDER | DIM_PLANT | PLANT_ID | many_to_one |
| PO_LINE_TO_PO | FACT_PURCHASE_ORDER_LINE | FACT_PURCHASE_ORDER | PO_ID | many_to_one |
| PO_LINE_TO_PART | FACT_PURCHASE_ORDER_LINE | DIM_PART | PART_ID | many_to_one |
| SO_TO_CUSTOMER | FACT_SALES_ORDER | DIM_CUSTOMER | CUSTOMER_ID | many_to_one |
| SO_TO_PLANT | FACT_SALES_ORDER | DIM_PLANT | PLANT_ID | many_to_one |
| SHIPMENT_TO_SUPPLIER | FACT_SHIPMENT | DIM_SUPPLIER | SUPPLIER_ID | many_to_one |
| SHIPMENT_TO_PART | FACT_SHIPMENT | DIM_PART | PART_ID | many_to_one |
| INVENTORY_TO_PART | FACT_INVENTORY | DIM_PART | PART_ID | many_to_one |
| INVENTORY_TO_PLANT | FACT_INVENTORY | DIM_PLANT | PLANT_ID | many_to_one |

---

## Semantic View Design Patterns

### Pattern 1: Domain-Specific View

Covers one analytical domain with all related dimensions and facts:

```
┌─────────────────────────────────────────┐
│         SV_PROCUREMENT                   │
│                                          │
│  Dimensions:                             │
│    DIM_SUPPLIER (who)                    │
│    DIM_PART (what)                       │
│    DIM_PLANT (where)                     │
│    DIM_CALENDAR (when)                   │
│                                          │
│  Facts:                                  │
│    FACT_PURCHASE_ORDER (PO header)       │
│    FACT_PURCHASE_ORDER_LINE (PO detail)  │
│    FACT_SHIPMENT (inbound deliveries)    │
│                                          │
│  Metrics:                                │
│    - Supplier OTD (MET-012)             │
│    - PO Cycle Time (MET-001)            │
│    - Landed Cost (MET-014)              │
│    - Supplier Performance Index (MET-015)│
└─────────────────────────────────────────┘
```

### Pattern 2: Cross-Domain View

Joins entities across domain boundaries for root cause or end-to-end analysis:

```
┌─────────────────────────────────────────┐
│   SUPPLIER_QUALITY_PRODUCTION_SV         │
│                                          │
│  Procurement Domain:                     │
│    DIM_SUPPLIER → FACT_PURCHASE_ORDER    │
│                                          │
│       ─── crosses into ───               │
│                                          │
│  Quality Domain:                         │
│    FACT_QUALITY_EVENT                    │
│                                          │
│       ─── crosses into ───               │
│                                          │
│  Manufacturing Domain:                   │
│    FACT_WORK_ORDER                       │
│                                          │
│  Enables: "Which suppliers are causing   │
│   production quality failures?"          │
└─────────────────────────────────────────┘
```

### Pattern 3: Executive Summary View

Aggregated KPIs from all domains in one view for leadership dashboards:

```
┌─────────────────────────────────────────┐
│     EXECUTIVE_SUMMARY_SV                 │
│                                          │
│  From Procurement: Spend, Supplier OTD   │
│  From Inventory:   DOI, Stockout Rate    │
│  From Manufacturing: Yield, Scrap Rate   │
│  From Logistics:   Customer OTD, Fill    │
│  From Quality:     Defect Rate, COPQ     │
│  From Finance:     Revenue at Risk       │
│                                          │
│  All metrics pre-aggregated to monthly/  │
│  quarterly grain for fast executive      │
│  query response                          │
└─────────────────────────────────────────┘
```

---

## Semantic View YAML Structure

Each semantic view follows this structure in the Cortex project:

```yaml
name: <SEMANTIC_VIEW_NAME>
description: <Business description for Cortex Analyst>

tables:
  - name: <logical_table_name>
    base_table:
      database: AEROSPACE_SUPPLY_CHAIN
      schema: GOLD
      table: <physical_table_name>
    dimensions:          # Categorical/grouping columns
      - name: <column>
        expr: <SQL expression>
        data_type: <VARCHAR|BOOLEAN>
    time_dimensions:     # Date/time columns
      - name: <column>
        expr: <SQL expression>
        data_type: DATE
    facts:               # Numeric/measurable columns
      - name: <column>
        expr: <SQL expression>
        data_type: NUMBER
    unique_keys:
      - columns:
          - <primary_key_column>

relationships:           # Join definitions
  - name: <relationship_name>
    left_table: <fact_table>
    right_table: <dimension_table>
    relationship_columns:
      - left_column: <fk_column>
        right_column: <pk_column>
    relationship_type: many_to_one
```

---

## Metric Encoding in Semantic Views

Each governed metric from the business glossary is encoded as a fact or derived expression:

| Metric (ID) | Semantic View | Encoding Strategy |
|-------------|---------------|-------------------|
| On-Time Delivery (MET-001) | SV_PROCUREMENT, SHIPMENT_ANALYTICS_SV | `IS_ON_TIME` boolean fact + COUNT aggregation |
| Fill Rate (MET-002) | SV_SALES, CUSTOMER_ORDERS_SV | `QUANTITY_SHIPPED / QUANTITY_ORDERED * 100` |
| Inventory Days (MET-003) | SV_INVENTORY, INVENTORY_MANAGEMENT_SV | `ON_HAND_QTY` fact with derived daily demand |
| Inventory Turnover (MET-004) | SV_INVENTORY, INVENTORY_MANAGEMENT_SV | Derived from TOTAL_VALUE and consumption |
| Supplier Risk (MET-005) | SV_PROCUREMENT, SUPPLIER_PERFORMANCE_SV | `RISK_SCORE` direct fact on DIM_SUPPLIER |
| Production Yield (MET-006) | SV_MANUFACTURING, MANUFACTURING_ANALYTICS_SV | `QUANTITY_COMPLETED / QUANTITY_ORDERED * 100` |
| Scrap Rate (MET-007) | SV_MANUFACTURING, MANUFACTURING_ANALYTICS_SV | `QUANTITY_SCRAPPED / QUANTITY_ORDERED * 100` |
| Revenue at Risk (MET-008) | EXECUTIVE_SUMMARY_SV | Cross-domain: SO value where shipment IS_ON_TIME=FALSE |
| WO Completion Rate (MET-009) | SV_MANUFACTURING, MANUFACTURING_ANALYTICS_SV | `COUNT(completed_on_time) / COUNT(total)` |
| Freight Cost/Unit (MET-010) | SHIPMENT_ANALYTICS_SV | `FREIGHT_COST / QUANTITY` |
| Carrier OTD (MET-011) | SHIPMENT_ANALYTICS_SV | `IS_ON_TIME` grouped by CARRIER_ID |
| Supplier OTD (MET-012) | SV_PROCUREMENT, SUPPLIER_PERFORMANCE_SV | `ON_TIME_DELIVERY_PCT` on DIM_SUPPLIER |
| Quality Defect Rate (MET-013) | SV_QUALITY | `QUANTITY_DEFECTIVE / QUANTITY_INSPECTED * 100` |
| Landed Cost (MET-014) | SV_PROCUREMENT, PROCUREMENT_ANALYTICS_SV | `UNIT_PRICE + FREIGHT_PER_UNIT + DUTIES + HANDLING` |
| SPI (MET-015) | SUPPLIER_PERFORMANCE_SV | Composite from quality, delivery, cost, responsiveness |

---

## Persona-to-Semantic View Mapping

| Persona | Primary Semantic View | Secondary Views | Key Questions |
|---------|----------------------|-----------------|---------------|
| Procurement Manager | SV_PROCUREMENT, PROCUREMENT_ANALYTICS_SV | SUPPLIER_PERFORMANCE_SV | "Which suppliers are underperforming?" |
| Supply Planner | SV_INVENTORY, INVENTORY_MANAGEMENT_SV | PROCUREMENT_INVENTORY_FINANCE_SV | "What parts are below reorder point?" |
| Logistics Manager | SHIPMENT_ANALYTICS_SV | ORDER_SHIPMENT_CUSTOMER_SV | "What's our on-time delivery this month?" |
| Manufacturing Director | SV_MANUFACTURING, MANUFACTURING_ANALYTICS_SV | SUPPLIER_QUALITY_PRODUCTION_SV | "What's our production yield by plant?" |
| Quality Director | SV_QUALITY | SUPPLIER_QUALITY_PRODUCTION_SV | "What's driving scrap this quarter?" |
| Sales Director | SV_SALES, CUSTOMER_ORDERS_SV | ORDER_SHIPMENT_CUSTOMER_SV | "What's our fill rate by customer tier?" |
| CFO / Executive | EXECUTIVE_SUMMARY_SV | PROCUREMENT_INVENTORY_FINANCE_SV | "What's our revenue at risk?" |

---

## Cortex Extensions

| Extension | Code | Capability |
|-----------|------|-----------|
| Cortex Analyst | CA | Natural language to SQL query generation |
| AI Functions | AI | AI-powered summarization, classification, extraction |

### Extension Assignment

| Views with CA only | Views with CA + AI |
|--------------------|--------------------|
| SV_PROCUREMENT | SUPPLIER_PERFORMANCE_SV |
| SV_INVENTORY | PROCUREMENT_ANALYTICS_SV |
| SV_MANUFACTURING | INVENTORY_MANAGEMENT_SV |
| SV_QUALITY | SHIPMENT_ANALYTICS_SV |
| SV_SALES | MANUFACTURING_ANALYTICS_SV |
| GOVERNANCE_COMPLIANCE_SV | CUSTOMER_ORDERS_SV |
| ORDER_SHIPMENT_CUSTOMER_SV | EXECUTIVE_SUMMARY_SV |
| | SUPPLIER_QUALITY_PRODUCTION_SV |
| | PROCUREMENT_INVENTORY_FINANCE_SV |
| | SUPPLIER_SHIPMENT_WAREHOUSE_SV |

---

## Consistency Validation

The following queries must return identical results regardless of which semantic view they are routed through:

### Test Case 1: On-Time Delivery %

```
Question: "What is the overall on-time delivery percentage?"
Expected: Same value whether asked via SV_PROCUREMENT or SHIPMENT_ANALYTICS_SV
Formula:  COUNT(IS_ON_TIME = TRUE) / COUNT(*) * 100 WHERE STATUS IN ('Delivered','Closed')
```

### Test Case 2: Inventory Days of Supply

```
Question: "What's the average days of inventory?"
Expected: Same value from SV_INVENTORY or INVENTORY_MANAGEMENT_SV
Formula:  AVG(ON_HAND_QTY) / AVG(daily_demand)
```

### Test Case 3: Supplier Risk Distribution

```
Question: "How many high-risk suppliers do we have?"
Expected: Same count from SV_PROCUREMENT or SUPPLIER_PERFORMANCE_SV
Formula:  COUNT(*) WHERE RISK_SCORE > 70 (or OTD < 85 OR QUALITY < 70)
```

### Test Case 4: Fill Rate

```
Question: "What's our fill rate this month?"
Expected: Same value from SV_SALES or CUSTOMER_ORDERS_SV
Formula:  SUM(QUANTITY_SHIPPED) / NULLIF(SUM(QUANTITY_ORDERED), 0) * 100
```

---

## Semantic View Governance

| Rule | Description |
|------|-------------|
| **Naming** | Domain views: `SV_<DOMAIN>` or `<DOMAIN>_ANALYTICS_SV`; Cross-domain: `<D1>_<D2>_<D3>_SV` |
| **Ownership** | All owned by ACCOUNTADMIN; domain steward approves changes |
| **Versioning** | Managed in workspace via `cortex_project/` YAML files |
| **Deployment** | Deploy through Cortex project — never manual DDL |
| **Testing** | Every change validated with sample NL queries per persona |
| **Documentation** | Every semantic view has a description field explaining its scope |
| **Metric Consistency** | Shared metrics (OTD, DOI, Fill Rate) use identical formulas across all views |
| **No Duplication** | A metric formula is defined once; views reference the same calculation |

---

## Deployment Reference

### Workspace Files

```
cortex_project/
├── cortex-project.yaml              # Project manifest
├── SUPPLY_CHAIN_ANALYTICS.sv.yaml   # Primary semantic view definition
└── SUPPLY_CHAIN_COPILOT.agent.yaml  # Agent using semantic views
```

### Snowflake Objects

```
AEROSPACE_SUPPLY_CHAIN.SEMANTIC
├── SV_PROCUREMENT
├── SV_INVENTORY
├── SV_MANUFACTURING
├── SV_QUALITY
└── SV_SALES

SUPPLY_CHAIN_RAW_DB.SEMANTIC_VIEWS
├── SUPPLIER_PERFORMANCE_SV
├── PROCUREMENT_ANALYTICS_SV
├── INVENTORY_MANAGEMENT_SV
├── SHIPMENT_ANALYTICS_SV
├── MANUFACTURING_ANALYTICS_SV
├── CUSTOMER_ORDERS_SV
├── GOVERNANCE_COMPLIANCE_SV
├── SUPPLIER_QUALITY_PRODUCTION_SV
├── SUPPLIER_SHIPMENT_WAREHOUSE_SV
├── PROCUREMENT_INVENTORY_FINANCE_SV
├── ORDER_SHIPMENT_CUSTOMER_SV
└── EXECUTIVE_SUMMARY_SV
```

---

## Sample Natural Language Queries by View

| Semantic View | Sample Question | Expected Behavior |
|--------------|-----------------|-------------------|
| SV_PROCUREMENT | "Top 5 suppliers by spend this quarter" | Aggregates PO TOTAL_VALUE by SUPPLIER_NAME, filters by ORDER_DATE |
| SV_INVENTORY | "Which parts are below safety stock?" | Filters AVAILABLE_QTY < SAFETY_STOCK, returns part details |
| SV_MANUFACTURING | "Average yield rate by plant last month" | AVG(YIELD_RATE) grouped by PLANT_NAME, date filtered |
| SV_QUALITY | "Root causes of critical defects this year" | Filters SEVERITY='critical', groups by ROOT_CAUSE |
| SV_SALES | "Revenue by customer type, ordered descending" | SUM(TOTAL_VALUE) grouped by CUSTOMER_TYPE |
| EXECUTIVE_SUMMARY_SV | "Give me a KPI dashboard for July" | Returns OTD, Fill Rate, DOI, Yield, Spend, Risk for the month |
| SUPPLIER_QUALITY_PRODUCTION_SV | "Which suppliers caused the most scrap?" | Joins supplier → quality → work order, sums QUANTITY_SCRAPPED |
| PROCUREMENT_INVENTORY_FINANCE_SV | "What's our working capital tied up in inventory?" | SUM(TOTAL_VALUE) from inventory with procurement context |
