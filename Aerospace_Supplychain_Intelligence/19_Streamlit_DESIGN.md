# Supply Chain AI Command Center - Architecture & Design

## Overview

A **Streamlit-in-Snowflake** (SiS) application providing AI-powered supply chain analytics for aerospace manufacturing. Built on the `AEROSPACE_SUPPLY_CHAIN_AI` database with 28 RAW tables and governed analytics views.

---

## Architecture

```
+----------------------------------------------------------+
|                   USER INTERFACE                           |
|           Streamlit (6-tab SPA with sidebar nav)          |
+----------------------------------------------------------+
|                                                            |
|  +------------------------------------------------------+ |
|  |              CORTEX AI LAYER                          | |
|  |  snowflake.cortex.Complete (llama3.1-70b)            | |
|  |  - Natural language insights                          | |
|  |  - Forecast interpretation                            | |
|  |  - Scenario mitigation plans                          | |
|  +------------------------------------------------------+ |
|                                                            |
|  +------------------------------------------------------+ |
|  |            ANALYTICS LAYER                            | |
|  |  Derived Views:                                       | |
|  |  - V_DERIVED_SUPPLIER_RISK                           | |
|  |  - V_DERIVED_PO_CYCLE_TIME                           | |
|  |  - V_DERIVED_INVENTORY_ALERTS                        | |
|  |  - V_DERIVED_WORK_ORDER_METRICS                      | |
|  |  - V_DERIVED_SHIPMENT_METRICS                        | |
|  |  - V_METRIC_ALERTS (RAG status)                      | |
|  |  - EXECUTIVE_KPI_MONTHLY                             | |
|  |  - METRIC_THRESHOLDS                                 | |
|  +------------------------------------------------------+ |
|                                                            |
|  +------------------------------------------------------+ |
|  |              RAW DATA LAYER                           | |
|  |  Dimensions: DIM_SUPPLIER, DIM_PART, DIM_PLANT,      | |
|  |              DIM_WAREHOUSE, DIM_CUSTOMER, DIM_CARRIER | |
|  |  Facts: FACT_SHIPMENT, FACT_PURCHASE_ORDER,           | |
|  |         FACT_SALES_ORDER, FACT_WORK_ORDER,            | |
|  |         FACT_INVENTORY, FACT_QUALITY_EVENT,           | |
|  |         FACT_IOT_SENSOR_DATA, FACT_REPAIR_ORDER       | |
|  +------------------------------------------------------+ |
+----------------------------------------------------------+
```

---

## File Structure

```
Aerospace_Supplychain_Ontology_Design/
├── snowflake.yml              # Snowflake project definition
├── environment.yml            # Python dependencies (conda)
├── streamlit_app.py           # Main entry point + navigation
├── config/
│   ├── settings.py            # Constants, colors, thresholds
│   └── queries.py             # All SQL queries (centralized)
├── pages/
│   ├── 1_Executive_Dashboard.py    # KPIs, RAG alerts, trends
│   ├── 2_Anomaly_Detection.py      # Z-score anomaly detection
│   ├── 3_AI_Insights.py            # Cortex AI NL analysis
│   ├── 4_Predictive_Analytics.py   # SMA forecast + confidence
│   ├── 5_Scenario_Planner.py       # What-if disruption analysis
│   └── 6_Governed_Metrics.py       # Cross-persona consistency
├── DESIGN.md                  # This file (architecture)
└── SETUP.md                   # Deployment guide
```

---

## Data Model

### Database: AEROSPACE_SUPPLY_CHAIN_AI

| Schema | Purpose | Objects |
|--------|---------|---------|
| RAW | Source-aligned tables | 28 tables (13 dim + 15 fact) |
| ANALYTICS | Derived views + KPIs | Views, summary tables |
| SEMANTIC | Semantic views (Cortex Analyst) | Governed definitions |

### Key Analytics Views

