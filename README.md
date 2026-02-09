
# 📊 Amazon India – Seller & Operations Analytics  
**End-to-End SQL & Power BI Project**

---

## 🔍 Project Overview

This project simulates an **Amazon India–style seller analytics system**, built to demonstrate **real-world SQL analytics, data modeling, and Power BI dashboard development**.

The objective was to design a **business-ready analytics solution** that enables stakeholders to:

- Track overall revenue and profitability  
- Evaluate seller performance and contribution  
- Identify return- and refund-related risks  
- Monitor inventory health  
- Relate seller ratings to business outcomes  

The project follows **industry best practices** in analytics engineering and BI modeling.

---

## 🛠️ Tech Stack

- **Database:** MySQL 8.0  
- **Query Language:** SQL (Joins, Aggregations, Views, Data Validation)  
- **Visualization:** Power BI Desktop  
- **Data Modeling:** Star Schema  
- **Version Control:** Git & GitHub  

---

## 🗂️ Dataset Design

### Raw Transaction Tables
The dataset is synthetically generated and scaled to mimic real e-commerce data.

- `orders`
- `order_items`
- `products`
- `sellers`
- `inventory`
- `payments_fees`
- `returns_refunds`
- `seller_ratings`

Each table represents a real operational domain such as sales, fulfillment, inventory, or seller quality.



## 🧩 Entity Relationship Diagram (ERD)

Before building analytics and dashboards, the relational data model was designed
to reflect a real-world e-commerce system.

The ER diagram below represents the **core entities and relationships** used in
the project.

<img width="731" height="408" alt="Image" src="https://github.com/user-attachments/assets/c61d1a7c-902c-4c9b-9488-49998a3805ce" />

### Key Design Highlights

- One-to-many relationship between **Orders → Order Items**
- Sellers linked to products, inventory, and performance metrics
- Returns and payments modeled as dependent transactional entities
- Normalized structure to avoid data duplication
- Designed to support scalable analytics and BI use cases

The ER model served as the foundation for:
- SQL table creation
- Data validation rules
- Analytical view design
- Star schema modeling in Power BI


## 🧠 SQL Analytics Layer (Semantic Views)

Instead of exposing raw tables directly to Power BI, a **semantic analytics layer** was created using SQL views.

### Key Views

- **`vw_sales_fact`**  
  Transaction-level fact table (one row per order item)

- **`vw_dim_seller`**  
  Clean seller dimension used for slicers and labels

- **`vw_seller_revenue`**  
  Seller-level revenue and order metrics

- **`vw_seller_profitability`**  
  Net margin and fee analysis by seller

- **`vw_seller_returns`**  
  Return counts and refund impact

- **`vw_seller_rating_revenue`**  
  Relationship between seller ratings and revenue

- **`vw_inventory_risk`**  
  Inventory health classification (Healthy / Low Stock / Out of Stock)

**Why SQL Views?**
- Centralize business logic  
- Prevent duplicated calculations in Power BI  
- Ensure consistency across reports  
- Improve maintainability and scalability  

---

## ⭐ Data Modeling (Power BI)

A **Star Schema** was implemented to ensure correct filtering and performance.

### Model Structure

- **Fact Table**
  - `vw_sales_fact`

- **Dimension Table**
  - `vw_dim_seller`

- **Satellite / Summary Tables**
  - Seller revenue, profitability, returns, ratings, and inventory views

### Key Modeling Decisions

- All slicers use **dimension tables only**
- No fact-to-fact or dimension-to-dimension relationships
- Single-direction filter propagation
- KPIs calculated using **DAX measures**, not stored columns

This design eliminated:
- Duplicate sellers in visuals  
- Blank slicer values  
- Partial or inconsistent filtering  

---

## 📈 Power BI Dashboards

### 🟦 Page 1: Executive Overview (Revenue & Profit)

**Target Audience:** Business Leadership / Management  

**KPIs**
- Total Revenue  
- Total Orders  
- Average Seller Revenue  
- Average Seller Net Margin  
- Net Margin (All Sellers)  

**Visuals**
- Seller Revenue Ranking  
- Seller Profitability Comparison  
- Category Sales Distribution  

**Business Question Answered:**  
> *How is the business performing overall?*

---

### 🟧 Page 2: Operations & Risk (Returns & Inventory)

**Target Audience:** Operations, Supply Chain, Quality Teams  

**KPIs**
- Total Returns  
- Return Rate (%)  
- Total Refund Amount  
- Low Stock Products  

**Visuals**
- Seller Return Rate Comparison  
- Refund Amount by Seller  
- Inventory Status Donut Chart  
- Low / Out-of-Stock Products Table  

**Business Question Answered:**  
> *Where are operational risks and revenue leakages?*

---

## 📐 KPI & Metric Logic

- **Return Rate (%)**  
Total Returns ÷ Total Sold Items

- **Net Margin**
Revenue – Seller Payout – Platform Fees


- **Inventory Risk Classification**
- Healthy  
- Low Stock  
- Out of Stock  

All metrics are **fully dynamic** and respond to slicers.

---

## 🧪 Data Validation & Quality Checks

SQL validation was performed to ensure data reliability:

- Selling price never exceeds MRP  
- Refund amount never exceeds net price  
- Cancelled orders excluded from revenue  
- Inventory levels never go negative  
- Seller ratings constrained between 1 and 5  

These checks ensure **trustworthy insights**, not just visuals.

---

## 🎯 Key Learnings & Highlights

- Designed a **production-style BI model**, not a tutorial demo  
- Solved real Power BI challenges (blank slicers, duplicate values)  
- Applied **business-first thinking** to analytics  
- Built a scalable, explainable, interview-ready project  

---

## 📷 Dashboard Screenshots

<img width="973" height="597" alt="Image" src="https://github.com/user-attachments/assets/58969a32-265d-4f7b-a592-60145c53cd7d" />
<img width="992" height="598" alt="Image" src="https://github.com/user-attachments/assets/0a26624a-2901-4b9a-835b-09d25b743b55" />

---

## 🧑‍💼 Interview Talking Points

- Why SQL views were used instead of raw tables  
- Why star schema was necessary for correct filtering  
- How return rate was calculated using measures  
- How data modeling issues were identified and resolved  
- How business questions guided dashboard design  

---

## 🚀 Future Enhancements

- Customer analytics (retention & repeat behavior)  
- Time-series trend analysis  
- Power BI Service publishing & scheduled refresh  
- Additional drill-through pages  

---

## 📬 Author

**RAvi Mamgai**  
**Skills Demonstrated:** SQL | Data Modeling | Power BI | Analytics Engineering  

---

> *This project reflects real-world analytics problem-solving rather than a guided tutorial.*
