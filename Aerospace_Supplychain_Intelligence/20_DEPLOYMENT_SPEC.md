# 20 - Deployment Specification

## Aerospace Supply Chain — Deployment & Operations Guide

---

## Overview

This document specifies the deployment architecture, object dependencies, execution order, and operational procedures for the Aerospace Supply Chain platform.

---

## Deployment Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                    SNOWFLAKE ACCOUNT: ZT82836                         │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌─ AEROSPACE_SUPPLY_CHAIN ─────────────────────────────────────┐   │
│  │                                                               │   │
│  │  ┌─ RAW ──────┐  ┌─ GOLD ─────┐  ┌─ SEMANTIC ───────────┐  │   │
│  │  │ Source      │  │ Star schema│  │ SV_PROCUREMENT       │  │   │
│  │  │ tables      │  │ DIM_*      │  │ SV_INVENTORY         │  │   │
│  │  │ (DDL only)  │  │ FACT_*     │  │ SV_MANUFACTURING     │  │   │
│  │  │             │  │ META_*     │  │ SV_QUALITY           │  │   │
│  │  └─────────────┘  └────────────┘  │ SV_SALES             │  │   │
│  │                                    │ SUPPLY_CHAIN_COPILOT │  │   │
│  │                                    │ KNOWLEDGE_SEARCH     │  │   │
│  │                                    └──────────────────────┘  │   │
│  └───────────────────────────────────────────────────────────────┘   │
│                                                                       │
│  ┌─ COMPUTE ────────────────────────────────────────────────────┐   │
│  │  COMPUTE_WH (XS) — General queries + Cortex Search indexing   │   │
│  └───────────────────────────────────────────────────────────────┘   │
│                                                                       │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Object Inventory

### Databases & Schemas

| Object | Type | Purpose |
|--------|------|---------|
| AEROSPACE_SUPPLY_CHAIN | Database | Primary platform database |
| AEROSPACE_SUPPLY_CHAIN.RAW | Schema | Source-aligned ingestion tables |
| AEROSPACE_SUPPLY_CHAIN.GOLD | Schema | Star schema (facts + dimensions) |
| AEROSPACE_SUPPLY_CHAIN.SEMANTIC | Schema | Semantic views + agents + search |

### Tables (28 total in GOLD)

| Category | Tables | Count |
|----------|--------|-------|
| Dimensions | DIM_BOM, DIM_CALENDAR, DIM_CARRIER, DIM_CERTIFICATION, DIM_CUSTOMER, DIM_PART, DIM_PLANT, DIM_RAW_MATERIAL, DIM_ROUTING, DIM_SUPPLIER, DIM_SUPPLIER_PART, DIM_WAREHOUSE, DIM_WORK_CENTER | 13 |
| Facts | FACT_AOG_EVENT, FACT_INVENTORY, FACT_INVENTORY_MOVEMENT, FACT_IOT_SENSOR_DATA, FACT_PURCHASE_ORDER, FACT_PURCHASE_ORDER_LINE, FACT_PURCHASE_REQUISITION, FACT_QUALITY_EVENT, FACT_REPAIR_ORDER, FACT_SALES_ORDER, FACT_SALES_ORDER_LINE, FACT_SHIPMENT, FACT_WORK_ORDER | 13 |
| Metadata | META_BUSINESS_GLOSSARY, META_METRIC_DEFINITION | 2 |

### Semantic Views (5 in SEMANTIC schema)

| Object | Extensions | Description |
|--------|-----------|-------------|
| SV_PROCUREMENT | CA | Procurement and supplier analytics |
| SV_INVENTORY | CA | Inventory management analytics |
| SV_MANUFACTURING | CA | Manufacturing and production analytics |
| SV_QUALITY | CA | Quality and defect analytics |
| SV_SALES | CA | Sales and customer analytics |

### AI Services

| Object | Type | Description |
|--------|------|-------------|
| SUPPLY_CHAIN_COPILOT | Cortex Agent | Conversational analytics agent |
| SUPPLY_CHAIN_KNOWLEDGE_SEARCH | Cortex Search | Business glossary + metric search |

