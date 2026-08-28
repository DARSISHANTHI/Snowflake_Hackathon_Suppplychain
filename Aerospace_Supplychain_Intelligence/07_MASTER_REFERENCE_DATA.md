# 07 - Master Reference Data

## Aerospace Supply Chain — Domain Reference & Code Standards

---

## Overview

This document defines all master reference data, domain enumerations, and enterprise code standards used across the Aerospace Supply Chain platform. It serves as the authoritative source for valid values, naming conventions, and identifier formats that govern data quality and consistency.




## Suppliers

### Aerospace Suppliers (100 Organizations)

| # | Supplier Name | # | Supplier Name |
|---|--------------|---|--------------|
| 1 | Hexcel Corporation | 51 | Elbit Systems |
| 2 | Spirit AeroSystems | 52 | Saab Aerospace |
| 3 | Safran Aerosystems | 53 | Hanwha Aerospace |
| 4 | Precision Castparts | 54 | Rheinmetall Aerospace |
| 5 | ATI Specialty Materials | 55 | CAE |
| 6 | GE Aerospace | 56 | Magellan Aerospace |
| 7 | RTX Pratt & Whitney | 57 | Ontic Engineering |
| 8 | Rolls-Royce Aerospace | 58 | Ametek Aerospace |
| 9 | Collins Aerospace | 59 | General Dynamics Aerospace |
| 10 | Honeywell Aerospace | 60 | Northstar Aerospace |
| 11 | MTU Aero Engines | 61 | Hutchinson Aerospace |
| 12 | GKN Aerospace | 62 | Airbus Atlantic |
| 13 | Howmet Aerospace | 63 | Smiths Aerospace |
| 14 | Triumph Group | 64 | Marshall Aerospace |
| 15 | Moog Aerospace | 65 | FACC Aerospace |
| 16 | Parker Aerospace | 66 | RUAG Aerospace |
| 17 | Eaton Aerospace | 67 | Diehl Aviation |
| 18 | Meggitt | 68 | Aerojet Rocketdyne |
| 19 | Cobham Aerospace | 69 | Astra Aviation |
| 20 | Safran Aircraft Engines | 70 | Wesco Aircraft |
| 21 | CFM International | 71 | Boeing Global Services |
| 22 | ITP Aero | 72 | Jet Aviation |
| 23 | L3Harris Technologies | 73 | ST Engineering Aerospace |
| 24 | Thales Aerospace | 74 | AAR Corporation |
| 25 | Astronics | 75 | HEICO Aerospace |
| 26 | Crane Aerospace | 76 | Avcorp Industries |
| 27 | SKF Aerospace | 77 | Sargent Aerospace |
| 28 | RBC Bearings | 78 | Aviation Partners |
| 29 | Senior Aerospace | 79 | Acme Aerospace |
| 30 | TransDigm Group | 80 | Mubea Aerospace |
| 31 | Arconic | 81 | Novaria Group |
| 32 | Alcoa Aerospace | 82 | Kaman Aerospace |
| 33 | Carpenter Technology | 83 | Valence Surface Technologies |
| 34 | Haynes International | 84 | Doncasters Aerospace |
| 35 | TIMET | 85 | Senior Flexonics Aerospace |
| 36 | VSMPO-AVISMA | 86 | Mubea Aerostructures |
| 37 | Kawasaki Aerospace | 87 | Bodycote Aerospace |
| 38 | Mitsubishi Heavy Industries | 88 | Duncan Aviation |
| 39 | Fuji Aerospace | 89 | Delta TechOps |
| 40 | Premium AEROTEC | 90 | Turkish Aerospace Industries |
| 41 | Latecoere | 91 | Korea Aerospace Industries |
| 42 | Leonardo Aerostructures | 92 | Spirit Europe |
| 43 | Daher Aerospace | 93 | ZeroAvia Components |
| 44 | Ducommun | 94 | Vertical Aerospace Systems |
| 45 | Aernnova Aerospace | 95 | Joby Aviation Supply |
| 46 | Nordam | 96 | Lilium Components |
| 47 | Barnes Aerospace | 97 | Volocopter Systems |
| 48 | Albany Engineered Composites | 98 | Blue Origin Components |
| 49 | Curtiss-Wright | 99 | SpaceX Manufacturing |
| 50 | Teledyne Aerospace | 100 | Rocket Lab Aerospace |

