# Aerospace Supply Chain Intelligence Platform
## Complete CoCo CLI Build Guide — End-to-End

**Hackathon:** Supply Chain Ontology & Governed Conversational Analytics  
**Account:** ZT82836 | **Role:** ACCOUNTADMIN | **Warehouse:** COMPUTE_WH  
**Database:** AEROSPACE_SUPPLY_CHAIN_AI| **Schemas:** RAW, SEMANTIC, ANALYTICS

---

## How to Use This Guide

This file is designed as a **single-prompt reference** for Snowflake CoCo CLI. Each step below is a self-contained prompt you can paste into CoCo CLI. Execute them in order (Step 1 → Step 5). Each step includes all the context CoCo needs — table definitions, column specs, data volumes, relationships, metric formulas, and deployment targets.

**Execution approach:**
- Copy the content inside each ``` block and paste into CoCo CLI
- Wait for completion before moving to the next step
- Steps with large data volumes (Step 2) may require multiple iterations

---

## Prerequisites & Dependencies Checklist

```
BEFORE EXECUTING THE BUILD STEPS, ENSURE:

1. ROLES & PERMISSIONS:
   - ACCOUNTADMIN or role with CREATE DATABASE, CREATE WAREHOUSE privileges
   - Role can create semantic views, agents, cortex search, and streamlit apps
   
2. WAREHOUSE:
   - COMPUTE_WH exists (or create: CREATE WAREHOUSE COMPUTE_WH 
     WAREHOUSE_SIZE = 'X-SMALL' AUTO_SUSPEND = 60 AUTO_RESUME = TRUE)

3. CORTEX FEATURES ENABLED:
   - Cortex Analyst (for semantic views)
   - Cortex Agent (for the copilot)
   - Cortex Search (for knowledge base)
   - CoWork access enabled for the account

4. PACKAGES FOR STREAMLIT:
   - plotly
   - pandas
   - snowflake-snowpark-python
   - streamlit (built-in)

5. NETWORK/REGION:
   - Ensure account is in a region supporting Cortex features
   - claude-3-5-sonnet or alternative LLM available

6. WORKSPACE FILES (in COCO_CLI_HACKATHON/ folder):
   - 01_PROJECT_OVERVIEW.md — Challenge statement and objectives
   - 02_BUSINESS_GLOSSARY.md — Canonical term definitions
   - 03_DOMAIN_MODEL.md — Entity relationships and ontology
   - 04_ER_MODEL.md — Entity-relationship diagrams
   - 05_DATA_DICTIONARY.md — Full column-level documentation
   - 06_DDL_SPEC.sql — Table creation scripts (source DDL)
   - 07_MASTER_REFERENCE_DATA.md — Reference data specifications
   - 08_ONTOLOGY_MODEL.md — Formal ontology definitions
   - 10_SEMANTIC_VIEWS.md — Semantic view specifications
   - 11_METRIC_CATALOG.md — Complete KPI & metric reference
   - 12_CORTEX_SEARCH.md — Search service configuration
   - 13_AGENT_ARCHITECTURE.md — Cortex Agent design
   - 14_COWORK_ASSISTANT.md — CoWork integration spec
   - 15_BUSINESS_QUESTIONS.md — Validated question catalog (78 questions)
   - 16_MULTI_HOP_QUESTIONS.md — Complex multi-hop reasoning tests
   - 17_EXECUTIVE_KPIS.md — Executive dashboard KPI definitions
   - 18_GOVERNANCE.md — Data governance rules
   - 19_STREAMLIT_REQUIREMENTS.md — 7-page dashboard UI spec
   - 20_DEPLOYMENT_SPEC.md — Deployment architecture & order
```

---

## Step 1: Create Database, Schemas, and Tables with Data Dictionary

### 1.1 Create Database and Schemas

```
Create a Snowflake database called AEROSPACE_SUPPLY_CHAIN_AI with the following schemas:

- RAW: Source-aligned ingestion tables (DDL structure mirrors source systems) Star schema — governed facts and dimensions (core supply chain data model)
- SEMANTIC: Semantic views, Cortex Search services, and Cortex Agents
- ANALYTICS: Aggregated reporting views, KPIs, Streamlit stages

Use warehouse COMPUTE_WH and role ACCOUNTADMIN.
```

### 1.2 Tables — Data Dictionary with Business Descriptions

```
Create the following tables in AEROSPACE_SUPPLY_CHAIN.RAW with full column definitions, 
data types, primary keys, unique constraints, and business descriptions.

=== DIMENSION TABLES (13) ===

TABLE: DIM_SUPPLIER
Business Description: Master registry of all aerospace component suppliers including 
tier classification, certification status, performance metrics, and SCD Type 2 versioning.
Columns:
- SUPPLIER_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY — Surrogate key
- SUPPLIER_ID VARCHAR(15) NOT NULL UNIQUE — Format: SUP-XXXXX. Natural business key.
- SUPPLIER_CODE VARCHAR(30) NOT NULL — Short supplier code
- SUPPLIER_NAME VARCHAR(200) NOT NULL — Legal registered company name
- TIER_LEVEL NUMBER(38,0) — Tier classification (1=Strategic, 2=Preferred, 3=Approved)
- COUNTRY VARCHAR(50) — Country of primary operations
- REGION VARCHAR(50) — Geographic region (North America, Europe, Asia Pacific)
- CITY VARCHAR(100) — Supplier's city
- SUPPLIER_TYPE VARCHAR(50) — Type (manufacturer, distributor, service_provider)
- CATEGORY VARCHAR(50) — Supply category (Strategic, Preferred, Approved, Conditional)
- RISK_SCORE NUMBER(5,2) — Composite risk score 0-100 (higher=riskier)
- QUALITY_RATING NUMBER(5,2) — Quality rating 0-100 based on defect rates
- ON_TIME_DELIVERY_PCT NUMBER(5,2) — Percentage of orders delivered on time (0-100)
- ANNUAL_REVENUE NUMBER(15,2) — Supplier's annual revenue
- EMPLOYEE_COUNT NUMBER(38,0) — Number of employees
- CERTIFICATION_STATUS VARCHAR(50) — Current certification status
- ITAR_CONTROLLED BOOLEAN — ITAR controlled flag
- EAR_CONTROLLED BOOLEAN — EAR controlled flag
- IS_ACTIVE BOOLEAN DEFAULT TRUE — Whether supplier is currently active
- EFFECTIVE_DATE DATE — SCD2 effective date
- EXPIRY_DATE DATE — SCD2 expiry date
- CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
- UPDATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
Clustering: LINEAR(TIER_LEVEL, COUNTRY)

TABLE: DIM_PART
Business Description: Master part catalog containing all aerospace components 
classified by ATA chapter, part family, and criticality level.
Columns:
- PART_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY — Surrogate key
- PART_ID VARCHAR(20) NOT NULL UNIQUE — Format: PRT-XXXXX. Natural business key.
- PART_NUMBER VARCHAR(50) NOT NULL — Engineering part number
- PART_NAME VARCHAR(200) NOT NULL — Descriptive part name
- PART_FAMILY VARCHAR(50) — Part family grouping (Engine, Airframe, Avionics, etc.)
- ATA_CHAPTER VARCHAR(50) — ATA chapter classification (21, 24, 27, etc.)
- CRITICALITY VARCHAR(20) — Criticality level (critical, major, minor)
- UNIT_OF_MEASURE VARCHAR(10) — Unit (EA, KG, LB, etc.)
- STANDARD_COST NUMBER(12,4) — Standard cost per unit in USD
- WEIGHT_KG NUMBER(10,4) — Part weight in kilograms
- LEAD_TIME_DAYS NUMBER(5) — Standard procurement lead time in days
- MAKE_BUY_CODE VARCHAR(10) — Whether part is made or bought (Make, Buy)
- ITAR_CONTROLLED BOOLEAN — ITAR controlled flag
- LIFECYCLE_STATUS VARCHAR(20) — Status (Active, Obsolete, Prototype, End_of_Life)
- CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
- UPDATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
Clustering: LINEAR(PART_FAMILY, ATA_CHAPTER)

TABLE: DIM_PLANT
Business Description: Manufacturing and distribution facilities where production, 
storage, or MRO operations occur.
Columns:
- PLANT_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY — Surrogate key
- PLANT_ID VARCHAR(15) NOT NULL UNIQUE — Format: PLT-XXXXX. Natural business key.
- PLANT_CODE VARCHAR(30) NOT NULL — Short plant code
- PLANT_NAME VARCHAR(200) NOT NULL — Full plant name
- COUNTRY VARCHAR(50) — Plant country
- REGION VARCHAR(50) — Geographic region
- CITY VARCHAR(100) — Plant city
- PLANT_TYPE VARCHAR(50) — Type (assembly, component_manufacturing, MRO, warehouse)
- CAPACITY_UNITS NUMBER(10) — Production capacity in units
- OPERATING_SHIFTS NUMBER(2) — Number of operating shifts per day
- SQUARE_METERS NUMBER(10) — Plant floor area in square meters
- IS_ACTIVE BOOLEAN DEFAULT TRUE — Whether plant is currently active
- LATITUDE NUMBER(10,6) — Geographic latitude
- LONGITUDE NUMBER(10,6) — Geographic longitude
- CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
- UPDATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
Clustering: LINEAR(REGION, COUNTRY)

TABLE: DIM_WAREHOUSE
Business Description: Physical inventory storage locations within plants, 
tracking capacity and utilization.
Columns:
- WAREHOUSE_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY — Surrogate key
- WAREHOUSE_ID VARCHAR(15) NOT NULL UNIQUE — Format: WH-XXXXX
- WAREHOUSE_CODE VARCHAR(30) NOT NULL — Short warehouse code
- WAREHOUSE_NAME VARCHAR(200) NOT NULL — Full warehouse name
- PLANT_ID VARCHAR(15) FK → DIM_PLANT.PLANT_ID — Plant this warehouse belongs to
- WAREHOUSE_TYPE VARCHAR(50) — Type (raw_material, WIP, finished_goods, MRO)
- CAPACITY_UNITS NUMBER(10) — Storage capacity in units
- CURRENT_UTILIZATION_PCT NUMBER(5,2) — Current utilization percentage
- IS_ACTIVE BOOLEAN DEFAULT TRUE
- CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()

TABLE: DIM_WORK_CENTER
Business Description: Manufacturing operation stations within plants where 
specific production processes are performed.
Columns:
- WORK_CENTER_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY — Surrogate key
- WORK_CENTER_ID VARCHAR(15) NOT NULL UNIQUE — Format: WC-XXXXX
- WORK_CENTER_CODE VARCHAR(30) NOT NULL — Short work center code
- WORK_CENTER_NAME VARCHAR(200) NOT NULL — Full work center name
- PLANT_ID VARCHAR(15) FK → DIM_PLANT.PLANT_ID — Plant this work center belongs to
- MACHINE_TYPE VARCHAR(50) — Type (CNC, assembly, inspection, testing, heat_treat)
- CAPACITY_HOURS_DAY NUMBER(5,2) — Available hours per day
- HOURLY_RATE NUMBER(8,2) — Operating cost per hour
- IS_ACTIVE BOOLEAN DEFAULT TRUE
- CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()

TABLE: DIM_CUSTOMER
Business Description: Airlines, MRO providers, and defense organizations that 
purchase aerospace parts or services.
Columns:
- CUSTOMER_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY — Surrogate key
- CUSTOMER_ID VARCHAR(15) NOT NULL UNIQUE — Format: CUS-XXXXX
- CUSTOMER_CODE VARCHAR(30) NOT NULL — Short customer code
- CUSTOMER_NAME VARCHAR(200) NOT NULL — Full customer name
- COUNTRY VARCHAR(50) — Customer's country
- REGION VARCHAR(50) — Geographic region
- CUSTOMER_TYPE VARCHAR(50) — Type (airline, MRO, defense, OEM, distributor)
- REVENUE_TIER VARCHAR(20) — Revenue tier (Platinum, Gold, Silver, Bronze)
- ANNUAL_REVENUE NUMBER(15,2) — Customer's annual spend
- CREDIT_LIMIT NUMBER(15,2) — Credit limit extended to customer
- IS_ACTIVE BOOLEAN DEFAULT TRUE
- CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
- UPDATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()

TABLE: DIM_CARRIER
Business Description: Logistics providers responsible for physical transportation 
of goods between locations.
Columns:
- CARRIER_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY — Surrogate key
- CARRIER_ID VARCHAR(15) NOT NULL UNIQUE — Format: CAR-XXXXX
- CARRIER_CODE VARCHAR(30) NOT NULL — Short carrier code
- CARRIER_NAME VARCHAR(200) NOT NULL — Full carrier name
- CARRIER_TYPE VARCHAR(30) — Type (air_freight, ocean, ground, express, multimodal)
- COUNTRY VARCHAR(50) — Carrier's home country
- ON_TIME_PCT NUMBER(5,2) — Historical on-time delivery percentage
- COST_PER_KG NUMBER(10,4) — Average freight cost per kilogram
- IS_ACTIVE BOOLEAN DEFAULT TRUE
- CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()

