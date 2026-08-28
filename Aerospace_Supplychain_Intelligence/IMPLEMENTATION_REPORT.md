# Aerospace Supply Chain Intelligence Platform — Implementation Report

**Database:** `AEROSPACE_SUPPLY_CHAIN_AI`  
**Account:** zt82836 | **Role:** ACCOUNTADMIN | **Warehouse:** COMPUTE_WH  
**Build Date:** 2026-08-25  
**Built with:** Snowflake CoCo CLI (Cortex Code)

---

## 1. Project Overview

### Objective
Build a governed, conversational analytics platform for aerospace supply chain operations using Snowflake's native AI services (Cortex Analyst, Cortex Search, Cortex Agents). The platform provides a single source of truth across procurement, inventory, manufacturing, quality, and sales domains.

### Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    SUPPLY_CHAIN_COPILOT (Cortex Agent)                   │
│              claude-3-5-sonnet | 10 tools | Ontology-governed            │
├────────────────────────────────┬────────────────────────────────────────┤
│   CORTEX SEARCH (Knowledge)    │         CORTEX ANALYST (Data)          │
│   90 indexed documents         │         9 Semantic Views               │
│   CDC-backed | Arctic Embed    │         Star Schema + Cross-Domain     │
├────────────────────────────────┴────────────────────────────────────────┤
│                        SEMANTIC LAYER (Views)                            │
│  5 Domain + 3 Cross-Domain + 1 Executive = 9 Semantic Views             │
├─────────────────────────────────────────────────────────────────────────┤
│                     ANALYTICS SCHEMA (Derived Views)                     │
│  7 Derivation Rule Views + 2 Governance Views + Threshold Alerting      │
├─────────────────────────────────────────────────────────────────────────┤
│                         RAW SCHEMA (Source Tables)                       │
│  13 Dimensions + 13 Facts + 2 Metadata = 28 Tables | 36,000+ rows      │
└─────────────────────────────────────────────────────────────────────────┘
```

### Key Capabilities
- Natural language queries across 5 supply chain domains
- Ontology-governed disambiguation (persona-aware resolution)
- Cross-domain root cause analysis (supplier → quality → production)
- Executive KPI dashboard with RAG alerting
- 24 metrics with formal definitions, targets, and threshold monitoring

---

## 2. Database & Schema Design

### Schemas Created

| Schema | Purpose | Objects |
|--------|---------|---------|
| `RAW` | Source-of-record tables with all operational data | 28 tables |
| `SEMANTIC` | Semantic views, knowledge base, search service, agent | 9 SVs + 1 search + 1 agent |
| `ANALYTICS` | Derived metrics, alerting, governance views | 9 views + 2 tables |

---

## 3. Table Inventory (RAW Schema)

### Dimension Tables (13)

| Table | Rows | Description |
|-------|------|-------------|
| `DIM_SUPPLIER` | 100 | Tiered supplier master (Tier 1-3, risk/quality/delivery scores) |
| `DIM_PART` | 500 | Aerospace parts by ATA chapter, family, criticality |
| `DIM_PLANT` | 5 | Global manufacturing facilities (Hyderabad, Toulouse, Seattle, Singapore, Hamburg) |
| `DIM_WAREHOUSE` | 20 | Storage locations (4 per plant: Raw Material, FG, Spare, WIP) |
| `DIM_WORK_CENTER` | 50 | Production cells (10 types per plant: CNC, Assembly, NDT, etc.) |
| `DIM_CUSTOMER` | 10 | Airlines, MROs, OEMs, Defense (Platinum/Gold/Silver tiers) |
| `DIM_CARRIER` | 5 | Logistics providers (DHL, FedEx, DB Schenker, K+N, Expeditors) |
| `DIM_CALENDAR` | 181 | Date dimension (2026-01-01 to 2026-06-30) |
| `DIM_RAW_MATERIAL` | 5 | Aerospace materials (Titanium, Inconel, Carbon Fiber, Aluminum, Epoxy) |
| `DIM_BOM` | 500 | Bill of materials (parent-child assembly relationships) |
| `DIM_SUPPLIER_PART` | 500 | Supplier-part contracts with pricing and qualification |
| `DIM_CERTIFICATION` | 500 | Part/supplier certifications (FAA PMA, EASA, AS9100D, NADCAP) |
| `DIM_ROUTING` | 1,000 | Manufacturing operations (routing sequences per part) |

### Fact Tables (13)

| Table | Rows | Description |
|-------|------|-------------|
| `FACT_PURCHASE_ORDER` | 500 | PO headers (supplier, plant, dates, value, status) |
| `FACT_PURCHASE_ORDER_LINE` | 2,500 | PO line items (part, qty, price, landed cost) |
| `FACT_PURCHASE_REQUISITION` | 500 | Purchase requests (demand signals) |
| `FACT_SALES_ORDER` | 400 | Customer order headers |
| `FACT_SALES_ORDER_LINE` | 1,600 | Order lines (qty ordered/shipped, backorders) |
| `FACT_SHIPMENT` | 5,000 | Inbound/outbound/transfer shipments with OTD tracking |
| `FACT_INVENTORY` | 500 | Point-in-time stock snapshots (available, reserved, DOI) |
| `FACT_INVENTORY_MOVEMENT` | 10,000 | Stock movements (receipt, issue, transfer, scrap) |
| `FACT_WORK_ORDER` | 1,500 | Production orders (planned/actual, yield, scrap) |
| `FACT_QUALITY_EVENT` | 1,000 | Quality incidents (NCRs, CAPAs, inspections) |
| `FACT_IOT_SENSOR_DATA` | 10,000 | Machine telemetry (temp, vibration, pressure, RPM) |
| `FACT_AOG_EVENT` | 25 | Aircraft On Ground emergencies |
| `FACT_REPAIR_ORDER` | 250 | MRO shop visits |

### Metadata Tables (2)

| Table | Rows | Description |
|-------|------|-------------|
| `META_BUSINESS_GLOSSARY` | 20 | Canonical business term definitions (CDC-enabled) |
| `META_METRIC_DEFINITION` | 24 | Metric formulas, targets, business rules (CDC-enabled) |

---

## 4. Business Glossary (Implemented)

Key terms encoded in `META_BUSINESS_GLOSSARY`:

| Term ID | Term | Target |
|---------|------|--------|
| BG-001 | On-Time Delivery (OTD) | 95% |
| BG-002 | Fill Rate | 98% |
| BG-003 | Days of Inventory (DOI) | 45 days |
| BG-004 | Inventory Turnover | 8 turns/year |
| BG-005 | Supplier Performance Index (SPI) | 80 |
| BG-006 | Critical Supplier | Strategic + Tier 1 + >$10M |
| BG-007 | Revenue At Risk | $0 (minimize) |
| BG-008 | Landed Cost | Price + freight + 3% duties + 2% handling |
| BG-009 | Yield Rate | 97% |
| BG-010 | Defect Rate | <2% |
| BG-011 | Perfect Order Rate | 90% |
| BG-012 | Capacity Utilization | 85% |
| BG-013 | Cash-to-Cash Cycle | 60 days |
| BG-014 | AOG (Aircraft On Ground) | 4-hour response |
| BG-015 | Procurement Spend | Budget adherence |

---

## 5. Metric Catalog (24 Metrics)

### Procurement Domain
| ID | Metric | Formula | Target |
|----|--------|---------|--------|
| MET-001 | OTD Overall | on-time / total * 100 | 95% |
| MET-005 | Supplier Risk Score | Composite 0-100 | ≤50 |
| MET-012 | Supplier OTD | Inbound on-time / total * 100 | 95% |
| MET-014 | Landed Cost | Unit + freight + 5% (duties+handling) | Minimize |
| MET-015 | SPI | Quality×0.3 + Delivery×0.3 + Cost×0.2 + Response×0.2 | 80 |
| MET-019 | Procurement Spend | SUM(PO value) | Budget |

### Inventory Domain
| ID | Metric | Formula | Target |
|----|--------|---------|--------|
| MET-003 | Days of Inventory | ON_HAND / avg daily demand | 45 days |
| MET-004 | Inventory Turnover | Annual COGS / avg inventory | 8 turns |
| MET-016 | Stockout Rate | Zero-stock parts / total | ≤1% |
| MET-017 | Excess Inventory % | Excess value / total value | ≤5% |

### Manufacturing Domain
| ID | Metric | Formula | Target |
|----|--------|---------|--------|
| MET-006 | Production Yield | Produced / (Produced + Scrapped) * 100 | 97% |
| MET-007 | Scrap Rate | Scrapped / Planned * 100 | ≤3% |
| MET-009 | WO Completion Rate | On-time WOs / total completed | 90% |
| MET-023 | Capacity Utilization | Actual hours / available hours | 85% |

### Quality Domain
| ID | Metric | Formula | Target |
|----|--------|---------|--------|
| MET-013 | Defect Rate | Defective / Inspected * 100 | ≤2% |
| MET-020 | COPQ | SUM(COST_OF_QUALITY) | Minimize |

### Logistics & Customer Domain
| ID | Metric | Formula | Target |
|----|--------|---------|--------|
| MET-002 | Fill Rate | Shipped / Ordered * 100 | 98% |
| MET-010 | Freight Cost/Unit | Freight / Weight | ≤$5/kg |
| MET-011 | Carrier OTD | Carrier on-time / total | 90% |
| MET-018 | AOG Response Time | AVG(duration_hours) | ≤4 hrs |
| MET-022 | Perfect Order Rate | Complete+OnTime+NoDamage+Docs | 90% |

### Executive Composites
| ID | Metric | Formula | Target |
|----|--------|---------|--------|
| MET-008 | Revenue at Risk | Value of disrupted orders | $0 |
| MET-021 | Cash-to-Cash Cycle | DIO + DSO - DPO | 60 days |
| MET-024 | SC Health Index | Normalized composite of all KPIs | ≥80 |

---

## 6. Ontology & Derivation Rules

### Derivation Rules (Implemented as ANALYTICS Views)

| Rule | View | Logic |
|------|------|-------|
| DR-01 | `V_DERIVED_SHIPMENT_METRICS` | IS_ON_TIME = ACTUAL_DELIVERY ≤ PROMISED |
| DR-02 | `V_DERIVED_WORK_ORDER_METRICS` | YIELD = Produced / (Produced + Scrapped) × 100 |
| DR-03 | `V_DERIVED_INVENTORY_ALERTS` | NEEDS_REORDER when AVAILABLE < REORDER_POINT |
| DR-04 | `V_DERIVED_INVENTORY_ALERTS` | IS_OVERSTOCKED when AVAILABLE > MAX_STOCK |
| DR-05 | `V_DERIVED_PO_CYCLE_TIME` | Cycle Time = DATEDIFF(ORDER_DATE, RECEIVED_DATE) |
| DR-06 | `V_DERIVED_SUPPLIER_RISK` | High Risk if OTD<85% OR Quality<70 OR FinRisk=High |
| DR-07 | `V_DERIVED_MATERIAL_REQUIREMENTS` | Required Qty = WO Qty × BOM Qty Per Assembly |

### Integrity Constraints (Live Monitoring)

| Constraint | Check | Result |
|-----------|-------|--------|
| IC-01 | PO references inactive supplier | 0 violations |
| IC-02 | SO references inactive customer | 0 violations |
| IC-03 | Negative inventory quantity | 0 violations |
| IC-04 | BOM self-referencing | 2 violations (minor) |
| IC-05 | Shipment dates not chronological | 0 violations |
| IC-06 | WO dates not sequential | 0 violations |
| IC-07 | Quality event references invalid part | 0 violations |

### Disambiguation Matrix (Encoded in Knowledge Base)

| Ambiguous Term | Procurement | Manufacturing | Logistics | Quality | Executive |
|---------------|-------------|---------------|-----------|---------|-----------|
| "delivery performance" | Supplier OTD (MET-012) | WO Completion (MET-009) | Customer OTD (MET-001) | — | MET-001 |
| "cost" | Landed Cost (MET-014) | Production cost | Freight (MET-010) | COPQ (MET-020) | Spend (MET-019) |
| "inventory" | — | — | Available qty | — | DOI (MET-003) |
| "risk" | Supplier Risk (MET-005) | — | — | Defect exposure | Revenue at Risk (MET-008) |

---

## 7. Semantic Views (9 Deployed)

### Domain Views (5)

| Semantic View | Tables | Relationships | VQRs |
|--------------|--------|---------------|------|
| `SV_PROCUREMENT` | DIM_SUPPLIER, DIM_PART, FACT_PURCHASE_ORDER, FACT_PURCHASE_ORDER_LINE | 3 joins | 3 |
| `SV_INVENTORY` | DIM_PART, DIM_PLANT, DIM_WAREHOUSE, FACT_INVENTORY, FACT_INVENTORY_MOVEMENT | 3 joins | 3 |
| `SV_MANUFACTURING` | DIM_PART, DIM_PLANT, DIM_WORK_CENTER, FACT_WORK_ORDER | 3 joins | 3 |
| `SV_QUALITY` | DIM_PART, DIM_SUPPLIER, DIM_PLANT, FACT_QUALITY_EVENT | 3 joins | 3 |
| `SV_SALES` | DIM_CUSTOMER, DIM_PART, FACT_SALES_ORDER, FACT_SALES_ORDER_LINE | 3 joins | 3 |

### Cross-Domain Views (3)

| Semantic View | Purpose | Key Relationships |
|--------------|---------|-------------------|
| `SUPPLIER_QUALITY_PRODUCTION_SV` | Root cause: supplier → quality → production | Supplier↔Quality↔Work Order via PART_ID |
| `ORDER_SHIPMENT_CUSTOMER_SV` | End-to-end fulfillment: order → ship → deliver | Sales↔Shipment↔Carrier via SO_ID, CUSTOMER_ID |
| `PROCUREMENT_INVENTORY_FINANCE_SV` | Working capital: spend → inventory position | PO↔Inventory via PART_ID, PLANT_ID |

### Executive View (1)

| Semantic View | Source | Metrics |
|--------------|--------|---------|
| `EXECUTIVE_SUMMARY_SV` | ANALYTICS.EXECUTIVE_KPI_MONTHLY | OTD, Fill Rate, Spend, Yield, Scrap, Defect Rate, COPQ |

---

## 8. Cortex Search Service

| Property | Value |
|----------|-------|
| **Service** | `AEROSPACE_SUPPLY_CHAIN_AI.SEMANTIC.SUPPLY_CHAIN_KNOWLEDGE_SEARCH` |
| **Status** | ACTIVE (indexing + serving) |
| **Embedding** | snowflake-arctic-embed-m-v1.5 |
| **Refresh** | INCREMENTAL (CDC from 3 source tables) |
| **Target Lag** | 1 hour |
| **Indexed Documents** | 90 |

### Source Documents by Category

| Category | Count | Content |
|----------|-------|---------|
| glossary | 17 | Business term definitions |
| metric | 12 | Metric formulas, targets, rules |
| disambiguation | 4 | Persona-aware term resolution |
| ontology | 5 | Entity types, process flow, derivation rules |
| governance | 2 | One-definition principle, auditability |
| policy | 3 | Approval thresholds, escalation, single-source |
| best_practice | 3 | Safety stock, supplier eval, benchmarks |

---

## 9. Cortex Agent

| Property | Value |
|----------|-------|
| **Agent** | `AEROSPACE_SUPPLY_CHAIN_AI.SEMANTIC.SUPPLY_CHAIN_COPILOT` |
| **Model** | claude-3-5-sonnet |
| **Tools** | 10 (9 Cortex Analyst + 1 Cortex Search) |
| **Governance** | Ontology-governed with disambiguation protocol |

### Tool Routing

| Tool | Type | Semantic View | Domain Keywords |
|------|------|---------------|-----------------|
| `procurement_analyst` | cortex_analyst_text_to_sql | SV_PROCUREMENT | supplier, PO, spend, buyer, contract |
| `inventory_analyst` | cortex_analyst_text_to_sql | SV_INVENTORY | stock, warehouse, DOI, reorder, safety |
| `manufacturing_analyst` | cortex_analyst_text_to_sql | SV_MANUFACTURING | yield, work order, scrap, capacity |
| `quality_analyst` | cortex_analyst_text_to_sql | SV_QUALITY | defect, NCR, CAPA, root cause |
| `sales_analyst` | cortex_analyst_text_to_sql | SV_SALES | customer, sales, fill rate, revenue |
| `supplier_quality_production_analyst` | cortex_analyst_text_to_sql | SUPPLIER_QUALITY_PRODUCTION_SV | supplier causing quality/scrap |
| `order_shipment_customer_analyst` | cortex_analyst_text_to_sql | ORDER_SHIPMENT_CUSTOMER_SV | perfect order, carrier OTD by customer |
| `procurement_inventory_finance_analyst` | cortex_analyst_text_to_sql | PROCUREMENT_INVENTORY_FINANCE_SV | working capital, spend vs inventory |
| `executive_dashboard` | cortex_analyst_text_to_sql | EXECUTIVE_SUMMARY_SV | KPI dashboard, monthly trends, targets |
| `supply_chain_knowledge` | cortex_search | SUPPLY_CHAIN_KNOWLEDGE_SEARCH | definitions, formulas, policies |

### Agent Instructions Summary
1. **One Definition Principle** — every concept has one canonical definition
2. **Disambiguation Protocol** — ambiguous terms resolved via persona context
3. **Derivation Rules** — exact formulas for OTD, Yield, Fill Rate, Risk, etc.
4. **Auditability** — always explain data source and formula used
5. **Targets** — OTD=95%, Fill=98%, Yield=97%, Defect<2%, DOI=45, Turns=8

---

## 10. Alerting & Monitoring

### Live Metric Status (V_METRIC_ALERTS)

| Metric | Actual | Target | Status |
|--------|--------|--------|--------|
| Stockout Rate | 0.00% | ≤1% | 🟢 GREEN |
| Production Yield | 95.38% | 97% | 🟡 YELLOW |
| Scrap Rate | 3.35% | ≤3% | 🟡 YELLOW |
| OTD Overall | 36.25% | 95% | 🔴 RED |
| Fill Rate | 82.26% | 98% | 🔴 RED |
| Defect Rate | 4.42% | ≤2% | 🔴 RED |
| WO Completion | 36.74% | 90% | 🔴 RED |

*(RED metrics expected with random seed data — would be realistic in production)*

### Threshold Configuration (16 metrics)

| Direction | Logic |
|-----------|-------|
| HIGHER_BETTER | GREEN if ≥ target, YELLOW if within 5% below, RED otherwise |
| LOWER_BETTER | GREEN if ≤ target, YELLOW if within tolerance, RED if exceeds |
| RANGE | GREEN if within optimal range, YELLOW if approaching limits |

---

## 11. Validation Test Results

### Agent Query Test: "What is our current production yield and how does it compare to target?"

**Result:**
- Correctly routed to `manufacturing_analyst`
- Used canonical formula: Produced / (Produced + Scrapped) × 100
- Returned: **95.9% actual vs 97% target** (1.1pp gap)
- Cited metric ID, explained formula, offered drill-down suggestions

### Agent Query Test: "What is our total procurement spend this year?"

**Result:**
- Correctly routed to `procurement_analyst`
- Generated correct SQL: `SUM(TOTAL_VALUE) WHERE YEAR = 2026`
- Returned: **$586.6M across 500 POs**

---

## 12. Object Summary

| Category | Count | Objects |
|----------|-------|---------|
| Database | 1 | AEROSPACE_SUPPLY_CHAIN_AI |
| Schemas | 3 | RAW, SEMANTIC, ANALYTICS |
| Base Tables | 31 | 13 DIM + 13 FACT + 2 META + 3 supporting |
| Analytics Views | 9 | 7 derivation + 2 governance |
| Semantic Views | 9 | 5 domain + 3 cross-domain + 1 executive |
| Cortex Search Services | 1 | SUPPLY_CHAIN_KNOWLEDGE_SEARCH |
| Cortex Agents | 1 | SUPPLY_CHAIN_COPILOT |
| Knowledge Documents | 90 | Indexed by Arctic Embed |
| Defined Metrics | 24 | With thresholds and RAG alerting |
| Verified Queries | 20+ | Across all semantic views |
| Total Data Rows | 36,000+ | Realistic aerospace supply chain data |

---

## 13. Reference Data (Key Entities)

### Plants
| ID | Name | Location | Region |
|----|------|----------|--------|
| PLNT001 | Hyderabad Aerospace Hub | Hyderabad, India | Asia Pacific |
| PLNT002 | Toulouse Assembly Center | Toulouse, France | Europe |
| PLNT003 | Seattle Manufacturing Plant | Seattle, USA | North America |
| PLNT004 | Singapore Precision Works | Singapore | Asia Pacific |
| PLNT005 | Hamburg Composites Facility | Hamburg, Germany | Europe |

### Customers (Sample)
| ID | Name | Type | Tier |
|----|------|------|------|
| CUST00001 | Airbus SAS | OEM | Platinum |
| CUST00002 | Boeing Commercial | OEM | Platinum |
| CUST00003 | Lufthansa Technik | MRO | Gold |
| CUST00006 | Lockheed Martin Aeronautics | Defense | Platinum |
| CUST00009 | Rolls-Royce Civil Aerospace | OEM | Gold |

### Part Families & ATA Chapters
| Family | Code | ATA Chapters | Example Parts |
|--------|------|-------------|---------------|
| Engine Components | ENG | 70-80 | Turbine Blade, Fan Blade, Compressor |
| Airframe Components | AIR | 51-57 | Wing Rib, Wing Spar, Fuselage Frame |
| Landing Systems | LDG | 32 | Landing Gear Assembly, Brake Assembly |
| Hydraulic Systems | HYD | 29 | Hydraulic Actuator, Hydraulic Pump |
| Flight Controls | FLT | 27 | Control Surface, Flap Track, Spoiler |
| Avionics | AVN | 31, 34 | Flight Control Computer, Navigation Sensor |
| Electrical Systems | ELEC | 24 | Electrical Harness, Starter Generator |

### Carriers
| ID | Name | Type | Coverage |
|----|------|------|----------|
| CAR001 | DHL Aviation Logistics | Air Freight | Global |
| CAR002 | FedEx Custom Critical | Air/Ground Express | Global |
| CAR003 | DB Schenker Aerospace | Multimodal | Europe/Asia |
| CAR004 | Kuehne+Nagel Aerospace | Ocean/Air | Global |
| CAR005 | Expeditors AOG Service | AOG Express | NA/Europe |

---

## 14. Governance Framework

### Principles Enforced
1. **One Definition** — every business concept has exactly one canonical definition
2. **One Formula** — every metric has exactly one immutable calculation
3. **Context Resolution** — ambiguous terms require persona clarification
4. **Auditability** — every answer traces to source tables and join paths
5. **Consistency** — same question returns same number regardless of asker

### Data Quality Monitoring
- `V_INTEGRITY_CONSTRAINT_VIOLATIONS` — real-time constraint checking
- `V_ONTOLOGY_HEALTH_SUMMARY` — aggregated violation counts
- `V_METRIC_ALERTS` — live RAG status across 16 thresholds

---

## 15. Specs Implemented

| Spec File | Status | What Was Built |
|-----------|--------|----------------|
| 01_PROJECT_OVERVIEW | ✅ Complete | Database, schemas, architecture |
| 02_BUSINESS_GLOSSARY | ✅ Complete | 20 glossary terms in META table + KB |
| 03_DOMAIN_MODEL | ✅ Complete | Entity relationships encoded in semantic views |
| 04_ER_MODEL | ✅ Complete | 28 tables with FK relationships |
| 05_DATA_DICTIONARY | ✅ Complete | All columns with types per spec |
| 06_DDL_SPEC | ✅ Complete | All CREATE TABLE statements executed |
| 07_MASTER_REFERENCE_DATA | ✅ Complete | Plants, carriers, customers, materials seeded |
| 08_ONTOLOGY_MODEL | ✅ Complete | Derivation rules, integrity constraints, disambiguation |
| 10_SEMANTIC_VIEWS | ✅ Complete | 9 semantic views deployed |
| 11_METRIC_CATALOG | ✅ Complete | 24 metrics with thresholds and RAG alerting |
| 12_CORTEX_SEARCH | ✅ Complete | CDC-backed search with 90 documents |
| 13_AGENT_ARCHITECTURE | ✅ Complete | 10-tool agent with ontology governance |

---

*Built with Snowflake CoCo CLI | Hackathon: Supply Chain Ontology & Governed Conversational Analytics*
