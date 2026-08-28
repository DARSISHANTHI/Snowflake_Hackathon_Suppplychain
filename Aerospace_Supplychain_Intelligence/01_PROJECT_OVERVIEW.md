# 01 - Project Overview

## Snowflake CoCo CLI Hackathon

### Supply Chain Ontology and Governed Conversational Analytics

---

## Challenge Statement

Supply chain data is scattered across ERP, logistics, supplier, and IoT systems with inconsistent definitions — the same question yields different answers across teams. Build an industry ontology (a business entity and relationship model) expressed as governed semantic views, so that a natural language layer returns consistent, trustworthy answers grounded in shared definitions and metrics.

---

## Objectives

1. **Define the Supply Chain Ontology** — Core entities, relationships, hierarchies, and canonical metrics (on-time delivery, fill rate, days of inventory, landed cost)
2. **Encode as Semantic Views** — Business meaning (not raw column names) drives answers
3. **Layer Governed Conversational Analytics** — Any team asks cross-domain questions and gets one consistent answer
4. **Demonstrate Consistency Across Personas** — The same metric resolves identically for Planning, Procurement, and Logistics

---

## Ontology: Entity Relationship Model

```
┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│   SUPPLIER   │────────▶│     PART     │◀────────│  RAW MATERIAL│
└──────────────┘         └──────────────┘         └──────────────┘
       │                        │
       │                        ▼
       │                 ┌──────────────┐         ┌──────────────┐
       │                 │     BOM      │────────▶│  WORK CENTER │
       │                 └──────────────┘         └──────────────┘
       │                        │                        │
       ▼                        ▼                        ▼
┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│   PURCHASE   │────────▶│    PLANT     │◀────────│  WORK ORDER  │
│    ORDER     │         └──────────────┘         └──────────────┘
└──────────────┘                │
       │                        ▼
       │                 ┌──────────────┐         ┌──────────────┐
       │                 │  WAREHOUSE   │────────▶│  INVENTORY   │
       │                 └──────────────┘         └──────────────┘
       ▼                        │
┌──────────────┐                ▼
│   SHIPMENT   │◀───────┌──────────────┐         ┌──────────────┐
└──────────────┘        │   CARRIER    │         │   CUSTOMER   │
       │                └──────────────┘         └──────────────┘
       │                                                ▲
       └────────────────────────────────────────────────┘
                         SALES ORDER
```

---

## Core Entities

| Entity | Table | Description |
|--------|-------|-------------|
| Supplier | DIM_SUPPLIER | Tiered suppliers providing parts and materials |
| Part | DIM_PART | Aerospace parts and components (ATA classified) |
| Plant | DIM_PLANT | Manufacturing facilities and MRO sites |
| Warehouse | DIM_WAREHOUSE | Storage locations within plants |
| Customer | DIM_CUSTOMER | Airlines, MROs, and defense organizations |
| Carrier | DIM_CARRIER | Logistics providers for shipments |
| Work Center | DIM_WORK_CENTER | Manufacturing operation stations |
| Raw Material | DIM_RAW_MATERIAL | Base materials (titanium, composites, etc.) |
| BOM | DIM_BOM | Bill of materials defining assembly structures |

---

## Key Relationships

| From | To | Relationship | Cardinality |
|------|----|-------------|-------------|
| Supplier | Part | Supplies | M:N (via DIM_SUPPLIER_PART) |
| Part | BOM | Assembled into | 1:M |
| Plant | Warehouse | Contains | 1:M |
| Plant | Work Center | Operates | 1:M |
| Purchase Order | Supplier | Placed with | M:1 |
| Purchase Order | Plant | Delivered to | M:1 |
| Sales Order | Customer | Ordered by | M:1 |
| Shipment | Carrier | Transported by | M:1 |
| Shipment | Part | Contains | M:1 |
| Work Order | Part | Produces | M:1 |
| Work Order | Plant | Executed at | M:1 |
| Inventory | Part + Plant + Warehouse | Stored at | M:1 |

---

## Canonical Metrics

