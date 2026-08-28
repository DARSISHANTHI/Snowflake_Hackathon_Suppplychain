# 08 - Ontology Model

## Aerospace Supply Chain — Formal Ontology Specification

---

## Purpose

This document defines the formal ontology for the Aerospace Supply Chain platform — a structured representation of entities, their properties, relationships, constraints, and business rules that enables consistent, trustworthy conversational analytics. The ontology bridges the gap between physical data structures (tables/columns) and business meaning (concepts/metrics), ensuring that any natural language question resolves to the same governed SQL regardless of who asks.

---

## Ontology Layers

```
┌─────────────────────────────────────────────────────────────────────┐
│ LAYER 4: CONVERSATIONAL INTERFACE                                    │
│ Natural language → Governed SQL via Cortex Analyst/Agents           │
├─────────────────────────────────────────────────────────────────────┤
│ LAYER 3: SEMANTIC LAYER (Semantic Views)                            │
│ Business names, metric formulas, join logic, access control         │
├─────────────────────────────────────────────────────────────────────┤
│ LAYER 2: ONTOLOGY MODEL (This Document)                             │
│ Entities, relationships, hierarchies, rules, disambiguation        │
├─────────────────────────────────────────────────────────────────────┤
│ LAYER 1: PHYSICAL DATA MODEL (Star Schema)                          │
│ Tables, columns, keys, indexes, clustering                          │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Core Concepts

### Entity Types

The ontology classifies all business entities into three categories:

| Category | Description | Entities |
|----------|-------------|----------|
| **Actor** | Organizations or systems that perform actions | Supplier, Customer, Carrier, Plant, Work Center |
| **Object** | Physical items that are acted upon | Part, Raw Material, BOM, Inventory |
| **Event** | Business occurrences with temporal context | Purchase Order, Sales Order, Shipment, Work Order, Quality Event, AOG Event, Repair Order |

### Property Types

| Type | Description | Examples |
|------|-------------|----------|
| **Identifier** | Uniquely identifies an entity instance | SUPPLIER_ID, PART_ID, PO_ID |
| **Descriptor** | Describes characteristics of an entity | SUPPLIER_NAME, PART_FAMILY, CARRIER_TYPE |
| **Measure** | Quantifiable values for analysis | QUANTITY, TOTAL_VALUE, FREIGHT_COST |
| **Temporal** | Time-bound properties | ORDER_DATE, CREATED_TIMESTAMP |
| **Status** | Current state of an entity | STATUS, IS_ACTIVE, LIFECYCLE_STATUS |
| **Classification** | Categorization for grouping | TIER_LEVEL, ATA_CHAPTER, CRITICALITY |

---

## Entity Definitions

### Actor: Supplier

```yaml
entity: Supplier
type: Actor
definition: >
  An organization that provides parts, materials, or services to the 
  aerospace manufacturer. Classified by tier level (1-3) indicating 
  proximity in the supply chain.
table: DIM_SUPPLIER
identifier: SUPPLIER_ID
display_name: SUPPLIER_NAME
classifications:
  - TIER_LEVEL: [1, 2, 3]
  - CATEGORY: [Strategic, Preferred, Approved, Conditional]
  - SUPPLIER_TYPE: [manufacturer, distributor, service_provider]
measures:
  - RISK_SCORE: "0-100 composite risk (higher = riskier)"
  - QUALITY_RATING: "0-100 quality performance"
  - ON_TIME_DELIVERY_PCT: "Historical OTD percentage"
  - ANNUAL_REVENUE: "Supplier's annual revenue in USD"
relationships:
  - supplies: Part (M:N via DIM_SUPPLIER_PART)
  - receives: Purchase Order (1:M)
  - linked_to: Quality Event (1:M)
  - ships_via: Shipment (1:M)
business_rules:
  - "Critical if CATEGORY='Strategic' AND TIER_LEVEL=1 AND spend > $10M"
  - "High Risk if OTD < 85% OR QUALITY_RATING < 70"
  - "SCD Type 2 — historical versions maintained"
```

### Actor: Customer

```yaml
entity: Customer
type: Actor
definition: >
  An organization that purchases aerospace parts or services. Includes 
  airlines, MRO providers, and defense organizations.
table: DIM_CUSTOMER
identifier: CUSTOMER_ID
display_name: CUSTOMER_NAME
classifications:
  - CUSTOMER_TYPE: [airline, MRO, defense, OEM, distributor]
  - REVENUE_TIER: [Platinum, Gold, Silver, Bronze]
  - REGION: [North America, Europe, Asia Pacific, Middle East, Other]