### Supplier Types

| Type | Description |
|------|-------------|
| Raw Material Supplier | Provides base metals, composites, chemicals |
| Component Supplier | Manufactures sub-assemblies and components |
| Engine Supplier | Provides engine modules and parts |
| Avionics Supplier | Provides electronic systems and sensors |
| Tier-1 Supplier | Direct supplier to OEMs |

### Supplier Categories

| Category | Description | Criteria |
|----------|-------------|----------|
| Strategic | Critical to operations, long-term partnerships | Tier 1, Annual spend > $10M |
| Preferred | Established, reliable performance | OTD > 90%, Quality > 85 |
| Standard | Transactional, commodity items | All others |

---

## Customers

### Aerospace Customers (30 Organizations)

| # | Customer Name | Type |
|---|--------------|------|
| 1 | Airbus | OEM |
| 2 | Boeing | OEM |
| 3 | Lockheed Martin | Defense |
| 4 | Northrop Grumman | Defense |
| 5 | Dassault Aviation | OEM |
| 6 | Embraer | OEM |
| 7 | Bombardier | OEM |
| 8 | Leonardo | Defense |
| 9 | BAE Systems | Defense |
| 10 | Textron Aviation | OEM |
| 11 | Gulfstream | Business Aviation |
| 12 | Cessna | General Aviation |
| 13 | Bell Helicopter | Rotorcraft |
| 14 | Sikorsky | Rotorcraft |
| 15 | Air India | Airline |
| 16 | IndiGo | Airline |
| 17 | United Airlines | Airline |
| 18 | Delta Airlines | Airline |
| 19 | Qatar Airways | Airline |
| 20 | Singapore Airlines | Airline |
| 21 | Lufthansa | Airline |
| 22 | ANA | Airline |
| 23 | Japan Airlines | Airline |
| 24 | Ryanair | Airline |
| 25 | EasyJet | Airline |
| 26 | Virgin Atlantic | Airline |
| 27 | Air France | Airline |
| 28 | KLM | Airline |
| 29 | Turkish Airlines | Airline |
| 30 | Saudi Arabian Airlines | Airline |

---

## Raw Materials

### Material Master (20 Materials)

| # | Material Name | Material Type |
|---|--------------|---------------|
| 1 | Titanium Alloy Ti-6Al-4V | Titanium |
| 2 | Titanium Billet | Titanium |
| 3 | Inconel 718 | Nickel Alloy |
| 4 | Inconel 625 | Nickel Alloy |
| 5 | Nickel Alloy | Nickel Alloy |
| 6 | Carbon Fiber Prepreg | Composite |
| 7 | Composite Honeycomb | Composite |
| 8 | Epoxy Resin | Chemical |
| 9 | Ceramic Matrix Composite | Composite |
| 10 | Aluminum 7075 | Aluminum |
| 11 | Aluminum 2024 | Aluminum |
| 12 | Aircraft Grade Steel | Steel |
| 13 | Stainless Steel 316L | Steel |
| 14 | Copper Alloy | Aluminum |
| 15 | Magnesium Alloy | Aluminum |
| 16 | Titanium Sheet | Titanium |
| 17 | Forged Ring | Steel |
| 18 | Titanium Bar Stock | Titanium |
| 19 | Aerospace Adhesive | Adhesive |
| 20 | Thermal Barrier Coating | Coating |

### Material Types