TABLE: DIM_CALENDAR
Business Description: Date dimension for fiscal and calendar periods enabling 
time-based analysis across all fact tables.
Columns:
- DATE_KEY DATE NOT NULL PRIMARY KEY — Calendar date
- YEAR NUMBER(4) — Calendar year
- QUARTER NUMBER(1) — Calendar quarter (1-4)
- MONTH NUMBER(2) — Calendar month (1-12)
- MONTH_NAME VARCHAR(15) — Name of the month
- WEEK_OF_YEAR NUMBER(2) — ISO week number
- DAY_OF_WEEK NUMBER(1) — Day of the week (1-7)
- DAY_NAME VARCHAR(15) — Name of the day
- IS_WEEKEND BOOLEAN — Flag if date falls on weekend
- IS_HOLIDAY BOOLEAN DEFAULT FALSE — Flag if date is a holiday
- FISCAL_YEAR NUMBER(4) — Fiscal year number
- FISCAL_QUARTER NUMBER(1) — Fiscal quarter (1-4)

TABLE: DIM_RAW_MATERIAL
Business Description: Base materials used in manufacturing aerospace parts, 
tracked for specification compliance and shelf life.
Columns:
- MATERIAL_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY — Surrogate key
- MATERIAL_ID VARCHAR(15) NOT NULL UNIQUE — Format: MAT-XXXXX
- MATERIAL_CODE VARCHAR(30) NOT NULL — Short material code
- MATERIAL_NAME VARCHAR(200) NOT NULL — Full material name
- MATERIAL_TYPE VARCHAR(50) — Type (titanium, aluminum, composite, steel, nickel_alloy)
- SPECIFICATION VARCHAR(100) — Material specification standard
- UNIT_OF_MEASURE VARCHAR(10) — Unit of measure
- STANDARD_COST NUMBER(12,4) — Standard cost per unit
- DENSITY NUMBER(10,4) — Material density
- ITAR_CONTROLLED BOOLEAN — ITAR controlled flag
- SHELF_LIFE_DAYS NUMBER(5) — Shelf life in days
- CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
- UPDATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()

TABLE: DIM_BOM
Business Description: Bill of Materials defining parent-child part assembly 
structures and quantities for aerospace assemblies.
Columns:
- BOM_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY — Surrogate key
- BOM_ID VARCHAR(20) NOT NULL UNIQUE — Format: BOM-XXXXX
- BOM_CODE VARCHAR(30) NOT NULL — BOM code identifier
- PARENT_PART_ID VARCHAR(20) NOT NULL FK → DIM_PART.PART_ID — Assembly being built
- CHILD_PART_ID VARCHAR(20) NOT NULL FK → DIM_PART.PART_ID — Component consumed
- QUANTITY_PER NUMBER(10,4) NOT NULL — Units of child per one parent
- POSITION_NUMBER NUMBER(38,0) — Assembly position sequence number
- EFFECTIVE_DATE DATE — Date BOM relationship becomes effective
- EXPIRY_DATE DATE — Date BOM relationship expires
- BOM_LEVEL NUMBER(38,0) — Level in the BOM hierarchy
- PROGRAM VARCHAR(50) — Aircraft program this BOM belongs to
- CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()

TABLE: DIM_SUPPLIER_PART
Business Description: Supplier-part cross-reference with contract pricing, 
lead times, and performance ratings.
Columns:
- SUPPLIER_PART_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY — Surrogate key
- SUPPLIER_PART_ID VARCHAR(20) NOT NULL UNIQUE — Natural business key
- SUPPLIER_ID VARCHAR(15) NOT NULL FK → DIM_SUPPLIER.SUPPLIER_ID
- PART_ID VARCHAR(20) NOT NULL FK → DIM_PART.PART_ID
- LEAD_TIME_DAYS NUMBER(5) — Supplier-specific lead time
- MOQ NUMBER(10) — Minimum order quantity
- CONTRACT_PRICE NUMBER(12,4) — Contracted unit price
- CERTIFICATION_STATUS VARCHAR(50) — Part certification status with this supplier
- SUPPLIER_RATING NUMBER(5,2) — Supplier rating for this part
- CONTRACT_ID VARCHAR(20) — Contract reference
- EFFECTIVE_DATE DATE — Contract effective date
- EXPIRY_DATE DATE — Contract expiry date
- CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()

TABLE: DIM_CERTIFICATION
Business Description: Part certification and regulatory compliance tracking 
for FAA, EASA, AS9100, and ITAR.
Columns:
- CERTIFICATION_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY — Surrogate key
- PART_ID VARCHAR(20) FK → DIM_PART.PART_ID
- FAA_APPROVED VARCHAR(1) — FAA approval status (Y/N)
- EASA_APPROVED VARCHAR(1) — EASA approval status (Y/N)
- AS9100 VARCHAR(1) — AS9100 certification (Y/N)
- ITAR VARCHAR(1) — ITAR compliance (Y/N)
- EXPORT_CONTROL VARCHAR(1) — Export control classification (Y/N)
- CERTIFICATION_DATE DATE — Date certification was granted
- EXPIRY_DATE DATE — Certification expiry date
- ISSUING_AUTHORITY VARCHAR(100) — Authority that issued the certification
- CERTIFICATE_NUMBER VARCHAR(50) — Certificate reference number
- AUDIT_NOTES VARCHAR(500) — Notes from certification audit
- LAST_UPDATED TIMESTAMP_NTZ — Last update timestamp

TABLE: DIM_ROUTING
Business Description: Manufacturing routing defining operation sequences 
and standard times for production of each part.
Columns:
- ROUTING_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY — Surrogate key
- ROUTING_ID VARCHAR(15) NOT NULL UNIQUE — Natural business key
- PART_ID VARCHAR(20) FK → DIM_PART.PART_ID — Part this routing applies to
- OPERATION_SEQ NUMBER(38,0) — Operation sequence number
- WORK_CENTER_ID VARCHAR(15) FK → DIM_WORK_CENTER.WORK_CENTER_ID
- STANDARD_TIME_HRS NUMBER(8,2) — Standard operation time in hours
- SETUP_TIME_HRS NUMBER(8,2) — Setup time in hours
- DESCRIPTION VARCHAR(500) — Operation description
- CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()

=== FACT TABLES (13) ===

TABLE: FACT_PURCHASE_ORDER
Business Description: Purchase order headers representing formal commitments 
to buy parts/materials from suppliers.
Columns:
- PO_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY — Surrogate key
- PO_ID VARCHAR(20) NOT NULL UNIQUE — Format: PO-XXXXXXX
- PO_CODE VARCHAR(30) NOT NULL — PO code
- SUPPLIER_ID VARCHAR(15) FK → DIM_SUPPLIER.SUPPLIER_ID
- PLANT_ID VARCHAR(15) FK → DIM_PLANT.PLANT_ID
- ORDER_DATE DATE NOT NULL FK → DIM_CALENDAR.DATE_KEY
- PROMISED_DATE DATE FK → DIM_CALENDAR.DATE_KEY — Supplier promised delivery
- RECEIVED_DATE DATE FK → DIM_CALENDAR.DATE_KEY — Actual receipt date
- STATUS VARCHAR(50) — Open, Partial, Closed, Cancelled
- TOTAL_VALUE NUMBER(15,2) — Total PO value in USD
- CURRENCY_CODE VARCHAR(3) — Currency code
- BUYER_ID VARCHAR(20) — Internal buyer identifier
- PRIORITY_CODE VARCHAR(20) — Priority (AOG, Critical, High, Medium, Low)
- CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
- UPDATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
Clustering: LINEAR(ORDER_DATE, SUPPLIER_ID)

TABLE: FACT_PURCHASE_ORDER_LINE
Business Description: Individual line items within purchase orders specifying 
exact parts, quantities, and unit costs.
Columns:
- PO_LINE_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY — Surrogate key
- PO_LINE_ID VARCHAR(25) NOT NULL UNIQUE — Format: POL-XXXXXXX
- PO_ID VARCHAR(20) FK → FACT_PURCHASE_ORDER.PO_ID
- PART_ID VARCHAR(20) FK → DIM_PART.PART_ID
- QUANTITY_ORDERED NUMBER(10) — Ordered quantity
- QUANTITY_RECEIVED NUMBER(10) — Received quantity
- UNIT_PRICE NUMBER(12,4) — Price per unit
- LINE_VALUE NUMBER(15,2) — Total line value
- PROMISED_DATE DATE FK → DIM_CALENDAR.DATE_KEY
- RECEIVED_DATE DATE FK → DIM_CALENDAR.DATE_KEY
- STATUS VARCHAR(50) — Line status
- CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
Clustering: LINEAR(PO_ID)

TABLE: FACT_PURCHASE_REQUISITION
Business Description: Purchase requisitions preceding formal purchase orders, 
representing demand signals from planning.
Columns:
- PR_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY — Surrogate key
- PR_ID VARCHAR(20) NOT NULL UNIQUE — Format: PR-XXXXXXX
- PART_ID VARCHAR(20) FK → DIM_PART.PART_ID
- PLANT_ID VARCHAR(15) FK → DIM_PLANT.PLANT_ID
- REQUESTED_QTY NUMBER(10) — Quantity requested
- NEED_DATE DATE FK → DIM_CALENDAR.DATE_KEY
- STATUS VARCHAR(50) — Requisition status
- SUPPLIER_ID VARCHAR(15) FK → DIM_SUPPLIER.SUPPLIER_ID — Suggested supplier
- CURRENCY_CODE VARCHAR(3)
- APPROVAL_DATE DATE FK → DIM_CALENDAR.DATE_KEY
- BUYER_ID VARCHAR(20)
- PRIORITY_CODE VARCHAR(20)
- CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
- UPDATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()

TABLE: FACT_SALES_ORDER
Business Description: Customer orders for aerospace parts driving demand 
through the supply chain.
Columns:
- SO_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY — Surrogate key
- SO_ID VARCHAR(20) NOT NULL UNIQUE — Format: SO-XXXXXXX
- SO_CODE VARCHAR(30) NOT NULL — Sales order code
- CUSTOMER_ID VARCHAR(15) FK → DIM_CUSTOMER.CUSTOMER_ID
- PLANT_ID VARCHAR(15) FK → DIM_PLANT.PLANT_ID
- ORDER_DATE DATE FK → DIM_CALENDAR.DATE_KEY
- REQUESTED_DATE DATE FK → DIM_CALENDAR.DATE_KEY
- PROMISED_DATE DATE FK → DIM_CALENDAR.DATE_KEY
- SHIPPED_DATE DATE FK → DIM_CALENDAR.DATE_KEY
- STATUS VARCHAR(50) — Open, In Production, Shipped, Delivered, Closed, Cancelled
- TOTAL_VALUE NUMBER(15,2) — Total order value
- CURRENCY_CODE VARCHAR(3)
- PRIORITY VARCHAR(20)
- CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
- UPDATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
Clustering: LINEAR(ORDER_DATE, CUSTOMER_ID)

TABLE: FACT_SALES_ORDER_LINE
Business Description: Individual line items within sales orders with 
part-level quantity and pricing detail.
Columns:
- SO_LINE_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY — Surrogate key
- SO_LINE_ID VARCHAR(25) NOT NULL UNIQUE — Format: SOL-XXXXXXX
- SO_ID VARCHAR(20) FK → FACT_SALES_ORDER.SO_ID
- PART_ID VARCHAR(20) FK → DIM_PART.PART_ID
- QUANTITY_ORDERED NUMBER(10)
- QUANTITY_SHIPPED NUMBER(10)
- UNIT_PRICE NUMBER(12,4)
- LINE_VALUE NUMBER(15,2)
- REQUESTED_DATE DATE FK → DIM_CALENDAR.DATE_KEY
- PROMISED_DATE DATE FK → DIM_CALENDAR.DATE_KEY
- STATUS VARCHAR(50)
- CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
Clustering: LINEAR(SO_ID)

TABLE: FACT_SHIPMENT
Business Description: Physical movement of goods — inbound from suppliers, 
outbound to customers, or inter-plant transfers.
Columns:
- SHIPMENT_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY — Surrogate key
- SHIPMENT_ID VARCHAR(20) NOT NULL UNIQUE — Format: SHP-XXXXXXX
- SHIPMENT_CODE VARCHAR(30) NOT NULL
- SHIPMENT_TYPE VARCHAR(20) — inbound, outbound, inter_plant
- ORIGIN_PLANT_ID VARCHAR(15) FK → DIM_PLANT.PLANT_ID (role: origin)
- DESTINATION_PLANT_ID VARCHAR(15) FK → DIM_PLANT.PLANT_ID (role: destination)
- SUPPLIER_ID VARCHAR(15) FK → DIM_SUPPLIER.SUPPLIER_ID (inbound)
- CUSTOMER_ID VARCHAR(15) FK → DIM_CUSTOMER.CUSTOMER_ID (outbound)
- CARRIER_ID VARCHAR(15) FK → DIM_CARRIER.CARRIER_ID
- PO_ID VARCHAR(20) FK → FACT_PURCHASE_ORDER.PO_ID
- SO_ID VARCHAR(20) FK → FACT_SALES_ORDER.SO_ID
- PART_ID VARCHAR(20) FK → DIM_PART.PART_ID
- QUANTITY NUMBER(10)
- SHIP_DATE DATE FK → DIM_CALENDAR.DATE_KEY
- PROMISED_DELIVERY_DATE DATE FK → DIM_CALENDAR.DATE_KEY
- ACTUAL_DELIVERY_DATE DATE FK → DIM_CALENDAR.DATE_KEY
- STATUS VARCHAR(50) — Planned, In Transit, Delivered, Delayed, Exception
- FREIGHT_COST NUMBER(12,2)
- WEIGHT_KG NUMBER(10,2)
- TRACKING_NUMBER VARCHAR(50)
- IS_ON_TIME BOOLEAN — ACTUAL_DELIVERY_DATE <= PROMISED_DELIVERY_DATE
- CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
- UPDATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
Clustering: LINEAR(SHIP_DATE, SHIPMENT_TYPE)

