# AEROSPACE SUPPLY CHAIN INTELLIGENCE PLATFORM — CoCo CLI Build File

**Instruction:** Execute this file in Snowflake CoCo CLI with `Build @this_file`. CoCo will deploy the complete platform end-to-end.

**Database:** AEROSPACE_SUPPLY_CHAIN_AI  
**Schemas:** RAW, SEMANTIC, ANALYTICS  
**Role:** ACCOUNTADMIN | **Warehouse:** COMPUTE_WH

---

## STEP 1: CREATE DATABASE & SCHEMAS

Create the database and three schemas. Execute these SQL statements:

```sql
CREATE DATABASE IF NOT EXISTS AEROSPACE_SUPPLY_CHAIN_AI;
CREATE SCHEMA IF NOT EXISTS AEROSPACE_SUPPLY_CHAIN_AI.RAW;
CREATE SCHEMA IF NOT EXISTS AEROSPACE_SUPPLY_CHAIN_AI.SEMANTIC;
CREATE SCHEMA IF NOT EXISTS AEROSPACE_SUPPLY_CHAIN_AI.ANALYTICS;
```

---

## STEP 2: CREATE DIMENSION TABLES (13 tables)

Execute all CREATE TABLE statements in AEROSPACE_SUPPLY_CHAIN_AI.RAW schema:

```sql
USE SCHEMA AEROSPACE_SUPPLY_CHAIN_AI.RAW;

CREATE OR REPLACE TABLE DIM_SUPPLIER (
    SUPPLIER_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY,
    SUPPLIER_ID VARCHAR(20) NOT NULL UNIQUE,
    SUPPLIER_NAME VARCHAR(200) NOT NULL,
    COUNTRY VARCHAR(50),
    REGION VARCHAR(50),
    TIER_LEVEL NUMBER(1),
    CATEGORY VARCHAR(50),
    RISK_SCORE NUMBER(5,2),
    QUALITY_SCORE NUMBER(5,2),
    DELIVERY_SCORE NUMBER(5,2),
    FINANCIAL_RISK VARCHAR(20),
    CERTIFICATION_STATUS VARCHAR(50),
    ANNUAL_SPEND NUMBER(15,2),
    CONTRACT_END_DATE DATE,
    IS_ACTIVE BOOLEAN DEFAULT TRUE,
    CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE DIM_RAW_MATERIAL (
    RAW_MATERIAL_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY,
    MATERIAL_ID VARCHAR(20) NOT NULL UNIQUE,
    MATERIAL_NAME VARCHAR(100) NOT NULL,
    MATERIAL_GROUP VARCHAR(50),
    UNIT_OF_MEASURE VARCHAR(20),
    STANDARD_COST NUMBER(15,4),
    LEAD_TIME_DAYS NUMBER(5),
    SHELF_LIFE_DAYS NUMBER(5),
    HAZMAT_CLASS VARCHAR(20),
    CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE DIM_PART (
    PART_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY,
    PART_ID VARCHAR(20) NOT NULL UNIQUE,
    PART_NAME VARCHAR(200) NOT NULL,
    PART_FAMILY VARCHAR(50),
    ATA_CHAPTER NUMBER(3),
    UNIT_COST NUMBER(15,4),
    WEIGHT_KG NUMBER(10,3),
    LEAD_TIME_DAYS NUMBER(5),
    SAFETY_STOCK NUMBER(10),
    REORDER_POINT NUMBER(10),
    MAKE_BUY_CODE VARCHAR(10),
    CRITICALITY VARCHAR(20),
    LIFECYCLE_STATUS VARCHAR(20) DEFAULT 'Active',
    CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE DIM_PLANT (
    PLANT_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY,
    PLANT_ID VARCHAR(20) NOT NULL UNIQUE,
    PLANT_NAME VARCHAR(200) NOT NULL,
    CITY VARCHAR(100),
    COUNTRY VARCHAR(50),
    REGION VARCHAR(50),
    CAPACITY_UNITS NUMBER(10),
    SHIFTS_PER_DAY NUMBER(1) DEFAULT 2,
    IS_ACTIVE BOOLEAN DEFAULT TRUE,
    CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE DIM_WAREHOUSE (
    WAREHOUSE_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY,
    WAREHOUSE_ID VARCHAR(20) NOT NULL UNIQUE,
    WAREHOUSE_NAME VARCHAR(200) NOT NULL,
    PLANT_ID VARCHAR(20),
    WAREHOUSE_TYPE VARCHAR(50),
    CAPACITY_SQFT NUMBER(10),
    TEMPERATURE_CONTROLLED BOOLEAN DEFAULT FALSE,
    IS_ACTIVE BOOLEAN DEFAULT TRUE,
    CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE DIM_WORK_CENTER (
    WORK_CENTER_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY,
    WORK_CENTER_ID VARCHAR(20) NOT NULL UNIQUE,
    WORK_CENTER_NAME VARCHAR(200) NOT NULL,
    PLANT_ID VARCHAR(20),
    WORK_CENTER_TYPE VARCHAR(50),
    MACHINE_TYPE VARCHAR(50),
    CAPACITY_HOURS_PER_DAY NUMBER(5,2),
    IS_ACTIVE BOOLEAN DEFAULT TRUE,
    CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE DIM_CUSTOMER (
    CUSTOMER_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY,
    CUSTOMER_ID VARCHAR(15) NOT NULL UNIQUE,
    CUSTOMER_NAME VARCHAR(200) NOT NULL,
    CUSTOMER_TYPE VARCHAR(50),
    COUNTRY VARCHAR(50),
    REGION VARCHAR(50),
    REVENUE_TIER VARCHAR(20),
    ANNUAL_REVENUE NUMBER(15,2),
    CONTRACT_STATUS VARCHAR(20) DEFAULT 'Active',
    CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE DIM_CARRIER (
    CARRIER_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY,
    CARRIER_ID VARCHAR(20) NOT NULL UNIQUE,
    CARRIER_NAME VARCHAR(200) NOT NULL,
    SERVICE_TYPE VARCHAR(50),
    COVERAGE_REGION VARCHAR(100),
    ON_TIME_RATE NUMBER(5,2),
    IS_ACTIVE BOOLEAN DEFAULT TRUE,
    CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE DIM_CALENDAR (
    CALENDAR_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY,
    DATE_KEY DATE NOT NULL UNIQUE,
    YEAR NUMBER(4),
    QUARTER NUMBER(1),
    MONTH NUMBER(2),
    MONTH_NAME VARCHAR(20),
    WEEK_OF_YEAR NUMBER(2),
    DAY_OF_WEEK NUMBER(1),
    DAY_NAME VARCHAR(20),
    IS_WORKING_DAY BOOLEAN,
    FISCAL_YEAR NUMBER(4),
    FISCAL_QUARTER NUMBER(1)
);

CREATE OR REPLACE TABLE DIM_BOM (
    BOM_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY,
    BOM_ID VARCHAR(20) NOT NULL UNIQUE,
    PARENT_PART_ID VARCHAR(20),
    CHILD_PART_ID VARCHAR(20),
    QUANTITY_PER NUMBER(10,4),
    UNIT_OF_MEASURE VARCHAR(20),
    BOM_LEVEL NUMBER(3),
    EFFECTIVE_DATE DATE,
    EXPIRATION_DATE DATE,
    PROGRAM VARCHAR(50),
    CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE DIM_SUPPLIER_PART (
    SUPPLIER_PART_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY,
    SUPPLIER_ID VARCHAR(20) NOT NULL,
    PART_ID VARCHAR(20) NOT NULL,
    UNIT_PRICE NUMBER(15,4),
    LEAD_TIME_DAYS NUMBER(5),
    MIN_ORDER_QTY NUMBER(10),
    CONTRACT_START_DATE DATE,
    CONTRACT_END_DATE DATE,
    IS_PREFERRED BOOLEAN DEFAULT FALSE,
    QUALIFICATION_STATUS VARCHAR(50),
    CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE DIM_CERTIFICATION (
    CERTIFICATION_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY,
    CERTIFICATION_ID VARCHAR(20) NOT NULL UNIQUE,
    PART_ID VARCHAR(20),
    SUPPLIER_ID VARCHAR(20),
    CERTIFICATION_TYPE VARCHAR(100),
    CERTIFYING_BODY VARCHAR(100),
    ISSUE_DATE DATE,
    EXPIRY_DATE DATE,
    STATUS VARCHAR(20) DEFAULT 'Active',
    CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE DIM_ROUTING (
    ROUTING_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY,
    ROUTING_ID VARCHAR(20) NOT NULL UNIQUE,
    PART_ID VARCHAR(20),
    OPERATION_SEQ NUMBER(5),
    WORK_CENTER_ID VARCHAR(20),
    OPERATION_NAME VARCHAR(100),
    SETUP_TIME_MIN NUMBER(8,2),
    RUN_TIME_MIN NUMBER(8,2),
    CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);
```