| Type | Typical Applications |
|------|---------------------|
| Titanium | Engine components, structural parts, fasteners |
| Composite | Wing skins, nacelles, interior panels |
| Nickel Alloy | High-temperature engine components |
| Aluminum | Fuselage frames, wing ribs, non-critical structures |
| Steel | Landing gear, fasteners, bearings |
| Chemical | Bonding, surface treatment |
| Coating | Thermal protection, corrosion resistance |
| Adhesive | Structural bonding, composite assembly |

---

## Parts

### Part Families (10 Families)

| Family | Code | Typical ATA Chapters |
|--------|------|---------------------|
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

### Part Names (30 Parts)

| # | Part Name | Typical Family |
|---|-----------|---------------|
| 1 | Turbine Blade | Engine Components |
| 2 | Fan Blade | Engine Components |
| 3 | Compressor Blade | Engine Components |
| 4 | Turbine Disc | Engine Components |
| 5 | Engine Shaft | Engine Components |
| 6 | Fuel Nozzle | Engine Components |
| 7 | Combustion Chamber | Engine Components |
| 8 | Wing Rib | Airframe Components |
| 9 | Wing Spar | Airframe Components |
| 10 | Wing Panel | Airframe Components |
| 11 | Fuselage Frame | Airframe Components |
| 12 | Bulkhead Assembly | Airframe Components |
| 13 | Landing Gear Assembly | Landing Systems |
| 14 | Brake Assembly | Landing Systems |
| 15 | Hydraulic Actuator | Hydraulic Systems |
| 16 | Hydraulic Pump | Hydraulic Systems |
| 17 | Control Surface | Flight Controls |
| 18 | Flap Track | Flight Controls |
| 19 | Spoiler Panel | Flight Controls |
| 20 | Avionics Module | Avionics |
| 21 | Flight Control Computer | Avionics |
| 22 | Navigation Sensor | Avionics |
| 23 | Radar Module | Avionics |
| 24 | Electrical Harness | Electrical Systems |
| 25 | Starter Generator | Electrical Systems |
| 26 | Nacelle Panel | Nacelle Systems |
| 27 | Pylon Assembly | Nacelle Systems |
| 28 | Cargo Door | Airframe Components |
| 29 | Cabin Pressure Valve | Cabin Systems |
| 30 | Oxygen System Module | Cabin Systems |

---

## Plants & Facilities

### Plant Names (20 Facilities)

| # | Plant Name | Region | Type |
|---|-----------|--------|------|
| 1 | Safran Hyderabad Plant | India | Manufacturing |
| 2 | Safran Bangalore Plant | India | Manufacturing |
| 3 | Safran Toulouse Plant | France | Manufacturing |
| 4 | Safran Paris Plant | France | Manufacturing |
| 5 | Safran Singapore Hub | Singapore | Distribution |
| 6 | Safran Seattle Repair Center | USA | MRO |
| 7 | Safran Mexico Plant | Mexico | Manufacturing |
| 8 | Safran Montreal Plant | Canada | Manufacturing |
| 9 | Safran Hamburg Plant | Germany | Manufacturing |
| 10 | Safran Derby Plant | United Kingdom | Manufacturing |
| 11 | Safran Chennai Plant | India | Manufacturing |
| 12 | Safran Pune Plant | India | Manufacturing |
| 13 | Safran Nagpur Plant | India | Manufacturing |
| 14 | Safran Bangalore MRO | India | MRO |
| 15 | Safran Dallas Repair Hub | USA | MRO |
| 16 | Safran Casablanca Plant | Morocco | Manufacturing |
| 17 | Safran Munich Facility | Germany | Manufacturing |
| 18 | Safran Warsaw Facility | Poland | Manufacturing |
| 19 | Safran Singapore MRO | Singapore | MRO |
| 20 | Safran Hyderabad Engine Center | India | Engine Assembly |

### Site Codes

