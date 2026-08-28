# Aerospace Supply Chain - Data Dictionary

**Database:** AEROSPACE_SUPPLY_CHAIN  
**Schema:** RAW  

---

## DIM_BOM

Bill of Materials dimension - defines parent-child part relationships for assembly structures.

| Column Name | Data Type | Description | Relationship |
|-------------|-----------|-------------|--------------|
| BOM_SK | NUMBER | Surrogate key (auto-increment) | Primary Key |
| BOM_ID | TEXT | Natural business key for BOM record | Unique |
| BOM_CODE | TEXT | BOM code identifier | - |
| PARENT_PART_ID | TEXT | Parent assembly part identifier | FK to DIM_PART.PART_ID |
| CHILD_PART_ID | TEXT | Child component part identifier | FK to DIM_PART.PART_ID |
| QUANTITY_PER | NUMBER | Quantity of child part per parent assembly | - |
| POSITION_NUMBER | NUMBER | Assembly position sequence number | - |
| EFFECTIVE_DATE | DATE | Date BOM relationship becomes effective | - |
| EXPIRY_DATE | DATE | Date BOM relationship expires | - |
| BOM_LEVEL | NUMBER | Level in the BOM hierarchy | - |
| PROGRAM | TEXT | Aircraft program this BOM belongs to | - |
| CREATED_TIMESTAMP | TIMESTAMP_NTZ | Record creation timestamp | - |

---

## DIM_CALENDAR

Calendar dimension for date-based reporting and fiscal period mapping.

| Column Name | Data Type | Description | Relationship |
|-------------|-----------|-------------|--------------|
| DATE_KEY | DATE | Calendar date (primary key) | Primary Key |
| YEAR | NUMBER | Calendar year | - |
| QUARTER | NUMBER | Calendar quarter (1-4) | - |
| MONTH | NUMBER | Calendar month (1-12) | - |
| MONTH_NAME | TEXT | Name of the month | - |
| WEEK_OF_YEAR | NUMBER | ISO week number | - |
| DAY_OF_WEEK | NUMBER | Day of the week (1-7) | - |
| DAY_NAME | TEXT | Name of the day | - |
| IS_WEEKEND | BOOLEAN | Flag if date falls on weekend | - |
| IS_HOLIDAY | BOOLEAN | Flag if date is a holiday | - |
| FISCAL_YEAR | NUMBER | Fiscal year number | - |
| FISCAL_QUARTER | NUMBER | Fiscal quarter (1-4) | - |

---

## DIM_CARRIER

Carrier/logistics provider dimension for shipment tracking.

| Column Name | Data Type | Description | Relationship |
|-------------|-----------|-------------|--------------|
| CARRIER_SK | NUMBER | Surrogate key (auto-increment) | Primary Key |
| CARRIER_ID | TEXT | Natural business key for carrier | Unique |
| CARRIER_CODE | TEXT | Short carrier code | - |
| CARRIER_NAME | TEXT | Full carrier name | - |
| CARRIER_TYPE | TEXT | Type of carrier (air, sea, ground, etc.) | - |
| COUNTRY | TEXT | Carrier's home country | - |
| ON_TIME_PCT | NUMBER | Historical on-time delivery percentage | - |
| COST_PER_KG | NUMBER | Average cost per kilogram | - |
| IS_ACTIVE | BOOLEAN | Whether carrier is currently active | - |
| CREATED_TIMESTAMP | TIMESTAMP_NTZ | Record creation timestamp | - |

---

## DIM_CERTIFICATION

Part certification and compliance dimension for regulatory tracking.

| Column Name | Data Type | Description | Relationship |
|-------------|-----------|-------------|--------------|
| CERTIFICATION_SK | NUMBER | Surrogate key (auto-increment) | Primary Key |
| PART_ID | TEXT | Part identifier for certification | FK to DIM_PART.PART_ID |
| FAA_APPROVED | TEXT | FAA approval status (Y/N) | - |
| EASA_APPROVED | TEXT | EASA approval status (Y/N) | - |
| AS9100 | TEXT | AS9100 certification status (Y/N) | - |
| ITAR | TEXT | ITAR compliance status (Y/N) | - |
| EXPORT_CONTROL | TEXT | Export control classification (Y/N) | - |
| CERTIFICATION_DATE | DATE | Date certification was granted | - |
| EXPIRY_DATE | DATE | Certification expiry date | - |
| ISSUING_AUTHORITY | TEXT | Authority that issued the certification | - |
| CERTIFICATE_NUMBER | TEXT | Certificate reference number | - |
| AUDIT_NOTES | TEXT | Notes from certification audit | - |
| LAST_UPDATED | TIMESTAMP_NTZ | Last update timestamp | - |

---

## DIM_CUSTOMER

Customer dimension for airlines, MROs, and defense organizations.