| Metric | Definition | Formula | Personas |
|--------|-----------|---------|----------|
| On-Time Delivery (OTD) | % of orders delivered by promised date | `COUNT(on_time) / COUNT(total) * 100` | Procurement, Logistics |
| Fill Rate | % of demand fulfilled from available stock | `quantity_shipped / quantity_ordered * 100` | Planning, Logistics |
| Days of Inventory (DOI) | Days of supply on hand | `on_hand_qty / avg_daily_usage` | Planning, Finance |
| Landed Cost | Total cost including freight, duties, handling | `unit_cost + freight_cost + handling` | Procurement, Finance |
| Supplier OTD | Supplier on-time delivery performance | `COUNT(po_on_time) / COUNT(po_total) * 100` | Procurement |
| Yield Rate | Production yield percentage | `qty_completed / qty_ordered * 100` | Manufacturing |
| Quality PPM | Defective parts per million | `qty_defective / qty_inspected * 1,000,000` | Quality, Supplier Mgmt |
| AOG Response Time | Hours to resolve Aircraft On Ground events | `AVG(duration_hours)` | Logistics, Customer Service |

---

## Solution Architecture

```
┌─────────────────────────────────────────────────────────┐
│                  CONVERSATIONAL LAYER                     │
│            (Cortex Analyst + Cortex Agents)              │
├─────────────────────────────────────────────────────────┤
│                   SEMANTIC VIEWS                          │
│         (Governed business definitions & metrics)        │
├─────────────────────────────────────────────────────────┤
│                   GOLD SCHEMA                            │
│       (Star schema - Facts & Dimensions)                 │
├─────────────────────────────────────────────────────────┤
│                   RAW SCHEMA                             │
│          (Source-aligned ingested data)                   │
├─────────────────────────────────────────────────────────┤
│              SOURCE SYSTEMS                               │
│     ERP │ Logistics │ Supplier │ IoT │ Quality           │
└─────────────────────────────────────────────────────────┘
```

---

## Personas Served

| Persona | Key Questions | Metrics Used |
|---------|--------------|--------------|
| **Planning** | What's my days of supply? Where are stockouts imminent? | DOI, Fill Rate, Safety Stock |
| **Procurement** | Which suppliers are underperforming? What's my spend? | Supplier OTD, Landed Cost, Lead Time |
| **Logistics** | Are shipments on track? What's the AOG status? | OTD, AOG Response Time, Carrier Performance |
| **Manufacturing** | What's my yield? Where are quality issues? | Yield Rate, Quality PPM, WO Completion |
| **Finance** | What's the inventory valuation? Cost of quality? | DOI (value), Landed Cost, Cost of Quality |

---

## Judging Criteria

| Criterion | How We Address It |
|-----------|-------------------|
| **Real-World Relevance** | Aerospace supply chain with industry-standard ATA classification, tiered suppliers, AOG events, and regulatory compliance (ITAR, AS9100) |
| **Technical Execution** | Star schema design, semantic views encoding business logic, Cortex Analyst for NL queries, governed metrics with single source of truth |
| **Solution Completeness** | End-to-end from raw data ingestion through ontology definition, semantic encoding, to conversational analytics with multi-persona consistency |

---

## Technology Stack

- **Snowflake** — Cloud data platform (storage, compute, governance)
- **Cortex Analyst** — Natural language to SQL via semantic views
- **Cortex Agents** — Orchestrated conversational analytics
- **Semantic Views** — Business meaning layer over physical tables
- **CoCo CLI** — AI-assisted development and deployment

---

## Database Structure

```
AEROSPACE_SUPPLY_CHAIN
├── RAW          -- Source-aligned tables (ingestion layer)
├── GOLD         -- Star schema (facts & dimensions)
└── SEMANTIC     -- Semantic views (business meaning layer)
```

---

## Project Deliverables

1. **Data Model** — Star schema with 13 dimensions and 13 fact tables
2. **Data Dictionary** — Full column-level documentation with relationships (`data_dictionary.md`)
3. **DDL Scripts** — Table creation scripts (`gold_tables_ddl.sql`)
4. **Semantic Views** — Governed semantic layer encoding ontology and metrics
5. **Cortex Agent** — Conversational interface for cross-domain analytics
6. **Demo** — Multi-persona queries proving metric consistency
