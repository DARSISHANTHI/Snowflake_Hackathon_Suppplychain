# 13 - Agent Architecture

## Aerospace Supply Chain — Cortex Agent Design

---

## Overview

The Cortex Agent serves as the conversational interface for the Aerospace Supply Chain platform, orchestrating multiple tools — Cortex Analyst (semantic views), Cortex Search (knowledge base), and Python functions — to answer natural language questions with governed, consistent responses grounded in the supply chain ontology.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         USER INTERFACE                                │
│              (Streamlit App / CoWork / API)                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌───────────────────────────────────────────────────────────────┐   │
│  │                    CORTEX AGENT                                 │   │
│  │                                                                │   │
│  │  ┌──────────┐  ┌──────────────┐  ┌──────────────────────┐   │   │
│  │  │ PLANNER  │  │ ORCHESTRATOR │  │   RESPONSE GENERATOR  │   │   │
│  │  │          │  │              │  │                       │   │   │
│  │  │ Classify │  │ Route to     │  │ Format answer with    │   │   │
│  │  │ intent & │  │ appropriate  │  │ citations, caveats,   │   │   │
│  │  │ persona  │  │ tool(s)      │  │ and confidence        │   │   │
│  │  └──────────┘  └──────┬───────┘  └──────────────────────┘   │   │
│  │                        │                                       │   │
│  │         ┌──────────────┼──────────────┐                       │   │
│  │         ▼              ▼              ▼                       │   │
│  │  ┌────────────┐ ┌────────────┐ ┌────────────┐               │   │
│  │  │  CORTEX    │ │  CORTEX    │ │  PYTHON    │               │   │
│  │  │  ANALYST   │ │  SEARCH    │ │  TOOL      │               │   │
│  │  │            │ │            │ │            │               │   │
│  │  │ Semantic   │ │ Knowledge  │ │ Custom     │               │   │
│  │  │ Views →SQL │ │ Base →Text │ │ Functions  │               │   │
│  │  └────────────┘ └────────────┘ └────────────┘               │   │
│  │                                                                │   │
│  └───────────────────────────────────────────────────────────────┘   │
│                                                                       │
├─────────────────────────────────────────────────────────────────────┤
│                    GOVERNED DATA LAYER                                │
│  Semantic Views │ Star Schema │ Business Glossary │ Metric Catalog   │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Agent Configuration

### Workspace File: cortex_project/SUPPLY_CHAIN_COPILOT.agent.yaml

```yaml
name: SUPPLY_CHAIN_COPILOT
description: >
  Conversational analytics agent for the Aerospace Supply Chain platform.
  Answers cross-domain questions using governed semantic views and 
  business glossary knowledge, ensuring consistent metric resolution
  across all personas.

models:
  - name: semantic_model
    type: cortex_analyst_model
    spec:
      semantic_view: AEROSPACE_SUPPLY_CHAIN.SEMANTIC.SV_PROCUREMENT

orchestration:
  target_model: claude-3-5-sonnet

instructions: |
  You are the Supply Chain Copilot, an expert in aerospace supply chain 
  operations. Answer questions using governed metrics and semantic views.
  
  RULES:
  1. Always use the semantic view tools to answer data questions
  2. Use cortex_search for definitions and business rule lookups
  3. Never fabricate data — if unsure, say so
  4. When a metric is ambiguous, ask for persona context
  5. Cite the metric ID (MET-xxx) when referencing KPIs
  6. Explain the formula used when showing metric results

tools:
  - tool_spec:
      type: cortex_analyst_tool
      name: procurement_analyst
      spec:
        semantic_view_fqn: AEROSPACE_SUPPLY_CHAIN.SEMANTIC.SV_PROCUREMENT
  - tool_spec:
      type: cortex_analyst_tool
      name: inventory_analyst
      spec:
        semantic_view_fqn: AEROSPACE_SUPPLY_CHAIN.SEMANTIC.SV_INVENTORY
  - tool_spec:
      type: cortex_analyst_tool
      name: manufacturing_analyst
      spec:
        semantic_view_fqn: AEROSPACE_SUPPLY_CHAIN.SEMANTIC.SV_MANUFACTURING
  - tool_spec:
      type: cortex_analyst_tool
      name: quality_analyst
      spec:
        semantic_view_fqn: AEROSPACE_SUPPLY_CHAIN.SEMANTIC.SV_QUALITY
  - tool_spec:
      type: cortex_analyst_tool
      name: sales_analyst
      spec:
        semantic_view_fqn: AEROSPACE_SUPPLY_CHAIN.SEMANTIC.SV_SALES
  - tool_spec:
      type: cortex_search
      name: supply_chain_knowledge
      spec:
        service_name: AEROSPACE_SUPPLY_CHAIN.SEMANTIC.SUPPLY_CHAIN_KNOWLEDGE_SEARCH
        max_results: 5
        title_column: term_id
        body_column: content
```