---

## STEP 3: CREATE FACT TABLES (13 tables)

```sql
USE SCHEMA AEROSPACE_SUPPLY_CHAIN_AI.RAW;

CREATE OR REPLACE TABLE FACT_PURCHASE_ORDER (
    PO_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY,
    PO_ID VARCHAR(20) NOT NULL UNIQUE,
    SUPPLIER_ID VARCHAR(20),
    PLANT_ID VARCHAR(20),
    ORDER_DATE DATE,
    PROMISED_DATE DATE,
    RECEIVED_DATE DATE,
    TOTAL_VALUE NUMBER(15,2),
    CURRENCY VARCHAR(3) DEFAULT 'USD',
    STATUS VARCHAR(50),
    BUYER_ID VARCHAR(20),
    PRIORITY VARCHAR(20),
    CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
) CLUSTER BY LINEAR(ORDER_DATE, SUPPLIER_ID);

CREATE OR REPLACE TABLE FACT_PURCHASE_ORDER_LINE (
    PO_LINE_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY,
    PO_LINE_ID VARCHAR(30) NOT NULL UNIQUE,
    PO_ID VARCHAR(20),
    PART_ID VARCHAR(20),
    QUANTITY_ORDERED NUMBER(10),
    QUANTITY_RECEIVED NUMBER(10),
    UNIT_PRICE NUMBER(15,4),
    LINE_VALUE NUMBER(15,2),
    FREIGHT_COST NUMBER(12,2),
    LANDED_COST NUMBER(15,2),
    CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE FACT_PURCHASE_REQUISITION (
    PR_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY,
    PR_ID VARCHAR(20) NOT NULL UNIQUE,
    PART_ID VARCHAR(20),
    PLANT_ID VARCHAR(20),
    REQUESTED_DATE DATE,
    REQUIRED_DATE DATE,
    QUANTITY NUMBER(10),
    ESTIMATED_COST NUMBER(15,2),
    STATUS VARCHAR(50),
    REQUESTOR_ID VARCHAR(20),
    PRIORITY VARCHAR(20),
    CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE FACT_SALES_ORDER (
    SO_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY,
    SO_ID VARCHAR(20) NOT NULL UNIQUE,
    CUSTOMER_ID VARCHAR(15),
    PLANT_ID VARCHAR(20),
    ORDER_DATE DATE,
    REQUESTED_DATE DATE,
    PROMISED_DATE DATE,
    TOTAL_VALUE NUMBER(15,2),
    CURRENCY VARCHAR(3) DEFAULT 'USD',
    STATUS VARCHAR(50),
    PRIORITY VARCHAR(20),
    CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
) CLUSTER BY LINEAR(ORDER_DATE, CUSTOMER_ID);

CREATE OR REPLACE TABLE FACT_SALES_ORDER_LINE (
    SO_LINE_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY,
    SO_LINE_ID VARCHAR(30) NOT NULL UNIQUE,
    SO_ID VARCHAR(20),
    PART_ID VARCHAR(20),
    QUANTITY_ORDERED NUMBER(10),
    QUANTITY_SHIPPED NUMBER(10),
    UNIT_PRICE NUMBER(15,4),
    LINE_VALUE NUMBER(15,2),
    BACKORDER_QTY NUMBER(10) DEFAULT 0,
    CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE FACT_SHIPMENT (
    SHIPMENT_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY,
    SHIPMENT_ID VARCHAR(20) NOT NULL UNIQUE,
    SHIPMENT_TYPE VARCHAR(10),
    CARRIER_ID VARCHAR(20),
    ORIGIN_PLANT_ID VARCHAR(20),
    DESTINATION_PLANT_ID VARCHAR(20),
    SUPPLIER_ID VARCHAR(20),
    CUSTOMER_ID VARCHAR(15),
    PO_ID VARCHAR(20),
    SO_ID VARCHAR(20),
    SHIP_DATE DATE,
    PROMISED_DELIVERY_DATE DATE,
    ACTUAL_DELIVERY_DATE DATE,
    FREIGHT_COST NUMBER(12,2),
    WEIGHT_KG NUMBER(10,2),
    STATUS VARCHAR(50),
    IS_ON_TIME BOOLEAN,
    CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
) CLUSTER BY LINEAR(SHIP_DATE, SHIPMENT_TYPE);

CREATE OR REPLACE TABLE FACT_INVENTORY (
    INVENTORY_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY,
    INVENTORY_ID VARCHAR(20) NOT NULL UNIQUE,
    PART_ID VARCHAR(20),
    PLANT_ID VARCHAR(20),
    WAREHOUSE_ID VARCHAR(20),
    SNAPSHOT_DATE DATE,
    AVAILABLE_QTY NUMBER(10),
    RESERVED_QTY NUMBER(10),
    ON_HAND_QTY NUMBER(10),
    TOTAL_VALUE NUMBER(15,2),
    DAYS_OF_INVENTORY NUMBER(8,2),
    REORDER_POINT NUMBER(10),
    SAFETY_STOCK NUMBER(10),
    MAX_STOCK_LEVEL NUMBER(10),
    CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
) CLUSTER BY LINEAR(SNAPSHOT_DATE, PLANT_ID);

CREATE OR REPLACE TABLE FACT_INVENTORY_MOVEMENT (
    MOVEMENT_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY,
    MOVEMENT_ID VARCHAR(20) NOT NULL UNIQUE,
    PART_ID VARCHAR(20),
    PLANT_ID VARCHAR(20),
    WAREHOUSE_ID VARCHAR(20),
    MOVEMENT_DATE DATE,
    MOVEMENT_TYPE VARCHAR(50),
    QUANTITY NUMBER(10),
    REFERENCE_ID VARCHAR(30),
    CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE FACT_WORK_ORDER (
    WO_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY,
    WO_ID VARCHAR(20) NOT NULL UNIQUE,
    PART_ID VARCHAR(20),
    PLANT_ID VARCHAR(20),
    WORK_CENTER_ID VARCHAR(20),
    ORDER_DATE DATE,
    PLANNED_START_DATE DATE,
    ACTUAL_START_DATE DATE,
    PLANNED_END_DATE DATE,
    ACTUAL_END_DATE DATE,
    QUANTITY_PLANNED NUMBER(10),
    QUANTITY_PRODUCED NUMBER(10),
    QUANTITY_SCRAPPED NUMBER(10),
    YIELD_RATE NUMBER(5,2),
    STATUS VARCHAR(50),
    WO_TYPE VARCHAR(50),
    PRIORITY VARCHAR(20),
    PROGRAM VARCHAR(50),
    CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
) CLUSTER BY LINEAR(ORDER_DATE, PLANT_ID);

CREATE OR REPLACE TABLE FACT_QUALITY_EVENT (
    QE_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY,
    QE_ID VARCHAR(20) NOT NULL UNIQUE,
    PART_ID VARCHAR(20),
    SUPPLIER_ID VARCHAR(20),
    PLANT_ID VARCHAR(20),
    EVENT_DATE DATE,
    EVENT_TYPE VARCHAR(50),
    SEVERITY VARCHAR(20),
    DEFECT_TYPE VARCHAR(100),
    ROOT_CAUSE VARCHAR(200),
    CORRECTIVE_ACTION VARCHAR(200),
    DISPOSITION VARCHAR(50),
    QUANTITY_INSPECTED NUMBER(10),
    QUANTITY_DEFECTIVE NUMBER(10),
    COST_OF_QUALITY NUMBER(12,2),
    RESOLUTION_DATE DATE,
    STATUS VARCHAR(50),
    CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
) CLUSTER BY LINEAR(EVENT_DATE, PLANT_ID);

CREATE OR REPLACE TABLE FACT_IOT_SENSOR_DATA (
    SENSOR_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY,
    SENSOR_ID VARCHAR(20) NOT NULL,
    WORK_CENTER_ID VARCHAR(20),
    PLANT_ID VARCHAR(20),
    READING_TIMESTAMP TIMESTAMP_NTZ,
    TEMPERATURE_C NUMBER(8,2),
    VIBRATION_MM_S NUMBER(8,2),
    PRESSURE_BAR NUMBER(8,2),
    RPM NUMBER(10),
    POWER_KW NUMBER(8,2),
    OIL_LEVEL_PCT NUMBER(5,2),
    STATUS VARCHAR(20),
    ALERT_FLAG BOOLEAN
) CLUSTER BY LINEAR(READING_TIMESTAMP, PLANT_ID);

CREATE OR REPLACE TABLE FACT_AOG_EVENT (
    AOG_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY,
    AOG_ID VARCHAR(20) NOT NULL UNIQUE,
    CUSTOMER_ID VARCHAR(15),
    PART_ID VARCHAR(20),
    EVENT_DATE DATE,
    DURATION_HOURS NUMBER(8,2),
    REVENUE_IMPACT NUMBER(15,2),
    ROOT_CAUSE VARCHAR(500),
    RESOLUTION_ACTION VARCHAR(500),
    SEVERITY_CODE VARCHAR(20),
    RESOLUTION_DATE DATE,
    MAINTENANCE_PROVIDER_ID VARCHAR(20),
    CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE FACT_REPAIR_ORDER (
    REPAIR_ORDER_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY,
    REPAIR_ORDER_ID VARCHAR(20) NOT NULL UNIQUE,
    ENGINE_SN VARCHAR(30),
    PART_ID VARCHAR(20),
    CUSTOMER_ID VARCHAR(15),
    RECEIVED_DATE DATE,
    RELEASED_DATE DATE,
    REPAIR_COST NUMBER(15,2),
    REPAIR_STATUS VARCHAR(50),
    TECHNICIAN_ID VARCHAR(20),
    REPAIR_TYPE VARCHAR(50),
    WARRANTY_FLAG VARCHAR(1),
    TURNAROUND_TIME_DAYS NUMBER(5),
    CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);
```