measures:
  - ANNUAL_REVENUE: "Customer annual spend in USD"
  - CREDIT_LIMIT: "Approved credit limit"
relationships:
  - places: Sales Order (1:M)
  - receives: Shipment (1:M)
  - experiences: AOG Event (1:M)
  - owns: Repair Order (1:M)
```

### Actor: Carrier

```yaml
entity: Carrier
type: Actor
definition: >
  A logistics provider responsible for physical transportation of goods 
  between locations.
table: DIM_CARRIER
identifier: CARRIER_ID
display_name: CARRIER_NAME
classifications:
  - CARRIER_TYPE: [air_freight, ocean, ground, express, multimodal]
measures:
  - ON_TIME_PCT: "Historical on-time delivery percentage"
  - COST_PER_KG: "Average freight cost per kilogram"
relationships:
  - transports: Shipment (1:M)
```

### Actor: Plant

```yaml
entity: Plant
type: Actor
definition: >
  A physical manufacturing or distribution facility where production, 
  storage, or MRO operations occur.
table: DIM_PLANT
identifier: PLANT_ID
display_name: PLANT_NAME
classifications:
  - PLANT_TYPE: [assembly, component_manufacturing, MRO, warehouse, distribution]
  - REGION: [North America, Europe, Asia Pacific, Other]
measures:
  - CAPACITY_UNITS: "Production capacity"
  - OPERATING_SHIFTS: "Daily shift count"
  - SQUARE_METERS: "Floor area"
relationships:
  - contains: Warehouse (1:M)
  - operates: Work Center (1:M)
  - receives: Purchase Order (1:M)
  - fulfills: Sales Order (1:M)
  - executes: Work Order (1:M)
  - stores: Inventory (1:M)
  - origin_of: Shipment (1:M, role: origin)
  - destination_of: Shipment (1:M, role: destination)
```

### Actor: Work Center

```yaml
entity: Work Center
type: Actor
definition: >
  A specific machine, station, or production cell within a plant where 
  manufacturing operations are performed.
table: DIM_WORK_CENTER
identifier: WORK_CENTER_ID
display_name: WORK_CENTER_NAME
classifications:
  - MACHINE_TYPE: [CNC, assembly, inspection, testing, heat_treat, coating]
measures:
  - CAPACITY_HOURS_DAY: "Available hours per day"
  - HOURLY_RATE: "Operating cost per hour"
relationships:
  - belongs_to: Plant (M:1)
  - performs: Work Order (1:M)
  - defined_in: Routing (1:M)
  - monitored_by: IoT Sensor (1:M)
```

### Object: Part

```yaml
entity: Part
type: Object
definition: >
  An aerospace component or assembly identified by engineering part number, 
  classified by ATA chapter, and tracked through its lifecycle.
table: DIM_PART
identifier: PART_ID
display_name: PART_NAME
classifications:
  - PART_FAMILY: [Engine, Airframe, Avionics, Landing Gear, Interior, ...]
  - ATA_CHAPTER: [21-Air Conditioning, 24-Electrical, 27-Flight Controls, ...]
  - CRITICALITY: [critical, major, minor]
  - MAKE_BUY_CODE: [Make, Buy]
  - LIFECYCLE_STATUS: [Active, Obsolete, Prototype, End_of_Life]
measures:
  - STANDARD_COST: "Standard unit cost in USD"
  - WEIGHT_KG: "Weight in kilograms"
  - LEAD_TIME_DAYS: "Standard procurement lead time"
relationships:
  - supplied_by: Supplier (M:N via DIM_SUPPLIER_PART)
  - assembled_from: Part (M:M via DIM_BOM, self-referencing)
  - stocked_in: Inventory (1:M)
  - ordered_in: PO Line, SO Line (1:M)
  - produced_by: Work Order (1:M)
  - shipped_in: Shipment (1:M)
  - certified_by: Certification (1:M)
  - routed_through: Routing (1:M)
business_rules:
  - "ITAR_CONTROLLED parts require export license for international shipment"
  - "CRITICAL parts require dual-source supplier strategy"
  - "OBSOLETE parts cannot appear on new Purchase Orders"
```

### Object: Raw Material

```yaml
entity: Raw Material
type: Object
definition: >
  Base material used in manufacturing aerospace parts. Tracked for 
  specification compliance, shelf life, and export control.