| Column Name | Data Type | Description | Relationship |
|-------------|-----------|-------------|--------------|
| CUSTOMER_SK | NUMBER | Surrogate key (auto-increment) | Primary Key |
| CUSTOMER_ID | TEXT | Natural business key for customer | Unique |
| CUSTOMER_CODE | TEXT | Short customer code | - |
| CUSTOMER_NAME | TEXT | Full customer name | - |
| COUNTRY | TEXT | Customer's country | - |
| REGION | TEXT | Geographic region | - |
| CUSTOMER_TYPE | TEXT | Type (airline, MRO, defense, etc.) | - |
| REVENUE_TIER | TEXT | Revenue tier classification | - |
| ANNUAL_REVENUE | NUMBER | Customer's annual revenue | - |
| CREDIT_LIMIT | NUMBER | Credit limit extended to customer | - |
| IS_ACTIVE | BOOLEAN | Whether customer is currently active | - |
| CREATED_TIMESTAMP | TIMESTAMP_NTZ | Record creation timestamp | - |
| UPDATED_TIMESTAMP | TIMESTAMP_NTZ | Last update timestamp | - |

---

## DIM_PART

Part master dimension containing all aerospace parts and components.

| Column Name | Data Type | Description | Relationship |
|-------------|-----------|-------------|--------------|
| PART_SK | NUMBER | Surrogate key (auto-increment) | Primary Key |
| PART_ID | TEXT | Natural business key for part | Unique |
| PART_NUMBER | TEXT | Engineering part number | - |
| PART_NAME | TEXT | Descriptive part name | - |
| PART_FAMILY | TEXT | Part family grouping | - |
| ATA_CHAPTER | TEXT | ATA chapter classification | - |
| CRITICALITY | TEXT | Criticality level (critical, major, minor) | - |
| UNIT_OF_MEASURE | TEXT | Unit of measure (EA, KG, etc.) | - |
| STANDARD_COST | NUMBER | Standard cost per unit | - |
| WEIGHT_KG | NUMBER | Part weight in kilograms | - |
| LEAD_TIME_DAYS | NUMBER | Standard lead time in days | - |
| MAKE_BUY_CODE | TEXT | Whether part is made or bought | - |
| ITAR_CONTROLLED | BOOLEAN | ITAR controlled flag | - |
| LIFECYCLE_STATUS | TEXT | Part lifecycle status (Active, Obsolete, etc.) | - |
| CREATED_TIMESTAMP | TIMESTAMP_NTZ | Record creation timestamp | - |
| UPDATED_TIMESTAMP | TIMESTAMP_NTZ | Last update timestamp | - |

---

## DIM_PLANT

Manufacturing plant/facility dimension.

| Column Name | Data Type | Description | Relationship |
|-------------|-----------|-------------|--------------|
| PLANT_SK | NUMBER | Surrogate key (auto-increment) | Primary Key |
| PLANT_ID | TEXT | Natural business key for plant | Unique |
| PLANT_CODE | TEXT | Short plant code | - |
| PLANT_NAME | TEXT | Full plant name | - |
| COUNTRY | TEXT | Plant country | - |
| REGION | TEXT | Geographic region | - |
| CITY | TEXT | Plant city | - |
| PLANT_TYPE | TEXT | Type of plant (assembly, MRO, warehouse) | - |
| CAPACITY_UNITS | NUMBER | Production capacity in units | - |
| OPERATING_SHIFTS | NUMBER | Number of operating shifts per day | - |
| SQUARE_METERS | NUMBER | Plant floor area in square meters | - |
| IS_ACTIVE | BOOLEAN | Whether plant is currently active | - |
| LATITUDE | NUMBER | Geographic latitude | - |
| LONGITUDE | NUMBER | Geographic longitude | - |
| CREATED_TIMESTAMP | TIMESTAMP_NTZ | Record creation timestamp | - |
| UPDATED_TIMESTAMP | TIMESTAMP_NTZ | Last update timestamp | - |

---

## DIM_RAW_MATERIAL

Raw material dimension for materials used in manufacturing.

| Column Name | Data Type | Description | Relationship |
|-------------|-----------|-------------|--------------|
| MATERIAL_SK | NUMBER | Surrogate key (auto-increment) | Primary Key |
| MATERIAL_ID | TEXT | Natural business key for material | Unique |
| MATERIAL_CODE | TEXT | Short material code | - |
| MATERIAL_NAME | TEXT | Full material name | - |
| MATERIAL_TYPE | TEXT | Type (titanium, aluminum, composite, etc.) | - |
| SPECIFICATION | TEXT | Material specification standard | - |
| UNIT_OF_MEASURE | TEXT | Unit of measure | - |
| STANDARD_COST | NUMBER | Standard cost per unit | - |
| DENSITY | NUMBER | Material density | - |
| ITAR_CONTROLLED | BOOLEAN | ITAR controlled flag | - |
| SHELF_LIFE_DAYS | NUMBER | Shelf life in days | - |
| CREATED_TIMESTAMP | TIMESTAMP_NTZ | Record creation timestamp | - |
| UPDATED_TIMESTAMP | TIMESTAMP_NTZ | Last update timestamp | - |

