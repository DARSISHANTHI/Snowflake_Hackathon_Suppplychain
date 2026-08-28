# 14 - CoWork Assistant

## Aerospace Supply Chain — Snowflake CoWork Integration

---

## Overview

Snowflake CoWork provides a collaborative AI assistant interface where users interact with the Supply Chain Copilot agent directly within Snowsight. This document defines how the Cortex Agent is exposed through CoWork for governed conversational analytics across the organization.

---

## CoWork Configuration

### Agent Registration

The Supply Chain Copilot agent is accessible via CoWork once deployed:

| Property | Value |
|----------|-------|
| **Agent Name** | SUPPLY_CHAIN_COPILOT |
| **Database** | AEROSPACE_SUPPLY_CHAIN |
| **Schema** | SEMANTIC |
| **Access** | Users with USAGE on the agent object |
| **Interface** | Snowsight CoWork panel |

---

## User Experience

### Entry Points

```
┌─────────────────────────────────────────────────────────┐
│  SNOWSIGHT                                               │
│                                                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────────┐  │
│  │ CoWork   │  │Streamlit │  │  SQL Worksheet        │  │
│  │ Panel    │  │  App     │  │  (API call)           │  │
│  │          │  │          │  │                       │  │
│  │ Chat UI  │  │ Chat +   │  │ SNOWFLAKE.CORTEX.     │  │
│  │ with     │  │ Visuals  │  │ DATA_AGENT_RUN(...)   │  │
│  │ Agent    │  │          │  │                       │  │
│  └──────────┘  └──────────┘  └──────────────────────┘  │
│       │              │               │                   │
│       └──────────────┴───────────────┘                   │
│                      │                                    │
│                      ▼                                    │
│          ┌───────────────────────┐                       │
│          │  SUPPLY_CHAIN_COPILOT │                       │
│          │  (Cortex Agent)       │                       │
│          └───────────────────────┘                       │
└─────────────────────────────────────────────────────────┘
```

### Conversation Capabilities

| Capability | Description | Example |
|-----------|-------------|---------|
| Data queries | Ask questions answered by semantic views | "What's our fill rate this month?" |
| Definitions | Look up business terms and metric formulas | "How is landed cost calculated?" |
| Comparisons | Compare metrics across dimensions | "Compare OTD by region" |
| Trends | Analyze changes over time | "Show me yield trend for Q2" |
| Root cause | Investigate issues across domains | "Why is supplier OTD declining?" |
| Recommendations | Get actionable insights | "Which suppliers need audit?" |
| Multi-turn | Follow-up questions with context | "Now break that down by plant" |

---

## Persona-Based Interactions

### Procurement Manager

```
User: "Show me my worst-performing suppliers this quarter"
Agent: Uses SV_PROCUREMENT → ranks by SPI
       "Here are your bottom 5 suppliers by SPI for Q3 2026:
        | Supplier | SPI | OTD | Quality | Risk |
        ..."

User: "What's driving the low score for SUP-042?"
Agent: Multi-tool → Search (SPI formula) + Analyst (component scores)
       "SUP-042's SPI of 58 is driven by:
        - Delivery score: 45 (OTD at 78%, target 95%)
        - Quality score: 62 (defect rate 4.2%, target 2%)
        ..."
```

### Supply Planner

```
User: "Which parts are at risk of stockout?"
Agent: Uses SV_INVENTORY → filters AVAILABLE_QTY < REORDER_POINT
       "14 parts are below reorder point across 3 plants:
        | Part | Plant | Available | Reorder Point | DOI |
        ..."

User: "Do we have POs in pipeline for those?"
Agent: Cross-domain → SV_PROCUREMENT + SV_INVENTORY
       "8 of 14 have open POs. 6 parts need immediate attention:
        ..."
```

### Executive