TABLE: FACT_INVENTORY
Business Description: Current inventory snapshot by part, plant, and warehouse 
with stock levels, reorder points, and valuation.
Columns:
- INVENTORY_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY — Surrogate key
- INVENTORY_ID VARCHAR(20) NOT NULL UNIQUE — Format: INV-XXXXXXX
- INVENTORY_CODE VARCHAR(30)
- PART_ID VARCHAR(20) FK → DIM_PART.PART_ID
- PLANT_ID VARCHAR(15) FK → DIM_PLANT.PLANT_ID
- WAREHOUSE_ID VARCHAR(15) FK → DIM_WAREHOUSE.WAREHOUSE_ID
- ON_HAND_QTY NUMBER(10)
- AVAILABLE_QTY NUMBER(10)
- RESERVED_QTY NUMBER(10)
- IN_TRANSIT_QTY NUMBER(10)
- REORDER_POINT NUMBER(10)
- SAFETY_STOCK NUMBER(10)
- MAX_STOCK NUMBER(10)
- UNIT_COST NUMBER(12,4)
- TOTAL_VALUE NUMBER(15,2)
- LAST_RECEIPT_DATE DATE
- LAST_ISSUE_DATE DATE
- SNAPSHOT_DATE DATE FK → DIM_CALENDAR.DATE_KEY
- CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
- UPDATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
Clustering: LINEAR(PLANT_ID, PART_ID)

TABLE: FACT_INVENTORY_MOVEMENT
Business Description: Inventory transaction history tracking all stock 
movements including receipts, issues, transfers, and adjustments.
Columns:
- MOVEMENT_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY — Surrogate key
- MOVEMENT_ID VARCHAR(20) NOT NULL UNIQUE — Format: MOV-XXXXXXX
- PART_ID VARCHAR(20) FK → DIM_PART.PART_ID
- PLANT_ID VARCHAR(15) FK → DIM_PLANT.PLANT_ID
- WAREHOUSE_ID VARCHAR(15) FK → DIM_WAREHOUSE.WAREHOUSE_ID
- MOVEMENT_TYPE VARCHAR(30) — receipt, issue, transfer, adjustment
- QUANTITY NUMBER(10)
- MOVEMENT_DATE DATE FK → DIM_CALENDAR.DATE_KEY
- BATCH_ID VARCHAR(20)
- LOT_NUMBER VARCHAR(30)
- TRANSACTION_ID VARCHAR(20)
- REASON_CODE VARCHAR(20)
- REFERENCE_DOC VARCHAR(30)
- CREATED_BY VARCHAR(50)
- CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
Clustering: LINEAR(MOVEMENT_DATE, MOVEMENT_TYPE)

TABLE: FACT_WORK_ORDER
Business Description: Manufacturing work orders for production, rework, 
and repair operations tracking yield and cost.
Columns:
- WORK_ORDER_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY — Surrogate key
- WORK_ORDER_ID VARCHAR(20) NOT NULL UNIQUE — Format: WO-XXXXXXX
- WORK_ORDER_CODE VARCHAR(30) NOT NULL
- WORK_ORDER_TYPE VARCHAR(20) — production, rework, repair, prototype
- PART_ID VARCHAR(20) FK → DIM_PART.PART_ID
- PLANT_ID VARCHAR(15) FK → DIM_PLANT.PLANT_ID
- WORK_CENTER_ID VARCHAR(15) FK → DIM_WORK_CENTER.WORK_CENTER_ID
- QUANTITY_ORDERED NUMBER(10)
- QUANTITY_COMPLETED NUMBER(10)
- QUANTITY_SCRAPPED NUMBER(10)
- PLANNED_START_DATE DATE FK → DIM_CALENDAR.DATE_KEY
- PLANNED_END_DATE DATE FK → DIM_CALENDAR.DATE_KEY
- ACTUAL_START_DATE DATE FK → DIM_CALENDAR.DATE_KEY
- ACTUAL_END_DATE DATE FK → DIM_CALENDAR.DATE_KEY
- STATUS VARCHAR(50) — Released, In Progress, Completed, Closed, Cancelled
- PRIORITY VARCHAR(20)
- YIELD_RATE NUMBER(5,2) — QUANTITY_COMPLETED / QUANTITY_ORDERED * 100
- TOTAL_COST NUMBER(15,2)
- CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
- UPDATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
Clustering: LINEAR(PLANNED_START_DATE, PLANT_ID)

TABLE: FACT_QUALITY_EVENT
Business Description: Quality events including inspections, non-conformances (NCRs), 
and corrective actions (CAPAs) with root cause and disposition.
Columns:
- QUALITY_EVENT_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY — Surrogate key
- QUALITY_EVENT_ID VARCHAR(20) NOT NULL UNIQUE — Format: QE-XXXXXXX
- QUALITY_EVENT_CODE VARCHAR(30)
- PART_ID VARCHAR(20) FK → DIM_PART.PART_ID
- SUPPLIER_ID VARCHAR(15) FK → DIM_SUPPLIER.SUPPLIER_ID
- PLANT_ID VARCHAR(15) FK → DIM_PLANT.PLANT_ID
- WORK_ORDER_ID VARCHAR(20) FK → FACT_WORK_ORDER.WORK_ORDER_ID
- EVENT_TYPE VARCHAR(50) — inspection, NCR, CAPA, audit, customer_complaint
- DEFECT_TYPE VARCHAR(100)
- SEVERITY VARCHAR(20) — critical, major, minor
- ROOT_CAUSE VARCHAR(500)
- CORRECTIVE_ACTION VARCHAR(500)
- DISPOSITION VARCHAR(50) — scrap, rework, use_as_is, return_to_supplier
- QUANTITY_INSPECTED NUMBER(10)
- QUANTITY_DEFECTIVE NUMBER(10)
- EVENT_DATE DATE FK → DIM_CALENDAR.DATE_KEY
- RESOLUTION_DATE DATE FK → DIM_CALENDAR.DATE_KEY
- STATUS VARCHAR(50)
- COST_OF_QUALITY NUMBER(12,2)
- CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
- UPDATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
Clustering: LINEAR(EVENT_DATE, PLANT_ID)

TABLE: FACT_IOT_SENSOR_DATA
Business Description: IoT sensor readings from manufacturing equipment 
monitoring temperature, vibration, pressure, and power consumption.
Columns:
- SENSOR_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY — Surrogate key
- SENSOR_ID VARCHAR(20) — Sensor device identifier
- WORK_CENTER_ID VARCHAR(15) FK → DIM_WORK_CENTER.WORK_CENTER_ID
- PLANT_ID VARCHAR(15) FK → DIM_PLANT.PLANT_ID
- READING_TIMESTAMP TIMESTAMP_NTZ — Timestamp of sensor reading
- TEMPERATURE_C NUMBER(8,2) — Temperature in Celsius
- VIBRATION_MM_S NUMBER(8,2) — Vibration in mm/s
- PRESSURE_BAR NUMBER(8,2) — Pressure in bar
- RPM NUMBER(10) — Rotations per minute
- POWER_KW NUMBER(8,2) — Power consumption in kilowatts
- OIL_LEVEL_PCT NUMBER(5,2) — Oil level percentage
- STATUS VARCHAR(20) — Normal, Warning, Critical
- ALERT_FLAG BOOLEAN — Whether alert threshold was triggered
Clustering: LINEAR(READING_TIMESTAMP, PLANT_ID)

TABLE: FACT_AOG_EVENT
Business Description: Aircraft On Ground events — highest priority supply 
chain disruptions requiring emergency response within 4 hours.
Columns:
- AOG_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY — Surrogate key
- AOG_ID VARCHAR(20) NOT NULL UNIQUE — Format: AOG-XXXXXXX
- CUSTOMER_ID VARCHAR(15) FK → DIM_CUSTOMER.CUSTOMER_ID
- PART_ID VARCHAR(20) FK → DIM_PART.PART_ID
- EVENT_DATE DATE FK → DIM_CALENDAR.DATE_KEY
- DURATION_HOURS NUMBER(8,2)
- REVENUE_IMPACT NUMBER(15,2)
- ROOT_CAUSE VARCHAR(500)
- RESOLUTION_ACTION VARCHAR(500)
- SEVERITY_CODE VARCHAR(20) — AOG_Critical, AOG_Urgent, AOG_Standard
- RESOLUTION_DATE DATE FK → DIM_CALENDAR.DATE_KEY
- MAINTENANCE_PROVIDER_ID VARCHAR(20)
- CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
- UPDATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()

TABLE: FACT_REPAIR_ORDER
Business Description: MRO repair orders for component overhaul, repair, 
and modification tracking turnaround time and cost.
Columns:
- REPAIR_ORDER_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY — Surrogate key
- REPAIR_ORDER_ID VARCHAR(20) NOT NULL UNIQUE — Format: RO-XXXXXXX
- ENGINE_SN VARCHAR(30) — Engine serial number
- PART_ID VARCHAR(20) FK → DIM_PART.PART_ID
- CUSTOMER_ID VARCHAR(15) FK → DIM_CUSTOMER.CUSTOMER_ID
- RECEIVED_DATE DATE FK → DIM_CALENDAR.DATE_KEY
- RELEASED_DATE DATE FK → DIM_CALENDAR.DATE_KEY
- REPAIR_COST NUMBER(15,2)
- REPAIR_STATUS VARCHAR(50)
- TECHNICIAN_ID VARCHAR(20)
- REPAIR_TYPE VARCHAR(50) — overhaul, repair, modification, inspection
- WARRANTY_FLAG VARCHAR(1) — Y/N
- TURNAROUND_TIME_DAYS NUMBER(5)
- CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
- UPDATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()

=== METADATA TABLES (2) ===

TABLE: META_BUSINESS_GLOSSARY
Business Description: Canonical business term definitions ensuring consistent 
terminology across all personas and semantic views.
Columns:
- TERM_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY — Surrogate key
- TERM_ID VARCHAR(15) NOT NULL UNIQUE — Format: BG-XXX
- BUSINESS_TERM VARCHAR(100) NOT NULL — Business term name
- BUSINESS_DEFINITION VARCHAR(500) — Definition of the term
- SOURCE_TABLE VARCHAR(100) — Source table(s) for the term
- FORMULA VARCHAR(1000) — Calculation formula (if metric)
- OWNER VARCHAR(100) — Business owner of the term
- STATUS VARCHAR(20) DEFAULT 'Active' — Term status
- CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
Change Tracking: ON

TABLE: META_METRIC_DEFINITION
Business Description: Standardized KPI formulas with targets, grain, 
and business rules for governed reporting.
Columns:
- METRIC_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY — Surrogate key
- METRIC_ID VARCHAR(15) NOT NULL UNIQUE — Format: MET-XXX
- METRIC_NAME VARCHAR(100) NOT NULL — Metric display name
- METRIC_DESCRIPTION VARCHAR(500) — What the metric measures
- FORMULA VARCHAR(2000) — SQL calculation formula
- UNIT VARCHAR(20) — Unit (%, Days, USD, Turns, Score)
- TARGET_VALUE NUMBER(18,4) — Target/threshold value
- SOURCE_TABLES VARCHAR(500) — Tables used to compute
- GRAIN VARCHAR(200) — Granularity (Per Supplier Per Month, etc.)
- BUSINESS_RULE VARCHAR(1000) — Business rules for computation
- CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
Change Tracking: ON
```

---

## Step 2: Populate Data — Seed & Reference Data

```
Populate all tables in AEROSPACE_SUPPLY_CHAIN.RAWwith realistic aerospace supply chain data:

## Dimension Tables ( for Hackathon)