---

## DIM_ROUTING

Manufacturing routing dimension defining operation sequences for parts.

| Column Name | Data Type | Description | Relationship |
|-------------|-----------|-------------|--------------|
| ROUTING_SK | NUMBER | Surrogate key (auto-increment) | Primary Key |
| ROUTING_ID | TEXT | Natural business key for routing | Unique |
| PART_ID | TEXT | Part this routing applies to | FK to DIM_PART.PART_ID |
| OPERATION_SEQ | NUMBER | Operation sequence number | - |
| WORK_CENTER_ID | TEXT | Work center performing operation | FK to DIM_WORK_CENTER.WORK_CENTER_ID |
| STANDARD_TIME_HRS | NUMBER | Standard operation time in hours | - |
| SETUP_TIME_HRS | NUMBER | Setup time in hours | - |
| DESCRIPTION | TEXT | Operation description | - |
| CREATED_TIMESTAMP | TIMESTAMP_NTZ | Record creation timestamp | - |

---

## DIM_SUPPLIER

Supplier dimension with tiered supplier information and performance metrics.

| Column Name | Data Type | Description | Relationship |
|-------------|-----------|-------------|--------------|
| SUPPLIER_SK | NUMBER | Surrogate key (auto-increment) | Primary Key |
| SUPPLIER_ID | TEXT | Natural business key for supplier | Unique |
| SUPPLIER_CODE | TEXT | Short supplier code | - |
| SUPPLIER_NAME | TEXT | Full supplier name | - |
| TIER_LEVEL | NUMBER | Supplier tier (1, 2, 3) | - |
| COUNTRY | TEXT | Supplier's country | - |
| REGION | TEXT | Geographic region | - |
| CITY | TEXT | Supplier's city | - |
| SUPPLIER_TYPE | TEXT | Type (manufacturer, distributor, etc.) | - |
| CATEGORY | TEXT | Supply category | - |
| RISK_SCORE | NUMBER | Risk assessment score | - |
| QUALITY_RATING | NUMBER | Quality rating score | - |
| ON_TIME_DELIVERY_PCT | NUMBER | On-time delivery percentage | - |
| ANNUAL_REVENUE | NUMBER | Supplier's annual revenue | - |
| EMPLOYEE_COUNT | NUMBER | Number of employees | - |
| CERTIFICATION_STATUS | TEXT | Current certification status | - |
| ITAR_CONTROLLED | BOOLEAN | ITAR controlled flag | - |
| EAR_CONTROLLED | BOOLEAN | EAR controlled flag | - |
| IS_ACTIVE | BOOLEAN | Whether supplier is currently active | - |
| EFFECTIVE_DATE | DATE | SCD2 effective date | - |
| EXPIRY_DATE | DATE | SCD2 expiry date | - |
| CREATED_TIMESTAMP | TIMESTAMP_NTZ | Record creation timestamp | - |
| UPDATED_TIMESTAMP | TIMESTAMP_NTZ | Last update timestamp | - |

---

## DIM_SUPPLIER_PART

Supplier-part cross-reference dimension with pricing and lead times.

| Column Name | Data Type | Description | Relationship |
|-------------|-----------|-------------|--------------|
| SUPPLIER_PART_SK | NUMBER | Surrogate key (auto-increment) | Primary Key |
| SUPPLIER_PART_ID | TEXT | Natural business key | Unique |
| SUPPLIER_ID | TEXT | Supplier identifier | FK to DIM_SUPPLIER.SUPPLIER_ID |
| PART_ID | TEXT | Part identifier | FK to DIM_PART.PART_ID |
| LEAD_TIME_DAYS | NUMBER | Supplier-specific lead time | - |
| MOQ | NUMBER | Minimum order quantity | - |
| CONTRACT_PRICE | NUMBER | Contracted unit price | - |
| CERTIFICATION_STATUS | TEXT | Part certification status with this supplier | - |
| SUPPLIER_RATING | NUMBER | Supplier rating for this part | - |
| CONTRACT_ID | TEXT | Contract reference | - |
| EFFECTIVE_DATE | DATE | Contract effective date | - |
| EXPIRY_DATE | DATE | Contract expiry date | - |
| CREATED_TIMESTAMP | TIMESTAMP_NTZ | Record creation timestamp | - |

---

## DIM_WAREHOUSE

Warehouse dimension for inventory storage locations.

| Column Name | Data Type | Description | Relationship |
|-------------|-----------|-------------|--------------|
| WAREHOUSE_SK | NUMBER | Surrogate key (auto-increment) | Primary Key |
| WAREHOUSE_ID | TEXT | Natural business key for warehouse | Unique |
| WAREHOUSE_CODE | TEXT | Short warehouse code | - |
| WAREHOUSE_NAME | TEXT | Full warehouse name | - |
| PLANT_ID | TEXT | Plant this warehouse belongs to | FK to DIM_PLANT.PLANT_ID |
| WAREHOUSE_TYPE | TEXT | Type (raw material, finished goods, etc.) | - |
| CAPACITY_UNITS | NUMBER | Storage capacity in units | - |
| CURRENT_UTILIZATION_PCT | NUMBER | Current utilization percentage | - |
| IS_ACTIVE | BOOLEAN | Whether warehouse is currently active | - |
| CREATED_TIMESTAMP | TIMESTAMP_NTZ | Record creation timestamp | - |