table: DIM_RAW_MATERIAL
identifier: MATERIAL_ID
display_name: MATERIAL_NAME
classifications:
  - MATERIAL_TYPE: [titanium, aluminum, composite, steel, nickel_alloy, polymer]
measures:
  - STANDARD_COST: "Cost per unit of measure"
  - DENSITY: "Material density"
  - SHELF_LIFE_DAYS: "Maximum storage duration"
```

### Object: BOM (Bill of Materials)

```yaml
entity: BOM
type: Object
definition: >
  Defines the parent-child assembly structure specifying which parts 
  compose a higher-level assembly and in what quantities.
table: DIM_BOM
identifier: BOM_ID
properties:
  - PARENT_PART_ID: "Assembly being built"
  - CHILD_PART_ID: "Component consumed"
  - QUANTITY_PER: "Units of child per one parent"
  - BOM_LEVEL: "Depth in assembly hierarchy"
  - POSITION_NUMBER: "Assembly position sequence"
relationships:
  - parent: Part (M:1)
  - child: Part (M:1)
business_rules:
  - "BOM is acyclic — a part cannot be its own ancestor"
  - "EFFECTIVE_DATE/EXPIRY_DATE control time-valid configurations"
  - "QUANTITY_PER must be > 0"
```

### Event: Purchase Order

```yaml
entity: Purchase Order
type: Event
definition: >
  A formal commitment to buy parts/materials from a supplier, with 
  agreed price, quantity, and delivery date.
table: FACT_PURCHASE_ORDER (header) + FACT_PURCHASE_ORDER_LINE (detail)
identifier: PO_ID
temporal:
  - ORDER_DATE: "When PO was placed"
  - PROMISED_DATE: "When supplier commits to deliver"
  - RECEIVED_DATE: "When goods were actually received"
statuses: [Open, Partial, Closed, Cancelled]
measures:
  - TOTAL_VALUE: "Total PO value in USD"
relationships:
  - placed_with: Supplier (M:1)
  - delivered_to: Plant (M:1)
  - contains: PO Line (1:M)
  - fulfilled_by: Shipment (1:M)
derived_metrics:
  - cycle_time: "RECEIVED_DATE - ORDER_DATE"
  - on_time: "RECEIVED_DATE <= PROMISED_DATE"
```

### Event: Sales Order

```yaml
entity: Sales Order
type: Event
definition: >
  A customer order for aerospace parts or services, driving demand 
  through the supply chain.
table: FACT_SALES_ORDER (header) + FACT_SALES_ORDER_LINE (detail)
identifier: SO_ID
temporal:
  - ORDER_DATE: "When customer placed the order"
  - REQUESTED_DATE: "Customer's desired delivery date"
  - PROMISED_DATE: "Date committed to customer"
  - SHIPPED_DATE: "Actual ship date"
statuses: [Open, In Production, Shipped, Delivered, Closed, Cancelled]
measures:
  - TOTAL_VALUE: "Total order value in USD"
relationships:
  - ordered_by: Customer (M:1)
  - fulfilled_from: Plant (M:1)
  - contains: SO Line (1:M)
  - shipped_via: Shipment (1:M)
derived_metrics:
  - fill_rate: "SUM(qty_shipped) / SUM(qty_ordered) * 100"
  - on_time: "SHIPPED_DATE <= PROMISED_DATE"
```

### Event: Shipment

```yaml
entity: Shipment
type: Event
definition: >
  Physical movement of goods between locations — inbound from suppliers, 
  outbound to customers, or inter-plant transfers.
table: FACT_SHIPMENT
identifier: SHIPMENT_ID
classifications:
  - SHIPMENT_TYPE: [inbound, outbound, inter_plant]
temporal:
  - SHIP_DATE: "Departure date"
  - PROMISED_DELIVERY_DATE: "Expected arrival"
  - ACTUAL_DELIVERY_DATE: "Actual arrival"
statuses: [Planned, In Transit, Delivered, Delayed, Exception]
measures:
  - QUANTITY: "Units shipped"
  - FREIGHT_COST: "Transportation cost"
  - WEIGHT_KG: "Total weight"
relationships:
  - from_supplier: Supplier (M:1, inbound)
  - to_customer: Customer (M:1, outbound)
  - origin: Plant (M:1)
  - destination: Plant (M:1)
  - transported_by: Carrier (M:1)
  - contains: Part (M:1)
  - fulfills_po: Purchase Order (M:1)
  - fulfills_so: Sales Order (M:1)
