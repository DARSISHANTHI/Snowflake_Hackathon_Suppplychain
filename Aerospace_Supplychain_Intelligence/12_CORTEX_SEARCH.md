# 12 - Cortex Search

## Aerospace Supply Chain — Cortex Search Service Configuration

---

## Overview

Cortex Search provides vector-based semantic search over unstructured and semi-structured data within the Aerospace Supply Chain platform. It enables the Cortex Agent to retrieve contextual information — business glossary definitions, metric formulas, part specifications, and supplier documentation — when answering complex natural language questions that require domain knowledge beyond what's encoded in semantic views.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     CORTEX AGENT                                  │
│          (Orchestrates search + analyst + tools)                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌───────────────────────┐    ┌───────────────────────────────┐ │
│  │   CORTEX SEARCH       │    │     CORTEX ANALYST            │ │
│  │   (Unstructured)      │    │     (Structured SQL)          │ │
│  │                       │    │                               │ │
│  │  • Business glossary  │    │  • Semantic views             │ │
│  │  • Metric definitions │    │  • Governed metrics           │ │
│  │  • Domain knowledge   │    │  • Star schema queries        │ │
│  │  • Part specs         │    │                               │ │
│  └───────────────────────┘    └───────────────────────────────┘ │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## Search Services

### Service: Supply Chain Knowledge Base

| Property | Value |
|----------|-------|
| **Name** | SUPPLY_CHAIN_KNOWLEDGE_SEARCH |
| **Database** | AEROSPACE_SUPPLY_CHAIN |
| **Schema** | SEMANTIC |
| **Purpose** | Semantic search over business glossary, metrics, and domain knowledge |
| **Source Table** | META_BUSINESS_GLOSSARY + META_METRIC_DEFINITION (combined) |
| **Search Column** | CONTENT (concatenated definition + formula + business rules) |
| **Attributes** | TERM_ID, CATEGORY, OWNER, SOURCE_TABLE |
| **Embedding Model** | Snowflake Arctic Embed |
| **Refresh** | On change (CDC from source tables) |

### Search Index Content

The search service indexes the following content types:

| Content Type | Source | Fields Indexed | Use Case |
|-------------|--------|----------------|----------|
| Business Terms | META_BUSINESS_GLOSSARY | BUSINESS_TERM, BUSINESS_DEFINITION, FORMULA | "What does OTD mean?" |
| Metric Definitions | META_METRIC_DEFINITION | METRIC_NAME, METRIC_DESCRIPTION, FORMULA, BUSINESS_RULE | "How is fill rate calculated?" |
| Domain Rules | Encoded in definitions | Disambiguation rules, thresholds, targets | "What's a good yield rate?" |
| Ontology Context | Entity descriptions | Entity relationships, cardinality, hierarchy | "How are suppliers related to quality?" |

---

## Search Service DDL

```sql
CREATE OR REPLACE CORTEX SEARCH SERVICE AEROSPACE_SUPPLY_CHAIN.SEMANTIC.SUPPLY_CHAIN_KNOWLEDGE_SEARCH
  ON content
  ATTRIBUTES term_id, category, owner, source_table
  WAREHOUSE = COMPUTE_WH
  TARGET_LAG = '1 hour'
  AS (
    SELECT
      TERM_ID as term_id,
      'glossary' as category,
      OWNER as owner,
      SOURCE_TABLE as source_table,
      BUSINESS_TERM || ': ' || BUSINESS_DEFINITION || 
        COALESCE(' Formula: ' || FORMULA, '') as content
    FROM AEROSPACE_SUPPLY_CHAIN.GOLD.META_BUSINESS_GLOSSARY
    WHERE STATUS = 'Active'
    
    UNION ALL
    
    SELECT
      METRIC_ID as term_id,
      'metric' as category,
      'Platform' as owner,
      SOURCE_TABLES as source_table,
      METRIC_NAME || ': ' || METRIC_DESCRIPTION || 
        ' Formula: ' || FORMULA ||
        COALESCE(' Unit: ' || UNIT, '') ||
        COALESCE(' Target: ' || TARGET_VALUE::VARCHAR, '') ||
        COALESCE(' Grain: ' || GRAIN, '') ||
        COALESCE(' Rule: ' || BUSINESS_RULE, '') as content
    FROM AEROSPACE_SUPPLY_CHAIN.GOLD.META_METRIC_DEFINITION
  );
```