---

## DIM_WORK_CENTER

Work center dimension for manufacturing operations.

| Column Name | Data Type | Description | Relationship |
|-------------|-----------|-------------|--------------|
| WORK_CENTER_SK | NUMBER | Surrogate key (auto-increment) | Primary Key |
| WORK_CENTER_ID | TEXT | Natural business key for work center | Unique |
| WORK_CENTER_CODE | TEXT | Short work center code | - |
| WORK_CENTER_NAME | TEXT | Full work center name | - |
| PLANT_ID | TEXT | Plant this work center belongs to | FK to DIM_PLANT.PLANT_ID |
| MACHINE_TYPE | TEXT | Type of machine/equipment | - |
| CAPACITY_HOURS_DAY | NUMBER | Daily capacity in hours | - |
| HOURLY_RATE | NUMBER | Cost per hour | - |
| IS_ACTIVE | BOOLEAN | Whether work center is currently active | - |
| CREATED_TIMESTAMP | TIMESTAMP_NTZ | Record creation timestamp | - |

---

## FACT_AOG_EVENT

Aircraft On Ground events - critical supply chain disruption tracking.

| Column Name | Data Type | Description | Relationship |
|-------------|-----------|-------------|--------------|
| AOG_SK | NUMBER | Surrogate key (auto-increment) | Primary Key |
| AOG_ID | TEXT | Natural business key for AOG event | Unique |
| CUSTOMER_ID | TEXT | Customer affected by AOG | FK to DIM_CUSTOMER.CUSTOMER_ID |
| PART_ID | TEXT | Part causing the AOG | FK to DIM_PART.PART_ID |
| EVENT_DATE | DATE | Date of AOG event | FK to DIM_CALENDAR.DATE_KEY |
| DURATION_HOURS | NUMBER | Duration of AOG in hours | - |
| REVENUE_IMPACT | NUMBER | Financial impact of AOG | - |
| ROOT_CAUSE | TEXT | Root cause of AOG event | - |
| RESOLUTION_ACTION | TEXT | Action taken to resolve | - |
| SEVERITY_CODE | TEXT | Severity classification | - |
| RESOLUTION_DATE | DATE | Date AOG was resolved | FK to DIM_CALENDAR.DATE_KEY |
| MAINTENANCE_PROVIDER_ID | TEXT | MRO provider handling resolution | - |
| CREATED_TIMESTAMP | TIMESTAMP_NTZ | Record creation timestamp | - |
| UPDATED_TIMESTAMP | TIMESTAMP_NTZ | Last update timestamp | - |

---

## FACT_INVENTORY

Current inventory snapshot by part, plant, and warehouse.

| Column Name | Data Type | Description | Relationship |
|-------------|-----------|-------------|--------------|
| INVENTORY_SK | NUMBER | Surrogate key (auto-increment) | Primary Key |
| INVENTORY_ID | TEXT | Natural business key | Unique |
| INVENTORY_CODE | TEXT | Inventory code | - |
| PART_ID | TEXT | Part identifier | FK to DIM_PART.PART_ID |
| PLANT_ID | TEXT | Plant identifier | FK to DIM_PLANT.PLANT_ID |
| WAREHOUSE_ID | TEXT | Warehouse identifier | FK to DIM_WAREHOUSE.WAREHOUSE_ID |
| ON_HAND_QTY | NUMBER | Quantity physically on hand | - |
| AVAILABLE_QTY | NUMBER | Quantity available for use | - |
| RESERVED_QTY | NUMBER | Quantity reserved for orders | - |
| IN_TRANSIT_QTY | NUMBER | Quantity currently in transit | - |
| REORDER_POINT | NUMBER | Quantity triggering reorder | - |
| SAFETY_STOCK | NUMBER | Safety stock level | - |
| MAX_STOCK | NUMBER | Maximum stock level | - |
| UNIT_COST | NUMBER | Cost per unit | - |
| TOTAL_VALUE | NUMBER | Total inventory value | - |
| LAST_RECEIPT_DATE | DATE | Date of last goods receipt | - |
| LAST_ISSUE_DATE | DATE | Date of last goods issue | - |
| SNAPSHOT_DATE | DATE | Date of inventory snapshot | FK to DIM_CALENDAR.DATE_KEY |
| CREATED_TIMESTAMP | TIMESTAMP_NTZ | Record creation timestamp | - |
| UPDATED_TIMESTAMP | TIMESTAMP_NTZ | Last update timestamp | - |

---