| View | Purpose | Key Columns |
|------|---------|-------------|
| V_DERIVED_SUPPLIER_RISK | Supplier performance index | SPI_SCORE, RISK_SCORE, RISK_CLASSIFICATION |
| V_DERIVED_PO_CYCLE_TIME | PO lead time analysis | CYCLE_TIME_DAYS, DAYS_LATE, PO_ON_TIME |
| V_DERIVED_INVENTORY_ALERTS | Stock health monitoring | INVENTORY_STATUS, NEEDS_REORDER, IS_OVERSTOCKED |
| V_DERIVED_WORK_ORDER_METRICS | Manufacturing KPIs | YIELD_RATE_DERIVED, SCRAP_RATE, SCHEDULE_VARIANCE |
| V_METRIC_ALERTS | RAG status for all KPIs | ACTUAL_VALUE, TARGET_VALUE, RAG_STATUS |
| EXECUTIVE_KPI_MONTHLY | Monthly executive rollup | OTD_PCT, FILL_RATE_PCT, TOTAL_REVENUE |

---

## Canonical Metrics

| Metric | Formula | Source |
|--------|---------|--------|
| On-Time Delivery (OTD) | COUNT(IS_ON_TIME=TRUE) / COUNT(*) * 100 | FACT_SHIPMENT |
| Fill Rate | SUM(QUANTITY_SHIPPED) / SUM(QUANTITY_ORDERED) * 100 | FACT_SALES_ORDER_LINE |
| Production Yield | AVG(YIELD_RATE) | FACT_WORK_ORDER |
| Scrap Rate | SUM(SCRAPPED) / SUM(PLANNED) * 100 | FACT_WORK_ORDER |
| Defect Rate | SUM(DEFECTIVE) / SUM(INSPECTED) * 100 | FACT_QUALITY_EVENT |
| Supplier Risk | AVG(RISK_SCORE) | DIM_SUPPLIER |

---

## Visualization Catalog

| Visual | Tab | Purpose |
|--------|-----|---------|
| KPI Metric Cards | Executive | RAG-coded current values vs targets |
| Line Charts | Executive, Predictive | Trend analysis with target lines |
| Bar Charts (ranked) | Executive | Top-N suppliers by risk/spend |
| Scatter Plots | Anomaly | Z-score anomaly visualization |
| Pie/Arc Charts | Anomaly | Anomaly type breakdown |
| Area Chart + Band | Predictive | Forecast with confidence interval |
| Growth Bar Chart | Predictive | Period-over-period growth (color-coded) |
| Grouped Bar | Scenario | Before/After comparison |
| Data Tables (styled) | All | Conditional formatting (RAG/risk) |

### Recommended Power BI-Style Visuals (Future)

| Visual | Best Use | Interactive Behavior |
|--------|----------|---------------------|
| Risk Heatmap | Risk by Supplier x Plant | Click cell -> filter page |
| Bubble Scatter | Probability x Impact matrix | Click -> filter details |
| Pareto Chart | 80/20 risk contributors | Select -> cross-filter |
| Sankey Diagram | Supplier -> Material -> Product flow | Select node -> filter |
| Treemap | Financial exposure composition | Select block -> cross-filter |
| Control Chart | Abnormal delay detection | Select outlier -> investigate |
| Forecast + Band | Future risk prediction | Date slicer changes forecast |
| Gantt Chart | PO/production timeline | Select order -> show timeline |

---

## AI Integration

- **Model**: `llama3.1-70b` via `snowflake.cortex.Complete`
- **Context**: Dynamic data context assembled from 6 live queries
- **Use Cases**: Health summary, risk analysis, recommendations, forecast interpretation, mitigation plans
- **Prompt Pattern**: System role + data context + user question + output format instructions

---

## Design Principles

1. **Separation of Concerns** - Config, queries, and pages in separate modules
2. **Caching** - `@st.cache_data(ttl=300)` on all data queries
3. **Decimal Safety** - All numeric columns cast with `pd.to_numeric(errors="coerce")`
4. **Governed Metrics** - Single metric definition used across all personas
5. **Altair-first** - Declarative, interactive charts via Vega-Lite
6. **Cortex AI** - Native Snowflake AI, no external API keys needed
