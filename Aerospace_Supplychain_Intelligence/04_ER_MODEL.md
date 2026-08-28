# 04 - Entity Relationship Model

## Aerospace Supply Chain — Physical Data Model

---

## Overview

This document provides the complete entity-relationship model for the Aerospace Supply Chain platform. It defines all primary keys, foreign keys, cardinality, and join paths that underpin the star schema design in the GOLD layer and enable governed conversational analytics through semantic views.

---

## Schema Design Philosophy

| Principle | Implementation |
|-----------|---------------|
| Star Schema | Centralized fact tables surrounded by conformed dimensions |
| Surrogate Keys | All dimensions use `_SK` (auto-increment) as primary key |
| Natural Keys | All dimensions maintain `_ID` as unique business identifier |
| Conformed Dimensions | Shared dimensions (Part, Plant, Calendar) join consistently across all facts |
| Role-Playing Dimensions | DIM_CALENDAR joins via multiple date columns; DIM_PLANT joins as origin/destination |
| Late-Arriving Facts | Surrogate keys decouple load order from referential integrity |

---

## Primary Key Index

### Dimension Tables

| Table | Primary Key (SK) | Natural Key (ID) | Unique Constraint |
|-------|-----------------|-------------------|-------------------|
| DIM_BOM | BOM_SK | BOM_ID | BOM_ID |
| DIM_CALENDAR | DATE_KEY | DATE_KEY | — (DATE_KEY is both PK and natural key) |
| DIM_CARRIER | CARRIER_SK | CARRIER_ID | CARRIER_ID |
| DIM_CERTIFICATION | CERTIFICATION_SK | — | — |
| DIM_CUSTOMER | CUSTOMER_SK | CUSTOMER_ID | CUSTOMER_ID |
| DIM_PART | PART_SK | PART_ID | PART_ID |
| DIM_PLANT | PLANT_SK | PLANT_ID | PLANT_ID |
| DIM_RAW_MATERIAL | MATERIAL_SK | MATERIAL_ID | MATERIAL_ID |
| DIM_ROUTING | ROUTING_SK | ROUTING_ID | ROUTING_ID |
| DIM_SUPPLIER | SUPPLIER_SK | SUPPLIER_ID | SUPPLIER_ID |
| DIM_SUPPLIER_PART | SUPPLIER_PART_SK | SUPPLIER_PART_ID | SUPPLIER_PART_ID |
| DIM_WAREHOUSE | WAREHOUSE_SK | WAREHOUSE_ID | WAREHOUSE_ID |
| DIM_WORK_CENTER | WORK_CENTER_SK | WORK_CENTER_ID | WORK_CENTER_ID |

### Fact Tables

| Table | Primary Key (SK) | Natural Key (ID) | Unique Constraint |
|-------|-----------------|-------------------|-------------------|
| FACT_AOG_EVENT | AOG_SK | AOG_ID | AOG_ID |
| FACT_INVENTORY | INVENTORY_SK | INVENTORY_ID | INVENTORY_ID |
| FACT_INVENTORY_MOVEMENT | MOVEMENT_SK | MOVEMENT_ID | MOVEMENT_ID |
| FACT_IOT_SENSOR_DATA | SENSOR_SK | — | — |
| FACT_PURCHASE_ORDER | PO_SK | PO_ID | PO_ID |
| FACT_PURCHASE_ORDER_LINE | PO_LINE_SK | PO_LINE_ID | PO_LINE_ID |
| FACT_PURCHASE_REQUISITION | PR_SK | PR_ID | PR_ID |
| FACT_QUALITY_EVENT | QUALITY_EVENT_SK | QUALITY_EVENT_ID | QUALITY_EVENT_ID |
| FACT_REPAIR_ORDER | REPAIR_ORDER_SK | REPAIR_ORDER_ID | REPAIR_ORDER_ID |
| FACT_SALES_ORDER | SO_SK | SO_ID | SO_ID |
| FACT_SALES_ORDER_LINE | SO_LINE_SK | SO_LINE_ID | SO_LINE_ID |
| FACT_SHIPMENT | SHIPMENT_SK | SHIPMENT_ID | SHIPMENT_ID |
| FACT_WORK_ORDER | WORK_ORDER_SK | WORK_ORDER_ID | WORK_ORDER_ID |

---