## FACT_INVENTORY_MOVEMENT

Inventory transaction history tracking all stock movements.

| Column Name | Data Type | Description | Relationship |
|-------------|-----------|-------------|--------------|
| MOVEMENT_SK | NUMBER | Surrogate key (auto-increment) | Primary Key |
| MOVEMENT_ID | TEXT | Natural business key | Unique |
| PART_ID | TEXT | Part being moved | FK to DIM_PART.PART_ID |
| PLANT_ID | TEXT | Plant where movement occurred | FK to DIM_PLANT.PLANT_ID |
| WAREHOUSE_ID | TEXT | Warehouse involved | FK to DIM_WAREHOUSE.WAREHOUSE_ID |
| MOVEMENT_TYPE | TEXT | Type (receipt, issue, transfer, adjustment) | - |
| QUANTITY | NUMBER | Quantity moved | - |
| MOVEMENT_DATE | DATE | Date of movement | FK to DIM_CALENDAR.DATE_KEY |
| BATCH_ID | TEXT | Batch identifier | - |
| LOT_NUMBER | TEXT | Lot/serial number | - |
| TRANSACTION_ID | TEXT | Transaction reference | - |
| REASON_CODE | TEXT | Reason code for movement | - |
| REFERENCE_DOC | TEXT | Reference document (PO, WO, etc.) | - |
| CREATED_BY | TEXT | User who created the movement | - |
| CREATED_TIMESTAMP | TIMESTAMP_NTZ | Record creation timestamp | - |

---

## FACT_IOT_SENSOR_DATA

IoT sensor readings from manufacturing equipment.

| Column Name | Data Type | Description | Relationship |
|-------------|-----------|-------------|--------------|
| SENSOR_SK | NUMBER | Surrogate key (auto-increment) | Primary Key |
| SENSOR_ID | TEXT | Sensor device identifier | - |
| WORK_CENTER_ID | TEXT | Work center being monitored | FK to DIM_WORK_CENTER.WORK_CENTER_ID |
| PLANT_ID | TEXT | Plant where sensor is located | FK to DIM_PLANT.PLANT_ID |
| READING_TIMESTAMP | TIMESTAMP_NTZ | Timestamp of sensor reading | - |
| TEMPERATURE_C | NUMBER | Temperature in Celsius | - |
| VIBRATION_MM_S | NUMBER | Vibration in mm/s | - |
| PRESSURE_BAR | NUMBER | Pressure in bar | - |
| RPM | NUMBER | Rotations per minute | - |
| POWER_KW | NUMBER | Power consumption in kilowatts | - |
| OIL_LEVEL_PCT | NUMBER | Oil level percentage | - |
| STATUS | TEXT | Sensor status (Normal, Warning, Critical) | - |
| ALERT_FLAG | BOOLEAN | Whether alert threshold was triggered | - |

---

## FACT_PURCHASE_ORDER

Purchase order header for supplier orders.

| Column Name | Data Type | Description | Relationship |
|-------------|-----------|-------------|--------------|
| PO_SK | NUMBER | Surrogate key (auto-increment) | Primary Key |
| PO_ID | TEXT | Natural business key for PO | Unique |
| PO_CODE | TEXT | PO code | - |
| SUPPLIER_ID | TEXT | Supplier receiving the order | FK to DIM_SUPPLIER.SUPPLIER_ID |
| PLANT_ID | TEXT | Ordering plant | FK to DIM_PLANT.PLANT_ID |
| ORDER_DATE | DATE | Date PO was placed | FK to DIM_CALENDAR.DATE_KEY |
| PROMISED_DATE | DATE | Supplier's promised delivery date | FK to DIM_CALENDAR.DATE_KEY |
| RECEIVED_DATE | DATE | Actual receipt date | FK to DIM_CALENDAR.DATE_KEY |
| STATUS | TEXT | PO status (Open, Closed, Cancelled) | - |
| TOTAL_VALUE | NUMBER | Total PO value | - |
| CURRENCY_CODE | TEXT | Currency code | - |
| BUYER_ID | TEXT | Buyer/purchaser identifier | - |
| PRIORITY_CODE | TEXT | Priority classification | - |
| CREATED_TIMESTAMP | TIMESTAMP_NTZ | Record creation timestamp | - |
| UPDATED_TIMESTAMP | TIMESTAMP_NTZ | Last update timestamp | - |

---

## FACT_PURCHASE_ORDER_LINE

Purchase order line items with part-level detail.