---

## STEP 4: CREATE METADATA TABLES (with Change Tracking)

```sql
USE SCHEMA AEROSPACE_SUPPLY_CHAIN_AI.RAW;

CREATE OR REPLACE TABLE META_BUSINESS_GLOSSARY (
    TERM_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY,
    TERM_ID VARCHAR(15) NOT NULL UNIQUE,
    BUSINESS_TERM VARCHAR(100) NOT NULL,
    BUSINESS_DEFINITION VARCHAR(500),
    SOURCE_TABLE VARCHAR(100),
    FORMULA VARCHAR(1000),
    OWNER VARCHAR(100),
    STATUS VARCHAR(20) DEFAULT 'Active',
    CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
) CHANGE_TRACKING = TRUE;

CREATE OR REPLACE TABLE META_METRIC_DEFINITION (
    METRIC_SK NUMBER NOT NULL AUTOINCREMENT PRIMARY KEY,
    METRIC_ID VARCHAR(15) NOT NULL UNIQUE,
    METRIC_NAME VARCHAR(100) NOT NULL,
    METRIC_DESCRIPTION VARCHAR(500),
    FORMULA VARCHAR(2000),
    UNIT VARCHAR(20),
    TARGET_VALUE NUMBER(18,4),
    SOURCE_TABLES VARCHAR(500),
    GRAIN VARCHAR(200),
    BUSINESS_RULE VARCHAR(1000),
    CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
) CHANGE_TRACKING = TRUE;
```

---

## STEP 5: SEED ALL DATA

Populate all tables with realistic aerospace supply chain data using the Master Reference Data catalog. Use explicit VALUES for reference tables and GENERATOR-based inserts for high-volume transactional tables.

### 5.1 DIM_PLANT — 20 Manufacturing Facilities

```
| PLANT_ID | Plant Name                    | City       | Country        | Region         | Type             |
|----------|-------------------------------|------------|----------------|----------------|------------------|
| PLNT001  | Safran Hyderabad Plant        | Hyderabad  | India          | Asia Pacific   | Manufacturing    |
| PLNT002  | Safran Bangalore Plant        | Bangalore  | India          | Asia Pacific   | Manufacturing    |
| PLNT003  | Safran Toulouse Plant         | Toulouse   | France         | Europe         | Manufacturing    |
| PLNT004  | Safran Paris Plant            | Paris      | France         | Europe         | Manufacturing    |
| PLNT005  | Safran Singapore Hub          | Singapore  | Singapore      | Asia Pacific   | Distribution     |
| PLNT006  | Safran Seattle Repair Center  | Seattle    | USA            | North America  | MRO              |
| PLNT007  | Safran Mexico Plant           | Mexico City| Mexico         | North America  | Manufacturing    |
| PLNT008  | Safran Montreal Plant         | Montreal   | Canada         | North America  | Manufacturing    |
| PLNT009  | Safran Hamburg Plant          | Hamburg    | Germany        | Europe         | Manufacturing    |
| PLNT010  | Safran Derby Plant            | Derby      | United Kingdom | Europe         | Manufacturing    |
| PLNT011  | Safran Chennai Plant          | Chennai    | India          | Asia Pacific   | Manufacturing    |
| PLNT012  | Safran Pune Plant             | Pune       | India          | Asia Pacific   | Manufacturing    |
| PLNT013  | Safran Nagpur Plant           | Nagpur     | India          | Asia Pacific   | Manufacturing    |
| PLNT014  | Safran Bangalore MRO          | Bangalore  | India          | Asia Pacific   | MRO              |
| PLNT015  | Safran Dallas Repair Hub      | Dallas     | USA            | North America  | MRO              |
| PLNT016  | Safran Casablanca Plant       | Casablanca | Morocco        | Middle East    | Manufacturing    |
| PLNT017  | Safran Munich Facility        | Munich     | Germany        | Europe         | Manufacturing    |
| PLNT018  | Safran Warsaw Facility        | Warsaw     | Poland         | Europe         | Manufacturing    |
| PLNT019  | Safran Singapore MRO          | Singapore  | Singapore      | Asia Pacific   | MRO              |
| PLNT020  | Safran Hyderabad Engine Center| Hyderabad  | India          | Asia Pacific   | Engine Assembly  |
```

Site Codes: HYD, BLR, TLS, SEA, SIN, HAM, MTL, PAR, MEX, DER

### 5.2 DIM_CARRIER — 25 Logistics Providers

```
| CARRIER_ID | Carrier Name            | Service Type   | Coverage        |
|------------|-------------------------|----------------|-----------------|
| CAR001     | DHL Aviation            | Air + Ground   | Global          |
| CAR002     | FedEx Express           | Air + Ground   | Global          |
| CAR003     | UPS Supply Chain        | Air + Ground   | Global          |
| CAR004     | Maersk Logistics        | Sea + Ground   | Global          |
| CAR005     | Kuehne Nagel            | Multimodal     | Global          |
| CAR006     | DB Schenker             | Multimodal     | Europe/Asia     |
| CAR007     | CEVA Logistics          | Multimodal     | Global          |
| CAR008     | DSV                     | Multimodal     | Global          |
| CAR009     | Expeditors              | Multimodal     | North America   |
| CAR010     | Bollore Logistics       | Multimodal     | Europe/Africa   |
| CAR011     | Nippon Express          | Multimodal     | Asia Pacific    |
| CAR012     | C.H. Robinson           | Ground         | North America   |
| CAR013     | Hellmann Logistics      | Multimodal     | Europe          |
| CAR014     | GEODIS                  | Multimodal     | Europe          |
| CAR015     | CMA CGM Logistics       | Sea            | Global          |
| CAR016     | XPO Logistics           | Ground         | North America   |
| CAR017     | Yusen Logistics         | Multimodal     | Asia Pacific    |
| CAR018     | Kerry Logistics         | Multimodal     | Asia Pacific    |
| CAR019     | Atlas Air               | Air Cargo      | Global          |
| CAR020     | Lufthansa Cargo         | Air Cargo      | Europe/Global   |
| CAR021     | Qatar Airways Cargo     | Air Cargo      | Middle East     |
| CAR022     | Singapore Airlines Cargo| Air Cargo      | Asia Pacific    |
| CAR023     | Emirates SkyCargo       | Air Cargo      | Middle East     |
| CAR024     | Turkish Cargo           | Air Cargo      | Europe/Asia     |
| CAR025     | Air France Cargo        | Air Cargo      | Europe          |
```

### 5.3 DIM_CUSTOMER — 30 Aerospace Customers

```
| CUSTOMER_ID | Customer Name          | Type              | Tier     |
|-------------|------------------------|-------------------|----------|
| CUST00001   | Airbus                 | OEM               | Platinum |
| CUST00002   | Boeing                 | OEM               | Platinum |
| CUST00003   | Lockheed Martin        | Defense           | Platinum |
| CUST00004   | Northrop Grumman       | Defense           | Gold     |
| CUST00005   | Dassault Aviation      | OEM               | Gold     |
| CUST00006   | Embraer                | OEM               | Gold     |
| CUST00007   | Bombardier             | OEM               | Gold     |
| CUST00008   | Leonardo               | Defense           | Silver   |
| CUST00009   | BAE Systems            | Defense           | Gold     |
| CUST00010   | Textron Aviation       | OEM               | Silver   |
| CUST00011   | Gulfstream             | Business Aviation | Silver   |
| CUST00012   | Bell Helicopter        | Rotorcraft        | Silver   |
| CUST00013   | Sikorsky               | Rotorcraft        | Silver   |
| CUST00014   | Air India              | Airline           | Silver   |
| CUST00015   | IndiGo                 | Airline           | Bronze   |
| CUST00016   | United Airlines        | Airline           | Gold     |
| CUST00017   | Delta Airlines         | Airline           | Gold     |
| CUST00018   | Qatar Airways          | Airline           | Gold     |
| CUST00019   | Singapore Airlines     | Airline           | Gold     |
| CUST00020   | Lufthansa              | Airline           | Gold     |
| CUST00021   | ANA                    | Airline           | Silver   |
| CUST00022   | Japan Airlines         | Airline           | Silver   |
| CUST00023   | Ryanair                | Airline           | Bronze   |
| CUST00024   | EasyJet                | Airline           | Bronze   |
| CUST00025   | Virgin Atlantic        | Airline           | Silver   |
| CUST00026   | Air France             | Airline           | Gold     |
| CUST00027   | KLM                    | Airline           | Silver   |
| CUST00028   | Turkish Airlines       | Airline           | Silver   |
| CUST00029   | Saudi Arabian Airlines | Airline           | Silver   |
| CUST00030   | Rolls-Royce Civil      | OEM               | Platinum |
```

