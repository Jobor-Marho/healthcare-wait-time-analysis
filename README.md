# 🏥 Healthcare Wait Time Analysis (SQL)

## 📌 Project Overview
This project analyzes patient wait times across healthcare locations and departments using **PostgreSQL**.  
The analysis focuses on identifying operational bottlenecks, high-wait locations, department-level delays, and monthly trends in excessive wait times.

The goal is to demonstrate practical **SQL-based data analysis** for real-world healthcare operations.

---

## 📂 Dataset Description
The analysis is based on four CSV datasets located in the `data/` directory:

| File | Description |
|------|-------------|
| `locations.csv` | Healthcare facility locations |
| `departments.csv` | Hospital departments |
| `patients.csv` | Patient visit records containing check-in and check-out timestamps |
| `Wait.pdf` | Supporting documentation / reference material |

---

## 🛠 Tools & Technologies
- **PostgreSQL**
- **SQL (CTEs, joins, aggregates, windowed time calculations)**
- **Git & GitHub**
- **CSV data sources**

---

## 🧱 Database Schema
The project uses three core tables:

### **locations**
- `location_id` (PK)
- `location_name`

### **departments**
- `department_id` (PK)
- `department_name`

### **patients**
- `id` (PK)
- `check_in_time`
- `check_out_time`
- `department_id` (FK)
- `location_id` (FK)

### Data Integrity Features:
- Foreign key constraints
- `NOT NULL` constraints
- Check constraints to ensure valid timestamps

---

## 📊 Analysis Performed

### ⏱ Patient Wait Time Calculation
- Computed individual patient wait times (in minutes) using timestamp differences
- Converted epoch values to minutes for readability

### 📍 Average Wait Time per Location
- Calculated average wait time for each healthcare location
- Ranked locations by wait duration
- Identified **problem locations** where average wait time exceeds **120 minutes**

### 🏥 Department-Level Bottleneck Analysis
- Analyzed average wait times per department
- Flagged departments with excessive delays (> 120 minutes)
- Highlighted operational bottlenecks at department level

### 🚨 High-Wait Location Percentage
- Calculated the percentage of locations exceeding the 120-minute wait threshold
- Used filtered aggregations to measure system-wide performance

### 📅 Monthly Trends of High-Wait Locations
- Tracked monthly trends using `DATE_TRUNC`
- Measured how many locations exceeded acceptable wait times per month
- Displayed results in a readable `Mon YYYY` format
- Calculated the monthly percentage of high-wait locations

---

## 📁 Project Structure

```
data/
└── CustomerExodus.csv
sql/
└── analysis.sql
└── README.md
```


---

## ▶️ How to Run the Analysis
1. Create the database tables using the SQL scripts
2. Load the CSV files into PostgreSQL
3. Execute queries in `sql/analysis.sql`
4. Review outputs for operational insights

---

## 📈 Key Insights
- Certain locations consistently exceed acceptable wait times
- Specific departments contribute disproportionately to delays
- Monthly trend analysis reveals periods of peak congestion
- High-wait locations form a significant percentage of the system




## 👤 Author
**Edric Oghenejobor**  
Software Engineer | Data Analyst