## Foreign Key Relationships

### DIM_BOM

```
DIM_BOM.PARENT_PART_ID ──────── M:1 ──────── DIM_PART.PART_ID
DIM_BOM.CHILD_PART_ID ───────── M:1 ──────── DIM_PART.PART_ID
```

### DIM_CERTIFICATION

```
DIM_CERTIFICATION.PART_ID ────── M:1 ──────── DIM_PART.PART_ID
```

### DIM_ROUTING

```
DIM_ROUTING.PART_ID ─────────── M:1 ──────── DIM_PART.PART_ID
DIM_ROUTING.WORK_CENTER_ID ──── M:1 ──────── DIM_WORK_CENTER.WORK_CENTER_ID
```

### DIM_SUPPLIER_PART

```
DIM_SUPPLIER_PART.SUPPLIER_ID ── M:1 ──────── DIM_SUPPLIER.SUPPLIER_ID
DIM_SUPPLIER_PART.PART_ID ────── M:1 ──────── DIM_PART.PART_ID
```

### DIM_WAREHOUSE

```
DIM_WAREHOUSE.PLANT_ID ────────── M:1 ──────── DIM_PLANT.PLANT_ID
```

### DIM_WORK_CENTER

```
DIM_WORK_CENTER.PLANT_ID ──────── M:1 ──────── DIM_PLANT.PLANT_ID
```

### FACT_PURCHASE_ORDER

```
FACT_PURCHASE_ORDER.SUPPLIER_ID ──── M:1 ──── DIM_SUPPLIER.SUPPLIER_ID
FACT_PURCHASE_ORDER.PLANT_ID ─────── M:1 ──── DIM_PLANT.PLANT_ID
FACT_PURCHASE_ORDER.ORDER_DATE ───── M:1 ──── DIM_CALENDAR.DATE_KEY
FACT_PURCHASE_ORDER.PROMISED_DATE ── M:1 ──── DIM_CALENDAR.DATE_KEY
FACT_PURCHASE_ORDER.RECEIVED_DATE ── M:1 ──── DIM_CALENDAR.DATE_KEY
```

### FACT_PURCHASE_ORDER_LINE

```
FACT_PURCHASE_ORDER_LINE.PO_ID ──────── M:1 ──── FACT_PURCHASE_ORDER.PO_ID
FACT_PURCHASE_ORDER_LINE.PART_ID ────── M:1 ──── DIM_PART.PART_ID
FACT_PURCHASE_ORDER_LINE.PROMISED_DATE ─ M:1 ──── DIM_CALENDAR.DATE_KEY
FACT_PURCHASE_ORDER_LINE.RECEIVED_DATE ─ M:1 ──── DIM_CALENDAR.DATE_KEY
```

### FACT_PURCHASE_REQUISITION

```
FACT_PURCHASE_REQUISITION.PART_ID ────── M:1 ──── DIM_PART.PART_ID
FACT_PURCHASE_REQUISITION.PLANT_ID ───── M:1 ──── DIM_PLANT.PLANT_ID
FACT_PURCHASE_REQUISITION.SUPPLIER_ID ── M:1 ──── DIM_SUPPLIER.SUPPLIER_ID
FACT_PURCHASE_REQUISITION.NEED_DATE ──── M:1 ──── DIM_CALENDAR.DATE_KEY
FACT_PURCHASE_REQUISITION.APPROVAL_DATE ─ M:1 ──── DIM_CALENDAR.DATE_KEY
```

### FACT_SALES_ORDER

```
FACT_SALES_ORDER.CUSTOMER_ID ──── M:1 ──── DIM_CUSTOMER.CUSTOMER_ID
FACT_SALES_ORDER.PLANT_ID ─────── M:1 ──── DIM_PLANT.PLANT_ID
FACT_SALES_ORDER.ORDER_DATE ───── M:1 ──── DIM_CALENDAR.DATE_KEY
FACT_SALES_ORDER.REQUESTED_DATE ─ M:1 ──── DIM_CALENDAR.DATE_KEY
FACT_SALES_ORDER.PROMISED_DATE ── M:1 ──── DIM_CALENDAR.DATE_KEY
FACT_SALES_ORDER.SHIPPED_DATE ─── M:1 ──── DIM_CALENDAR.DATE_KEY
```