---

## Deployment Order

Strict execution order respecting dependencies:

```
PHASE 1: Infrastructure
  ├── 01. Create database
  ├── 02. Create schemas (RAW, GOLD, SEMANTIC)
  └── 03. Create warehouse (if not exists)

PHASE 2: Physical Model
  ├── 04. Create dimension tables (DIM_*)
  ├── 05. Create fact tables (FACT_*)
  └── 06. Create metadata tables (META_*)

PHASE 3: Data Load
  ├── 07. Seed dimension data
  ├── 08. Seed fact data
  └── 09. Seed metadata (glossary + metrics)

PHASE 4: Analytics Layer
  ├── 10. Create analytical views
  └── 11. Validate data quality

PHASE 5: Semantic Layer
  ├── 12. Deploy semantic views (SV_*)
  ├── 13. Deploy Cortex Search service
  └── 14. Deploy Cortex Agent

PHASE 6: Application
  ├── 15. Deploy Streamlit app
  └── 16. Validate end-to-end
```

---

## Deployment Scripts

### Script Mapping

| Phase | Script Location | Description |
|-------|----------------|-------------|
| 1 | `ddl/01_create_database_and_schemas.sql` | Database + schemas |
| 2a | `ddl/02_create_dimensions.sql` | All dimension tables |
| 2b | `ddl/03_create_facts.sql` | All fact tables |
| 2c | `ddl/04_metadata_tables.sql` | META_* tables |
| 3 | `data/01_seed_data.sql` | Initial data load |
| 4 | `ddl/05_analytics_views.sql` | Analytical views |
| 5a | `semantic_views/01_create_semantic_views.sql` | All semantic views |
| 5b | `cortex_search/01_cortex_search_service.sql` | Search service |
| 5c | `agent/01_cortex_agent.sql` | Agent deployment |
| 6 | `streamlit/01_streamlit_setup.sql` | Streamlit app |
| ALL | `scripts/00_deploy_all.sql` | Full deployment orchestrator |

---

## Environment Configuration

### Warehouse

| Property | Value |
|----------|-------|
| Name | COMPUTE_WH |
| Size | X-Small (can scale) |
| Auto-suspend | 60 seconds |
| Auto-resume | Yes |
| Min/Max clusters | 1/2 |

### Roles

| Role | Purpose | Key Grants |
|------|---------|-----------|
| ACCOUNTADMIN | Platform owner | Full control |
| SUPPLY_CHAIN_ADMIN | Operations | DDL + DML on all schemas |
| PROCUREMENT_ROLE | Procurement users | SELECT on procurement SVs |
| PLANNING_ROLE | Planning users | SELECT on inventory SVs |
| MANUFACTURING_ROLE | Manufacturing users | SELECT on manufacturing SVs |
| LOGISTICS_ROLE | Logistics users | SELECT on shipment SVs |
| EXECUTIVE_ROLE | Leadership | SELECT on all SVs |

---

## Workspace Files

```
/workspace/
├── 01_PROJECT_OVERVIEW.md
├── 02_BUSINESS_GLOSSARY.md
├── 03_DOMAIN_MODEL.md
├── 04_ER_MODEL.md
├── 05_DATA_DICTIONARY.md
├── 06_DDL_SPEC.sql
├── 07_MASTER_REFERENCE_DATA.md
├── 08_ONTOLOGY_MODEL.md
├── 10_SEMANTIC_VIEWS.md
├── 11_METRIC_CATALOG.md
├── 12_CORTEX_SEARCH.md
├── 13_AGENT_ARCHITECTURE.md
├── 14_COWORK_ASSISTANT.md
├── 15_BUSINESS_QUESTIONS.md
├── 16_MULTI_HOP_QUESTIONS.md
├── 17_EXECUTIVE_KPIS.md
├── 18_GOVERNANCE.md
├── 19_STREAMLIT_REQUIREMENTS.md
├── 20_DEPLOYMENT_SPEC.md
├── SUPPLY_CHAIN_PLATFORM_BUILD_GUIDE.md
├── data_dictionary.md
├── tables_ddl.sql
├── gold_tables_ddl.sql
├── environment.yml
├── cortex_project/
│   ├── cortex-project.yaml
│   ├── SUPPLY_CHAIN_ANALYTICS.sv.yaml
│   └── SUPPLY_CHAIN_COPILOT.agent.yaml
├── Aerospace_Manufacturing_Intelligence/
│   ├── README.md
│   ├── agent/
│   ├── cortex_search/
│   ├── data/
│   ├── ddl/
│   ├── scripts/
│   ├── semantic_views/
│   └── streamlit/
└── Shanthi/
    └── Supplychain_ontology_cli.sql
```