### 5.4 DIM_SUPPLIER — 100 Aerospace Suppliers

Seed the full 100-supplier list from Master Reference Data:

```
| #  | Supplier Name                  | #  | Supplier Name                  |
|----|--------------------------------|----|--------------------------------|
| 1  | Hexcel Corporation             | 51 | Elbit Systems                  |
| 2  | Spirit AeroSystems             | 52 | Saab Aerospace                 |
| 3  | Safran Aerosystems             | 53 | Hanwha Aerospace               |
| 4  | Precision Castparts            | 54 | Rheinmetall Aerospace          |
| 5  | ATI Specialty Materials        | 55 | CAE                            |
| 6  | GE Aerospace                   | 56 | Magellan Aerospace             |
| 7  | RTX Pratt & Whitney            | 57 | Ontic Engineering              |
| 8  | Rolls-Royce Aerospace          | 58 | Ametek Aerospace               |
| 9  | Collins Aerospace              | 59 | General Dynamics Aerospace     |
| 10 | Honeywell Aerospace            | 60 | Northstar Aerospace            |
| 11 | MTU Aero Engines               | 61 | Hutchinson Aerospace           |
| 12 | GKN Aerospace                  | 62 | Airbus Atlantic                |
| 13 | Howmet Aerospace               | 63 | Smiths Aerospace               |
| 14 | Triumph Group                  | 64 | Marshall Aerospace             |
| 15 | Moog Aerospace                 | 65 | FACC Aerospace                 |
| 16 | Parker Aerospace               | 66 | RUAG Aerospace                 |
| 17 | Eaton Aerospace                | 67 | Diehl Aviation                 |
| 18 | Meggitt                        | 68 | Aerojet Rocketdyne             |
| 19 | Cobham Aerospace               | 69 | Astra Aviation                 |
| 20 | Safran Aircraft Engines        | 70 | Wesco Aircraft                 |
| 21 | CFM International              | 71 | Boeing Global Services         |
| 22 | ITP Aero                       | 72 | Jet Aviation                   |
| 23 | L3Harris Technologies          | 73 | ST Engineering Aerospace       |
| 24 | Thales Aerospace               | 74 | AAR Corporation                |
| 25 | Astronics                      | 75 | HEICO Aerospace                |
| 26 | Crane Aerospace                | 76 | Avcorp Industries              |
| 27 | SKF Aerospace                  | 77 | Sargent Aerospace              |
| 28 | RBC Bearings                   | 78 | Aviation Partners              |
| 29 | Senior Aerospace               | 79 | Acme Aerospace                 |
| 30 | TransDigm Group                | 80 | Mubea Aerospace                |
| 31 | Arconic                        | 81 | Novaria Group                  |
| 32 | Alcoa Aerospace                | 82 | Kaman Aerospace                |
| 33 | Carpenter Technology           | 83 | Valence Surface Technologies   |
| 34 | Haynes International           | 84 | Doncasters Aerospace           |
| 35 | TIMET                          | 85 | Senior Flexonics Aerospace     |
| 36 | VSMPO-AVISMA                   | 86 | Mubea Aerostructures           |
| 37 | Kawasaki Aerospace             | 87 | Bodycote Aerospace             |
| 38 | Mitsubishi Heavy Industries    | 88 | Duncan Aviation                |
| 39 | Fuji Aerospace                 | 89 | Delta TechOps                  |
| 40 | Premium AEROTEC                | 90 | Turkish Aerospace Industries   |
| 41 | Latecoere                      | 91 | Korea Aerospace Industries     |
| 42 | Leonardo Aerostructures        | 92 | Spirit Europe                  |
| 43 | Daher Aerospace                | 93 | ZeroAvia Components            |
| 44 | Ducommun                       | 94 | Vertical Aerospace Systems     |
| 45 | Aernnova Aerospace             | 95 | Joby Aviation Supply           |
| 46 | Nordam                         | 96 | Lilium Components              |
| 47 | Barnes Aerospace               | 97 | Volocopter Systems             |
| 48 | Albany Engineered Composites   | 98 | Blue Origin Components         |
| 49 | Curtiss-Wright                 | 99 | SpaceX Manufacturing           |
| 50 | Teledyne Aerospace             | 100| Rocket Lab Aerospace           |
```

**Supplier Types:** Raw Material, Component, Engine, Avionics, Tier-1
**Categories:** Strategic (Tier 1, >$10M), Preferred (OTD>90%, Quality>85), Standard (all others)
**Countries:** US, FR, DE, GB, IN, CA, SG, JP, MX, PL, MA
**Tier Distribution:** 1-10 = Tier 1, 11-40 = Tier 2, 41-100 = Tier 3
**Scores:** RISK_SCORE (15-95), QUALITY_SCORE (65-99), DELIVERY_SCORE (70-99) — randomized

### 5.5 DIM_RAW_MATERIAL — 20 Materials

```
| MATERIAL_ID | Material Name               | Material Group    | Unit | Std Cost | Lead Time |
|-------------|----------------------------|-------------------|------|----------|-----------|
| RM000001    | Titanium Alloy Ti-6Al-4V   | Titanium          | KG   | 85.50    | 45 days   |
| RM000002    | Titanium Billet            | Titanium          | KG   | 92.00    | 60 days   |
| RM000003    | Inconel 718                | Nickel Alloy      | KG   | 125.00   | 60 days   |
| RM000004    | Inconel 625                | Nickel Alloy      | KG   | 135.00   | 55 days   |
| RM000005    | Nickel Alloy               | Nickel Alloy      | KG   | 110.00   | 50 days   |
| RM000006    | Carbon Fiber Prepreg T800  | Composites        | SQM  | 210.00   | 30 days   |
| RM000007    | Composite Honeycomb        | Composites        | SQM  | 180.00   | 25 days   |
| RM000008    | Epoxy Resin System EA9396  | Adhesives         | LTR  | 450.00   | 14 days   |
| RM000009    | Ceramic Matrix Composite   | Composites        | KG   | 580.00   | 90 days   |
| RM000010    | Aluminum 7075-T6 Sheet     | Aluminum Alloys   | KG   | 32.50    | 21 days   |
| RM000011    | Aluminum 2024              | Aluminum Alloys   | KG   | 28.00    | 18 days   |
| RM000012    | Aircraft Grade Steel       | Steel             | KG   | 45.00    | 30 days   |
| RM000013    | Stainless Steel 316L       | Steel             | KG   | 52.00    | 28 days   |
| RM000014    | Copper Alloy               | Non-Ferrous       | KG   | 38.00    | 21 days   |
| RM000015    | Magnesium Alloy            | Non-Ferrous       | KG   | 65.00    | 35 days   |
| RM000016    | Titanium Sheet             | Titanium          | KG   | 95.00    | 50 days   |
| RM000017    | Forged Ring                | Steel             | EA   | 2500.00  | 75 days   |
| RM000018    | Titanium Bar Stock         | Titanium          | KG   | 88.00    | 45 days   |
| RM000019    | Aerospace Adhesive         | Adhesives         | LTR  | 320.00   | 14 days   |
| RM000020    | Thermal Barrier Coating    | Coatings          | LTR  | 750.00   | 21 days   |
```

### 5.6 DIM_PART — 500 Parts (30 Named Types × Variants)

**Part Families and ATA Chapter mapping:**

| Family | Code | ATA Chapters | Part Names |
|--------|------|-------------|------------|
| Engine Components | ENG | 70-80 | Turbine Blade, Fan Blade, Compressor Blade, Turbine Disc, Engine Shaft, Fuel Nozzle, Combustion Chamber |
| Airframe Components | AIR | 51-57 | Wing Rib, Wing Spar, Wing Panel, Fuselage Frame, Bulkhead Assembly, Cargo Door |
| Landing Systems | LDG | 32 | Landing Gear Assembly, Brake Assembly |
| Hydraulic Systems | HYD | 29 | Hydraulic Actuator, Hydraulic Pump |
| Flight Controls | FLT | 27 | Control Surface, Flap Track, Spoiler Panel |
| Avionics | AVN | 31, 34 | Avionics Module, Flight Control Computer, Navigation Sensor, Radar Module |
| Electrical Systems | ELEC | 24 | Electrical Harness, Starter Generator |
| Nacelle Systems | NAC | 54 | Nacelle Panel, Pylon Assembly |
| Cabin Systems | CAB | 25 | Cabin Pressure Valve, Oxygen System Module |