### FACT_SALES_ORDER_LINE

```
FACT_SALES_ORDER_LINE.SO_ID ─────── M:1 ──── FACT_SALES_ORDER.SO_ID
FACT_SALES_ORDER_LINE.PART_ID ───── M:1 ──── DIM_PART.PART_ID
FACT_SALES_ORDER_LINE.REQUESTED_DATE ─ M:1 ──── DIM_CALENDAR.DATE_KEY
FACT_SALES_ORDER_LINE.PROMISED_DATE ── M:1 ──── DIM_CALENDAR.DATE_KEY
```

### FACT_SHIPMENT

```
FACT_SHIPMENT.ORIGIN_PLANT_ID ──────── M:1 ──── DIM_PLANT.PLANT_ID (role: origin)
FACT_SHIPMENT.DESTINATION_PLANT_ID ─── M:1 ──── DIM_PLANT.PLANT_ID (role: destination)
FACT_SHIPMENT.SUPPLIER_ID ──────────── M:1 ──── DIM_SUPPLIER.SUPPLIER_ID
FACT_SHIPMENT.CUSTOMER_ID ──────────── M:1 ──── DIM_CUSTOMER.CUSTOMER_ID
FACT_SHIPMENT.CARRIER_ID ───────────── M:1 ──── DIM_CARRIER.CARRIER_ID
FACT_SHIPMENT.PO_ID ────────────────── M:1 ──── FACT_PURCHASE_ORDER.PO_ID
FACT_SHIPMENT.SO_ID ────────────────── M:1 ──── FACT_SALES_ORDER.SO_ID
FACT_SHIPMENT.PART_ID ──────────────── M:1 ──── DIM_PART.PART_ID
FACT_SHIPMENT.SHIP_DATE ────────────── M:1 ──── DIM_CALENDAR.DATE_KEY
FACT_SHIPMENT.PROMISED_DELIVERY_DATE ── M:1 ──── DIM_CALENDAR.DATE_KEY
FACT_SHIPMENT.ACTUAL_DELIVERY_DATE ──── M:1 ──── DIM_CALENDAR.DATE_KEY
```

### FACT_INVENTORY

```
FACT_INVENTORY.PART_ID ─────── M:1 ──── DIM_PART.PART_ID
FACT_INVENTORY.PLANT_ID ────── M:1 ──── DIM_PLANT.PLANT_ID
FACT_INVENTORY.WAREHOUSE_ID ── M:1 ──── DIM_WAREHOUSE.WAREHOUSE_ID
FACT_INVENTORY.SNAPSHOT_DATE ── M:1 ──── DIM_CALENDAR.DATE_KEY
```

### FACT_INVENTORY_MOVEMENT

```
FACT_INVENTORY_MOVEMENT.PART_ID ─────── M:1 ──── DIM_PART.PART_ID
FACT_INVENTORY_MOVEMENT.PLANT_ID ────── M:1 ──── DIM_PLANT.PLANT_ID
FACT_INVENTORY_MOVEMENT.WAREHOUSE_ID ── M:1 ──── DIM_WAREHOUSE.WAREHOUSE_ID
FACT_INVENTORY_MOVEMENT.MOVEMENT_DATE ─ M:1 ──── DIM_CALENDAR.DATE_KEY
```

### FACT_WORK_ORDER

```
FACT_WORK_ORDER.PART_ID ──────────── M:1 ──── DIM_PART.PART_ID
FACT_WORK_ORDER.PLANT_ID ─────────── M:1 ──── DIM_PLANT.PLANT_ID
FACT_WORK_ORDER.WORK_CENTER_ID ───── M:1 ──── DIM_WORK_CENTER.WORK_CENTER_ID
FACT_WORK_ORDER.PLANNED_START_DATE ── M:1 ──── DIM_CALENDAR.DATE_KEY
FACT_WORK_ORDER.PLANNED_END_DATE ──── M:1 ──── DIM_CALENDAR.DATE_KEY
FACT_WORK_ORDER.ACTUAL_START_DATE ─── M:1 ──── DIM_CALENDAR.DATE_KEY
FACT_WORK_ORDER.ACTUAL_END_DATE ───── M:1 ──── DIM_CALENDAR.DATE_KEY
```

### FACT_QUALITY_EVENT