| Table Name              |  Count | Comment                                  |
|-------------------------|--------------|------------------------------------------|
| DIM_SUPPLIER            | 100          | tiered global aerospace suppliers        |
| DIM_PART                | 500          | ATA-classified parts across all families |
| DIM_PLANT               | 5            | global facilities                        |
| DIM_WAREHOUSE           | 20           | 4 per plant average                      |
| DIM_WORK_CENTER         | 50           | 10 per plant average                     |
| DIM_CUSTOMER            | 10           | airlines, MROs, defense                  |
| DIM_CARRIER             | 5            | logistics providers                      |
| DIM_CALENDAR            | 180          | 6-month date range                       |
| DIM_RAW_MATERIAL        | 5            | aerospace materials                      |
| DIM_BOM                 | 500          | assembly structures                      |
| DIM_SUPPLIER_PART       | 500          | supplier-part contracts                  |
| DIM_CERTIFICATION       | 500          | one per part                             |
| DIM_ROUTING             | 1,000        | multiple ops per part                    |


## Fact Tables ( for Hackathon)

| Table Name                |  Count | Comment                                |
|---------------------------|--------------|----------------------------------------|
| FACT_PURCHASE_ORDER       | 500          |                                        |
| FACT_PURCHASE_ORDER_LINE  | 2,500        | 5 lines per PO avg                     |
| FACT_PURCHASE_REQUISITION | 500          |                                        |
| FACT_SALES_ORDER          | 400          |                                        |
| FACT_SALES_ORDER_LINE     | 1,600        | 4 lines per SO avg                     |
| FACT_SHIPMENT             | 5,000        | inbound/outbound/inter-plant mix       |
| FACT_INVENTORY            | 500          | daily snapshot                         |
| FACT_INVENTORY_MOVEMENT   | 10,000       |                                        |
| FACT_WORK_ORDER           | 1,500        |                                        |
| FACT_QUALITY_EVENT        | 1,000        |                                        |
| FACT_IOT_SENSOR_DATA      | 10,000       |                                        |
| FACT_AOG_EVENT            | 25           | rare, high-impact events               |
| FACT_REPAIR_ORDER         | 250          |                                        |


METADATA:
- META_BUSINESS_GLOSSARY: 20 rows (BG-001 through BG-020)
  Terms: OTD, Fill Rate, DOI, Landed Cost, Yield Rate, Scrap Rate, COPQ, 
  AOG, MRO, OEM, DPPM, SPI, Working Capital, Safety Stock, Reorder Point,
  Cycle Time, Perfect Order Rate, Revenue at Risk, Capacity Utilization, 
  Inventory Turnover
- META_METRIC_DEFINITION: 15 rows (MET-001 through MET-015)
  Metrics: OTD Overall (MET-001), Fill Rate (MET-002), DOI (MET-003), 
  Inventory Turnover (MET-004), Risk Score (MET-005), Production Yield (MET-006),
  Scrap Rate (MET-007), Revenue At Risk (MET-008), WO Completion (MET-009),
  Freight Cost/Unit (MET-010), Carrier OTD (MET-011), Supplier OTD (MET-012),
  Defect Rate (MET-013), Landed Cost (MET-014), SPI (MET-015)

SEED DATA GUIDELINES:
- Use realistic supplier names (e.g., Titanium Aerospace Corp, Pacific Avionics Ltd)
- Distribute suppliers across tiers: Tier 1 (10%), Tier 2 (30%), Tier 3 (60%)
- ATA chapters: 21-Air Conditioning, 24-Electrical, 27-Flight Controls, 28-Fuel, 
  29-Hydraulic, 32-Landing Gear, 36-Pneumatic, 49-APU, 52-Doors, 71-Powerplant, 72-Engine
- Part families: Engine, Airframe, Avionics, Landing Gear, Interior, Systems
- Regions: North America (40%), Europe (30%), Asia Pacific (20%), Middle East (10%)
- Shipment on-time rate: ~92-95% (realistic aerospace benchmark)
- Quality defect rate: ~2-5% (realistic for aerospace)
- Yield rate: ~95-98%
- Ensure referential integrity: all FK references point to valid parent records
- Dates: Use 2024-01-01 through 2026-06-30 for transactional data
```

---

## Step 3: Create Semantic Views

```
Create semantic views that encode the supply chain ontology as governed business 
meaning over physical tables. Deploy to AEROSPACE_SUPPLY_CHAIN.SEMANTIC.

=== DOMAIN SEMANTIC VIEWS (AEROSPACE_SUPPLY_CHAIN.SEMANTIC) ===

SEMANTIC VIEW: SV_PROCUREMENT
Tables: DIM_SUPPLIER, DIM_PART, DIM_PLANT, DIM_CALENDAR, FACT_PURCHASE_ORDER, 
        FACT_PURCHASE_ORDER_LINE, FACT_SHIPMENT (inbound)
Extensions: CORTEX_ANALYST
Metrics Encoded: Supplier OTD (MET-012), PO Cycle Time, Landed Cost (MET-014), 
                 SPI (MET-015), Procurement Spend
Relationships:
  - FACT_PURCHASE_ORDER.SUPPLIER_ID → DIM_SUPPLIER.SUPPLIER_ID (many_to_one)
  - FACT_PURCHASE_ORDER.PLANT_ID → DIM_PLANT.PLANT_ID (many_to_one)
  - FACT_PURCHASE_ORDER_LINE.PO_ID → FACT_PURCHASE_ORDER.PO_ID (many_to_one)
  - FACT_PURCHASE_ORDER_LINE.PART_ID → DIM_PART.PART_ID (many_to_one)
Verified Queries:
- "Top 10 suppliers by total spend this year"
- "Which suppliers have OTD below 90%?"
- "Show procurement spend trend by quarter"
- "What is the average PO cycle time by supplier tier?"
- "Which parts have the highest landed cost?"

SEMANTIC VIEW: SV_INVENTORY
Tables: DIM_PART, DIM_PLANT, DIM_WAREHOUSE, DIM_CALENDAR, FACT_INVENTORY, 
        FACT_INVENTORY_MOVEMENT
Extensions: CORTEX_ANALYST
Metrics Encoded: Days of Inventory (MET-003), Inventory Turnover (MET-004), 
                 Stockout Rate, Excess Inventory %
Relationships:
  - FACT_INVENTORY.PART_ID → DIM_PART.PART_ID (many_to_one)
  - FACT_INVENTORY.PLANT_ID → DIM_PLANT.PLANT_ID (many_to_one)
  - FACT_INVENTORY.WAREHOUSE_ID → DIM_WAREHOUSE.WAREHOUSE_ID (many_to_one)
Verified Queries:
- "Which parts are below reorder point?"
- "What is the average days of supply by plant?"
- "Show inventory valuation by warehouse type"
- "Which parts have zero available quantity?"
- "What is inventory turnover by part family?"

SEMANTIC VIEW: SV_MANUFACTURING
Tables: DIM_PART, DIM_PLANT, DIM_WORK_CENTER, DIM_CALENDAR, FACT_WORK_ORDER, 
        FACT_IOT_SENSOR_DATA
Extensions: CORTEX_ANALYST
Metrics Encoded: Production Yield (MET-006), Scrap Rate (MET-007), 
                 WO Completion Rate (MET-009), Capacity Utilization
Relationships:
  - FACT_WORK_ORDER.PART_ID → DIM_PART.PART_ID (many_to_one)
  - FACT_WORK_ORDER.PLANT_ID → DIM_PLANT.PLANT_ID (many_to_one)
  - FACT_WORK_ORDER.WORK_CENTER_ID → DIM_WORK_CENTER.WORK_CENTER_ID (many_to_one)
Verified Queries:
- "What is the yield rate by plant this month?"
- "Which work centers have the most scrap?"
- "Show production schedule adherence trend"
- "Which parts have yield below 95%?"
- "What is capacity utilization by work center type?"

SEMANTIC VIEW: SV_QUALITY
Tables: DIM_PART, DIM_SUPPLIER, DIM_PLANT, DIM_CALENDAR, FACT_QUALITY_EVENT, 
        FACT_WORK_ORDER
Extensions: CORTEX_ANALYST
Metrics Encoded: Quality Defect Rate (MET-013), Cost of Quality, 
                 Resolution Time, Supplier Quality PPM
Relationships:
  - FACT_QUALITY_EVENT.PART_ID → DIM_PART.PART_ID (many_to_one)
  - FACT_QUALITY_EVENT.SUPPLIER_ID → DIM_SUPPLIER.SUPPLIER_ID (many_to_one)
  - FACT_QUALITY_EVENT.PLANT_ID → DIM_PLANT.PLANT_ID (many_to_one)
Verified Queries:
- "What is the defect rate by supplier?"
- "Show cost of quality trend by quarter"
- "Which root causes are most common for critical defects?"
- "Average time to resolve quality events by severity?"
- "Which plants have the highest quality event count?"

SEMANTIC VIEW: SV_SALES
Tables: DIM_CUSTOMER, DIM_PART, DIM_PLANT, DIM_CALENDAR, FACT_SALES_ORDER, 
        FACT_SALES_ORDER_LINE, FACT_SHIPMENT (outbound)
Extensions: CORTEX_ANALYST
Metrics Encoded: Fill Rate (MET-002), Customer OTD (MET-001), 
                 Revenue At Risk (MET-008), Perfect Order Rate
Relationships:
  - FACT_SALES_ORDER.CUSTOMER_ID → DIM_CUSTOMER.CUSTOMER_ID (many_to_one)
  - FACT_SALES_ORDER.PLANT_ID → DIM_PLANT.PLANT_ID (many_to_one)
  - FACT_SALES_ORDER_LINE.SO_ID → FACT_SALES_ORDER.SO_ID (many_to_one)
  - FACT_SALES_ORDER_LINE.PART_ID → DIM_PART.PART_ID (many_to_one)
Verified Queries:
- "What is the fill rate by customer type?"
- "Show revenue by customer tier this quarter"
- "Which customers have the most backorders?"
- "What is on-time delivery by region?"
- "Top 10 customers by order value"

=== CROSS-DOMAIN SEMANTIC VIEWS ===

SEMANTIC VIEW: SUPPLIER_QUALITY_PRODUCTION_SV
Tables: DIM_SUPPLIER, FACT_QUALITY_EVENT, FACT_WORK_ORDER, DIM_PART
Purpose: Supplier quality → production outcomes for root cause analysis
Extensions: CORTEX_ANALYST, AI
Verified Queries:
- "How do supplier quality issues impact production yield?"
- "Which incoming material defects caused the most production scrap?"

SEMANTIC VIEW: SUPPLIER_SHIPMENT_WAREHOUSE_SV
Tables: DIM_SUPPLIER, FACT_SHIPMENT, DIM_WAREHOUSE, FACT_INVENTORY
Purpose: Suppliers → shipments → warehouses for end-to-end logistics
Extensions: CORTEX_ANALYST, AI
Verified Queries:
- "What is the average time from shipment arrival to inventory availability?"
- "Show the correlation between delayed shipments and stockout events"

SEMANTIC VIEW: ORDER_SHIPMENT_CUSTOMER_SV
Tables: FACT_SALES_ORDER, FACT_SALES_ORDER_LINE, FACT_SHIPMENT, DIM_CUSTOMER
Purpose: Customer orders → shipment → delivery for perfect order analysis
Extensions: CORTEX_ANALYST
Verified Queries:
- "What is the perfect order rate by customer segment?"
- "Track order-to-delivery time for our top 20 customers"

SEMANTIC VIEW: PROCUREMENT_INVENTORY_FINANCE_SV
Tables: FACT_PURCHASE_ORDER, FACT_INVENTORY, DIM_PART, DIM_SUPPLIER
Purpose: Procurement spend → inventory positions → working capital
Extensions: CORTEX_ANALYST, AI
Verified Queries:
- "What is our working capital tied up in inventory by product category?"
- "Which parts have excess inventory due to over-procurement?"

SEMANTIC VIEW: GOVERNANCE_COMPLIANCE_SV
Tables: DIM_SUPPLIER, DIM_CERTIFICATION, DIM_SUPPLIER_PART
Purpose: Regulatory adherence, certification gaps, compliance risks
Extensions: CORTEX_ANALYST
Verified Queries:
- "Which suppliers have expiring certifications in the next 90 days?"
- "What is the certification coverage by supplier tier?"

SEMANTIC VIEW: EXECUTIVE_SUMMARY_SV
Tables: All fact and dimension tables (aggregated KPIs)
Purpose: High-level KPIs across all domains for leadership dashboards
Extensions: CORTEX_ANALYST, AI
Verified Queries:
- "Give me an executive summary of supply chain health"
- "What are the top 5 risks in our supply chain right now?"
- "Show me month-over-month trends for OTD, quality, and spend"

Deploy all semantic views using:
CREATE OR REPLACE SEMANTIC VIEW AEROSPACE_SUPPLY_CHAIN.SEMANTIC.<view_name> ... 
Grant USAGE to appropriate roles.
```

---

## Step 4: Build Cortex Search & Cortex Agent

### 4.1 Cortex Search Service

```
Create a Cortex Search service for the supply chain knowledge base:

SERVICE NAME: SUPPLY_CHAIN_KNOWLEDGE_SEARCH
DATABASE: AEROSPACE_SUPPLY_CHAIN
SCHEMA: SEMANTIC
WAREHOUSE: COMPUTE_WH