derived_metrics:
  - is_on_time: "ACTUAL_DELIVERY_DATE <= PROMISED_DELIVERY_DATE"
  - transit_days: "ACTUAL_DELIVERY_DATE - SHIP_DATE"
```

### Event: Work Order

```yaml
entity: Work Order
type: Event
definition: >
  A production order to manufacture, repair, or rework a specific quantity 
  of a part at a plant.
table: FACT_WORK_ORDER
identifier: WORK_ORDER_ID
classifications:
  - WORK_ORDER_TYPE: [production, rework, repair, prototype]
temporal:
  - PLANNED_START_DATE / PLANNED_END_DATE: "Scheduled window"
  - ACTUAL_START_DATE / ACTUAL_END_DATE: "Actual execution"
statuses: [Released, In Progress, Completed, Closed, Cancelled]
measures:
  - QUANTITY_ORDERED: "Planned production quantity"
  - QUANTITY_COMPLETED: "Good units produced"
  - QUANTITY_SCRAPPED: "Units scrapped"
  - YIELD_RATE: "First-pass yield percentage"
  - TOTAL_COST: "Total production cost"
relationships:
  - produces: Part (M:1)
  - executed_at: Plant (M:1)
  - uses: Work Center (M:1)
  - generates: Quality Event (1:M)
derived_metrics:
  - yield: "qty_completed / qty_ordered * 100"
  - scrap_rate: "qty_scrapped / qty_ordered * 100"
  - schedule_adherence: "ACTUAL_END_DATE <= PLANNED_END_DATE"
```

### Event: Quality Event

```yaml
entity: Quality Event
type: Event
definition: >
  A quality-related incident — inspection result, non-conformance report 
  (NCR), or corrective action (CAPA).
table: FACT_QUALITY_EVENT
identifier: QUALITY_EVENT_ID
classifications:
  - EVENT_TYPE: [inspection, NCR, CAPA, audit, customer_complaint]
  - SEVERITY: [critical, major, minor]
  - DISPOSITION: [scrap, rework, use_as_is, return_to_supplier]
temporal:
  - EVENT_DATE: "When event was identified"
  - RESOLUTION_DATE: "When event was resolved"
measures:
  - QUANTITY_INSPECTED: "Total inspected"
  - QUANTITY_DEFECTIVE: "Total defective"
  - COST_OF_QUALITY: "Financial impact"
relationships:
  - affects: Part (M:1)
  - attributed_to: Supplier (M:1)
  - occurred_at: Plant (M:1)
  - linked_to: Work Order (M:1)
derived_metrics:
  - defect_rate: "qty_defective / qty_inspected * 100"
  - resolution_days: "RESOLUTION_DATE - EVENT_DATE"
```

### Event: AOG Event

```yaml
entity: AOG Event
type: Event
definition: >
  Aircraft On Ground — highest priority supply chain event where an 
  aircraft cannot fly due to a missing or failed critical part.
table: FACT_AOG_EVENT
identifier: AOG_ID
classifications:
  - SEVERITY_CODE: [AOG_Critical, AOG_Urgent, AOG_Standard]
temporal:
  - EVENT_DATE: "When AOG was declared"
  - RESOLUTION_DATE: "When aircraft returned to service"
measures:
  - DURATION_HOURS: "Total grounding duration"
  - REVENUE_IMPACT: "Financial impact of grounding"
relationships:
  - affects: Customer (M:1)
  - caused_by: Part (M:1)
business_rules:
  - "Must respond within 4 hours"
  - "Triggers emergency procurement bypass"
  - "Escalates to executive if duration > 24 hours"
```

### Event: Repair Order

```yaml
entity: Repair Order
type: Event
definition: >
  MRO work order for component overhaul, repair, or modification. 
  Tracks engine/component through shop visit lifecycle.
table: FACT_REPAIR_ORDER
identifier: REPAIR_ORDER_ID
classifications:
  - REPAIR_TYPE: [overhaul, repair, modification, inspection]
temporal:
  - RECEIVED_DATE: "When part entered shop"
  - RELEASED_DATE: "When part was serviceable"
measures:
  - REPAIR_COST: "Total repair cost"
  - TURNAROUND_TIME_DAYS: "Shop visit duration"
relationships:
  - repairs: Part (M:1)
  - owned_by: Customer (M:1)
derived_metrics:
  - tat: "RELEASED_DATE - RECEIVED_DATE"