```
FACT_QUALITY_EVENT.PART_ID ──────── M:1 ──── DIM_PART.PART_ID
FACT_QUALITY_EVENT.SUPPLIER_ID ──── M:1 ──── DIM_SUPPLIER.SUPPLIER_ID
FACT_QUALITY_EVENT.PLANT_ID ─────── M:1 ──── DIM_PLANT.PLANT_ID
FACT_QUALITY_EVENT.WORK_ORDER_ID ── M:1 ──── FACT_WORK_ORDER.WORK_ORDER_ID
FACT_QUALITY_EVENT.EVENT_DATE ───── M:1 ──── DIM_CALENDAR.DATE_KEY
FACT_QUALITY_EVENT.RESOLUTION_DATE ─ M:1 ──── DIM_CALENDAR.DATE_KEY
```

### FACT_IOT_SENSOR_DATA

```
FACT_IOT_SENSOR_DATA.WORK_CENTER_ID ── M:1 ──── DIM_WORK_CENTER.WORK_CENTER_ID
FACT_IOT_SENSOR_DATA.PLANT_ID ──────── M:1 ──── DIM_PLANT.PLANT_ID
```

### FACT_AOG_EVENT

```
FACT_AOG_EVENT.CUSTOMER_ID ────── M:1 ──── DIM_CUSTOMER.CUSTOMER_ID
FACT_AOG_EVENT.PART_ID ────────── M:1 ──── DIM_PART.PART_ID
FACT_AOG_EVENT.EVENT_DATE ─────── M:1 ──── DIM_CALENDAR.DATE_KEY
FACT_AOG_EVENT.RESOLUTION_DATE ── M:1 ──── DIM_CALENDAR.DATE_KEY
```

### FACT_REPAIR_ORDER

```
FACT_REPAIR_ORDER.PART_ID ──────── M:1 ──── DIM_PART.PART_ID
FACT_REPAIR_ORDER.CUSTOMER_ID ──── M:1 ──── DIM_CUSTOMER.CUSTOMER_ID
FACT_REPAIR_ORDER.RECEIVED_DATE ── M:1 ──── DIM_CALENDAR.DATE_KEY
FACT_REPAIR_ORDER.RELEASED_DATE ── M:1 ──── DIM_CALENDAR.DATE_KEY
```

---

## Complete ER Diagram