| Code | Location | Country |
|------|----------|---------|
| HYD | Hyderabad | India |
| BLR | Bangalore | India |
| TLS | Toulouse | France |
| SEA | Seattle | USA |
| SIN | Singapore | Singapore |
| HAM | Hamburg | Germany |
| MTL | Montreal | Canada |
| PAR | Paris | France |
| MEX | Mexico City | Mexico |
| DER | Derby | United Kingdom |

### Operating Countries

| Country | Plants | Primary Function |
|---------|--------|-----------------|
| USA | 2 | MRO & Repair |
| France | 2 | Manufacturing HQ |
| Germany | 2 | Manufacturing |
| United Kingdom | 1 | Engine Manufacturing |
| India | 7 | Manufacturing & MRO |
| Canada | 1 | Manufacturing |
| Singapore | 2 | Distribution & MRO |
| Japan | 0 | Customer market |

---

## Work Centers & Warehouses

### Work Center Types (10 Types)

| Work Center Name | Code | Machine Type | Typical Operations |
|-----------------|------|--------------|-------------------|
| CNC Machining | CNC | CNC | Milling, drilling, boring |
| Blade Grinding | GRD | Grinding | Precision grinding of airfoils |
| Composite Layup | CMP | Robot | Fiber placement, autoclave cure |
| Final Assembly | ASSY | Assembly Line | Component integration |
| Heat Treatment | HT | Heat Treatment Furnace | Aging, annealing, hardening |
| NDT Inspection | NDT | Inspection Cell | X-ray, ultrasonic, dye penetrant |
| Painting Line | PNT | Robot | Surface preparation, coating |
| Laser Welding | LWS | Laser Welding | Precision joining |
| Precision Turning | TURN | CNC | Shaft, disc manufacturing |
| Quality Inspection | QI | Inspection Cell | CMM, visual inspection |

### Warehouse Types

| Type | Code | Contents |
|------|------|----------|
| Raw Material | RM | Metals, composites, chemicals |
| Finished Goods | FG | Completed parts ready for shipment |
| Spare Parts | SP | MRO inventory for aftermarket |
| WIP Storage | WIP | Work-in-process between operations |
| Distribution Center | DC | Regional distribution inventory |

---

## Carriers (25 Logistics Providers)

| # | Carrier Name | Type |
|---|-------------|------|
| 1 | DHL Aviation | Air + Ground |
| 2 | FedEx Express | Air + Ground |
| 3 | UPS Supply Chain | Air + Ground |
| 4 | Maersk Logistics | Sea + Ground |
| 5 | Kuehne Nagel | Multimodal |
| 6 | DB Schenker | Multimodal |
| 7 | CEVA Logistics | Multimodal |
| 8 | DSV | Multimodal |
| 9 | Expeditors | Multimodal |
| 10 | Bollore Logistics | Multimodal |
| 11 | Nippon Express | Multimodal |
| 12 | C.H. Robinson | Ground |
| 13 | Hellmann Logistics | Multimodal |
| 14 | GEODIS | Multimodal |
| 15 | CMA CGM Logistics | Sea |
| 16 | XPO Logistics | Ground |
| 17 | Yusen Logistics | Multimodal |
| 18 | Kerry Logistics | Multimodal |
| 19 | Atlas Air | Air Cargo |
| 20 | Lufthansa Cargo | Air Cargo |
| 21 | Qatar Airways Cargo | Air Cargo |
| 22 | Singapore Airlines Cargo | Air Cargo |
| 23 | Emirates SkyCargo | Air Cargo |
| 24 | Turkish Cargo | Air Cargo |
| 25 | Air France Cargo | Air Cargo |

---

## Quality Domain

### Defect Types

| Defect Type | Severity Range | Typical Root Cause |
|------------|----------------|-------------------|
| Micro Crack | Critical | Fatigue, heat treatment variation |
| Surface Defect | Major | Tool wear, material contamination |
| Material Hardness Issue | Critical | Heat treatment failure |
| Dimension Out Of Tolerance | Major | Machine calibration error |
| Coating Failure | Major | Process deviation |
| Foreign Object Damage | Critical | Handling, contamination |
| Assembly Defect | Major | Operator error |
| Heat Treatment Failure | Critical | Furnace calibration |
| Porosity | Major | Casting process variation |
| Corrosion | Major | Storage conditions, coating gap |