```

---

## Relationship Ontology

### Relationship Types

| Relationship | From Entity | To Entity | Cardinality | Semantic Meaning |
|-------------|-------------|-----------|-------------|------------------|
| supplies | Supplier | Part | M:N | Supplier provides part under contract |
| orders_from | Purchase Order | Supplier | M:1 | Company orders from supplier |
| orders_to | Sales Order | Customer | M:1 | Customer orders from company |
| ships_via | Shipment | Carrier | M:1 | Goods transported by carrier |
| stored_at | Inventory | Plant + Warehouse | M:1 | Stock held at location |
| produced_at | Work Order | Plant | M:1 | Manufacturing executed at facility |
| assembled_from | Part (parent) | Part (child) | M:M | Assembly composition |
| triggers | AOG Event | Emergency PO | 1:1 | AOG initiates procurement |
| causes | Quality Event | Disposition | 1:1 | Defect leads to action |
| monitored_by | Work Center | IoT Sensor | 1:M | Equipment condition tracking |

### Temporal Relationships (Process Flow)

```
Purchase Requisition ──triggers──▶ Purchase Order ──fulfilled_by──▶ Shipment (inbound)
                                        │
                                        ▼
                                  Goods Receipt ──updates──▶ Inventory
                                        │
                                        ▼
Sales Order ──triggers──▶ Work Order ──consumes──▶ Inventory
     │                        │
     │                        ▼
     │                  Quality Event
     │                        │
     ▼                        ▼
Shipment (outbound) ◀──picks_from── Inventory
     │
     ▼