| Column Name | Data Type | Description | Relationship |
|-------------|-----------|-------------|--------------|
| PO_LINE_SK | NUMBER | Surrogate key (auto-increment) | Primary Key |
| PO_LINE_ID | TEXT | Natural business key for PO line | Unique |
| PO_ID | TEXT | Parent purchase order | FK to FACT_PURCHASE_ORDER.PO_ID |
| PART_ID | TEXT | Part being ordered | FK to DIM_PART.PART_ID |
| QUANTITY_ORDERED | NUMBER | Quantity ordered | - |
| QUANTITY_RECEIVED | NUMBER | Quantity received so far | - |
| UNIT_PRICE | NUMBER | Price per unit | - |
| LINE_VALUE | NUMBER | Total line value | - |
| PROMISED_DATE | DATE | Promised delivery date for line | FK to DIM_CALENDAR.DATE_KEY |
| RECEIVED_DATE | DATE | Actual receipt date | FK to DIM_CALENDAR.DATE_KEY |
| STATUS | TEXT | Line status | - |
| CREATED_TIMESTAMP | TIMESTAMP_NTZ | Record creation timestamp | - |

---

## FACT_PURCHASE_REQUISITION

Purchase requisitions preceding formal purchase orders.

| Column Name | Data Type | Description | Relationship |
|-------------|-----------|-------------|--------------|
| PR_SK | NUMBER | Surrogate key (auto-increment) | Primary Key |
| PR_ID | TEXT | Natural business key for PR | Unique |
| PART_ID | TEXT | Part being requisitioned | FK to DIM_PART.PART_ID |
| PLANT_ID | TEXT | Requesting plant | FK to DIM_PLANT.PLANT_ID |
| REQUESTED_QTY | NUMBER | Quantity requested | - |
| NEED_DATE | DATE | Date material is needed | FK to DIM_CALENDAR.DATE_KEY |
| STATUS | TEXT | Requisition status | - |
| SUPPLIER_ID | TEXT | Suggested supplier | FK to DIM_SUPPLIER.SUPPLIER_ID |
| CURRENCY_CODE | TEXT | Currency code | - |
| APPROVAL_DATE | DATE | Date requisition was approved | FK to DIM_CALENDAR.DATE_KEY |
| BUYER_ID | TEXT | Assigned buyer | - |
| PRIORITY_CODE | TEXT | Priority classification | - |
| CREATED_TIMESTAMP | TIMESTAMP_NTZ | Record creation timestamp | - |
| UPDATED_TIMESTAMP | TIMESTAMP_NTZ | Last update timestamp | - |

---

## FACT_QUALITY_EVENT

Quality events including inspections, non-conformances, and CAPAs.

| Column Name | Data Type | Description | Relationship |
|-------------|-----------|-------------|--------------|
| QUALITY_EVENT_SK | NUMBER | Surrogate key (auto-increment) | Primary Key |
| QUALITY_EVENT_ID | TEXT | Natural business key | Unique |
| QUALITY_EVENT_CODE | TEXT | Quality event code | - |
| PART_ID | TEXT | Part involved in quality event | FK to DIM_PART.PART_ID |
| SUPPLIER_ID | TEXT | Supplier related to event (if applicable) | FK to DIM_SUPPLIER.SUPPLIER_ID |
| PLANT_ID | TEXT | Plant where event occurred | FK to DIM_PLANT.PLANT_ID |
| WORK_ORDER_ID | TEXT | Related work order | FK to FACT_WORK_ORDER.WORK_ORDER_ID |
| EVENT_TYPE | TEXT | Type (inspection, NCR, CAPA, etc.) | - |
| DEFECT_TYPE | TEXT | Category of defect | - |
| SEVERITY | TEXT | Severity level (critical, major, minor) | - |
| ROOT_CAUSE | TEXT | Root cause description | - |
| CORRECTIVE_ACTION | TEXT | Corrective action taken | - |
| DISPOSITION | TEXT | Disposition decision (scrap, rework, use-as-is) | - |
| QUANTITY_INSPECTED | NUMBER | Quantity inspected | - |
| QUANTITY_DEFECTIVE | NUMBER | Quantity found defective | - |
| EVENT_DATE | DATE | Date of quality event | FK to DIM_CALENDAR.DATE_KEY |
| RESOLUTION_DATE | DATE | Date event was resolved | FK to DIM_CALENDAR.DATE_KEY |
| STATUS | TEXT | Event status | - |
| COST_OF_QUALITY | NUMBER | Cost associated with quality event | - |
| CREATED_TIMESTAMP | TIMESTAMP_NTZ | Record creation timestamp | - |
| UPDATED_TIMESTAMP | TIMESTAMP_NTZ | Last update timestamp | - |

---

## FACT_REPAIR_ORDER

MRO repair orders for component overhaul and repair.