```
User: "Give me a supply chain health summary"
Agent: Uses EXECUTIVE_SUMMARY_SV → key KPIs
       "Supply Chain Health Index: 82/100 (Green)
        - OTD: 94.2% (Yellow, target 95%)
        - Fill Rate: 97.8% (Yellow, target 98%)
        - DOI: 42 days (Green, target 45)
        - Yield: 97.5% (Green, target 97%)
        - Revenue at Risk: $2.1M (3 late shipments)"
```

---

## Access Control

| Role | Agent Access | Semantic Views Accessible | Data Scope |
|------|-------------|--------------------------|-----------|
| PROCUREMENT_ROLE | Full | SV_PROCUREMENT, SUPPLIER_PERFORMANCE_SV | All suppliers |
| PLANNING_ROLE | Full | SV_INVENTORY, INVENTORY_MANAGEMENT_SV | All parts/plants |
| MANUFACTURING_ROLE | Full | SV_MANUFACTURING, SV_QUALITY | Assigned plants |
| LOGISTICS_ROLE | Full | SHIPMENT_ANALYTICS_SV, CUSTOMER_ORDERS_SV | All shipments |
| EXECUTIVE_ROLE | Full | EXECUTIVE_SUMMARY_SV, all domain views | Organization-wide |
| ANALYST_ROLE | Read-only | All semantic views | Full read access |

---

## Threading and Context

| Feature | Behavior |
|---------|----------|
| **Thread continuity** | Agent maintains context within a conversation thread |
| **Follow-up questions** | "Break that down by region" uses prior query context |
| **Disambiguation** | Agent asks clarifying questions when intent is unclear |
| **History** | Previous messages available for reference in thread |
| **New thread** | Clean context — no carryover from prior conversations |

---

## Response Formatting in CoWork

| Content Type | Format |
|-------------|--------|
| Single metric | Bold value with unit and target comparison |
| Tabular data | Markdown table (up to 10 rows, with "show more" option) |
| Definitions | Quoted block with source attribution |
| Warnings | Yellow callout for threshold breaches |
| Errors | Clear explanation of what went wrong |
| Suggestions | Bulleted follow-up question suggestions |

---

## Guardrails

| Guardrail | Implementation |
|-----------|---------------|
| No data fabrication | Agent only returns data from semantic views or search |
| Metric consistency | All calculations use governed formulas from META tables |
| Scope limitation | Agent declines questions outside supply chain domain |
| PII protection | No individual employee data exposed |
| ITAR awareness | Flags when query touches ITAR-controlled parts |
| Audit trail | All queries logged with user, timestamp, and response |

---

## Sample CoWork Session

```
┌─────────────────────────────────────────────────────────┐
│ CoWork - Supply Chain Copilot                            │
├─────────────────────────────────────────────────────────┤
│                                                          │
│ You: What's our on-time delivery this month?            │
│                                                          │
│ Agent: On-Time Delivery (MET-001) for August 2026:      │
│        94.2% (Target: 95% — slightly below target)      │
│                                                          │
│        Breakdown by shipment type:                       │
│        • Outbound (customer): 95.1% ✓                   │
│        • Inbound (supplier): 92.8% ✗                    │
│        • Inter-plant: 96.4% ✓                           │
│                                                          │
│        💡 Supplier inbound deliveries are pulling        │
│        down overall OTD. Would you like to see which     │
│        suppliers are underperforming?                    │
│                                                          │
│ You: Yes, show me the late suppliers                     │
│                                                          │
│ Agent: Suppliers with OTD < 90% in August:              │
│        | Supplier     | OTD  | Late POs | Impact    |   │
│        |-------------|------|----------|-----------|   │
│        | AeroComp Ltd| 78%  | 12       | $1.2M     |   │
│        | TitanForge  | 82%  | 8        | $890K     |   │
│        | CompositeCo | 85%  | 5        | $450K     |   │
│                                                          │
│ You: What parts from AeroComp are affected?             │
│                                                          │
│ Agent: AeroComp's late deliveries affect 7 parts:       │
│        [Cross-references PO lines with inventory...]     │
│                                                          │
└─────────────────────────────────────────────────────────┘
```