Delivery ──confirms──▶ Sales Order (Closed)
```

---

## Ontology Constraints

### Integrity Constraints

| Constraint | Rule | Enforcement |
|-----------|------|-------------|
| IC-01 | Every PO must reference an active supplier | SUPPLIER.IS_ACTIVE = TRUE |
| IC-02 | Every SO must reference an active customer | CUSTOMER.IS_ACTIVE = TRUE |
| IC-03 | Inventory qty cannot be negative | ON_HAND_QTY >= 0 |
| IC-04 | BOM cannot be self-referencing at same level | PARENT_PART_ID ≠ CHILD_PART_ID |
| IC-05 | Shipment dates must be chronological | SHIP_DATE <= ACTUAL_DELIVERY_DATE |
| IC-06 | Work order planned dates must be sequential | PLANNED_START_DATE <= PLANNED_END_DATE |
| IC-07 | Quality event must link to valid part | PART_ID exists in DIM_PART |
| IC-08 | ITAR parts cannot ship to embargoed countries | Export control validation |

### Derivation Rules

| Rule | Input | Output | Formula |
|------|-------|--------|---------|
| DR-01 | Shipment dates | IS_ON_TIME | `ACTUAL_DELIVERY_DATE <= PROMISED_DELIVERY_DATE` |
| DR-02 | Work Order quantities | YIELD_RATE | `QUANTITY_COMPLETED / QUANTITY_ORDERED * 100` |
| DR-03 | Inventory position | Reorder trigger | `AVAILABLE_QTY < REORDER_POINT` |
| DR-04 | Inventory position | Overstock flag | `AVAILABLE_QTY > MAX_STOCK` |
| DR-05 | PO dates | Cycle time | `DATEDIFF('day', ORDER_DATE, RECEIVED_DATE)` |
| DR-06 | Supplier metrics | Risk classification | `OTD<85 OR Quality<70 → High Risk` |
| DR-07 | BOM + Work Order | Material requirements | `WO.QUANTITY * BOM.QUANTITY_PER` |

---

## Semantic Disambiguation Matrix

This matrix defines how ambiguous business terms resolve to specific metrics based on the requesting persona's context:

### Term: "Delivery Performance"

| Persona | Resolves To | Metric | Source |
|---------|-------------|--------|--------|
| Procurement | Supplier on-time delivery | MET-012 | FACT_SHIPMENT (inbound) |
| Logistics | Customer shipment OTD | MET-001 | FACT_SHIPMENT (outbound) |
| Manufacturing | Work order schedule adherence | MET-009 | FACT_WORK_ORDER |
| Executive | Composite OTD (customer-facing) | MET-001 | FACT_SHIPMENT |

### Term: "Cost"

| Persona | Resolves To | Metric | Source |
|---------|-------------|--------|--------|
| Procurement | Landed cost per part | MET-014 | FACT_PO_LINE + FACT_SHIPMENT |
| Logistics | Freight cost per unit | MET-010 | FACT_SHIPMENT |
| Manufacturing | Production cost per unit | — | FACT_WORK_ORDER.TOTAL_COST / QTY |
| Quality | Cost of poor quality | — | FACT_QUALITY_EVENT.COST_OF_QUALITY |
| Finance | Total procurement spend | — | FACT_PURCHASE_ORDER.TOTAL_VALUE |

### Term: "Inventory"

| Persona | Resolves To | Metric | Source |
|---------|-------------|--------|--------|
| Planning | Days of inventory supply | MET-003 | FACT_INVENTORY |
| Finance | Inventory valuation ($) | — | FACT_INVENTORY.TOTAL_VALUE |
| Logistics | In-transit quantity | — | FACT_INVENTORY.IN_TRANSIT_QTY |
| Manufacturing | Available for production | — | FACT_INVENTORY.AVAILABLE_QTY |

### Term: "Risk"

| Persona | Resolves To | Metric | Source |
|---------|-------------|--------|--------|
| Procurement | Supplier risk score | MET-005 | DIM_SUPPLIER |
| Executive | Revenue at risk | MET-008 | FACT_SALES_ORDER + FACT_SHIPMENT |
| Planning | Stockout risk (parts below reorder) | MET-015 | FACT_INVENTORY |
| Quality | Critical defect exposure | — | FACT_QUALITY_EVENT (severity=critical) |

---

## Ontology-to-Semantic View Mapping

Each semantic view encodes a subset of the ontology for a specific analytical domain:

| Semantic View | Ontology Scope | Entities Covered | Key Metrics |
|--------------|----------------|------------------|-------------|
| Supply Chain Analytics | Full cross-domain | All entities | OTD, Fill Rate, DOI, Landed Cost, Yield |
| Supplier Performance | Procurement domain | Supplier, PO, Quality, Shipment | Supplier OTD, SPI, Risk Score |
| Inventory Health | Planning domain | Inventory, Part, Plant, Warehouse | DOI, Turnover, Stockout Rate |
| Order Fulfillment | Logistics domain | SO, Shipment, Customer, Carrier | Customer OTD, Fill Rate, Freight Cost |
| Manufacturing Excellence | Production domain | Work Order, Quality, Work Center, IoT | Yield, Scrap Rate, Capacity Utilization |

---

## Governance Principles

| # | Principle | Implementation |
|---|-----------|---------------|
| 1 | **One Definition** | Every business concept has exactly one canonical definition in META_BUSINESS_GLOSSARY |
| 2 | **One Formula** | Every metric has exactly one calculation formula in META_METRIC_DEFINITION |
| 3 | **Context Resolution** | Ambiguous terms resolve via persona context, never by guessing |
| 4 | **Auditability** | Every answer traces back to source tables, join paths, and filter conditions |
| 5 | **Consistency** | Same question from different personas returns same number (or explicitly different metric with explanation) |
| 6 | **Freshness** | Temporal grain and refresh frequency documented per entity |
| 7 | **Access Control** | Semantic views enforce row-level security by persona/role |
| 8 | **Extensibility** | New entities/metrics added without breaking existing definitions |

---

## Ontology Evolution Process

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  Propose     │────▶│  Review      │────▶│  Approve     │────▶│  Deploy      │
│  New Term/   │     │  Against     │     │  By Domain   │     │  To Semantic │
│  Metric      │     │  Ontology    │     │  Owner       │     │  Views       │
└──────────────┘     └──────────────┘     └──────────────┘     └──────────────┘
                            │                                          │
                            ▼                                          ▼
                     ┌──────────────┐                          ┌──────────────┐
                     │  Check for   │                          │  Update META │
                     │  Conflicts & │                          │  tables and  │
                     │  Ambiguity   │                          │  Glossary    │
                     └──────────────┘                          └──────────────┘
```

| Step | Action | Owner |
|------|--------|-------|
| 1 | Submit new term/metric with definition and formula | Any user |
| 2 | Validate against existing ontology for conflicts | Data Governance |
| 3 | Check disambiguation rules — does this create ambiguity? | Data Governance |
| 4 | Domain owner approval | Domain SME |
| 5 | Add to META_BUSINESS_GLOSSARY / META_METRIC_DEFINITION | Platform Team |
| 6 | Encode in relevant semantic view(s) | Platform Team |
| 7 | Test with sample NL queries across personas | QA |
| 8 | Deploy to production | DevOps |