---

## Validation Checklist

### Post-Deployment Verification

| # | Check | Method | Expected |
|---|-------|--------|----------|
| 1 | All tables created | `SHOW TABLES IN GOLD` | 28 tables |
| 2 | Data loaded | `SELECT COUNT(*) FROM FACT_SHIPMENT` | 250,000 rows |
| 3 | Semantic views active | `SHOW SEMANTIC VIEWS IN SEMANTIC` | 5 views |
| 4 | Agent responds | Query via DATA_AGENT_RUN | Valid response |
| 5 | Search returns results | Query business term | Relevant result |
| 6 | Metric consistency | Same question, different view | Same answer |
| 7 | RBAC enforced | Query as restricted role | Appropriate access |
| 8 | Clustering active | Check DIM_PART, FACT_SHIPMENT | Clustering ON |
| 9 | Change tracking | META tables | Change tracking ON |
| 10 | Streamlit accessible | Navigate to app | Page loads < 3s |

### Consistency Tests

| Test | Question | Expected Metric | Views Tested |
|------|----------|-----------------|-------------|
| T1 | "What is OTD?" | Same % | SV_PROCUREMENT, SHIPMENT_ANALYTICS_SV |
| T2 | "What is fill rate?" | Same % | SV_SALES, CUSTOMER_ORDERS_SV |
| T3 | "Total inventory value?" | Same $ | SV_INVENTORY, INVENTORY_MANAGEMENT_SV |
| T4 | "Supplier risk distribution?" | Same count | SV_PROCUREMENT, SUPPLIER_PERFORMANCE_SV |

---

## Operational Procedures

### Daily Operations

| Task | Schedule | Method |
|------|----------|--------|
| Inventory snapshot refresh | 06:00 UTC | Scheduled task |
| IoT data ingestion | Continuous | Stream + task |
| Data quality checks | 07:00 UTC | DMF execution |
| Search index refresh | Hourly | Cortex Search TARGET_LAG |

### Weekly Operations

| Task | Schedule | Method |
|------|----------|--------|
| Supplier scorecard recalc | Monday 03:00 | Stored procedure |
| Inventory aging analysis | Monday 03:00 | Stored procedure |
| Performance report generation | Friday 17:00 | Task |

### Monthly Operations

| Task | Schedule | Method |
|------|----------|--------|
| Metric review | 1st of month | Manual review |
| Access audit | 1st of month | Compliance check |
| Capacity planning | 15th of month | Analysis |

---

## Disaster Recovery

| Component | RPO | RTO | Method |
|-----------|-----|-----|--------|
| Tables | 0 (continuous) | < 1 hour | Time Travel + Fail-safe |
| Semantic Views | N/A (DDL) | < 5 min | Redeploy from workspace |
| Agent | N/A (DDL) | < 5 min | Redeploy from workspace |
| Search Service | 1 hour | < 30 min | Recreate + reindex |
| Streamlit | N/A (code) | < 5 min | Redeploy from workspace |

---

## Monitoring

| Metric | Tool | Alert Threshold |
|--------|------|-----------------|
| Query performance | Query History | p95 > 10s |
| Warehouse credit usage | Resource Monitor | > daily budget |
| Failed tasks | Task history | Any failure |
| Agent errors | Agent logs | Error rate > 5% |
| Data freshness | Custom check | Stale > SLA |
| Storage growth | Account Usage | > 20% MoM growth |