KNOWLEDGE BASE TABLE:
First create AEROSPACE_SUPPLY_CHAIN.SEMANTIC.KNOWLEDGE_BASE with columns:
- DOC_ID VARCHAR(50) PRIMARY KEY
- TITLE VARCHAR(500)
- CONTENT VARCHAR(16000) — Main searchable content
- CATEGORY VARCHAR(100) — glossary, metric, policy, best_practice
- LAST_UPDATED DATE

Populate with:
- All 20 business glossary entries (BG-001 through BG-020)
- All 15 metric definitions with formulas and business rules (MET-001 through MET-015)
- Industry benchmarks for aerospace KPIs
- Company policies (procurement thresholds, approval workflows)
- Best practices (safety stock calculations, supplier evaluation criteria)
- Domain terms: AOG, MRO, OEM, DPPM, ATA chapter definitions, tier levels

SEARCH SERVICE CONFIGURATION:
CREATE OR REPLACE CORTEX SEARCH SERVICE 
  AEROSPACE_SUPPLY_CHAIN.SEMANTIC.SUPPLY_CHAIN_KNOWLEDGE_SEARCH
  ON CONTENT
  ATTRIBUTES CATEGORY
  WAREHOUSE = COMPUTE_WH
  TARGET_LAG = '1 hour'
  AS (
    SELECT DOC_ID, TITLE, CONTENT, CATEGORY, LAST_UPDATED
    FROM AEROSPACE_SUPPLY_CHAIN.SEMANTIC.KNOWLEDGE_BASE
  );
```

### 4.2 Cortex Agent

```
Build a Cortex Agent for the Aerospace Supply Chain Intelligence Platform:

AGENT NAME: SUPPLY_CHAIN_COPILOT
DATABASE: AEROSPACE_SUPPLY_CHAIN
SCHEMA: SEMANTIC

AGENT CONFIGURATION:
- Model: claude-3-5-sonnet (for reasoning and content generation)
- Purpose: Answer complex supply chain questions by querying semantic views, 
  performing multi-hop reasoning, and providing actionable insights

TOOLS REQUIRED:
1. Cortex Analyst Tools — Connected to all 5 domain semantic views:
   - procurement_analyst → SV_PROCUREMENT
   - inventory_analyst → SV_INVENTORY
   - manufacturing_analyst → SV_MANUFACTURING
   - quality_analyst → SV_QUALITY
   - sales_analyst → SV_SALES

2. Cortex Search Tool — Connected to SUPPLY_CHAIN_KNOWLEDGE_SEARCH:
   - Provides access to business glossary, metric definitions, domain knowledge
   - Returns up to 5 relevant results per query

AGENT YAML SPECIFICATION:

models:
  - name: semantic_model
    type: cortex_analyst_model
    spec:
      semantic_view: AEROSPACE_SUPPLY_CHAIN.SEMANTIC.SV_PROCUREMENT

orchestration:
  target_model: claude-3-5-sonnet

instructions: |
  You are the Supply Chain Copilot, an expert in aerospace supply chain operations.
  Answer questions using governed metrics and semantic views.
  
  RULES:
  1. Always use the semantic view tools to answer data questions
  2. Use cortex_search for definitions and business rule lookups
  3. Never fabricate data — if unsure, say so
  4. When a metric is ambiguous, ask for persona context
  5. Cite the metric ID (MET-xxx) when referencing KPIs
  6. Explain the formula used when showing metric results
  
  TOOL ROUTING:
  - Data retrieval (numbers, lists, trends): Use appropriate Cortex Analyst tool
  - Definitions/knowledge: Use supply_chain_knowledge search
  - Complex multi-domain: Use multiple analyst tools sequentially
  - Root cause analysis: Search for context first, then query data

  DOMAIN ROUTING BY KEYWORDS:
  - supplier, procurement, PO, spend, buyer → procurement_analyst
  - inventory, stock, warehouse, DOI, reorder → inventory_analyst
  - production, yield, work order, capacity, scrap → manufacturing_analyst
  - quality, defect, NCR, CAPA, inspection → quality_analyst
  - customer, sales, order, fill rate, revenue → sales_analyst

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
        title_column: TITLE
        body_column: CONTENT

DEPLOYMENT:
Deploy via CoCo CLI or SQL:
  CREATE OR REPLACE CORTEX AGENT AEROSPACE_SUPPLY_CHAIN.SEMANTIC.SUPPLY_CHAIN_COPILOT
    FROM SPECIFICATION $$ <agent YAML> $$;

GRANT USAGE ON AGENT to appropriate roles.
```

---

## Step 5: Build CoWork Integration & Streamlit Dashboard

### 5.1 CoWork Access

```
Configure the SUPPLY_CHAIN_COPILOT agent to work with Snowflake CoWork:

GRANT ACCESS:
GRANT USAGE ON AGENT AEROSPACE_SUPPLY_CHAIN.SEMANTIC.SUPPLY_CHAIN_COPILOT 
  TO ROLE PUBLIC;
GRANT USAGE ON DATABASE AEROSPACE_SUPPLY_CHAIN TO ROLE PUBLIC;
GRANT USAGE ON ALL SCHEMAS IN DATABASE AEROSPACE_SUPPLY_CHAIN TO ROLE PUBLIC;
GRANT SELECT ON ALL TABLES IN SCHEMA AEROSPACE_SUPPLY_CHAIN.RAWTO ROLE PUBLIC;
GRANT USAGE ON ALL SEMANTIC VIEWS IN SCHEMA AEROSPACE_SUPPLY_CHAIN.SEMANTIC TO ROLE PUBLIC;

The agent is now accessible from the CoWork agent selector in Snowsight.
```

### 5.2 Streamlit Dashboard (7-Page App)

```
Build a 7-page Streamlit app called "Aerospace Supply Chain Intelligence Dashboard" 
deployed to Snowflake. Use wide layout, Plotly for charts, and get_active_session() 
for Snowpark queries. Include environment.yml with plotly and pandas dependencies.

IMPORTANT CONSTRAINTS:
- Do NOT use hide_index parameter on st.dataframe (not supported in this environment)
- Use st.cache_data with TTL=600 for all SQL queries
- All charts use use_container_width=True
- Use try/except with st.error() for failed queries

DEPLOYMENT:
- Stage: @AEROSPACE_SUPPLY_CHAIN.ANALYTICS.STREAMLIT_STAGE
- App Name: SUPPLY_CHAIN_DASHBOARD
- Warehouse: COMPUTE_WH

GLOBAL ELEMENTS:
- st.sidebar for navigation between pages
- Persona selector dropdown (Executive, Procurement, Planning, Manufacturing, Logistics, Quality)
- Sidebar filters: Date Range, Plant (multi-select), Supplier (searchable), Part Family
- Consistent color palette: green=#2ecc71, yellow=#f39c12, red=#e74c3c, blue=#3498db
- Session state for persona, filters, and chat history

---

PAGE 1: Executive Dashboard

- Supply Chain Health Index gauge (0-100):
  Formula: (OTD_score + FillRate_score + DOI_score + Yield_score + (100-Risk_score)) / 5
- KPI row (8 metrics as st.metric cards): OTD %, Fill Rate %, Days of Inventory, 
  Yield %, Total Spend, Revenue at Risk, Scrap %, Supplier Performance Index
- Color-code each KPI with RAG thresholds:
  OTD: green>=95, yellow>=90 | Fill: green>=98, yellow>=95
  DOI: green<=45, yellow<=60 | Yield: green>=98, yellow>=95
- 6-month trend line chart for OTD, Fill Rate, Yield, DOI
- Top 5 Risks table: highest risk suppliers + parts below safety stock
- Embedded chat input calling SNOWFLAKE.CORTEX.DATA_AGENT_RUN() with agent
  AEROSPACE_SUPPLY_CHAIN.SEMANTIC.SUPPLY_CHAIN_COPILOT
  Suggested questions: "What's driving the OTD decline?", "Which suppliers need attention?"

---

PAGE 2: Supply Chain Copilot (Chat)

- Full-page conversational interface using st.chat_message and st.chat_input
- Call SNOWFLAKE.CORTEX.DATA_AGENT_RUN() with agent 
  AEROSPACE_SUPPLY_CHAIN.SEMANTIC.SUPPLY_CHAIN_COPILOT
- Multi-turn conversation history in st.session_state
- Display responses as text, tables, or SQL code blocks
- Persona-based suggested questions:
  Executive: "Supply chain health?", "Top risks this week?"
  Procurement: "Declining OTD suppliers?", "Overdue POs?"
  Manufacturing: "Yield by plant?", "Scrap causes?"
  Logistics: "Carrier performance?", "Delayed shipments?"
- Show "Thinking..." spinner while agent processes

---

PAGE 3: Procurement Analytics

Source: FACT_PURCHASE_ORDER, FACT_PURCHASE_ORDER_LINE, DIM_SUPPLIER, DIM_PART
- KPIs: Total Spend, PO Count, Avg PO Value, Avg Lead Time
- Supplier Scorecard table (top 20, sortable): SUPPLIER_NAME, TIER_LEVEL, 
  ON_TIME_DELIVERY_PCT, QUALITY_RATING, RISK_SCORE, total spend
- PO Status donut chart by STATUS
- Supplier Risk vs Spend scatter: x=spend, y=RISK_SCORE, color=TIER_LEVEL
- Lead Time Trend: monthly average lead time line chart
- Regional Spend bar chart: total PO value by supplier REGION

---

PAGE 4: Inventory Management

Source: FACT_INVENTORY, FACT_INVENTORY_MOVEMENT, DIM_PART, DIM_PLANT, DIM_WAREHOUSE
- KPIs: Total Inventory Value, Parts Below Reorder, Avg DOI, Warehouse Utilization %
- Stockout Alert table: parts WHERE ON_HAND_QTY < SAFETY_STOCK
- DOI Distribution histogram (bands: 0-15, 15-30, 30-45, 45-60, 60+)
- Excess Inventory bar: top 15 parts where ON_HAND_QTY > MAX_STOCK
- Movement Trend area chart: receipts vs issues by month

---

PAGE 5: Manufacturing & Quality

Source: FACT_WORK_ORDER, FACT_QUALITY_EVENT, DIM_PLANT, DIM_WORK_CENTER, DIM_PART
- KPIs: Current Month Yield, Scrap Rate, Open Work Orders, Total COPQ
- Yield gauge (plotly indicator): current vs target (98%)
- Scrap Pareto bar: top 10 DEFECT_TYPE by count with cumulative line
- Work Order Status stacked bar by PLANT_ID
- Quality Trend line: monthly defect rate over 6 months
- COPQ Breakdown pie: COST_OF_QUALITY by EVENT_TYPE
- Capacity Utilization horizontal bar by WORK_CENTER_NAME

---

PAGE 6: Logistics & Delivery

Source: FACT_SHIPMENT, DIM_CARRIER, DIM_CUSTOMER, DIM_PLANT
- KPIs: Customer OTD %, Avg Transit Time, Total Freight Cost, Late Shipments count
- OTD gauge: current month vs target (95%)
- Carrier Scorecard table: name, OTD%, avg freight, shipment count
- Delay Analysis bar: late shipments by CARRIER_ID with avg delay days
- Transit Time box plot by SHIPMENT_TYPE
- Shipment Volume trend: monthly stacked area by SHIPMENT_TYPE
- Fill Rate Trend: monthly QUANTITY_SHIPPED / QUANTITY_ORDERED

---

PAGE 7: Governance & Compliance

Source: DIM_CERTIFICATION, DIM_SUPPLIER, FACT_QUALITY_EVENT
- Certification Status summary: count by FAA_APPROVED, EASA_APPROVED, AS9100
- Expiring Certifications alert: parts WHERE EXPIRY_DATE within 90 days
- Supplier Certification matrix heatmap
- ITAR-controlled parts inventory table
- Quality event resolution time trend by month
```

---

## Key Metric Formulas (Reference for Semantic Views)

```
MET-001 OTD (Overall):
  COUNT(CASE WHEN IS_ON_TIME = TRUE THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0)
  Source: FACT_SHIPMENT | Target: >= 95%

MET-002 Fill Rate:
  SUM(QUANTITY_SHIPPED) * 100.0 / NULLIF(SUM(QUANTITY_ORDERED), 0)
  Source: FACT_SALES_ORDER_LINE | Target: >= 98%

MET-003 Days of Inventory (DOI):
  ON_HAND_QTY / NULLIF(AVG_DAILY_USAGE, 0)
  Source: FACT_INVENTORY | Target: <= 45 days

MET-004 Inventory Turnover:
  COGS_ANNUAL / NULLIF(AVG_INVENTORY_VALUE, 0)
  Source: FACT_INVENTORY, FACT_INVENTORY_MOVEMENT | Target: >= 6 turns

MET-005 Risk Score:
  Composite: (Financial_Risk*0.25 + Delivery_Risk*0.25 + Quality_Risk*0.25 + Geo_Risk*0.25)
  Source: DIM_SUPPLIER | Target: <= 50

MET-006 Production Yield:
  QUANTITY_COMPLETED * 100.0 / NULLIF(QUANTITY_ORDERED, 0)
  Source: FACT_WORK_ORDER | Target: >= 98%