```
                                    ┌──────────────────┐
                                    │   DIM_CALENDAR   │
                                    │   ════════════   │
                                    │ PK: DATE_KEY     │
                                    │    YEAR          │
                                    │    QUARTER       │
                                    │    FISCAL_YEAR   │
                                    └────────┬─────────┘
                                             │
                    ┌────────────────────────┬┼┬────────────────────────┐
                    │                        │││                        │
                    ▼                        │▼│                        ▼
┌──────────────────────────┐                │ │        ┌──────────────────────────┐
│     DIM_SUPPLIER         │                │ │        │     DIM_CUSTOMER         │
│     ════════════         │                │ │        │     ════════════         │
│ PK: SUPPLIER_SK          │                │ │        │ PK: CUSTOMER_SK          │
│ NK: SUPPLIER_ID          │                │ │        │ NK: CUSTOMER_ID          │
│     SUPPLIER_NAME        │                │ │        │     CUSTOMER_NAME        │
│     TIER_LEVEL           │                │ │        │     CUSTOMER_TYPE        │
│     COUNTRY/REGION       │                │ │        │     COUNTRY/REGION       │
│     RISK_SCORE           │                │ │        │     REVENUE_TIER         │
│     QUALITY_RATING       │                │ │        │     ANNUAL_REVENUE       │
│     ON_TIME_DELIVERY_PCT │                │ │        │     CREDIT_LIMIT         │
└────────────┬─────────────┘                │ │        └────────────┬─────────────┘
             │                              │ │                     │
             │    ┌─────────────────────┐   │ │   ┌──────────────┐ │
             │    │ DIM_SUPPLIER_PART   │   │ │   │  DIM_CARRIER │ │
             │    │ ═════════════════   │   │ │   │  ══════════  │ │
             ├───▶│ PK: SUPPLIER_PART_SK│   │ │   │ PK: CARRIER_SK│ │
             │    │ FK: SUPPLIER_ID     │   │ │   │ NK: CARRIER_ID│ │
             │    │ FK: PART_ID ────────┼───┼─┼─┐ │    ON_TIME_PCT│ │
             │    │     CONTRACT_PRICE  │   │ │ │ │    COST_PER_KG│ │
             │    │     LEAD_TIME_DAYS  │   │ │ │ └──────┬───────┘ │
             │    │     MOQ            │   │ │ │        │         │
             │    └─────────────────────┘   │ │ │        │         │
             │                              │ │ │        │         │
             ▼                              ▼ ▼ ▼        ▼         ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                            FACT_SHIPMENT                                      │
│                            ═════════════                                      │
│ PK: SHIPMENT_SK                                                              │
│ NK: SHIPMENT_ID                                                              │
│ FK: SUPPLIER_ID, CUSTOMER_ID, CARRIER_ID, PART_ID                           │
│ FK: ORIGIN_PLANT_ID, DESTINATION_PLANT_ID                                    │
│ FK: PO_ID, SO_ID                                                             │
│ FK: SHIP_DATE, PROMISED_DELIVERY_DATE, ACTUAL_DELIVERY_DATE                  │
│     QUANTITY, FREIGHT_COST, WEIGHT_KG, IS_ON_TIME, STATUS                    │
└─────────────────────────────────────────────────────────────────────────────┘
             │                              │                     │
             │                              │                     │
             ▼                              ▼                     ▼
┌──────────────────────┐   ┌──────────────────────────┐   ┌────────────────────┐
│ FACT_PURCHASE_ORDER  │   │       DIM_PART           │   │ FACT_SALES_ORDER   │
│ ═══════════════════  │   │       ════════           │   │ ════════════════   │
│ PK: PO_SK            │   │ PK: PART_SK             │   │ PK: SO_SK          │
│ NK: PO_ID            │   │ NK: PART_ID             │   │ NK: SO_ID          │
│ FK: SUPPLIER_ID      │   │     PART_NUMBER         │   │ FK: CUSTOMER_ID    │
│ FK: PLANT_ID         │   │     PART_NAME           │   │ FK: PLANT_ID       │
│ FK: ORDER_DATE       │   │     PART_FAMILY         │   │ FK: ORDER_DATE     │
│     TOTAL_VALUE      │   │     ATA_CHAPTER         │   │     TOTAL_VALUE    │
│     STATUS           │   │     CRITICALITY         │   │     STATUS         │
└──────────┬───────────┘   │     LEAD_TIME_DAYS      │   └──────────┬─────────┘
           │               │     MAKE_BUY_CODE       │              │
           ▼               │     LIFECYCLE_STATUS    │              ▼
┌──────────────────────┐   └──────────────┬──────────┘   ┌────────────────────┐
│ FACT_PURCHASE_       │                  │              │ FACT_SALES_ORDER_  │
│ ORDER_LINE           │                  │              │ LINE               │
│ ═══════════════════  │                  │              │ ════════════════   │
│ PK: PO_LINE_SK       │                  │              │ PK: SO_LINE_SK     │
│ FK: PO_ID            │                  │              │ FK: SO_ID          │
│ FK: PART_ID ─────────┼──────────────────┤              │ FK: PART_ID ───────┤
│     QUANTITY_ORDERED │                  │              │     QTY_ORDERED    │
│     UNIT_PRICE       │                  │              │     UNIT_PRICE     │
└──────────────────────┘                  │              └────────────────────┘
                                          │
                    ┌─────────────────────┬┼┬─────────────────────┐
                    │                     │││                     │
                    ▼                     │▼│                     ▼
┌──────────────────────────┐             │ │        ┌──────────────────────────┐
│     DIM_PLANT            │             │ │        │      DIM_BOM             │
│     ═════════            │             │ │        │      ═══════             │
│ PK: PLANT_SK             │             │ │        │ PK: BOM_SK               │
│ NK: PLANT_ID             │             │ │        │ NK: BOM_ID               │
│     PLANT_NAME           │             │ │        │ FK: PARENT_PART_ID       │
│     COUNTRY/REGION       │             │ │        │ FK: CHILD_PART_ID        │
│     PLANT_TYPE           │             │ │        │     QUANTITY_PER         │
│     CAPACITY_UNITS       │             │ │        │     BOM_LEVEL            │
└────────────┬─────────────┘             │ │        └──────────────────────────┘
             │                           │ │
      ┌──────┴──────┐                   │ │
      │             │                   │ │
      ▼             ▼                   │ │
┌────────────┐ ┌────────────────┐       │ │
│DIM_WARE-   │ │DIM_WORK_CENTER │       │ │
│HOUSE       │ │════════════════ │       │ │
│════════════│ │PK: WC_SK       │       │ │
│PK: WH_SK  │ │NK: WC_ID       │       │ │
│NK: WH_ID  │ │FK: PLANT_ID    │       │ │
│FK: PLANT_ID│ │    MACHINE_TYPE│       │ │
│    TYPE    │ │    HOURLY_RATE │       │ │
└─────┬──────┘ └───────┬────────┘       │ │
      │                │                │ │
      ▼                ▼                ▼ ▼
┌──────────────────────────────────────────────────────────────────┐
│                        FACT_INVENTORY                              │
│                        ══════════════                              │
│ PK: INVENTORY_SK                                                  │
│ FK: PART_ID, PLANT_ID, WAREHOUSE_ID, SNAPSHOT_DATE               │
│     ON_HAND_QTY, AVAILABLE_QTY, RESERVED_QTY                     │
│     REORDER_POINT, SAFETY_STOCK, TOTAL_VALUE                     │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│                     FACT_WORK_ORDER                                │
│                     ═══════════════                                │
│ PK: WORK_ORDER_SK                                                 │
│ FK: PART_ID, PLANT_ID, WORK_CENTER_ID                            │
│ FK: PLANNED_START_DATE, PLANNED_END_DATE                          │
│ FK: ACTUAL_START_DATE, ACTUAL_END_DATE                            │
│     QTY_ORDERED, QTY_COMPLETED, QTY_SCRAPPED, YIELD_RATE         │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│                     FACT_QUALITY_EVENT                             │
│                     ═════════════════                              │
│ PK: QUALITY_EVENT_SK                                              │
│ FK: PART_ID, SUPPLIER_ID, PLANT_ID, WORK_ORDER_ID               │
│ FK: EVENT_DATE, RESOLUTION_DATE                                   │
│     EVENT_TYPE, DEFECT_TYPE, SEVERITY, DISPOSITION                │
│     QTY_INSPECTED, QTY_DEFECTIVE, COST_OF_QUALITY                │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│                     FACT_IOT_SENSOR_DATA                           │
│                     ═══════════════════                            │
│ PK: SENSOR_SK                                                     │
│ FK: WORK_CENTER_ID, PLANT_ID                                      │
│     SENSOR_ID, READING_TIMESTAMP                                  │
│     TEMPERATURE_C, VIBRATION_MM_S, PRESSURE_BAR, RPM              │
│     POWER_KW, OIL_LEVEL_PCT, STATUS, ALERT_FLAG                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## Role-Playing Dimensions

DIM_CALENDAR and DIM_PLANT serve multiple roles within fact tables:

### DIM_CALENDAR Roles

| Fact Table | Date Column | Role |
|-----------|-------------|------|
| FACT_PURCHASE_ORDER | ORDER_DATE | Order placement date |
| FACT_PURCHASE_ORDER | PROMISED_DATE | Supplier promised delivery |
| FACT_PURCHASE_ORDER | RECEIVED_DATE | Actual goods receipt |
| FACT_SALES_ORDER | ORDER_DATE | Customer order date |
| FACT_SALES_ORDER | REQUESTED_DATE | Customer requested date |
| FACT_SALES_ORDER | PROMISED_DATE | Committed delivery date |
| FACT_SALES_ORDER | SHIPPED_DATE | Actual ship date |
| FACT_SHIPMENT | SHIP_DATE | Shipment departure |
| FACT_SHIPMENT | PROMISED_DELIVERY_DATE | Expected arrival |
| FACT_SHIPMENT | ACTUAL_DELIVERY_DATE | Actual arrival |
| FACT_WORK_ORDER | PLANNED_START_DATE | Scheduled production start |
| FACT_WORK_ORDER | PLANNED_END_DATE | Scheduled production end |
| FACT_WORK_ORDER | ACTUAL_START_DATE | Actual production start |
| FACT_WORK_ORDER | ACTUAL_END_DATE | Actual production end |
| FACT_QUALITY_EVENT | EVENT_DATE | Quality event occurrence |
| FACT_QUALITY_EVENT | RESOLUTION_DATE | Event resolution |
| FACT_AOG_EVENT | EVENT_DATE | AOG occurrence |
| FACT_AOG_EVENT | RESOLUTION_DATE | AOG resolution |
| FACT_REPAIR_ORDER | RECEIVED_DATE | Part received for repair |
| FACT_REPAIR_ORDER | RELEASED_DATE | Part released after repair |
| FACT_INVENTORY | SNAPSHOT_DATE | Inventory snapshot date |
| FACT_INVENTORY_MOVEMENT | MOVEMENT_DATE | Stock movement date |

### DIM_PLANT Roles

| Fact Table | Column | Role |
|-----------|--------|------|
| FACT_SHIPMENT | ORIGIN_PLANT_ID | Shipping origin facility |
| FACT_SHIPMENT | DESTINATION_PLANT_ID | Delivery destination facility |
| FACT_PURCHASE_ORDER | PLANT_ID | Receiving plant |
| FACT_SALES_ORDER | PLANT_ID | Fulfilling plant |
| FACT_WORK_ORDER | PLANT_ID | Manufacturing plant |
| FACT_INVENTORY | PLANT_ID | Storage plant |
| FACT_QUALITY_EVENT | PLANT_ID | Plant where event occurred |
| FACT_IOT_SENSOR_DATA | PLANT_ID | Monitored plant |

---

## Cardinality Summary

| Relationship | Type | Description |
|-------------|------|-------------|
| Supplier → Purchase Orders | 1:M | One supplier receives many POs |
| Customer → Sales Orders | 1:M | One customer places many SOs |
| Plant → Warehouses | 1:M | One plant contains many warehouses |
| Plant → Work Centers | 1:M | One plant has many work centers |
| Part → BOM (parent) | 1:M | One part can be parent of many assemblies |
| Part → BOM (child) | 1:M | One part can be child in many assemblies |
| Part → Inventory | 1:M | One part stocked in many locations |
| Supplier ↔ Part | M:N | Many-to-many via DIM_SUPPLIER_PART |
| Purchase Order → PO Lines | 1:M | One PO has many line items |
| Sales Order → SO Lines | 1:M | One SO has many line items |
| Work Order → Quality Events | 1:M | One WO can have many quality events |
| Work Center → IoT Readings | 1:M | One work center has many sensor readings |
| Carrier → Shipments | 1:M | One carrier handles many shipments |

---

## Join Path Reference

Common analytical join paths for semantic view construction:

### Procurement Analytics

```sql
FACT_PURCHASE_ORDER po
  JOIN DIM_SUPPLIER s ON po.SUPPLIER_ID = s.SUPPLIER_ID
  JOIN FACT_PURCHASE_ORDER_LINE pol ON po.PO_ID = pol.PO_ID
  JOIN DIM_PART p ON pol.PART_ID = p.PART_ID
  JOIN DIM_PLANT pl ON po.PLANT_ID = pl.PLANT_ID
  JOIN DIM_CALENDAR c ON po.ORDER_DATE = c.DATE_KEY
