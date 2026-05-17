# GovFlow — Government Payroll ETL Pipeline

GovFlow is a data engineering project that simulates the integration between 
a legacy mainframe payroll system and a modern cloud data warehouse. Payroll 
records are generated using COBOL (mimicking a mainframe source system), 
orchestrated via JCL job definitions, extracted as fixed-width flat files, 
uploaded to AWS S3, transformed using Python ETL, and loaded into a Supabase 
PostgreSQL data warehouse for reporting and analytics.

This project demonstrates proficiency in legacy systems, ETL concepts, cloud 
storage, and advanced SQL.

---

## Architecture

![Architecture Diagram](images/architecture.png)

```
COBOL Program          →   Generates fixed-width payroll flat file
JCL Script             →   Mainframe job definition (production reference)
Linux Shell Script     →   Pipeline orchestration (local environment)
AWS S3                 →   Raw and processed file storage (data lake)
Python ETL             →   Flat file parsing and transformation
Supabase (PostgreSQL)  →   Star schema data warehouse
SQL Layer              →   Analytics, views, window functions, stored procs
```

---

## Skills Demonstrated

- **COBOL** — fixed-width flat file generation, mainframe data structures
- **JCL** — mainframe job control, dataset definitions, RECFM/LRECL
- **Linux Scripting** — pipeline orchestration, logging, MD5 checksums
- **ETL** — flat file parsing, data type transformation, bulk loading
- **AWS S3** — raw/processed zone data lake architecture
- **SQL** — star schema design, window functions, stored procedures, views

---

## Data Warehouse Schema

![Star Schema](images/schema.png)

Star schema with 4 dimension tables and 1 fact table:

```
dim_employee
dim_department
dim_grade
dim_pay_period
     ↓
fact_payroll
```

---

## SQL Highlights

```sql
-- Top earner per department
SELECT department, full_name, gross_salary
FROM (
    SELECT department, full_name, gross_salary,
           RANK() OVER (PARTITION BY department ORDER BY gross_salary DESC) AS rnk
    FROM vw_payroll_full
) ranked
WHERE rnk = 1;

-- Running payroll total by department
SELECT department, full_name, net_salary,
       SUM(net_salary) OVER (PARTITION BY department ORDER BY emp_id) AS running_total
FROM vw_payroll_full;
```

---

## How to Run

### Prerequisites
- GnuCOBOL (`brew install gnucobol`)
- Python 3.12+ with `uv`
- AWS CLI configured
- Supabase project with schema loaded

### Steps

```bash
# 1. Generate payroll flat file
./cobol/generate_payroll

# 2. Run pipeline orchestrator
./shell/run_pipeline.sh

# 3. Upload to S3 and transform
uv run src/etl/upload_s3.py

# 4. Load into Supabase
uv run src/etl/load_supabase.py
```

### Run payroll report
```sql
SELECT * FROM get_payroll_report('FINANCE');
```

---

## Project Structure

```
govflow/
├── cobol/          ← COBOL payroll generator
├── jcl/            ← Mainframe job definitions
├── shell/          ← Pipeline orchestration scripts
├── src/etl/        ← Python ETL and S3 upload
├── sql/            ← Schema, views, queries, stored procedures
├── images/         ← Architecture and schema diagrams
└── data/           ← Generated flat files (gitignored)
```