### Root Causes

| Root Cause | Typical Corrective Action |
|-----------|--------------------------|
| Supplier Process Variation | Supplier Corrective Action Request |
| Machine Calibration Error | Reinspection + recalibrate |
| Material Non Conformance | Scrap Material + audit supplier |
| Operator Error | Root Cause Investigation |
| Documentation Error | Update Manufacturing Process |
| Heat Treatment Variation | Production Hold + investigation |
| Tool Wear | Replace tooling + reinspect |
| Process Deviation | Root Cause Investigation |

### Corrective Actions

| Action | When Applied |
|--------|-------------|
| Rework Part | Defect is repairable to spec |
| Scrap Material | Defect cannot be repaired |
| Supplier Corrective Action Request | Root cause is supplier-originated |
| Root Cause Investigation | Complex or recurring issue |
| Reinspection | Suspect batch, verify extent |
| Audit Supplier | Systemic supplier quality issue |
| Production Hold | Critical safety concern |
| Update Manufacturing Process | Process gap identified |

---

## Status Enumerations

### Sales Order Statuses

| Status | Description | Transitions To |
|--------|-------------|----------------|
| Open | Order received, not yet released | Released |
| Released | Released to warehouse for fulfillment | Partially Shipped |
| Partially Shipped | Some lines shipped | Delivered |
| Delivered | All lines delivered to customer | Closed |
| Closed | Order complete, invoiced | — (terminal) |

### Purchase Order Statuses

| Status | Description | Transitions To |
|--------|-------------|----------------|
| Open | PO created, awaiting approval | Approved |
| Approved | PO approved, sent to supplier | Partially Received |
| Partially Received | Some lines received | Received |
| Received | All lines received | Closed |
| Closed | PO complete, matched to invoice | — (terminal) |

### Shipment Statuses

| Status | Description | Transitions To |
|--------|-------------|----------------|
| Planned | Shipment scheduled, not yet picked up | In Transit |
| In Transit | Goods en route | Delivered |
| Delivered | Goods received at destination | Closed |
| Delayed | Shipment overdue vs promised date | Delivered |
| Closed | Shipment complete, no further action | — (terminal) |

### Quality Event Statuses

| Status | Description | Transitions To |
|--------|-------------|----------------|
| Open | Event reported, awaiting investigation | Investigating |
| Investigating | Root cause analysis in progress | Corrected |
| Corrected | Corrective action implemented | Closed |
| Closed | Verified effective, no recurrence | — (terminal) |

### Work Order Types

| Type | Description |
|------|-------------|
| Production | Standard manufacturing of new parts |
| Repair | MRO repair of returned/damaged parts |
| Rework | Correction of quality defects |
| Prototype | First article / engineering prototype |

---

## Enterprise Code Standards

### Identifier Format Specification