MET-007 Scrap Rate:
  QUANTITY_SCRAPPED * 100.0 / NULLIF(QUANTITY_ORDERED, 0)
  Source: FACT_WORK_ORDER | Target: <= 2%

MET-008 Revenue At Risk:
  SUM(TOTAL_VALUE) WHERE STATUS IN ('Delayed', 'Exception', 'Backorder')
  Source: FACT_SALES_ORDER | Target: Minimize

MET-009 WO Completion Rate:
  COUNT(CASE WHEN STATUS='Completed' THEN 1 END) * 100.0 / COUNT(*)
  Source: FACT_WORK_ORDER | Target: >= 95%

MET-010 Freight Cost per Unit:
  SUM(FREIGHT_COST) / NULLIF(SUM(QUANTITY), 0)
  Source: FACT_SHIPMENT | Target: Minimize

MET-011 Carrier OTD:
  COUNT(IS_ON_TIME=TRUE) * 100.0 / COUNT(*) GROUP BY CARRIER_ID
  Source: FACT_SHIPMENT, DIM_CARRIER | Target: >= 95%

MET-012 Supplier OTD:
  ON_TIME_DELIVERY_PCT or computed from FACT_SHIPMENT by SUPPLIER_ID
  Source: DIM_SUPPLIER, FACT_SHIPMENT | Target: >= 95%

MET-013 Defect Rate:
  SUM(QUANTITY_DEFECTIVE) * 100.0 / NULLIF(SUM(QUANTITY_INSPECTED), 0)
  Source: FACT_QUALITY_EVENT | Target: <= 3%

MET-014 Landed Cost:
  UNIT_PRICE + FREIGHT_PER_UNIT + (UNIT_PRICE * 0.03) + (UNIT_PRICE * 0.02)
  Source: FACT_PURCHASE_ORDER_LINE, FACT_SHIPMENT | Target: Minimize

MET-015 Supplier Performance Index (SPI):
  (Quality*0.30) + (Delivery*0.30) + (Cost*0.20) + (Responsiveness*0.20)
  Source: DIM_SUPPLIER, FACT_SHIPMENT, FACT_QUALITY_EVENT | Target: >= 80
```

---

## Table-to-Metric Mapping Reference

```
TABLE: DIM_SUPPLIER
Metrics Derived: Supplier OTD (MET-012), Supplier Risk (MET-005), SPI (MET-015)
Joins To: FACT_PURCHASE_ORDER, FACT_SHIPMENT, FACT_QUALITY_EVENT, DIM_SUPPLIER_PART

TABLE: DIM_PART
Metrics Derived: Landed Cost (MET-014), DOI (MET-003)
Joins To: All fact tables, DIM_BOM, DIM_SUPPLIER_PART, DIM_CERTIFICATION, DIM_ROUTING

TABLE: DIM_PLANT
Metrics Derived: Capacity Utilization
Joins To: All fact tables, DIM_WAREHOUSE, DIM_WORK_CENTER

TABLE: FACT_PURCHASE_ORDER + FACT_PURCHASE_ORDER_LINE
Metrics Derived: PO Cycle Time, Procurement Spend, Landed Cost (MET-014)
Grain: Per PO (header) / Per PO Line (detail)

TABLE: FACT_SALES_ORDER + FACT_SALES_ORDER_LINE
Metrics Derived: Fill Rate (MET-002), Revenue At Risk (MET-008)
Grain: Per SO (header) / Per SO Line (detail)

TABLE: FACT_SHIPMENT
Metrics Derived: OTD (MET-001), Carrier OTD (MET-011), Freight Cost/Unit (MET-010)
Grain: Per shipment

TABLE: FACT_INVENTORY
Metrics Derived: DOI (MET-003), Inventory Turnover (MET-004), Stockout Rate
Grain: Per part-plant-warehouse (snapshot)

TABLE: FACT_WORK_ORDER
Metrics Derived: Production Yield (MET-006), Scrap Rate (MET-007), 
                 WO Completion Rate (MET-009)
Grain: Per work order

TABLE: FACT_QUALITY_EVENT
Metrics Derived: Defect Rate (MET-013), Cost of Quality
Grain: Per quality event

TABLE: FACT_IOT_SENSOR_DATA
Metrics Derived: Equipment health, predictive maintenance alerts
Grain: Per sensor reading (time-series)
```

---

## Deployment Order (Execution Sequence)

```
PHASE 1: Foundation
→ Step 1.1: CREATE DATABASE AEROSPACE_SUPPLY_CHAIN
→ Step 1.1: CREATE SCHEMA RAW, GOLD, SEMANTIC, ANALYTICS

PHASE 2: Data Model  
→ Step 1.2: CREATE 13 dimension tables in GOLD
→ Step 1.2: CREATE 13 fact tables in GOLD
→ Step 1.2: CREATE 2 metadata tables in GOLD

PHASE 3: Data Population
→ Step 2: Seed dimension data (750 suppliers, 5000 parts, etc.)
→ Step 2: Seed fact data (20K POs, 250K shipments, etc.)
→ Step 2: Seed metadata (20 glossary terms, 15 metric definitions)

PHASE 4: Semantic Layer
→ Step 3: Create 5 domain semantic views in SEMANTIC
→ Step 3: Create cross-domain semantic views
→ Step 3: Create executive summary semantic view
→ Step 3: Deploy workspace semantic view YAML

PHASE 5: AI & Conversational
→ Step 4.1: Create KNOWLEDGE_BASE table and populate
→ Step 4.1: Create SUPPLY_CHAIN_KNOWLEDGE_SEARCH Cortex Search service
→ Step 4.2: Deploy SUPPLY_CHAIN_COPILOT Cortex Agent

PHASE 6: Access & UI
→ Step 5.1: Grant access for CoWork usage
→ Step 5.2: Build and deploy Streamlit dashboard (7 pages)

PHASE 7: Validation
→ Test agent with verified queries from each domain
→ Validate metric consistency across personas
→ Run demo flow (see below)
```

---

## Validation Checklist

```
POST-DEPLOYMENT VERIFICATION:

| # | Check | Method | Expected |
|---|-------|--------|----------|
| 1 | All tables created | SHOW TABLES IN RAW| 28 tables |
| 2 | Data loaded | SELECT COUNT(*) FROM FACT_SHIPMENT | 250,000 rows |
| 3 | Semantic views active | SHOW SEMANTIC VIEWS IN SEMANTIC | 5+ views |
| 4 | Agent responds | Query via DATA_AGENT_RUN | Valid response |
| 5 | Search returns results | Query business term | Relevant result |
| 6 | Metric consistency | Same question, different view | Same answer |
| 7 | Streamlit accessible | Navigate to app | Page loads < 3s |

CONSISTENCY TESTS:
| Test | Question | Views Tested |
|------|----------|-------------|
| T1 | "What is OTD?" | SV_PROCUREMENT, SV_SALES |
| T2 | "What is fill rate?" | SV_SALES, CUSTOMER_ORDERS_SV |
| T3 | "Total inventory value?" | SV_INVENTORY |
| T4 | "Supplier risk distribution?" | SV_PROCUREMENT |
```

---

## Judge-Winning Demo Flow

```
Recommended demonstration sequence for maximum impact:

1. START: "Give me a 30-second supply chain health summary" (Executive breadth)
2. DRILL: "Why is OTD trending down for EMEA region?" (Root cause)  
3. MULTI-HOP: "Which customers are impacted by quality issues from our 
   highest-risk suppliers?" (Ontology traversal)
4. WHAT-IF: "What if Supplier SUP-00012 goes offline — what's the blast radius?" (Scenario)
5. ACTION: "What should we do to mitigate our top 3 supply chain risks?" (Recommendation)
6. VISUAL: Show Streamlit dashboard with real-time KPIs (Operationalization)
7. CLOSE: "Create an executive briefing for our quarterly review" (Content generation)
```

---

## Master Reference Data (for Step 2 Seed Data)

```
Use the following ACTUAL entity names when seeding data. This ensures CoCo generates 
realistic, consistent reference data across all tables.

=== SUPPLIERS (Use these 100 real aerospace companies) ===

Tier 1 (10%): Hexcel Corporation, Spirit AeroSystems, Safran Aerosystems, 
  Precision Castparts, GE Aerospace, RTX Pratt & Whitney, Rolls-Royce Aerospace, 
  Collins Aerospace, Honeywell Aerospace, MTU Aero Engines

Tier 2 (30%): GKN Aerospace, Howmet Aerospace, Triumph Group, Moog Aerospace, 
  Parker Aerospace, Eaton Aerospace, Meggitt, Cobham Aerospace, Safran Aircraft Engines, 
  CFM International, ITP Aero, L3Harris Technologies, Thales Aerospace, Astronics, 
  Crane Aerospace, SKF Aerospace, RBC Bearings, Senior Aerospace, TransDigm Group, 
  Arconic

Tier 3 (60%): Alcoa Aerospace, Carpenter Technology, Haynes International, TIMET, 
  VSMPO-AVISMA, Kawasaki Aerospace, Mitsubishi Heavy Industries, Fuji Aerospace, 
  Premium AEROTEC, Latecoere, Leonardo Aerostructures, Daher Aerospace, Ducommun, 
  Aernnova Aerospace, Nordam, Barnes Aerospace, Albany Engineered Composites, 
  Curtiss-Wright, Teledyne Aerospace, Elbit Systems, Saab Aerospace, 
  Hanwha Aerospace, Rheinmetall Aerospace, CAE, Magellan Aerospace, 
  Ontic Engineering, Ametek Aerospace, General Dynamics Aerospace, 
  Northstar Aerospace, Hutchinson Aerospace, Airbus Atlantic, Smiths Aerospace, 
  Marshall Aerospace, FACC Aerospace, RUAG Aerospace, Diehl Aviation, 
  Aerojet Rocketdyne, Astra Aviation, Wesco Aircraft, Boeing Global Services, 
  Jet Aviation, ST Engineering Aerospace, AAR Corporation, HEICO Aerospace, 
  Avcorp Industries, Sargent Aerospace, Aviation Partners, Acme Aerospace, 
  Mubea Aerospace, Novaria Group, Kaman Aerospace, Valence Surface Technologies, 
  Doncasters Aerospace, Senior Flexonics Aerospace, Mubea Aerostructures, 
  Bodycote Aerospace, Duncan Aviation, Delta TechOps, Turkish Aerospace Industries, 
  Korea Aerospace Industries, Spirit Europe, ATI Specialty Materials

=== CUSTOMERS (30 organizations) ===

OEMs: Airbus, Boeing, Lockheed Martin, Northrop Grumman, Dassault Aviation, 
  Embraer, Bombardier, Textron Aviation, Gulfstream, Cessna
Defense: Leonardo, BAE Systems
Rotorcraft: Bell Helicopter, Sikorsky
Airlines: Air India, IndiGo, United Airlines, Delta Airlines, Qatar Airways, 
  Singapore Airlines, Lufthansa, ANA, Japan Airlines, Ryanair, EasyJet, 
  Virgin Atlantic, Air France, KLM, Turkish Airlines, Saudi Arabian Airlines

=== CARRIERS (25 logistics providers) ===

Air + Ground: DHL Aviation, FedEx Express, UPS Supply Chain
Multimodal: Maersk Logistics, Kuehne Nagel, DB Schenker, CEVA Logistics, DSV, 
  Expeditors, Bollore Logistics, Nippon Express, Hellmann Logistics, GEODIS, 
  Yusen Logistics, Kerry Logistics
Sea: CMA CGM Logistics
Ground: C.H. Robinson, XPO Logistics
Air Cargo: Atlas Air, Lufthansa Cargo, Qatar Airways Cargo, 
  Singapore Airlines Cargo, Emirates SkyCargo, Turkish Cargo, Air France Cargo

=== PLANTS (20 facilities) ===

| Plant Name | Region | Country | Type |
|-----------|--------|---------|------|
| Safran Hyderabad Plant | Asia Pacific | India | Manufacturing |
| Safran Bangalore Plant | Asia Pacific | India | Manufacturing |
| Safran Toulouse Plant | Europe | France | Manufacturing |
| Safran Paris Plant | Europe | France | Manufacturing |
| Safran Singapore Hub | Asia Pacific | Singapore | Distribution |
| Safran Seattle Repair Center | North America | USA | MRO |
| Safran Mexico Plant | North America | Mexico | Manufacturing |
| Safran Montreal Plant | North America | Canada | Manufacturing |
| Safran Hamburg Plant | Europe | Germany | Manufacturing |
| Safran Derby Plant | Europe | United Kingdom | Manufacturing |
| Safran Chennai Plant | Asia Pacific | India | Manufacturing |
| Safran Pune Plant | Asia Pacific | India | Manufacturing |
| Safran Nagpur Plant | Asia Pacific | India | Manufacturing |
| Safran Bangalore MRO | Asia Pacific | India | MRO |
| Safran Dallas Repair Hub | North America | USA | MRO |
| Safran Casablanca Plant | Middle East | Morocco | Manufacturing |
| Safran Munich Facility | Europe | Germany | Manufacturing |
| Safran Warsaw Facility | Europe | Poland | Manufacturing |
| Safran Singapore MRO | Asia Pacific | Singapore | MRO |
| Safran Hyderabad Engine Center | Asia Pacific | India | Engine Assembly |