Generate 500 parts: cycle through 30 names with variant suffixes (001-017). 
Columns: UNIT_COST ($150-$125,000), WEIGHT_KG (0.1-250), LEAD_TIME_DAYS (7-90), SAFETY_STOCK (5-100), REORDER_POINT (10-200), MAKE_BUY_CODE (60% Buy, 40% Make), CRITICALITY (25% critical, 35% major, 40% minor).

### 5.7 DIM_WORK_CENTER — 50 Work Centers (10 types × 5 plants)

| Work Center Type | Code | Machine Type | Capacity Hours/Day |
|-----------------|------|--------------|-------------------|
| CNC Machining | CNC | CNC | 20.0 |
| Blade Grinding | GRD | Grinding | 20.0 |
| Composite Layup | CMP | Robot | 12.0 |
| Final Assembly | ASSY | Assembly Line | 16.0 |
| Heat Treatment | HT | Furnace | 12.0 |
| NDT Inspection | NDT | Inspection Cell | 12.0 |
| Painting Line | PNT | Robot | 12.0 |
| Laser Welding | LWS | Laser | 12.0 |
| Precision Turning | TURN | CNC | 20.0 |
| Quality Inspection | QI | CMM | 12.0 |

Generate one of each type per plant = 50 rows.

### 5.8 DIM_WAREHOUSE — 20 Warehouses (4 types × 5 plants)

| Type | Code | Contents | Temp Controlled |
|------|------|----------|-----------------|
| Raw Material | RM | Metals, composites, chemicals | Yes |
| Finished Goods | FG | Completed parts ready for shipment | No |
| Spare Parts | SP | MRO inventory for aftermarket | Yes |
| WIP Storage | WIP | Work-in-process between operations | No |

Capacity: RM=25K sqft, FG=35K, SP=15K, WIP=20K.

### 5.9 DIM_CALENDAR — 181 Days

Generate from 2026-01-01 through 2026-06-30 using GENERATOR. Include YEAR, QUARTER, MONTH, MONTH_NAME, WEEK_OF_YEAR, DAY_OF_WEEK, DAY_NAME, IS_WORKING_DAY (Mon-Fri=TRUE), FISCAL_YEAR, FISCAL_QUARTER.

### 5.10 Generated Dimension Data

| Table | Rows | Generation Logic |
|-------|------|-----------------|
| DIM_BOM | 500 | Parent-child assembly links across programs (A320, A350, LEAP1A, CFM56, B787, B777, F135, GE9X) |
| DIM_SUPPLIER_PART | 500 | Each part mapped to a supplier with UNIT_PRICE, LEAD_TIME, MIN_ORDER_QTY, QUALIFICATION_STATUS |
| DIM_CERTIFICATION | 500 | FAA PMA, EASA Part 21, AS9100D, NADCAP, ISO 9001 — issued by FAA/EASA/SAE/BSI |
| DIM_ROUTING | 1000 | 2 operations per part: Rough Machining, Finish Grinding, Heat Treatment, NDT Inspection, Surface Coating, Assembly, Balancing, Final Inspection, Deburring, Welding |

### 5.11 Transactional Fact Data Generation

| Table | Rows | Key Data Points |
|-------|------|-----------------|
| FACT_PURCHASE_ORDER | 500 | Date range: 2026-01-01 to 2026-06-20. Status: Open/Approved/Partially Received/Received/Closed. Priority: AOG/Critical/High/Medium/Low. Total value: $5K-$2.5M |
| FACT_PURCHASE_ORDER_LINE | 2,500 | 5 lines per PO. Qty: 5-200. Unit Price: $100-$50K. Includes FREIGHT_COST and LANDED_COST |
| FACT_PURCHASE_REQUISITION | 500 | Status: Draft/Submitted/Approved/Converted to PO/Rejected |
| FACT_SALES_ORDER | 400 | Customers from DIM_CUSTOMER. Value: $25K-$5M. Status: Open/Released/Partially Shipped/Delivered/Closed/Cancelled |
| FACT_SALES_ORDER_LINE | 1,600 | 4 lines per SO. Qty: 1-100. 15% have backorders |
| FACT_SHIPMENT | 5,000 | Mix: 2000 Inbound (from supplier) + 2000 Outbound (to customer) + 1000 Interplant. Transit: 3-21 days. 85% have delivery dates. IS_ON_TIME computed |
| FACT_INVENTORY | 500 | One snapshot per part. AVAILABLE_QTY (0-500), RESERVED_QTY (0-100), DOI (5-120 days) |
| FACT_INVENTORY_MOVEMENT | 10,000 | Types: Receipt, Issue, Transfer, Return, Adjustment, Scrap (cycled) |
| FACT_WORK_ORDER | 1,500 | Programs: A320/A350/LEAP1A/CFM56/B787/B777/F135/GE9X. Types: Production/Repair/Rework/Prototype. 70% completed. Yield: 90-100% |
| FACT_QUALITY_EVENT | 1,000 | Types: inspection/NCR/CAPA/audit/customer_complaint. Severity: critical(20%)/major(40%)/minor(40%) |
| FACT_IOT_SENSOR_DATA | 10,000 | Sensors per work center. Temp(18-450°C), Vibration(0.1-15mm/s), Pressure(1-25bar), RPM(500-25K). Status: Normal(85%)/Warning(10%)/Critical(5%) |
| FACT_AOG_EVENT | 25 | High-impact events. Duration: 2-96hrs. Revenue impact: $250K-$5M. Severity: AOG_Critical/Urgent/Standard |
| FACT_REPAIR_ORDER | 250 | Types: overhaul/repair/modification/inspection. TAT: 7-45 days. 20% warranty |

### 5.12 Quality Domain Reference Values

**Defect Types:** Micro Crack, Surface Defect, Material Hardness Issue, Dimension Out Of Tolerance, Coating Failure, Foreign Object Damage, Assembly Defect, Heat Treatment Failure, Porosity, Corrosion

**Root Causes:** Supplier Process Variation, Machine Calibration Error, Material Non Conformance, Operator Error, Documentation Error, Heat Treatment Variation, Tool Wear, Process Deviation

**Corrective Actions:** Rework Part, Scrap Material, Supplier Corrective Action Request, Root Cause Investigation, Reinspection, Audit Supplier, Production Hold, Update Manufacturing Process

**Dispositions:** scrap, rework, use_as_is, return_to_supplier

### 5.13 Status Enumerations

| Entity | Valid Statuses |
|--------|---------------|
| Purchase Order | Open → Approved → Partially Received → Received → Closed (+ Cancelled) |
| Sales Order | Open → Released → Partially Shipped → Delivered → Closed (+ Cancelled) |
| Shipment | Planned → In Transit → Delivered → Closed (+ Delayed) |
| Work Order | Released → In Progress → Completed → Closed (+ Cancelled) |
| Quality Event | Open → Investigating → Corrected → Closed |
| Work Order Type | Production, Repair, Rework, Prototype |

### 5.14 Metadata Seed

**META_BUSINESS_GLOSSARY** — 20 canonical terms:

| ID | Term | Definition | Formula |
|----|------|-----------|---------|
| BG-001 | On-Time Delivery (OTD) | % shipments delivered on/before promised date | COUNT(IS_ON_TIME) / COUNT(*) * 100 |
| BG-002 | Fill Rate | % demand fulfilled from available inventory | SUM(SHIPPED) / SUM(ORDERED) * 100 |
| BG-003 | Days of Inventory (DOI) | Days on-hand sustains average demand | ON_HAND / AVG_DAILY_DEMAND |
| BG-004 | Inventory Turnover | Times inventory consumed per year | Annual COGS / AVG Inventory |
| BG-005 | Supplier Performance Index | Composite: Q30% + D30% + C20% + R20% | Weighted score 0-100 |
| BG-006 | Critical Supplier | Strategic + Tier 1 + Spend > $10M | Boolean classification |
| BG-007 | Revenue At Risk | Order value impacted by disruptions | SUM(affected order values) |
| BG-008 | Landed Cost | Price + freight + 3% duties + 2% handling | Unit + freight/qty + 5% |
| BG-009 | Yield Rate | % production meeting quality first-pass | PRODUCED / (PRODUCED+SCRAPPED) * 100 |
| BG-010 | Defect Rate | % inspected parts found defective | DEFECTIVE / INSPECTED * 100 |
| BG-011 | Perfect Order Rate | Complete + on-time + no damage + correct docs | All 4 conditions |
| BG-012 | Capacity Utilization | % available capacity used | ACTUAL / AVAILABLE * 100 |
| BG-013 | Cash-to-Cash Cycle | Days between paying suppliers and receiving payment | DIO + DSO - DPO |
| BG-014 | AOG | Aircraft grounded, 4-hour response required | Emergency flag |
| BG-015 | Procurement Spend | Total PO value in period | SUM(TOTAL_VALUE) |
| BG-016 | Reorder Point | Level triggering replenishment | AVG_DEMAND * LEAD_TIME + SAFETY_STOCK |
| BG-017 | Supplier Risk Score | Composite 0-100, higher = riskier | OTD/Quality/Financial weighted |
| BG-018 | COPQ | Financial impact of quality failures | SUM(COST_OF_QUALITY) |
| BG-019 | Overstocked | Available qty > max stock level | Boolean flag |
| BG-020 | Delayed Shipment | In Transit past promised delivery | Boolean flag |