| Entity | ID Field | Code Field | Format Pattern | Example |
|--------|----------|------------|----------------|---------|
| DIM_SUPPLIER | S00001 | SUP-US-RMS-001 | `SUP-{COUNTRY}-{TYPE}-{SEQ}` | SUP-US-RMS-001 |
| DIM_RAW_MATERIAL | RM000001 | RM-TI-001 | `RM-{MATERIAL}-{SEQ}` | RM-TI-001 |
| DIM_PART | P000001 | ENG-TBL-00001 | `{FAMILY}-{PART}-{SEQ}` | ENG-TBL-00001 |
| DIM_BOM | BOM000001 | BOM-A320-001 | `BOM-{PROGRAM}-{SEQ}` | BOM-LEAP1A-001 |
| DIM_PLANT | PLNT001 | HYD01 | `{SITE}{SEQ}` | HYD01 |
| DIM_WORK_CENTER | WC0001 | HYD-CNC-001 | `{SITE}-{TYPE}-{SEQ}` | HYD-CNC-001 |
| DIM_WAREHOUSE | WH001 | HYD-RM-WH01 | `{SITE}-{TYPE}-WH{SEQ}` | HYD-RM-WH01 |
| DIM_CUSTOMER | CUST00001 | CUST-AIRBUS-001 | `CUST-{CUSTOMER}-{SEQ}` | CUST-AIRBUS-001 |
| DIM_CARRIER | CAR001 | CRR-DHL-001 | `CRR-{CARRIER}-{SEQ}` | CRR-DHL-001 |
| FACT_INVENTORY | INV000001 | INV-HYD-RM-000001 | `INV-{SITE}-{TYPE}-{SEQ}` | INV-HYD-RM-000001 |
| FACT_WORK_ORDER | WO000001 | WO-HYD-ENG-000001 | `WO-{SITE}-{PROGRAM}-{SEQ}` | WO-HYD-ENG-000001 |
| FACT_SALES_ORDER | SO000001 | SO-AIRBUS-2026-000001 | `SO-{CUSTOMER}-{YEAR}-{SEQ}` | SO-AIRBUS-2026-000001 |
| FACT_SALES_ORDER_LINE | SOL000001 | SO-AIRBUS-2026-000001-L001 | `{SALES_ORDER}-L{LINE}` | SO-AIRBUS-2026-000001-L001 |
| FACT_PURCHASE_ORDER | PO000001 | PO-HEXCEL-2026-000001 | `PO-{SUPPLIER}-{YEAR}-{SEQ}` | PO-HEXCEL-2026-000001 |
| FACT_PURCHASE_ORDER_LINE | POL000001 | PO-HEXCEL-2026-000001-L001 | `{PURCHASE_ORDER}-L{LINE}` | PO-HEXCEL-2026-000001-L001 |
| FACT_SHIPMENT | SHP000001 | SHP-HYD-OUT-000001 | `SHP-{SITE}-{TYPE}-{SEQ}` | SHP-HYD-OUT-000001 |
| FACT_QUALITY_EVENT | QE000001 | QE-HYD-2026-000001 | `QE-{SITE}-{YEAR}-{SEQ}` | QE-HYD-2026-000001 |
| META_BUSINESS_GLOSSARY | BG000001 | BG-000001 | `BG-{SEQ}` | BG-001 |
| META_METRIC_DEFINITION | MET000001 | MET-000001 | `MET-{SEQ}` | MET-001 |

### Code Component Definitions

| Component | Description | Valid Values |
|-----------|-------------|-------------|
| `{COUNTRY}` | 2-letter country code | US, FR, DE, GB, IN, CA, SG, JP |
| `{TYPE}` | Abbreviated supplier/warehouse type | RMS, CMP, ENG, AVN, T1 (suppliers); RM, FG, SP, WIP, DC (warehouses) |
| `{MATERIAL}` | Material type abbreviation | TI, NI, AL, ST, CF, EP, CM |
| `{FAMILY}` | Part family code | ENG, AIR, LDG, HYD, FLT, AVN |
| `{PART}` | Part abbreviation (3 chars) | TBL, FBL, CBL, TDC, SHF, etc. |
| `{PROGRAM}` | Aircraft program | A320, A350, LEAP1A, CFM56, B787 |
| `{SITE}` | 3-letter site code | HYD, BLR, TLS, SEA, SIN, HAM, MTL, PAR, MEX, DER |
| `{CUSTOMER}` | Customer short name | AIRBUS, BOEING, LOCKHEED, etc. |
| `{SUPPLIER}` | Supplier short name | HEXCEL, SPIRIT, SAFRAN, etc. |
| `{YEAR}` | 4-digit year | 2024, 2025, 2026 |
| `{SEQ}` | Zero-padded sequence | 001, 00001, 000001 (varies by entity) |
| `{LINE}` | Line number (3 digits) | L001, L002, L003 |