---

## Tool Routing Strategy

### Decision Matrix

| Query Intent | Primary Tool | Fallback | Example |
|-------------|-------------|----------|---------|
| Data retrieval (numbers, lists, aggregations) | Cortex Analyst | — | "Top 5 suppliers by spend" |
| Definition / explanation | Cortex Search | Analyst for examples | "What is fill rate?" |
| Trend / comparison | Cortex Analyst | Search for context | "OTD trend last 6 months" |
| Root cause / why | Search (context) + Analyst (data) | — | "Why is yield dropping?" |
| Recommendation | Search (rules) + Analyst (data) | — | "Which suppliers to audit?" |
| Multi-domain | Multiple Analyst tools | — | "Supplier quality vs delivery" |

### Semantic View Selection

| Domain Keywords | Routed To |
|----------------|-----------|
| supplier, procurement, purchase order, PO, spend, buyer | SV_PROCUREMENT |
| inventory, stock, warehouse, reorder, safety stock, DOI | SV_INVENTORY |
| manufacturing, production, work order, yield, scrap, capacity | SV_MANUFACTURING |
| quality, defect, NCR, CAPA, inspection, scrap, COPQ | SV_QUALITY |
| sales, customer, order, revenue, fill rate, backlog | SV_SALES |

---

## Persona-Aware Behavior

The agent adapts its responses based on identified persona context:

| Persona | Response Style | Default Metrics | Default Filters |
|---------|---------------|-----------------|-----------------|
| Procurement | Supplier-centric, cost-focused | SPI, Supplier OTD, Landed Cost | Active suppliers, open POs |
| Planning | Part/location focus, forward-looking | DOI, Stockout Rate, Reorder | Below safety stock parts |
| Logistics | Shipment-centric, time-sensitive | Customer OTD, Fill Rate, Transit Time | In-transit, delayed |
| Manufacturing | Plant/work center focus | Yield, Scrap Rate, Capacity | Active work orders |
| Quality | Defect-centric, root cause | Defect Rate, COPQ, Resolution Time | Open NCRs, critical severity |
| Executive | High-level KPIs, trends, risk | Revenue at Risk, Health Index, OTD | Cross-domain summary |

---

## Conversation Flow

```
User Question
     │
     ▼
┌──────────────┐
│ Intent       │──── Definition? ────▶ Cortex Search
│ Classification│
└──────┬───────┘
       │
       │ Data question
       ▼
┌──────────────┐
│ Domain       │──── Multi-domain? ────▶ Multiple Analyst calls
│ Detection    │
└──────┬───────┘
       │
       │ Single domain
       ▼
┌──────────────┐
│ Semantic View│
│ Selection    │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Cortex       │──── Generate SQL ────▶ Execute ────▶ Format Response
│ Analyst      │
└──────────────┘
```

---

## Multi-Hop Query Handling

For complex questions requiring multiple data sources:

```
User: "Which suppliers with declining OTD are causing inventory stockouts?"

Step 1: Cortex Analyst (SV_PROCUREMENT)
  → Get suppliers with OTD < 90% trending down

Step 2: Cortex Analyst (SV_INVENTORY)
  → Get parts below reorder point

Step 3: Agent Reasoning
  → Cross-reference: which low-OTD suppliers provide stockout parts?

Step 4: Response
  → "3 suppliers (SUP-042, SUP-107, SUP-233) with OTD < 85% supply 
     12 parts currently below safety stock..."
```

---

## Error Handling

| Error Type | Agent Behavior |
|-----------|---------------|
| Ambiguous metric | Ask clarifying question about persona/context |
| No data found | State "no results" with filter explanation |
| Multiple interpretations | Present options and ask user to choose |
| Out-of-domain question | Explain scope and suggest alternatives |
| Stale data | Note data freshness in response |

---

## Response Format Standards

| Element | Requirement |
|---------|-------------|
| Metric values | Always include unit (%, days, $, score) |
| Metric attribution | Cite metric ID (MET-xxx) on first use |
| Comparisons | Include baseline/target for context |
| Trends | State direction and magnitude |
| Tables | Use markdown tables for multi-row results |
| Charts | Describe trend direction when visual not available |
| Caveats | Note any filters, exclusions, or data limitations |
| Confidence | Flag when answer is approximate or partial |

---

## Deployment

| Property | Value |
|----------|-------|
| **Agent FQN** | AEROSPACE_SUPPLY_CHAIN.SEMANTIC.SUPPLY_CHAIN_COPILOT |
| **Workspace File** | cortex_project/SUPPLY_CHAIN_COPILOT.agent.yaml |
| **Orchestration Model** | claude-3-5-sonnet |
| **Semantic Views** | 5 domain views (SV_PROCUREMENT through SV_SALES) |
| **Search Service** | SUPPLY_CHAIN_KNOWLEDGE_SEARCH |
| **Access** | Via Streamlit app, CoWork, or API |