**META_METRIC_DEFINITION** — 24 metrics with full spec:

| ID | Metric | Formula | Unit | Target | Domain |
|----|--------|---------|------|--------|--------|
| MET-001 | OTD Overall | on-time/total*100 | % | 95 | Procurement |
| MET-002 | Fill Rate | shipped/ordered*100 | % | 98 | Logistics |
| MET-003 | DOI | ON_HAND/avg_demand | Days | 45 | Inventory |
| MET-004 | Inventory Turnover | COGS/avg_inv | Turns | 8 | Inventory |
| MET-005 | Supplier Risk | Composite | Score | ≤50 | Procurement |
| MET-006 | Production Yield | produced/(prod+scrap)*100 | % | 97 | Manufacturing |
| MET-007 | Scrap Rate | scrapped/planned*100 | % | ≤3 | Manufacturing |
| MET-008 | Revenue at Risk | SUM(affected orders) | USD | $0 | Executive |
| MET-009 | WO Completion | on-time/total*100 | % | 90 | Manufacturing |
| MET-010 | Freight Cost/Unit | freight/weight | USD/kg | ≤5 | Logistics |
| MET-011 | Carrier OTD | carrier on-time/total*100 | % | 90 | Logistics |
| MET-012 | Supplier OTD | inbound on-time/total*100 | % | 95 | Procurement |
| MET-013 | Defect Rate | defective/inspected*100 | % | ≤2 | Quality |
| MET-014 | Landed Cost | unit+freight+5% | USD | minimize | Procurement |
| MET-015 | SPI | Q*0.3+D*0.3+C*0.2+R*0.2 | Score | 80 | Procurement |
| MET-016 | Stockout Rate | zero_stock/total*100 | % | ≤1 | Inventory |
| MET-017 | Excess Inventory | excess_val/total_val*100 | % | ≤5 | Inventory |
| MET-018 | AOG Response Time | AVG(duration_hours) | Hours | ≤4 | Logistics |
| MET-019 | Procurement Spend | SUM(PO_VALUE) | USD | budget | Procurement |
| MET-020 | COPQ | SUM(COST_OF_QUALITY) | USD | minimize | Quality |
| MET-021 | Cash-to-Cash | DIO+DSO-DPO | Days | 60 | Executive |
| MET-022 | Perfect Order Rate | all_4_conditions/total*100 | % | 90 | Executive |
| MET-023 | Capacity Utilization | actual/available*100 | % | 85 | Manufacturing |
| MET-024 | SC Health Index | normalized composite/5 | Score | ≥80 | Executive |

---

## STEP 6: CREATE ANALYTICS VIEWS (Derivation Rules)

Create in AEROSPACE_SUPPLY_CHAIN_AI.ANALYTICS:

### 6.1 V_DERIVED_SHIPMENT_METRICS (DR-01)
- IS_ON_TIME_DERIVED = ACTUAL_DELIVERY_DATE <= PROMISED_DELIVERY_DATE
- TRANSIT_DAYS = DATEDIFF(day, SHIP_DATE, ACTUAL_DELIVERY_DATE)
- FREIGHT_COST_PER_KG = FREIGHT_COST / WEIGHT_KG

### 6.2 V_DERIVED_WORK_ORDER_METRICS (DR-02)
- YIELD_RATE_DERIVED = PRODUCED / (PRODUCED + SCRAPPED) * 100
- SCRAP_RATE = SCRAPPED / PLANNED * 100
- SCHEDULE_ADHERENT = ACTUAL_END <= PLANNED_END
- SCHEDULE_VARIANCE_DAYS = DATEDIFF(day, PLANNED_END, ACTUAL_END)

### 6.3 V_DERIVED_INVENTORY_ALERTS (DR-03, DR-04)
- NEEDS_REORDER = AVAILABLE_QTY < REORDER_POINT
- IS_OVERSTOCKED = AVAILABLE_QTY > MAX_STOCK_LEVEL
- INVENTORY_STATUS = STOCKOUT/CRITICAL/REORDER/EXCESS/NORMAL
- EXCESS_VALUE = (AVAILABLE - MAX) * unit_value
- JOINs DIM_PART and DIM_PLANT for context

### 6.4 V_DERIVED_PO_CYCLE_TIME (DR-05)
- CYCLE_TIME_DAYS = DATEDIFF(day, ORDER_DATE, RECEIVED_DATE)
- DAYS_LATE = DATEDIFF(day, PROMISED_DATE, RECEIVED_DATE)
- PO_ON_TIME = RECEIVED_DATE <= PROMISED_DATE
- JOINs DIM_SUPPLIER

### 6.5 V_DERIVED_SUPPLIER_RISK (DR-06)
- RISK_CLASSIFICATION: High if OTD<85% OR Quality<70 OR Financial=High
- IS_CRITICAL_SUPPLIER: Strategic AND Tier 1 AND Spend>$10M
- CONTRACT_EXPIRING_SOON: within 90 days
- SPI_SCORE = QUALITY*0.3 + DELIVERY*0.3 + (100-RISK)*0.4

### 6.6 V_DERIVED_MATERIAL_REQUIREMENTS (DR-07)
- REQUIRED_QUANTITY = WO_QUANTITY * BOM_QUANTITY_PER
- JOINs FACT_WORK_ORDER + DIM_BOM + DIM_PART (parent + child)
- Filter: WO STATUS IN ('Released', 'In Progress')

### 6.7 V_INTEGRITY_CONSTRAINT_VIOLATIONS
UNION ALL of checks:
- IC-01: PO references inactive supplier
- IC-02: SO references inactive customer
- IC-03: Negative inventory quantity
- IC-04: BOM self-referencing
- IC-05: Shipment dates not chronological
- IC-06: WO planned dates not sequential
- IC-07: Quality event references non-existent part

### 6.8 V_ONTOLOGY_HEALTH_SUMMARY
- GROUP BY CONSTRAINT_ID, COUNT(*) from V_INTEGRITY_CONSTRAINT_VIOLATIONS

### 6.9 Threshold Alerting

Create table METRIC_THRESHOLDS with columns: METRIC_ID, METRIC_NAME, GREEN_MIN, GREEN_MAX, YELLOW_MIN, YELLOW_MAX, RED_CONDITION, DIRECTION (VARCHAR(20)).

Populate 16 rows with threshold configs for key metrics.

Create V_METRIC_ALERTS view that:
1. Computes live metric values from source fact tables
2. JOINs to METRIC_THRESHOLDS
3. Outputs RAG_STATUS (GREEN/YELLOW/RED) per metric
4. Include ACTUAL_VALUE, TARGET_VALUE, VARIANCE

### 6.10 EXECUTIVE_KPI_MONTHLY Table

CREATE TABLE with pre-aggregated monthly KPIs:
- OTD_PCT, FILL_RATE_PCT, PROCUREMENT_SPEND, AVG_YIELD_RATE, SCRAP_RATE, DEFECT_RATE, TOTAL_COPQ
- Aggregated from FACT_SHIPMENT, FACT_SALES_ORDER_LINE, FACT_PURCHASE_ORDER, FACT_WORK_ORDER, FACT_QUALITY_EVENT
- Keyed by YEAR, MONTH, MONTH_NAME, QUARTER

---

## STEP 7: CREATE KNOWLEDGE BASE & CORTEX SEARCH

### 7.1 Create Knowledge Base Table

```sql
CREATE OR REPLACE TABLE AEROSPACE_SUPPLY_CHAIN_AI.SEMANTIC.KNOWLEDGE_BASE (
    DOC_ID VARCHAR(50) PRIMARY KEY,
    TITLE VARCHAR(500),
    CONTENT VARCHAR(16000),
    CATEGORY VARCHAR(100),
    LAST_UPDATED DATE DEFAULT CURRENT_DATE()
) CHANGE_TRACKING = TRUE;
```

### 7.2 Populate Knowledge Base (46 documents)