Site Codes: HYD, BLR, TLS, SEA, SIN, HAM, MTL, PAR, MEX, DER

=== RAW MATERIALS (20 materials) ===

| Material Name | Type | Applications |
|--------------|------|-------------|
| Titanium Alloy Ti-6Al-4V | Titanium | Engine components, structural |
| Titanium Billet | Titanium | Forgings, fasteners |
| Inconel 718 | Nickel Alloy | High-temp engine parts |
| Inconel 625 | Nickel Alloy | Exhaust systems |
| Nickel Alloy | Nickel Alloy | Turbine components |
| Carbon Fiber Prepreg | Composite | Wing skins, nacelles |
| Composite Honeycomb | Composite | Interior panels, floors |
| Epoxy Resin | Chemical | Bonding, surface treatment |
| Ceramic Matrix Composite | Composite | Thermal protection |
| Aluminum 7075 | Aluminum | Fuselage frames, ribs |
| Aluminum 2024 | Aluminum | Wing structures |
| Aircraft Grade Steel | Steel | Landing gear, fasteners |
| Stainless Steel 316L | Steel | Hydraulic fittings |
| Copper Alloy | Aluminum | Electrical connectors |
| Magnesium Alloy | Aluminum | Non-structural castings |
| Titanium Sheet | Titanium | Skins, fairings |
| Forged Ring | Steel | Engine cases |
| Titanium Bar Stock | Titanium | Machined components |
| Aerospace Adhesive | Adhesive | Structural bonding |
| Thermal Barrier Coating | Coating | Turbine blade protection |

=== PART NAMES (30 representative parts across families) ===

Engine: Turbine Blade, Fan Blade, Compressor Blade, Turbine Disc, Engine Shaft, 
  Fuel Nozzle, Combustion Chamber
Airframe: Wing Rib, Wing Spar, Wing Panel, Fuselage Frame, Bulkhead Assembly, 
  Cargo Door
Landing: Landing Gear Assembly, Brake Assembly
Hydraulic: Hydraulic Actuator, Hydraulic Pump
Flight Controls: Control Surface, Flap Track, Spoiler Panel
Avionics: Avionics Module, Flight Control Computer, Navigation Sensor, Radar Module
Electrical: Electrical Harness, Starter Generator
Nacelle: Nacelle Panel, Pylon Assembly
Cabin: Cabin Pressure Valve, Oxygen System Module

Part Families & ATA Chapters:
| Family | Code | ATA Chapters |
|--------|------|-------------|
| Engine Components | ENG | 70-80 |
| Airframe Components | AIR | 51-57 |
| Landing Systems | LDG | 32 |
| Hydraulic Systems | HYD | 29 |
| Fuel Systems | FUEL | 28 |
| Flight Controls | FLT | 27 |
| Electrical Systems | ELEC | 24 |
| Avionics | AVN | 31, 34 |
| Cabin Systems | CAB | 25 |
| Nacelle Systems | NAC | 54 |

=== WORK CENTER TYPES (10 types) ===

| Name | Code | Machine Type | Operations |
|------|------|-------------|-----------|
| CNC Machining | CNC | CNC | Milling, drilling, boring |
| Blade Grinding | GRD | Grinding | Precision airfoil grinding |
| Composite Layup | CMP | Robot | Fiber placement, autoclave |
| Final Assembly | ASSY | Assembly Line | Component integration |
| Heat Treatment | HT | Furnace | Aging, annealing, hardening |
| NDT Inspection | NDT | Inspection Cell | X-ray, ultrasonic, dye penetrant |
| Painting Line | PNT | Robot | Surface prep, coating |
| Laser Welding | LWS | Laser | Precision joining |
| Precision Turning | TURN | CNC | Shaft, disc manufacturing |
| Quality Inspection | QI | CMM | CMM, visual inspection |

=== WAREHOUSE TYPES ===

| Type | Code | Contents |
|------|------|----------|
| Raw Material | RM | Metals, composites, chemicals |
| Finished Goods | FG | Completed parts ready for shipment |
| Spare Parts | SP | MRO inventory for aftermarket |
| WIP Storage | WIP | Work-in-process between operations |
| Distribution Center | DC | Regional distribution inventory |
```

---

## Enterprise Code Standards & ID Formats

```
All entities use specific identifier patterns. CoCo must follow these when seeding data.

| Entity | ID Format | Example |
|--------|-----------|---------|
| DIM_SUPPLIER | S00001 / SUP-{COUNTRY}-{TYPE}-{SEQ} | S00001 / SUP-US-RMS-001 |
| DIM_RAW_MATERIAL | RM000001 / RM-{MATERIAL}-{SEQ} | RM000001 / RM-TI-001 |
| DIM_PART | P000001 / {FAMILY}-{PART}-{SEQ} | P000001 / ENG-TBL-00001 |
| DIM_BOM | BOM000001 / BOM-{PROGRAM}-{SEQ} | BOM000001 / BOM-LEAP1A-001 |
| DIM_PLANT | PLNT001 / {SITE}{SEQ} | PLNT001 / HYD01 |
| DIM_WORK_CENTER | WC0001 / {SITE}-{TYPE}-{SEQ} | WC0001 / HYD-CNC-001 |
| DIM_WAREHOUSE | WH001 / {SITE}-{TYPE}-WH{SEQ} | WH001 / HYD-RM-WH01 |
| DIM_CUSTOMER | CUST00001 / CUST-{NAME}-{SEQ} | CUST00001 / CUST-AIRBUS-001 |
| DIM_CARRIER | CAR001 / CRR-{NAME}-{SEQ} | CAR001 / CRR-DHL-001 |
| FACT_PURCHASE_ORDER | PO000001 / PO-{SUPPLIER}-{YEAR}-{SEQ} | PO000001 / PO-HEXCEL-2026-000001 |
| FACT_PURCHASE_ORDER_LINE | POL000001 / {PO}-L{LINE} | POL000001 / PO-HEXCEL-2026-000001-L001 |
| FACT_SALES_ORDER | SO000001 / SO-{CUSTOMER}-{YEAR}-{SEQ} | SO000001 / SO-AIRBUS-2026-000001 |
| FACT_SALES_ORDER_LINE | SOL000001 / {SO}-L{LINE} | SOL000001 / SO-AIRBUS-2026-000001-L001 |
| FACT_SHIPMENT | SHP000001 / SHP-{SITE}-{TYPE}-{SEQ} | SHP000001 / SHP-HYD-OUT-000001 |
| FACT_QUALITY_EVENT | QE000001 / QE-{SITE}-{YEAR}-{SEQ} | QE000001 / QE-HYD-2026-000001 |
| FACT_WORK_ORDER | WO000001 / WO-{SITE}-{PROGRAM}-{SEQ} | WO000001 / WO-HYD-ENG-000001 |
| FACT_INVENTORY | INV000001 / INV-{SITE}-{TYPE}-{SEQ} | INV000001 / INV-HYD-RM-000001 |
| META_BUSINESS_GLOSSARY | BG-001 | BG-001 through BG-020 |
| META_METRIC_DEFINITION | MET-001 | MET-001 through MET-015 |

Code Components:
- {COUNTRY}: US, FR, DE, GB, IN, CA, SG, JP, MX, PL, MA
- {TYPE}: RMS, CMP, ENG, AVN, T1 (suppliers); RM, FG, SP, WIP, DC (warehouses)
- {MATERIAL}: TI, NI, AL, ST, CF, EP, CM
- {FAMILY}: ENG, AIR, LDG, HYD, FLT, AVN, ELEC, FUEL, CAB, NAC
- {PROGRAM}: A320, A350, LEAP1A, CFM56, B787, B777, F135, GE9X
- {SITE}: HYD, BLR, TLS, SEA, SIN, HAM, MTL, PAR, MEX, DER, CHN, PUN, NAG, DAL, CAS, MUN, WAR
- {YEAR}: 2024, 2025, 2026
- Shipment Type Codes: IN (inbound), OUT (outbound), TRN (interplant transfer)
```

---

## Status Enumerations & Valid Values

```
All status fields must use ONLY these valid values. Seed data must respect transitions.

=== PURCHASE ORDER STATUS ===
Open → Approved → Partially Received → Received → Closed
(Also: Cancelled — terminal from any state)

=== SALES ORDER STATUS ===
Open → Released → Partially Shipped → Delivered → Closed
(Also: Cancelled — terminal from any state)

=== SHIPMENT STATUS ===
Planned → In Transit → Delivered → Closed
(Also: Delayed — from In Transit; Exception — from any active state)

=== WORK ORDER STATUS ===
Released → In Progress → Completed → Closed
(Also: Cancelled — terminal from any state)
Types: Production, Repair, Rework, Prototype

=== QUALITY EVENT STATUS ===
Open → Investigating → Corrected → Closed

=== QUALITY EVENT TYPES ===
inspection, NCR, CAPA, audit, customer_complaint

=== DEFECT TYPES ===
Micro Crack, Surface Defect, Material Hardness Issue, Dimension Out Of Tolerance,
Coating Failure, Foreign Object Damage, Assembly Defect, Heat Treatment Failure,
Porosity, Corrosion

=== ROOT CAUSES ===
Supplier Process Variation, Machine Calibration Error, Material Non Conformance,
Operator Error, Documentation Error, Heat Treatment Variation, Tool Wear,
Process Deviation

=== CORRECTIVE ACTIONS ===
Rework Part, Scrap Material, Supplier Corrective Action Request,
Root Cause Investigation, Reinspection, Audit Supplier, Production Hold,
Update Manufacturing Process

=== DISPOSITION ===
scrap, rework, use_as_is, return_to_supplier

=== SEVERITY ===
critical, major, minor

=== PRIORITY CODES ===
AOG, Critical, High, Medium, Low

=== AOG SEVERITY ===
AOG_Critical, AOG_Urgent, AOG_Standard

=== SUPPLIER CATEGORY ===
Strategic, Preferred, Standard, Conditional

=== CUSTOMER REVENUE TIER ===
Platinum, Gold, Silver, Bronze

=== PART LIFECYCLE STATUS ===
Active, Obsolete, Prototype, End_of_Life

=== PART CRITICALITY ===
critical, major, minor

=== MAKE/BUY CODE ===
Make, Buy
```

---

## Business Glossary Seed Content (META_BUSINESS_GLOSSARY)

```
Seed the following 20 rows into META_BUSINESS_GLOSSARY with full definitions:

BG-001 | On-Time Delivery (OTD) | % shipments delivered on or before promised date. 
  On-time if actual_delivery_date <= promised_delivery_date. Only completed shipments 
  (Delivered/Closed). Target: 95%. | FACT_SHIPMENT | Supply Chain

BG-002 | Fill Rate | % customer demand fulfilled from available inventory on first 
  attempt. Quantity shipped vs ordered. Backorders = unfilled. Target: 98%. | 
  FACT_SALES_ORDER_LINE | Supply Chain

BG-003 | Days of Inventory (DOI) | Days current on-hand inventory sustains average 
  daily demand. Uses trailing 90-day consumption. Target: 45 days. | FACT_INVENTORY | Planning

BG-004 | Inventory Turnover | Times inventory consumed and replenished per year. 
  Higher is better. Target: 8 turns/year. | FACT_INVENTORY | Finance

BG-005 | Supplier Performance Index (SPI) | Composite score 0-100: Quality (30%) + 
  Delivery (30%) + Cost (20%) + Responsiveness (20%). Target: 80. | DIM_SUPPLIER | Procurement

BG-006 | Critical Supplier | Strategic category AND Tier 1 AND annual spend > $10M. 
  Requires quarterly reviews and alternate source development. | DIM_SUPPLIER | Procurement

BG-007 | Revenue At Risk | Total value of customer orders impacted by supplier delays, 
  quality issues, or inventory shortages. | FACT_SALES_ORDER + FACT_SHIPMENT | Executive

BG-008 | Landed Cost | Total procurement cost: purchase price + freight + import duties 
  (3%) + handling (2%). | FACT_PURCHASE_ORDER_LINE + FACT_SHIPMENT | Finance

BG-009 | Yield Rate | % production meeting quality on first pass. Reworked parts not 
  counted as good. Target: 97%. | FACT_WORK_ORDER | Manufacturing

BG-010 | Defect Rate | % inspected parts found defective. Lower is better. | 
  FACT_QUALITY_EVENT | Quality

BG-011 | Perfect Order Rate | % orders delivered complete + on-time + damage-free + 
  correct docs. All 4 conditions simultaneously. Target: 90%. | FACT_SHIPMENT | Supply Chain

BG-012 | Capacity Utilization | % available production capacity used. Available = 
  shifts × hours/shift × working_days. Target: 85%. | FACT_WORK_ORDER + DIM_WORK_CENTER | Manufacturing

BG-013 | Cash-to-Cash Cycle | Days between paying suppliers and receiving payment. 
  DIO + DSO - DPO. Lower is better. Target: 60 days. | Multiple fact tables | Finance