### Shipment Type Codes

| Type | Code | Description |
|------|------|-------------|
| Inbound | IN | From supplier to plant |
| Outbound | OUT | From plant to customer |
| Interplant Transfer | TRN | Between internal facilities |

### Part Family Codes

| Family | Code |
|--------|------|
| Engine Components | ENG |
| Airframe Components | AIR |
| Avionics | AVN |
| Landing Systems | LDG |
| Hydraulic Systems | HYD |
| Flight Controls | FLT |

### Warehouse Type Codes

| Type | Code |
|------|------|
| Raw Material | RM |
| Finished Goods | FG |
| Spare Parts | SP |
| WIP Storage | WIP |
| Distribution Center | DC |

### Work Center Codes

| Work Center | Code |
|-------------|------|
| CNC Machining | CNC |
| Blade Grinding | GRD |
| Composite Layup | CMP |
| Final Assembly | ASSY |
| Heat Treatment | HT |
| NDT Inspection | NDT |
| Painting Line | PNT |
| Laser Welding | LWS |

---

## Business Terms & Metrics Reference

### Business Terms (Governed)

| ID | Term | Definition |
|----|------|-----------|
| BG-001 | On-Time Delivery (OTD) | % shipments delivered on or before promised date |
| BG-002 | Fill Rate | % customer demand fulfilled from available inventory |
| BG-003 | Days of Inventory (DOI) | Days on-hand inventory sustains average daily demand |
| BG-004 | Inventory Turnover | Times inventory consumed and replenished per year |
| BG-005 | Supplier Performance Index | Composite score: Quality 30% + Delivery 30% + Cost 20% + Responsiveness 20% |
| BG-006 | Critical Supplier | Strategic + Tier 1 + Annual spend > $10M |
| BG-007 | Revenue At Risk | Order value impacted by delays, quality issues, or shortages |
| BG-008 | Landed Cost | Purchase price + freight + duties (3%) + handling (2%) |
| BG-009 | Yield Rate | % production meeting quality on first pass |
| BG-010 | Defect Rate | % inspected parts found defective |
| BG-011 | Perfect Order Rate | Complete + on-time + damage-free + correct docs |
| BG-012 | Capacity Utilization | % available production capacity used |
| BG-013 | Cash-to-Cash Cycle | DIO + DSO − DPO (days) |
| BG-014 | AOG (Aircraft On Ground) | Aircraft grounded, parts must ship within 4 hours |
| BG-015 | Procurement Spend | Total PO value in period (USD) |
| BG-016 | Reorder Point | Level triggering replenishment |
| BG-017 | Supplier Risk Score | Composite risk 0–100 (higher = riskier) |
| BG-018 | Cost of Poor Quality (COPQ) | Financial impact of quality failures |
| BG-019 | Overstocked | Available qty > max stock level |
| BG-020 | Delayed Shipment | In Transit past promised delivery date |

### Metric Names (KPIs)

| # | Metric Name | Unit |
|---|-------------|------|
| 1 | On-Time Delivery | % |
| 2 | Fill Rate | % |
| 3 | Inventory Days | Days |
| 4 | Inventory Turnover | Turns |
| 5 | Supplier Risk Score | Score |
| 6 | Production Yield | % |
| 7 | Scrap Rate | % |
| 8 | Revenue At Risk | USD |
| 9 | Work Order Completion Rate | % |
| 10 | Freight Cost Per Unit | USD |
| 11 | Carrier OTD | % |
| 12 | Supplier OTD | % |
| 13 | Inventory Accuracy | % |
| 14 | Warehouse Utilization | % |
| 15 | Plant Utilization | % |
| 16 | Quality Defect Rate | % |
| 17 | Landed Cost | USD |
| 18 | Customer Service Level | % |
| 19 | Cycle Time | Days |
| 20 | AOG Risk | Score |