Insert documents across these categories:
- **glossary** (17 docs): Extended business term definitions including entity types (Actors, Objects, Events)
- **metric** (12 docs): Metric catalog summaries by domain + RAG threshold reference
- **disambiguation** (4 docs): Persona-aware resolution for "delivery performance", "cost", "inventory", "risk"
- **ontology** (5 docs): Entity types, process flow, derivation rules reference
- **governance** (2 docs): One-definition principle, auditability/consistency
- **policy** (3 docs): Approval thresholds, quality escalation, single-source risk
- **best_practice** (3 docs): Safety stock calculation, supplier evaluation, industry benchmarks

### 7.3 Create Cortex Search Service

```sql
CREATE OR REPLACE CORTEX SEARCH SERVICE
  AEROSPACE_SUPPLY_CHAIN_AI.SEMANTIC.SUPPLY_CHAIN_KNOWLEDGE_SEARCH
  ON CONTENT
  ATTRIBUTES TERM_ID, CATEGORY, OWNER, SOURCE_TABLE
  WAREHOUSE = COMPUTE_WH
  TARGET_LAG = '1 hour'
  AS (
    SELECT
      TERM_ID AS TERM_ID,
      'glossary' AS CATEGORY,
      OWNER AS OWNER,
      SOURCE_TABLE AS SOURCE_TABLE,
      BUSINESS_TERM || ': ' || BUSINESS_DEFINITION || 
        COALESCE(' Formula: ' || FORMULA, '') AS CONTENT
    FROM AEROSPACE_SUPPLY_CHAIN_AI.RAW.META_BUSINESS_GLOSSARY
    WHERE STATUS = 'Active'
    
    UNION ALL
    
    SELECT
      METRIC_ID AS TERM_ID,
      'metric' AS CATEGORY,
      'Platform' AS OWNER,
      SOURCE_TABLES AS SOURCE_TABLE,
      METRIC_NAME || ': ' || METRIC_DESCRIPTION || 
        ' Formula: ' || FORMULA ||
        COALESCE(' Unit: ' || UNIT, '') ||
        COALESCE(' Target: ' || TARGET_VALUE::VARCHAR, '') ||
        COALESCE(' Grain: ' || GRAIN, '') ||
        COALESCE(' Rule: ' || BUSINESS_RULE, '') AS CONTENT
    FROM AEROSPACE_SUPPLY_CHAIN_AI.RAW.META_METRIC_DEFINITION

    UNION ALL

    SELECT
      DOC_ID AS TERM_ID,
      CATEGORY AS CATEGORY,
      'Platform' AS OWNER,
      'KNOWLEDGE_BASE' AS SOURCE_TABLE,
      TITLE || ': ' || CONTENT AS CONTENT
    FROM AEROSPACE_SUPPLY_CHAIN_AI.SEMANTIC.KNOWLEDGE_BASE
  );
```

---

## STEP 8: CREATE SEMANTIC VIEWS (9 views)

Use `CALL SYSTEM$CREATE_SEMANTIC_VIEW_FROM_YAML('AEROSPACE_SUPPLY_CHAIN_AI.SEMANTIC', $$ ... $$)` for each view.

### 8.1 SV_PROCUREMENT
- Tables: DIM_SUPPLIER, DIM_PART, FACT_PURCHASE_ORDER, FACT_PURCHASE_ORDER_LINE
- Relationships: PO→Supplier (SUPPLIER_ID), PO_LINE→PO (PO_ID), PO_LINE→Part (PART_ID)
- Key facts: TOTAL_VALUE, QUANTITY_ORDERED/RECEIVED, UNIT_PRICE, LINE_VALUE, LANDED_COST, RISK_SCORE, QUALITY_SCORE, DELIVERY_SCORE, ANNUAL_SPEND
- VQRs: Top suppliers by spend, Suppliers below 90% OTD, Spend by quarter

### 8.2 SV_INVENTORY
- Tables: DIM_PART, DIM_PLANT, DIM_WAREHOUSE, FACT_INVENTORY, FACT_INVENTORY_MOVEMENT
- Relationships: Inventory→Part, Inventory→Plant, Inventory→Warehouse
- Key facts: AVAILABLE_QTY, ON_HAND_QTY, TOTAL_VALUE, DAYS_OF_INVENTORY, REORDER_POINT, SAFETY_STOCK, MAX_STOCK_LEVEL, QUANTITY (movements)
- VQRs: Parts below reorder, Avg DOI by plant, Inventory value by warehouse type

### 8.3 SV_MANUFACTURING
- Tables: DIM_PART, DIM_PLANT, DIM_WORK_CENTER, FACT_WORK_ORDER
- Relationships: WO→Part, WO→Plant, WO→Work Center
- Key facts: QUANTITY_PLANNED/PRODUCED/SCRAPPED, YIELD_RATE, CAPACITY_HOURS_PER_DAY
- VQRs: Yield by plant, Scrap by work center, Parts below 95% yield

### 8.4 SV_QUALITY
- Tables: DIM_PART, DIM_SUPPLIER, DIM_PLANT, FACT_QUALITY_EVENT
- Relationships: QE→Part, QE→Supplier, QE→Plant
- Key facts: QUANTITY_INSPECTED, QUANTITY_DEFECTIVE, COST_OF_QUALITY
- Dimensions: EVENT_TYPE, SEVERITY, DEFECT_TYPE, ROOT_CAUSE, DISPOSITION
- VQRs: Defect rate by supplier, COPQ by quarter, Common root causes

### 8.5 SV_SALES
- Tables: DIM_CUSTOMER, DIM_PART, FACT_SALES_ORDER, FACT_SALES_ORDER_LINE
- Relationships: SO→Customer, SO_LINE→SO, SO_LINE→Part
- Key facts: TOTAL_VALUE, QUANTITY_ORDERED/SHIPPED, LINE_VALUE, BACKORDER_QTY
- VQRs: Fill rate by customer type, Revenue by tier, Top customers by value

### 8.6 SUPPLIER_QUALITY_PRODUCTION_SV (Cross-Domain)
- Tables: DIM_SUPPLIER, DIM_PART, DIM_PLANT, FACT_QUALITY_EVENT, FACT_WORK_ORDER
- Relationships: Quality→Supplier, Quality→Part, Quality→Plant, WO→Part, WO→Plant
- VQRs: Suppliers causing most scrap, Quality impact on production yield

### 8.7 ORDER_SHIPMENT_CUSTOMER_SV (Cross-Domain)
- Tables: DIM_CUSTOMER, DIM_PART, DIM_CARRIER, FACT_SALES_ORDER, FACT_SALES_ORDER_LINE, FACT_SHIPMENT
- Relationships: SO→Customer, SO_LINE→SO, SO_LINE→Part, Shipment→Carrier, Shipment→Customer
- VQRs: Customer OTD by tier, Fill rate by customer

### 8.8 PROCUREMENT_INVENTORY_FINANCE_SV (Cross-Domain)
- Tables: DIM_SUPPLIER, DIM_PART, DIM_PLANT, FACT_PURCHASE_ORDER, FACT_PURCHASE_ORDER_LINE, FACT_INVENTORY
- Relationships: PO→Supplier, PO→Plant, PO_LINE→PO, PO_LINE→Part, Inventory→Part, Inventory→Plant
- VQRs: Working capital in inventory, Spend vs inventory by part family

### 8.9 EXECUTIVE_SUMMARY_SV
- Tables: ANALYTICS.EXECUTIVE_KPI_MONTHLY
- Dimensions: YEAR, MONTH_NAME, QUARTER, FISCAL_YEAR, FISCAL_QUARTER
- Facts: OTD_PCT, FILL_RATE_PCT, PROCUREMENT_SPEND, AVG_YIELD_RATE, SCRAP_RATE, DEFECT_RATE, TOTAL_COPQ, TOTAL_SHIPMENTS, TOTAL_REVENUE, PO_COUNT, WO_COUNT, QUALITY_EVENT_COUNT
- VQRs: Monthly KPI dashboard, Quarterly trend, Metrics vs targets

---

## STEP 9: CREATE CORTEX AGENT

