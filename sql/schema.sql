-- ================================================
-- GOVFLOW Data Warehouse Schema
-- Star schema for government payroll data
-- ================================================

-- Dimension: Employee
CREATE TABLE dim_employee (
    emp_id          VARCHAR(6) PRIMARY KEY,
    first_name      VARCHAR(50) NOT NULL,
    last_name       VARCHAR(50) NOT NULL,
    start_date      DATE NOT NULL
);

-- Dimension: Department
CREATE TABLE dim_department (
    dept_id         BIGSERIAL PRIMARY KEY,
    dept_name       VARCHAR(50) UNIQUE NOT NULL
);

-- Dimension: Grade
CREATE TABLE dim_grade (
    grade_id        BIGSERIAL PRIMARY KEY,
    grade_code      VARCHAR(4) UNIQUE NOT NULL,
    grade_level     INTEGER NOT NULL
);

-- Dimension: Pay Period
CREATE TABLE dim_pay_period (
    period_id       BIGSERIAL PRIMARY KEY,
    period_code     VARCHAR(6) UNIQUE NOT NULL,
    year            INTEGER NOT NULL,
    month           INTEGER NOT NULL
);

-- Fact: Payroll
CREATE TABLE fact_payroll (
    payroll_id          BIGSERIAL PRIMARY KEY,
    emp_id              VARCHAR(6) REFERENCES dim_employee(emp_id),
    dept_id             BIGINT REFERENCES dim_department(dept_id),
    grade_id            BIGINT REFERENCES dim_grade(grade_id),
    period_id           BIGINT REFERENCES dim_pay_period(period_id),
    gross_salary        NUMERIC(10,2) NOT NULL,
    tax_deduction       NUMERIC(10,2) NOT NULL,
    pension_deduction   NUMERIC(10,2) NOT NULL,
    net_salary          NUMERIC(10,2) NOT NULL,
    tax_code            VARCHAR(4),
    payment_status      VARCHAR(1),
    created_at          TIMESTAMP DEFAULT NOW(),
    CONSTRAINT unique_payroll UNIQUE (emp_id, period_id)
);