| Column Name | Data Type | Description | Relationship |
|-------------|-----------|-------------|--------------|
| REPAIR_ORDER_SK | NUMBER | Surrogate key (auto-increment) | Primary Key |
| REPAIR_ORDER_ID | TEXT | Natural business key for repair order | Unique |
| ENGINE_SN | TEXT | Engine serial number | - |
| PART_ID | TEXT | Part being repaired | FK to DIM_PART.PART_ID |
| CUSTOMER_ID | TEXT | Customer who owns the part | FK to DIM_CUSTOMER.CUSTOMER_ID |
| RECEIVED_DATE | DATE | Date part was received for repair | FK to DIM_CALENDAR.DATE_KEY |
| RELEASED_DATE | DATE | Date part was released after repair | FK to DIM_CALENDAR.DATE_KEY |
| REPAIR_COST | NUMBER | Total cost of repair | - |
| REPAIR_STATUS | TEXT | Current repair status | - |
| TECHNICIAN_ID | TEXT | Assigned technician | - |
| REPAIR_TYPE | TEXT | Type of repair (overhaul, repair, modification) | - |
| WARRANTY_FLAG | TEXT | Whether under warranty (Y/N) | - |
| TURNAROUND_TIME_DAYS | NUMBER | Total turnaround time in days | - |
| CREATED_TIMESTAMP | TIMESTAMP_NTZ | Record creation timestamp | - |
| UPDATED_TIMESTAMP | TIMESTAMP_NTZ | Last update timestamp | - |

---

## FACT_SALES_ORDER

Sales order header for customer orders.

| Column Name | Data Type | Description | Relationship |
|-------------|-----------|-------------|--------------|
| SO_SK | NUMBER | Surrogate key (auto-increment) | Primary Key |
| SO_ID | TEXT | Natural business key for sales order | Unique |
| SO_CODE | TEXT | Sales order code | - |
| CUSTOMER_ID | TEXT | Ordering customer | FK to DIM_CUSTOMER.CUSTOMER_ID |
| PLANT_ID | TEXT | Fulfilling plant | FK to DIM_PLANT.PLANT_ID |
| ORDER_DATE | DATE | Date order was placed | FK to DIM_CALENDAR.DATE_KEY |
| REQUESTED_DATE | DATE | Customer requested delivery date | FK to DIM_CALENDAR.DATE_KEY |
| PROMISED_DATE | DATE | Promised delivery date | FK to DIM_CALENDAR.DATE_KEY |
| SHIPPED_DATE | DATE | Actual ship date | FK to DIM_CALENDAR.DATE_KEY |
| STATUS | TEXT | Order status | - |
| TOTAL_VALUE | NUMBER | Total order value | - |
| CURRENCY_CODE | TEXT | Currency code | - |
| PRIORITY | TEXT | Order priority | - |
| CREATED_TIMESTAMP | TIMESTAMP_NTZ | Record creation timestamp | - |
| UPDATED_TIMESTAMP | TIMESTAMP_NTZ | Last update timestamp | - |

---

## FACT_SALES_ORDER_LINE

Sales order line items with part-level detail.

| Column Name | Data Type | Description | Relationship |
|-------------|-----------|-------------|--------------|
| SO_LINE_SK | NUMBER | Surrogate key (auto-increment) | Primary Key |
| SO_LINE_ID | TEXT | Natural business key for SO line | Unique |
| SO_ID | TEXT | Parent sales order | FK to FACT_SALES_ORDER.SO_ID |
| PART_ID | TEXT | Part being sold | FK to DIM_PART.PART_ID |
| QUANTITY_ORDERED | NUMBER | Quantity ordered by customer | - |
| QUANTITY_SHIPPED | NUMBER | Quantity shipped so far | - |
| UNIT_PRICE | NUMBER | Selling price per unit | - |
| LINE_VALUE | NUMBER | Total line value | - |
| REQUESTED_DATE | DATE | Customer requested date for line | FK to DIM_CALENDAR.DATE_KEY |
| PROMISED_DATE | DATE | Promised date for line | FK to DIM_CALENDAR.DATE_KEY |
| STATUS | TEXT | Line status | - |
| CREATED_TIMESTAMP | TIMESTAMP_NTZ | Record creation timestamp | - |

---

## FACT_SHIPMENT

Shipment tracking for inbound, outbound, and inter-plant transfers.

| Column Name | Data Type | Description | Relationship |
|-------------|-----------|-------------|--------------|
| SHIPMENT_SK | NUMBER | Surrogate key (auto-increment) | Primary Key |
| SHIPMENT_ID | TEXT | Natural business key for shipment | Unique |
| SHIPMENT_CODE | TEXT | Shipment code | - |
| SHIPMENT_TYPE | TEXT | Type (inbound, outbound, inter-plant) | - |
| ORIGIN_PLANT_ID | TEXT | Origin plant | FK to DIM_PLANT.PLANT_ID |
| DESTINATION_PLANT_ID | TEXT | Destination plant | FK to DIM_PLANT.PLANT_ID |
| SUPPLIER_ID | TEXT | Supplier (for inbound) | FK to DIM_SUPPLIER.SUPPLIER_ID |
| CUSTOMER_ID | TEXT | Customer (for outbound) | FK to DIM_CUSTOMER.CUSTOMER_ID |
| CARRIER_ID | TEXT | Carrier handling shipment | FK to DIM_CARRIER.CARRIER_ID |
| PO_ID | TEXT | Related purchase order | FK to FACT_PURCHASE_ORDER.PO_ID |
| SO_ID | TEXT | Related sales order | FK to FACT_SALES_ORDER.SO_ID |
| PART_ID | TEXT | Part being shipped | FK to DIM_PART.PART_ID |
| QUANTITY | NUMBER | Quantity shipped | - |
| SHIP_DATE | DATE | Date shipped | FK to DIM_CALENDAR.DATE_KEY |
| PROMISED_DELIVERY_DATE | DATE | Promised delivery date | FK to DIM_CALENDAR.DATE_KEY |
| ACTUAL_DELIVERY_DATE | DATE | Actual delivery date | FK to DIM_CALENDAR.DATE_KEY |
| STATUS | TEXT | Shipment status | - |
| FREIGHT_COST | NUMBER | Cost of freight | - |
| WEIGHT_KG | NUMBER | Total weight in kilograms | - |
| TRACKING_NUMBER | TEXT | Carrier tracking number | - |
| IS_ON_TIME | BOOLEAN | Whether delivered on time | - |
| CREATED_TIMESTAMP | TIMESTAMP_NTZ | Record creation timestamp | - |
| UPDATED_TIMESTAMP | TIMESTAMP_NTZ | Last update timestamp | - |

