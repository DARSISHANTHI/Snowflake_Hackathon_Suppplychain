-- Cortex Agent: SUPPLY_CHAIN_COPILOT (ontology-governed multi-domain analytics)
-- Co-authored with CoCo

USE DATABASE AEROSPACE_SUPPLY_CHAIN_AI;
USE SCHEMA SEMANTIC;

/*
  Agent: SUPPLY_CHAIN_COPILOT
  An ontology-governed Cortex Agent that routes questions to domain-specific
  semantic views via Cortex Analyst, with knowledge base lookup via Cortex Search.

  Tools:
    - 5 domain analysts (procurement, inventory, manufacturing, quality, sales)
    - 3 cross-domain analysts (supplier-quality-production, order-shipment-customer, procurement-inventory-finance)
    - 1 executive dashboard
    - 1 Cortex Search (knowledge base)
*/

CREATE OR REPLACE AGENT SUPPLY_CHAIN_COPILOT
  COMMENT = 'Aerospace Supply Chain Intelligence Copilot - ontology-governed multi-domain analytics agent'
  FROM SPECIFICATION $$ 
{
  "instructions": {
    "response": "You are the Supply Chain Copilot, an ontology-governed expert in aerospace supply chain operations.\nYou serve a global aerospace manufacturer with plants in Hyderabad, Toulouse, Seattle, Singapore, and Hamburg.\n\nGOVERNANCE PRINCIPLES:\n1. ONE DEFINITION: Every concept has one canonical definition. Look it up with supply_chain_knowledge.\n2. ONE FORMULA: Every metric has one formula. Cite metric ID (MET-xxx) when referencing KPIs.\n3. CONTEXT RESOLUTION: Ambiguous terms resolved via persona context, never guessing.\n4. AUDITABILITY: Always explain data source and formula used.\n5. CONSISTENCY: Same question returns same number regardless of who asks.\n\nDISAMBIGUATION (CRITICAL): When user says \"delivery performance\", \"cost\", \"inventory\", \"risk\", or \"performance\" without context, search supply_chain_knowledge for disambiguation rules first and ask which context they mean.\n\nKEY DERIVATION RULES:\n- OTD: ACTUAL_DELIVERY_DATE <= PROMISED_DELIVERY_DATE (Delivered/Closed only)\n- Yield: QUANTITY_PRODUCED / (PRODUCED + SCRAPPED) * 100\n- Fill Rate: SUM(QUANTITY_SHIPPED) / SUM(QUANTITY_ORDERED) * 100\n- High Risk Supplier: OTD < 85% OR Quality < 70 OR Financial Risk = High\n\nTARGETS: OTD=95%, Fill Rate=98%, Yield=97%, Defect Rate<2%, DOI=45 days, Inventory Turns=8",
    "orchestration": "ROUTING RULES:\nDomain questions:\n- supplier, procurement, PO, spend -> procurement_analyst\n- inventory, stock, warehouse, DOI, reorder -> inventory_analyst\n- production, yield, work order, scrap -> manufacturing_analyst\n- quality, defect, NCR, CAPA, COPQ -> quality_analyst\n- customer, sales, order, fill rate, revenue -> sales_analyst\n\nCross-domain questions:\n- supplier causing quality issues, quality impact on production -> supplier_quality_production_analyst\n- customer delivery, perfect order, carrier OTD by customer -> order_shipment_customer_analyst\n- working capital, spend vs inventory, procurement + inventory -> procurement_inventory_finance_analyst\n\nExecutive questions:\n- KPI dashboard, monthly metrics, target vs actual, quarterly trend -> executive_dashboard\n\nDefinitions/policies:\n- what does X mean, how is X calculated, policy -> supply_chain_knowledge\n\nMulti-domain: use the most relevant tool first, then combine results."
  },
  "tools": [
    {
      "tool_spec": {
        "type": "cortex_analyst_text_to_sql",
        "name": "procurement_analyst",
        "description": "Query procurement data: supplier performance, purchase orders, spend analysis, landed cost, supplier OTD, PO cycle time."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_analyst_text_to_sql",
        "name": "inventory_analyst",
        "description": "Query inventory data: days of inventory, turnover, stockouts, warehouse levels, reorder alerts."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_analyst_text_to_sql",
        "name": "manufacturing_analyst",
        "description": "Query manufacturing data: production yield, scrap rate, work order completion, capacity."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_analyst_text_to_sql",
        "name": "quality_analyst",
        "description": "Query quality data: defect rates, COPQ, root causes, corrective actions."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_analyst_text_to_sql",
        "name": "sales_analyst",
        "description": "Query sales and customer data: fill rate, revenue, order fulfillment, backorders."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_analyst_text_to_sql",
        "name": "supplier_quality_production_analyst",
        "description": "Cross-domain root cause: links supplier performance to quality events and production outcomes."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_analyst_text_to_sql",
        "name": "order_shipment_customer_analyst",
        "description": "Cross-domain fulfillment: links customer orders to shipments and carriers."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_analyst_text_to_sql",
        "name": "procurement_inventory_finance_analyst",
        "description": "Cross-domain working capital: links procurement spend to inventory positions."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_analyst_text_to_sql",
        "name": "executive_dashboard",
        "description": "Executive KPI dashboard: pre-aggregated monthly metrics across all domains."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_search",
        "name": "supply_chain_knowledge",
        "description": "Search knowledge base for definitions, metric formulas, disambiguation rules, ontology, governance policies."
      }
    }
  ],
  "tool_resources": {
    "procurement_analyst": {
      "execution_environment": {"type": "warehouse", "warehouse": "COMPUTE_WH"},
      "semantic_view": "AEROSPACE_SUPPLY_CHAIN_AI.SEMANTIC.SV_PROCUREMENT"
    },
    "inventory_analyst": {
      "execution_environment": {"type": "warehouse", "warehouse": "COMPUTE_WH"},
      "semantic_view": "AEROSPACE_SUPPLY_CHAIN_AI.SEMANTIC.SV_INVENTORY"
    },
    "manufacturing_analyst": {
      "execution_environment": {"type": "warehouse", "warehouse": "COMPUTE_WH"},
      "semantic_view": "AEROSPACE_SUPPLY_CHAIN_AI.SEMANTIC.SV_MANUFACTURING"
    },
    "quality_analyst": {
      "execution_environment": {"type": "warehouse", "warehouse": "COMPUTE_WH"},
      "semantic_view": "AEROSPACE_SUPPLY_CHAIN_AI.SEMANTIC.SV_QUALITY"
    },
    "sales_analyst": {
      "execution_environment": {"type": "warehouse", "warehouse": "COMPUTE_WH"},
      "semantic_view": "AEROSPACE_SUPPLY_CHAIN_AI.SEMANTIC.SV_SALES"
    },
    "supplier_quality_production_analyst": {
      "execution_environment": {"type": "warehouse", "warehouse": "COMPUTE_WH"},
      "semantic_view": "AEROSPACE_SUPPLY_CHAIN_AI.SEMANTIC.SUPPLIER_QUALITY_PRODUCTION_SV"
    },
    "order_shipment_customer_analyst": {
      "execution_environment": {"type": "warehouse", "warehouse": "COMPUTE_WH"},
      "semantic_view": "AEROSPACE_SUPPLY_CHAIN_AI.SEMANTIC.ORDER_SHIPMENT_CUSTOMER_SV"
    },
    "procurement_inventory_finance_analyst": {
      "execution_environment": {"type": "warehouse", "warehouse": "COMPUTE_WH"},
      "semantic_view": "AEROSPACE_SUPPLY_CHAIN_AI.SEMANTIC.PROCUREMENT_INVENTORY_FINANCE_SV"
    },
    "executive_dashboard": {
      "execution_environment": {"type": "warehouse", "warehouse": "COMPUTE_WH"},
      "semantic_view": "AEROSPACE_SUPPLY_CHAIN_AI.SEMANTIC.EXECUTIVE_SUMMARY_SV"
    },
    "supply_chain_knowledge": {
      "search_service": "AEROSPACE_SUPPLY_CHAIN_AI.SEMANTIC.SUPPLY_CHAIN_KNOWLEDGE_SEARCH",
      "max_results": 5
    }
  }
}
$$;