```

### Inventory Analytics

```sql
FACT_INVENTORY inv
  JOIN DIM_PART p ON inv.PART_ID = p.PART_ID
  JOIN DIM_PLANT pl ON inv.PLANT_ID = pl.PLANT_ID
  JOIN DIM_WAREHOUSE w ON inv.WAREHOUSE_ID = w.WAREHOUSE_ID
  JOIN DIM_SUPPLIER_PART sp ON p.PART_ID = sp.PART_ID
  JOIN DIM_SUPPLIER s ON sp.SUPPLIER_ID = s.SUPPLIER_ID
```

### Logistics Analytics

```sql
FACT_SHIPMENT sh
  JOIN DIM_CARRIER cr ON sh.CARRIER_ID = cr.CARRIER_ID
  JOIN DIM_PART p ON sh.PART_ID = p.PART_ID
  JOIN DIM_PLANT origin ON sh.ORIGIN_PLANT_ID = origin.PLANT_ID
  JOIN DIM_PLANT dest ON sh.DESTINATION_PLANT_ID = dest.PLANT_ID
  JOIN DIM_SUPPLIER s ON sh.SUPPLIER_ID = s.SUPPLIER_ID
  JOIN DIM_CUSTOMER c ON sh.CUSTOMER_ID = c.CUSTOMER_ID