---

## FACT_WORK_ORDER

Manufacturing work orders for production and MRO operations.

| Column Name | Data Type | Description | Relationship |
|-------------|-----------|-------------|--------------|
| WORK_ORDER_SK | NUMBER | Surrogate key (auto-increment) | Primary Key |
| WORK_ORDER_ID | TEXT | Natural business key for work order | Unique |
| WORK_ORDER_CODE | TEXT | Work order code | - |
| WORK_ORDER_TYPE | TEXT | Type (production, rework, repair) | - |
| PART_ID | TEXT | Part being manufactured | FK to DIM_PART.PART_ID |
| PLANT_ID | TEXT | Manufacturing plant | FK to DIM_PLANT.PLANT_ID |
| WORK_CENTER_ID | TEXT | Primary work center | FK to DIM_WORK_CENTER.WORK_CENTER_ID |
| QUANTITY_ORDERED | NUMBER | Quantity to produce | - |
| QUANTITY_COMPLETED | NUMBER | Quantity completed | - |
| QUANTITY_SCRAPPED | NUMBER | Quantity scrapped | - |
| PLANNED_START_DATE | DATE | Planned start date | FK to DIM_CALENDAR.DATE_KEY |
| PLANNED_END_DATE | DATE | Planned end date | FK to DIM_CALENDAR.DATE_KEY |
| ACTUAL_START_DATE | DATE | Actual start date | FK to DIM_CALENDAR.DATE_KEY |
| ACTUAL_END_DATE | DATE | Actual end date | FK to DIM_CALENDAR.DATE_KEY |
| STATUS | TEXT | Work order status | - |
| PRIORITY | TEXT | Priority level | - |
| YIELD_RATE | NUMBER | Production yield rate | - |
| TOTAL_COST | NUMBER | Total production cost | - |
| CREATED_TIMESTAMP | TIMESTAMP_NTZ | Record creation timestamp | - |
| UPDATED_TIMESTAMP | TIMESTAMP_NTZ | Last update timestamp | - |

---

## META_BUSINESS_GLOSSARY

Business glossary containing standardized term definitions.

| Column Name | Data Type | Description | Relationship |
|-------------|-----------|-------------|--------------|
| TERM_SK | NUMBER | Surrogate key (auto-increment) | Primary Key |
| TERM_ID | TEXT | Natural business key for term | Unique |
| BUSINESS_TERM | TEXT | Business term name | - |
| BUSINESS_DEFINITION | TEXT | Definition of the term | - |
| SOURCE_TABLE | TEXT | Source table for the term | - |
| FORMULA | TEXT | Calculation formula (if metric) | - |
| OWNER | TEXT | Business owner of the term | - |
| STATUS | TEXT | Term status (Active, Deprecated) | - |
| CREATED_TIMESTAMP | TIMESTAMP_NTZ | Record creation timestamp | - |

---

## META_METRIC_DEFINITION

Metric definitions for KPIs and business measures.

| Column Name | Data Type | Description | Relationship |
|-------------|-----------|-------------|--------------|
| METRIC_SK | NUMBER | Surrogate key (auto-increment) | Primary Key |
| METRIC_ID | TEXT | Natural business key for metric | Unique |
| METRIC_NAME | TEXT | Metric display name | - |
| METRIC_DESCRIPTION | TEXT | Description of what the metric measures | - |
| FORMULA | TEXT | Calculation formula/SQL | - |
| UNIT | TEXT | Unit of measure (%, days, $, etc.) | - |
| TARGET_VALUE | NUMBER | Target/threshold value | - |
| SOURCE_TABLES | TEXT | Tables used to compute this metric | - |
| GRAIN | TEXT | Granularity of the metric | - |
| BUSINESS_RULE | TEXT | Business rules for computation | - |
| CREATED_TIMESTAMP | TIMESTAMP_NTZ | Record creation timestamp | - |
