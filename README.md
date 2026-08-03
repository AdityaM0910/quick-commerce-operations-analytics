# Quick Commerce Operations Analytics Platform

A production-style operations analytics project inspired by Indian quick-commerce companies such as **Blinkit** and **Zepto**.

Unlike traditional portfolio projects built from a single static CSV, this project simulates a real business environment with a normalized PostgreSQL database, automated Python data generation, growing transactional data, SQL analytics, and Power BI dashboards.

> **Project Status**
>
> This repository is being developed incrementally.
>
> ✅ Database Design Completed
> ✅ Python Data Generation Completed
> 🚧 SQL Analytics In Progress
> ⏳ Power BI Dashboards Planned
> ⏳ Business Insights & Documentation Planned

---

# Business Problem

Quick-commerce companies process thousands of customer orders every day across multiple cities, dark stores, delivery partners, and inventory locations.

Operations teams require continuous visibility into:

* Order volume
* Revenue
* Delivery performance
* Inventory health
* Store performance
* Customer behaviour
* Cancellation trends

Without a centralized analytics platform, monitoring operational efficiency and making data-driven decisions becomes difficult.

---

# Business Solution

This project simulates a complete quick-commerce operations environment by building an end-to-end analytics platform consisting of:

* Normalized PostgreSQL database
* Automated Python data generation pipeline
* Continuously growing transactional dataset
* SQL analytics layer
* Power BI dashboards
* Business KPIs and operational insights

The objective is to replicate how a real analytics team monitors daily operations.

---

# Project Architecture

```text
                 Python Data Generator
                          │
                          ▼
                 PostgreSQL Database
                          │
                          ▼
                 SQL Views & KPIs
                          │
                          ▼
                  Power BI Data Model
                          │
                          ▼
               Executive & Operations Dashboards
```

---

# Project Overview

The project simulates the operations of a modern quick-commerce company.

Current implementation includes:

* Normalized PostgreSQL database
* Python data generation pipeline
* Growing transactional dataset
* Business-oriented data model

Upcoming phases include SQL analytics, Power BI dashboards, and executive business reporting.

---

# Tech Stack

| Layer                 | Technology    |
| --------------------- | ------------- |
| Database              | PostgreSQL    |
| Programming           | Python        |
| Database Connectivity | psycopg2      |
| Fake Data Generation  | Faker         |
| Environment Variables | python-dotenv |
| Analytics             | SQL           |
| Visualization         | Power BI      |
| Version Control       | Git & GitHub  |

---

# Features

* Normalized relational database
* Automated seed data generation
* Automated transactional data generation
* Compound business growth simulation
* Realistic order lifecycle
* Delivery partner simulation
* Inventory management
* City-wise operations
* Secure environment variable handling
* Business KPI foundation
* Power BI-ready database

---

# Current Progress

## ✅ Stage 1 — Business Understanding

Designed the operational workflow of a quick-commerce company by identifying business entities, order lifecycle, and operational KPIs.

Completed:

* Business process mapping
* Entity identification
* Operational workflow
* Business rules

---

## ✅ Stage 2 — Database Design

Designed and implemented a normalized PostgreSQL database.

Highlights:

* 12 normalized tables
* ENUM-based order status
* Foreign key relationships
* CHECK constraints
* Composite UNIQUE constraints
* Price snapshotting
* Calendar dimension table

See:

```
database/schema.sql
```

---

## ✅ Stage 3 — Python Data Generation Pipeline

Developed a modular Python pipeline for populating the database.

Implemented:

### Seed Data

* Cities
* Categories
* Products
* Stores
* Delivery Partners
* Customers
* Calendar
* Inventory

### Transactional Data

* Daily Orders
* Order Items
* Payments
* Deliveries

Simulation Features

* Compound daily business growth
* City-based fulfillment
* Inventory updates
* Cancellation simulation
* SLA-based delivery delays
* Customer ratings

Credentials are securely managed using `.env` files.

---

## 🚧 Stage 4 — SQL Analytics (In Progress)

Upcoming implementation:

* Business KPIs
* SQL Views
* CTEs
* Window Functions
* Operational Queries
* Performance Optimization

Folder:

```
sql/
```

---

## ⏳ Stage 5 — Power BI Dashboards

Planned dashboards:

* Executive Dashboard
* Operations Dashboard
* Sales Dashboard
* Inventory Dashboard
* Customer Dashboard
* Delivery Dashboard
* Store Performance Dashboard

Folder:

```
powerbi/
```

---

# Business KPIs (Planned)

* Total Orders
* Completed Orders
* Cancelled Orders
* Revenue
* Average Order Value
* Average Delivery Time
* Delivery Success Rate
* Customer Retention
* Repeat Customers
* Average Customer Rating
* Revenue by Store
* Revenue by City
* Inventory Health
* Stock Availability
* Revenue Growth
* Cancellation Rate
* Refund Rate
* Top Selling Products
* Bottom Selling Products

---

# Repository Structure

```text
quick-commerce-analytics/
│
├── python/
│   ├── db_connection.py
│   ├── seed_cities.py
│   ├── seed_categories.py
│   ├── seed_products.py
│   ├── seed_stores.py
│   ├── seed_delivery_partners.py
│   ├── seed_calendar.py
│   ├── seed_customers.py
│   ├── seed_inventory.py
│   ├── generate_daily_orders.py
│   └── run_30_day_simulation.py
│
├── sql/
│   └── README.md
│
├── powerbi/
│   └── README.md
│
├── database/
│   └── schema.sql
│
├── docs/
│   └── er_diagram.png
│
├── .env.example
├── .gitignore
├── requirements.txt
└── README.md
```

---

# Setup Instructions

## 1. Clone Repository

```bash
git clone <repository-url>
```

## 2. Install Dependencies

```bash
pip install -r requirements.txt
```

## 3. Configure Environment Variables

Copy

```
.env.example
```

to

```
.env
```

and provide your PostgreSQL credentials.

---

## 4. Create Database

Run

```
database/schema.sql
```

inside PostgreSQL.

---

## 5. Seed Reference Data

Execute:

```bash
python python/seed_cities.py
python python/seed_categories.py
python python/seed_products.py
python python/seed_stores.py
python python/seed_delivery_partners.py
python python/seed_calendar.py
python python/seed_customers.py
python python/seed_inventory.py
```

---

## 6. Generate Transactional Data

```bash
python python/generate_daily_orders.py
python python/run_30_day_simulation.py
```

---

# Skills Demonstrated

* PostgreSQL
* Database Design
* Relational Data Modeling
* SQL
* Python
* Data Generation
* ETL Concepts
* Business Analytics
* Operations Analytics
* Git
* GitHub

---

# Roadmap

### Version 1.0 ✅

* Business Understanding
* Database Design
* Python Data Generation

### Version 2.0 🚧

* SQL Analytics
* Business Queries
* SQL Views

### Version 3.0 ⏳

* Power BI Dashboards
* Data Model
* DAX Measures

### Version 4.0 ⏳

* Executive Insights
* Business Recommendations
* Documentation Enhancements

---

# Future Improvements

* Incremental ETL Pipeline
* Docker Support
* Scheduled Data Refresh
* REST API Integration
* Cloud Deployment
* Apache Airflow Integration
* Real-Time Streaming Analytics

---

# Author

**Aditya Mishra**

Data Analyst | SQL | Python | PostgreSQL | Power BI

LinkedIn: *Add after creating profile*