```

### Manufacturing Analytics

```sql
FACT_WORK_ORDER wo
  JOIN DIM_PART p ON wo.PART_ID = p.PART_ID
  JOIN DIM_PLANT pl ON wo.PLANT_ID = pl.PLANT_ID
  JOIN DIM_WORK_CENTER wc ON wo.WORK_CENTER_ID = wc.WORK_CENTER_ID
  LEFT JOIN FACT_QUALITY_EVENT qe ON wo.WORK_ORDER_ID = qe.WORK_ORDER_ID
```

### End-to-End Order Fulfillment

```sql
FACT_SALES_ORDER so
  JOIN FACT_SALES_ORDER_LINE sol ON so.SO_ID = sol.SO_ID
  JOIN DIM_PART p ON sol.PART_ID = p.PART_ID
  JOIN DIM_CUSTOMER c ON so.CUSTOMER_ID = c.CUSTOMER_ID
  JOIN FACT_SHIPMENT sh ON so.SO_ID = sh.SO_ID
  JOIN DIM_CARRIER cr ON sh.CARRIER_ID = cr.CARRIER_ID
  JOIN FACT_INVENTORY inv ON p.PART_ID = inv.PART_ID AND so.PLANT_ID = inv.PLANT_ID
```

---

## Data Volume Estimates

| Table | Row Count | Growth Pattern |
|-------|-----------|----------------|
| DIM_SUPPLIER | 750 | Slow (new supplier onboarding) |
| DIM_PART | 5,000 | Moderate (new part introductions) |
| DIM_PLANT | 25 | Rare (new facility construction) |
| DIM_WAREHOUSE | 100 | Rare |
| DIM_CUSTOMER | 30 | Slow |
| DIM_CARRIER | 25 | Rare |
| DIM_WORK_CENTER | 250 | Slow |
| DIM_CALENDAR | 1,096 | Fixed (3-year window) |
| FACT_PURCHASE_ORDER | 20,000 | ~500/month |
| FACT_PURCHASE_ORDER_LINE | 100,000 | ~2,500/month |
| FACT_SALES_ORDER | 15,000 | ~400/month |
| FACT_SALES_ORDER_LINE | 60,000 | ~1,500/month |
| FACT_SHIPMENT | 250,000 | ~6,000/month |
| FACT_INVENTORY | 25,000 | Snapshot (refreshed daily) |
| FACT_INVENTORY_MOVEMENT | 1,000,000 | ~25,000/month |
| FACT_WORK_ORDER | 75,000 | ~2,000/month |
| FACT_QUALITY_EVENT | 50,000 | ~1,200/month |
| FACT_IOT_SENSOR_DATA | 2,000,000 | ~50,000/day |
| FACT_AOG_EVENT | — | Event-driven (rare) |
| FACT_REPAIR_ORDER | — | Event-driven |

---

## Clustering Keys (Performance Optimization)

| Table | Clustering Key | Rationale |
|-------|---------------|-----------|
| DIM_PART | (PART_FAMILY, ATA_CHAPTER) | Queries filter by family and ATA |
| DIM_SUPPLIER | (TIER_LEVEL, COUNTRY) | Queries filter by tier and geography |
| DIM_PLANT | (REGION, COUNTRY) | Geographic filtering |
| FACT_PURCHASE_ORDER | (ORDER_DATE, SUPPLIER_ID) | Time-series by supplier |
| FACT_SALES_ORDER | (ORDER_DATE, CUSTOMER_ID) | Time-series by customer |
| FACT_SHIPMENT | (SHIP_DATE, SHIPMENT_TYPE) | Time-series by type |
| FACT_INVENTORY | (PLANT_ID, PART_ID) | Location + part lookup |
| FACT_INVENTORY_MOVEMENT | (MOVEMENT_DATE, MOVEMENT_TYPE) | Time-series by type |
| FACT_WORK_ORDER | (PLANNED_START_DATE, PLANT_ID) | Schedule by plant |
| FACT_QUALITY_EVENT | (EVENT_DATE, PLANT_ID) | Time-series by plant |
| FACT_IOT_SENSOR_DATA | (READING_TIMESTAMP, PLANT_ID) | Time-series by plant |