BG-014 | AOG (Aircraft On Ground) | Highest priority — aircraft grounded, parts must 
  ship within 4 hours. Triggers emergency procurement. | FACT_AOG_EVENT | Operations

BG-015 | Procurement Spend | Total PO value in period (all currencies converted to USD). | 
  FACT_PURCHASE_ORDER | Finance

BG-016 | Reorder Point | Inventory level triggering replenishment. When available_qty < 
  reorder_point, PR or WO is triggered. | FACT_INVENTORY | Planning

BG-017 | Supplier Risk Score | Composite 0-100 (higher = riskier). High Risk if 
  OTD < 85% OR quality_score < 70 OR financial_risk = High. | DIM_SUPPLIER | Procurement

BG-018 | Cost of Poor Quality (COPQ) | Financial impact of quality failures: scrap + 
  rework + warranty + inspection + customer returns. | FACT_QUALITY_EVENT | Quality

BG-019 | Overstocked | Available qty > max stock level. Excess capital tied up, 
  potential obsolescence risk. | FACT_INVENTORY | Planning

BG-020 | Delayed Shipment | Status "In Transit" and promised_delivery_date already 
  passed. Indicates transportation failure. | FACT_SHIPMENT | Logistics
```

---

## Multi-Hop Question Catalog (Agent Validation)

```
These multi-hop questions test the agent's ability to reason across multiple 
semantic views. Use these as validation test cases after deployment.

=== LEVEL 1: TWO HOPS ===

MH-01: "Which suppliers with declining OTD are causing inventory stockouts?"
  HOP 1 (SV_PROCUREMENT): Get suppliers where OTD < 90%
  HOP 2 (SV_INVENTORY): Get parts below reorder point supplied by those suppliers
  Expected: Supplier list + affected parts + inventory status + revenue at risk

MH-06: "Which carriers are causing the most customer delivery delays?"
  HOP 1 (SV_SALES): Find late customer deliveries
  HOP 2 (SHIPMENT_ANALYTICS_SV): Link to carrier performance
  Expected: Carrier ranking by customer-impacting delays

=== LEVEL 2: THREE HOPS ===

MH-02: "What is the revenue impact of supplier quality failures this quarter?"
  HOP 1 (SV_QUALITY): Get critical quality events by supplier
  HOP 2 (SV_PROCUREMENT): Identify affected parts and POs
  HOP 3 (SV_SALES): Find customer orders with those parts at risk
  Expected: Suppliers + COPQ amount + revenue at risk + affected customers

MH-05: "Are equipment anomalies linked to specific supplier material batches?"
  HOP 1 (FACT_IOT_SENSOR_DATA): Work centers with anomalies
  HOP 2 (SV_MANUFACTURING): Work orders during anomaly windows
  HOP 3 (SV_PROCUREMENT): Trace to supplier batches
  Expected: Equipment → Part → Supplier correlation

=== LEVEL 3: FOUR+ HOPS (Full Supply Chain Traversal) ===

MH-03: "Why did Customer X not receive their order on time?"
  HOP 1 (SV_SALES): Find late orders for customer
  HOP 2 (SV_INVENTORY): Check stock at promised date
  HOP 3 (SV_PROCUREMENT): Check PO/supplier delivery status
  HOP 4 (SHIPMENT_ANALYTICS_SV): Check carrier transit delays
  Expected: Full root cause chain with corrective recommendation

MH-04: "If Supplier X goes offline, what is the total business impact?"
  HOP 1 (SV_PROCUREMENT): Parts supplied exclusively + open POs
  HOP 2 (SV_INVENTORY): Days of supply remaining per affected part
  HOP 3 (SV_MANUFACTURING): Work orders consuming those parts
  HOP 4 (SV_SALES): Customer orders depending on those parts
  Expected: Parts affected + inventory runway + production at risk + revenue at risk

MH-07: "Trace a quality failure from detection to root cause across the supply chain"
  HOP 1 (SV_QUALITY): Quality event details (defect, severity)
  HOP 2 (SV_MANUFACTURING): Work order and work center context
  HOP 3 (SV_PROCUREMENT): Incoming material lot from supplier
  HOP 4 (SV_INVENTORY): Other inventory from same batch
  Expected: Full traceability from defect → process → supplier → batch exposure

=== SCENARIO QUESTIONS (for demo) ===

S1: "Give me a 30-second supply chain health summary"
S2: "What are our top 5 supply chain risks right now?"
S3: "Which customers are impacted by quality issues from our highest-risk suppliers?"
S4: "What should we do to mitigate single-source risk?"
S5: "Create an executive briefing for our quarterly review"
S6: "Compare Q1 vs Q2 performance across all KPIs"
S7: "Show the end-to-end timeline from PO to customer delivery for Part PRT-00123"
```

---

## Persona Routing & Domain Questions

```
Each persona has specific questions the agent must handle. The agent uses these 
keywords to route to the correct semantic view.

=== PROCUREMENT PERSONA ===
Keywords: supplier, procurement, PO, purchase order, spend, buyer, contract, landed cost
Routes to: SV_PROCUREMENT
Sample questions:
- "What is our total procurement spend this year?" → SUM(TOTAL_VALUE) with date filter
- "Who are our top 10 suppliers by spend?" → Ranked list
- "Which suppliers are high risk?" → RISK_SCORE > 70
- "What is the average PO cycle time?" → AVG(RECEIVED_DATE - ORDER_DATE)
- "How many open purchase orders do we have?" → COUNT WHERE STATUS = 'Open'
- "Compare supplier performance: Tier 1 vs Tier 2" → SPI by tier
- "What is our single-source risk?" → Parts with only 1 active supplier

=== PLANNING / INVENTORY PERSONA ===
Keywords: inventory, stock, warehouse, DOI, reorder, safety stock, excess, turnover
Routes to: SV_INVENTORY
Sample questions:
- "What is our total inventory value?" → SUM(TOTAL_VALUE)
- "Which parts are below safety stock?" → AVAILABLE < SAFETY_STOCK
- "What is the average days of inventory?" → AVG(DOI)
- "Which plants have the most excess inventory?" → Overstocked value
- "Show me slow-moving parts (DOI > 90 days)" → Filtered list
- "What parts need reordering today?" → AVAILABLE_QTY < REORDER_POINT

=== MANUFACTURING PERSONA ===
Keywords: production, yield, work order, capacity, scrap, plant, work center, WO
Routes to: SV_MANUFACTURING
Sample questions:
- "What is the yield rate by plant this month?" → AVG(YIELD_RATE) GROUP BY PLANT
- "Which work centers have the most scrap?" → SUM(QUANTITY_SCRAPPED)
- "Show production schedule adherence trend" → Actual vs planned dates
- "What is capacity utilization by work center type?" → Hours used / available

=== QUALITY PERSONA ===
Keywords: quality, defect, NCR, CAPA, inspection, scrap, rework, COPQ
Routes to: SV_QUALITY
Sample questions:
- "What is the defect rate by supplier?" → QUANTITY_DEFECTIVE / QUANTITY_INSPECTED
- "Show cost of quality trend by quarter" → SUM(COST_OF_QUALITY) by quarter
- "Which root causes are most common for critical defects?" → GROUP BY ROOT_CAUSE
- "Average time to resolve quality events by severity?" → AVG(RESOLUTION_DATE - EVENT_DATE)

=== LOGISTICS PERSONA ===
Keywords: shipment, carrier, transit, freight, delivery, tracking, transport, logistics
Routes to: SV_SALES (outbound), SHIPMENT_ANALYTICS_SV
Sample questions:
- "What is customer on-time delivery this month?" → IS_ON_TIME pct
- "Carrier performance this month?" → OTD by CARRIER_ID
- "Shipments delayed today?" → WHERE STATUS = 'Delayed'
- "Total freight cost this quarter?" → SUM(FREIGHT_COST)

=== EXECUTIVE PERSONA ===
Keywords: health, summary, KPI, risk, trend, compare, executive, overview
Routes to: EXECUTIVE_SUMMARY_SV or multiple domain SVs
Sample questions:
- "Give me a supply chain health summary" → Composite health index
- "What are the top 5 risks?" → Highest risk scores + stockouts + delays
- "Month-over-month trends for OTD, quality, and spend" → Multi-metric trend
- "How does Q2 compare to Q1 across all KPIs?" → Period comparison
```

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          USER INTERFACES                                      │
│    ┌──────────────┐    ┌──────────────┐    ┌──────────────────────┐         │
│    │   CoWork     │    │  Streamlit   │    │   Cortex Agent API   │         │
│    │  (Chat UI)   │    │ (Dashboard)  │    │  (DATA_AGENT_RUN)    │         │
│    └──────┬───────┘    └──────┬───────┘    └──────────┬───────────┘         │
│           │                    │                       │                      │
├───────────┼────────────────────┼───────────────────────┼──────────────────────┤
│           └────────────────────┼───────────────────────┘                      │
│                                ▼                                              │
│    ┌─────────────────────────────────────────────────────────────────┐       │
│    │               SUPPLY_CHAIN_COPILOT (Cortex Agent)                │       │
│    │                   Model: claude-3-5-sonnet                        │       │
│    │                                                                   │       │
│    │    ┌───────────────────┐    ┌──────────────────────────────┐    │       │
│    │    │   Cortex Search   │    │      Cortex Analyst           │    │       │
│    │    │  (Knowledge Base) │    │  (Semantic View Queries)      │    │       │
│    │    └──────────┬────────┘    └──────────┬───────────────────┘    │       │
│    └───────────────┼────────────────────────┼────────────────────────┘       │
│                    │                        │                                 │
├────────────────────┼────────────────────────┼─────────────────────────────────┤
│                    ▼                        ▼                                 │
│    ┌─────────────────────┐  ┌──────────────────────────────────────┐         │
│    │   KNOWLEDGE_BASE    │  │         SEMANTIC VIEWS                │         │
│    │  (Glossary, Rules)  │  │  SV_PROCUREMENT | SV_INVENTORY        │         │
│    │                     │  │  SV_MANUFACTURING | SV_QUALITY         │         │
│    │                     │  │  SV_SALES | Cross-Domain SVs           │         │
│    └─────────────────────┘  └──────────────┬───────────────────────┘         │
│                                            │                                 │
├────────────────────────────────────────────┼─────────────────────────────────┤
│                                            ▼                                 │
│    ┌─────────────────────────────────────────────────────────────────┐       │
│    │                 RAWSCHEMA (Star Schema)                         │       │
│    │   13 Dimensions + 13 Facts + 2 Meta Tables                       │       │
│    │   28 tables | 4M+ rows | Clustered & Optimized                   │       │
│    └─────────────────────────────────────────────────────────────────┘       │
│                                                                              │
│    Platform: Snowflake | Model: claude-3-5-sonnet | Warehouse: COMPUTE_WH    │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## File Reference (COCO_CLI_HACKATHON/ folder)

| File | Purpose | Used In Step |
|------|---------|-------------|
| 01_PROJECT_OVERVIEW.md | Challenge statement, objectives, architecture | Context |
| 02_BUSINESS_GLOSSARY.md | Canonical term definitions | Step 2, Step 4.1 |
| 03_DOMAIN_MODEL.md | Entity relationships and ontology | Step 1, Step 3 |
| 04_ER_MODEL.md | ER diagrams | Step 1 |
| 05_DATA_DICTIONARY.md | Full column-level documentation | Step 1.2 |
| 06_DDL_SPEC.sql | Working DDL (can execute directly) | Step 1.2 |
| 07_MASTER_REFERENCE_DATA.md | Reference data specifications | Step 2 |
| 08_ONTOLOGY_MODEL.md | Formal ontology definitions | Step 3 |
| 10_SEMANTIC_VIEWS.md | Semantic view design patterns and specs | Step 3 |
| 11_METRIC_CATALOG.md | Complete KPI formulas and targets | Step 2, Step 3 |
| 12_CORTEX_SEARCH.md | Search service configuration | Step 4.1 |
| 13_AGENT_ARCHITECTURE.md | Agent YAML, tool routing, instructions | Step 4.2 |
| 14_COWORK_ASSISTANT.md | CoWork integration spec | Step 5.1 |
| 15_BUSINESS_QUESTIONS.md | 78 validated test questions | Validation |
| 16_MULTI_HOP_QUESTIONS.md | Complex reasoning test cases | Validation |
| 17_EXECUTIVE_KPIS.md | Executive dashboard KPI definitions | Step 5.2 |
| 18_GOVERNANCE.md | Data governance rules | Step 3 |
| 19_STREAMLIT_REQUIREMENTS.md | 7-page dashboard UI spec | Step 5.2 |
| 20_DEPLOYMENT_SPEC.md | Deployment architecture & order | All |

---

*Built with Snowflake CoCo CLI | Hackathon: Supply Chain Ontology & Governed Conversational Analytics*
*Database: AEROSPACE_SUPPLY_CHAIN | Schemas: RAW, GOLD, SEMANTIC, ANALYTICS | Tables: 28 (13 DIM + 13 FACT + 2 META)*