```sql
CREATE OR REPLACE AGENT AEROSPACE_SUPPLY_CHAIN_AI.SEMANTIC.SUPPLY_CHAIN_COPILOT
  COMMENT = 'Aerospace Supply Chain Intelligence Copilot - ontology-governed multi-domain analytics agent'
  FROM SPECIFICATION $$
tools:
  - tool_spec:
      type: cortex_analyst_text_to_sql
      name: procurement_analyst
      description: "Query procurement data: supplier performance, purchase orders, spend analysis, landed cost, supplier OTD, PO cycle time."
  - tool_spec:
      type: cortex_analyst_text_to_sql
      name: inventory_analyst
      description: "Query inventory data: days of inventory, turnover, stockouts, warehouse levels, reorder alerts."
  - tool_spec:
      type: cortex_analyst_text_to_sql
      name: manufacturing_analyst
      description: "Query manufacturing data: production yield, scrap rate, work order completion, capacity."
  - tool_spec:
      type: cortex_analyst_text_to_sql
      name: quality_analyst
      description: "Query quality data: defect rates, COPQ, root causes, corrective actions."
  - tool_spec:
      type: cortex_analyst_text_to_sql
      name: sales_analyst
      description: "Query sales and customer data: fill rate, revenue, order fulfillment, backorders."
  - tool_spec:
      type: cortex_analyst_text_to_sql
      name: supplier_quality_production_analyst
      description: "Cross-domain root cause: links supplier performance to quality events and production outcomes."
  - tool_spec:
      type: cortex_analyst_text_to_sql
      name: order_shipment_customer_analyst
      description: "Cross-domain fulfillment: links customer orders to shipments and carriers."
  - tool_spec:
      type: cortex_analyst_text_to_sql
      name: procurement_inventory_finance_analyst
      description: "Cross-domain working capital: links procurement spend to inventory positions."
  - tool_spec:
      type: cortex_analyst_text_to_sql
      name: executive_dashboard
      description: "Executive KPI dashboard: pre-aggregated monthly metrics across all domains."
  - tool_spec:
      type: cortex_search
      name: supply_chain_knowledge
      description: "Search knowledge base for definitions, metric formulas, disambiguation rules, ontology, governance policies."

tool_resources:
  procurement_analyst:
    execution_environment:
      type: warehouse
      warehouse: COMPUTE_WH
    semantic_view: AEROSPACE_SUPPLY_CHAIN_AI.SEMANTIC.SV_PROCUREMENT
  inventory_analyst:
    execution_environment:
      type: warehouse
      warehouse: COMPUTE_WH
    semantic_view: AEROSPACE_SUPPLY_CHAIN_AI.SEMANTIC.SV_INVENTORY
  manufacturing_analyst:
    execution_environment:
      type: warehouse
      warehouse: COMPUTE_WH
    semantic_view: AEROSPACE_SUPPLY_CHAIN_AI.SEMANTIC.SV_MANUFACTURING
  quality_analyst:
    execution_environment:
      type: warehouse
      warehouse: COMPUTE_WH
    semantic_view: AEROSPACE_SUPPLY_CHAIN_AI.SEMANTIC.SV_QUALITY
  sales_analyst:
    execution_environment:
      type: warehouse
      warehouse: COMPUTE_WH
    semantic_view: AEROSPACE_SUPPLY_CHAIN_AI.SEMANTIC.SV_SALES
  supplier_quality_production_analyst:
    execution_environment:
      type: warehouse
      warehouse: COMPUTE_WH
    semantic_view: AEROSPACE_SUPPLY_CHAIN_AI.SEMANTIC.SUPPLIER_QUALITY_PRODUCTION_SV
  order_shipment_customer_analyst:
    execution_environment:
      type: warehouse
      warehouse: COMPUTE_WH
    semantic_view: AEROSPACE_SUPPLY_CHAIN_AI.SEMANTIC.ORDER_SHIPMENT_CUSTOMER_SV
  procurement_inventory_finance_analyst:
    execution_environment:
      type: warehouse
      warehouse: COMPUTE_WH
    semantic_view: AEROSPACE_SUPPLY_CHAIN_AI.SEMANTIC.PROCUREMENT_INVENTORY_FINANCE_SV
  executive_dashboard:
    execution_environment:
      type: warehouse
      warehouse: COMPUTE_WH
    semantic_view: AEROSPACE_SUPPLY_CHAIN_AI.SEMANTIC.EXECUTIVE_SUMMARY_SV
  supply_chain_knowledge:
    search_service: AEROSPACE_SUPPLY_CHAIN_AI.SEMANTIC.SUPPLY_CHAIN_KNOWLEDGE_SEARCH
    max_results: 5

instructions:
  response: |
    You are the Supply Chain Copilot, an ontology-governed expert in aerospace supply chain operations.
    You serve a global aerospace manufacturer with plants in Hyderabad, Toulouse, Seattle, Singapore, and Hamburg.

    GOVERNANCE PRINCIPLES:
    1. ONE DEFINITION: Every concept has one canonical definition. Look it up with supply_chain_knowledge.
    2. ONE FORMULA: Every metric has one formula. Cite metric ID (MET-xxx) when referencing KPIs.
    3. CONTEXT RESOLUTION: Ambiguous terms resolved via persona context, never guessing.
    4. AUDITABILITY: Always explain data source and formula used.
    5. CONSISTENCY: Same question returns same number regardless of who asks.

    DISAMBIGUATION (CRITICAL): When user says "delivery performance", "cost", "inventory", "risk", or "performance" without context, search supply_chain_knowledge for disambiguation rules first and ask which context they mean.

    KEY DERIVATION RULES:
    - OTD: ACTUAL_DELIVERY_DATE <= PROMISED_DELIVERY_DATE (Delivered/Closed only)
    - Yield: QUANTITY_PRODUCED / (PRODUCED + SCRAPPED) * 100
    - Fill Rate: SUM(QUANTITY_SHIPPED) / SUM(QUANTITY_ORDERED) * 100
    - High Risk Supplier: OTD < 85% OR Quality < 70 OR Financial Risk = High

    TARGETS: OTD=95%, Fill Rate=98%, Yield=97%, Defect Rate<2%, DOI=45 days, Inventory Turns=8

  orchestration: |
    ROUTING RULES:
    Domain questions:
    - supplier, procurement, PO, spend -> procurement_analyst
    - inventory, stock, warehouse, DOI, reorder -> inventory_analyst
    - production, yield, work order, scrap -> manufacturing_analyst
    - quality, defect, NCR, CAPA, COPQ -> quality_analyst
    - customer, sales, order, fill rate, revenue -> sales_analyst

    Cross-domain questions:
    - supplier causing quality issues, quality impact on production -> supplier_quality_production_analyst
    - customer delivery, perfect order, carrier OTD by customer -> order_shipment_customer_analyst
    - working capital, spend vs inventory, procurement + inventory -> procurement_inventory_finance_analyst

    Executive questions:
    - KPI dashboard, monthly metrics, target vs actual, quarterly trend -> executive_dashboard

    Definitions/policies:
    - what does X mean, how is X calculated, policy -> supply_chain_knowledge

    Multi-domain: use the most relevant tool first, then combine results.
$$;
```

---

## STEP 10: VALIDATE DEPLOYMENT

After completing all steps, validate by:

1. Check table counts: `SELECT TABLE_SCHEMA, COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_CATALOG = 'AEROSPACE_SUPPLY_CHAIN_AI' GROUP BY TABLE_SCHEMA;`
2. Verify semantic views: `SHOW SEMANTIC VIEWS IN SCHEMA AEROSPACE_SUPPLY_CHAIN_AI.SEMANTIC;` — should return 9
3. Verify search service: `SHOW CORTEX SEARCH SERVICES IN SCHEMA AEROSPACE_SUPPLY_CHAIN_AI.SEMANTIC;` — status ACTIVE, 90 rows
4. Verify agent: `SHOW AGENTS IN SCHEMA AEROSPACE_SUPPLY_CHAIN_AI.SEMANTIC;` — SUPPLY_CHAIN_COPILOT
5. Test agent query:
```sql
SELECT SNOWFLAKE.CORTEX.DATA_AGENT_RUN(
  'AEROSPACE_SUPPLY_CHAIN_AI.SEMANTIC.SUPPLY_CHAIN_COPILOT',
  '{"messages": [{"role": "user", "content": [{"type": "text", "text": "What is our total procurement spend this year?"}]}]}'
);
```
6. Verify metric alerts: `SELECT * FROM AEROSPACE_SUPPLY_CHAIN_AI.ANALYTICS.V_METRIC_ALERTS;`

---

## DEPLOYMENT SUMMARY

| Layer | Objects | Count |
|-------|---------|-------|
| Database | AEROSPACE_SUPPLY_CHAIN_AI | 1 |
| Schemas | RAW, SEMANTIC, ANALYTICS | 3 |
| Dimension Tables | DIM_* | 13 |
| Fact Tables | FACT_* | 13 |
| Metadata Tables | META_* | 2 |
| Supporting Tables | KB, Thresholds, Executive KPI | 3 |
| Analytics Views | V_DERIVED_*, V_INTEGRITY_*, V_METRIC_* | 9 |
| Semantic Views | SV_*, *_SV | 9 |
| Cortex Search | SUPPLY_CHAIN_KNOWLEDGE_SEARCH | 1 |
| Cortex Agent | SUPPLY_CHAIN_COPILOT | 1 |
| Total Data Rows | All tables combined | 36,000+ |
| Knowledge Documents | Indexed by Arctic Embed | 90 |

---

*Deploy with: `Build @COCO_CLI_HACKATHON/DEPLOY_BUILD.md`*
*Built with Snowflake CoCo CLI | Hackathon: Supply Chain Ontology & Governed Conversational Analytics*