---

## Query Patterns

### Pattern 1: Term Lookup

```
User: "What does landed cost mean?"
Agent: Routes to Cortex Search → retrieves BG-008 definition
Response: "Landed cost is the total cost to procure and deliver a part, 
           including purchase price + freight + duties (3%) + handling (2%)."
```

### Pattern 2: Metric Disambiguation

```
User: "How do you calculate on-time delivery?"
Agent: Routes to Cortex Search → retrieves MET-001 and MET-012
Response: "OTD is calculated as COUNT(IS_ON_TIME=TRUE) / COUNT(*) * 100, 
           only counting completed shipments. Target is 95%."
```

### Pattern 3: Business Rule Retrieval

```
User: "When is a supplier considered high risk?"
Agent: Routes to Cortex Search → retrieves BG-017
Response: "A supplier is High Risk if OTD < 85% OR quality_score < 70 
           OR financial_risk is High. Score is 0-100, higher = riskier."
```

### Pattern 4: Context for SQL Generation

```
User: "Show me critical suppliers with poor delivery"
Agent: 
  1. Cortex Search → retrieves BG-006 (Critical Supplier definition)
  2. Cortex Analyst → generates SQL using semantic view with correct filters
     (CATEGORY='Strategic' AND TIER_LEVEL=1 AND OTD < 85%)
```

---

## Search Configuration

| Parameter | Value | Rationale |
|-----------|-------|-----------|
| TARGET_LAG | 1 hour | Business glossary changes are infrequent |
| WAREHOUSE | COMPUTE_WH | Shared with other workloads |
| MAX_RESULTS | 5 | Top-k results for agent context window |
| SIMILARITY_THRESHOLD | 0.7 | Balance between precision and recall |

---

## Integration with Cortex Agent

The Cortex Search service is registered as a tool in the agent configuration:

```yaml
tools:
  - tool_spec:
      type: cortex_search
      name: supply_chain_knowledge
      spec:
        service_name: AEROSPACE_SUPPLY_CHAIN.SEMANTIC.SUPPLY_CHAIN_KNOWLEDGE_SEARCH
        max_results: 5
        title_column: term_id
        body_column: content
```

### Agent Routing Logic

| Query Pattern | Route To | Example |
|--------------|----------|---------|
| "What is/means/define..." | Cortex Search | "What is fill rate?" |
| "How is X calculated?" | Cortex Search | "How is SPI calculated?" |
| "Show me / List / Count..." | Cortex Analyst (Semantic View) | "Show me top 10 suppliers by OTD" |
| "Why is X happening?" | Search (context) + Analyst (data) | "Why is OTD dropping?" |
| "Compare X vs Y" | Cortex Analyst | "Compare Q1 vs Q2 yield" |

---

## Content Refresh Strategy

| Source | Refresh Trigger | Frequency |
|--------|----------------|-----------|
| META_BUSINESS_GLOSSARY | CDC (change tracking enabled) | On insert/update |
| META_METRIC_DEFINITION | CDC (change tracking enabled) | On insert/update |
| Future: Part Specifications | Scheduled refresh | Daily |
| Future: Supplier Documentation | Scheduled refresh | Weekly |

---

## Monitoring

| Metric | Threshold | Alert |
|--------|-----------|-------|
| Index freshness | > 2 hours stale | Warning |
| Query latency (p95) | > 500ms | Warning |
| Zero-result rate | > 20% of queries | Investigate |
| Relevance feedback (thumbs down) | > 10% | Review search content |
