-- ================================================
-- GOVFLOW Analytical SQL Layer
-- Government Payroll Data Warehouse Queries
-- ================================================


-- ------------------------------------------------
-- 1. FULL PAYROLL VIEW (joining all 5 tables)
-- ------------------------------------------------
CREATE OR REPLACE VIEW vw_payroll_full AS
SELECT
    e.emp_id,
    e.first_name || ' ' || e.last_name   AS full_name,
    d.dept_name                           AS department,
    g.grade_code,
    g.grade_level,
    p.period_code,
    p.year,
    p.month,
    f.gross_salary,
    f.tax_deduction,
    f.pension_deduction,
    f.net_salary,
    f.tax_code,
    f.payment_status
FROM fact_payroll f
JOIN dim_employee   e ON f.emp_id    = e.emp_id
JOIN dim_department d ON f.dept_id   = d.dept_id
JOIN dim_grade      g ON f.grade_id  = g.grade_id
JOIN dim_pay_period p ON f.period_id = p.period_id;

-- ------------------------------------------------
-- 2. Grade salary ranking using window function
-- ------------------------------------------------
SELECT
    grade_code,
    grade_level,
    COUNT(*)                        AS employee_count,
    ROUND(AVG(gross_salary), 2)     AS avg_gross,
    MIN(gross_salary)               AS min_salary,
    MAX(gross_salary)               AS max_salary,
    RANK() OVER (ORDER BY AVG(gross_salary) DESC) AS salary_rank
FROM vw_payroll_full
GROUP BY grade_code, grade_level
ORDER BY salary_rank;


-- ------------------------------------------------
-- 3. SALARY ANALYSIS BY GRADE WITH RANKING
-- ------------------------------------------------
SELECT
    grade_code,
    grade_level,
    COUNT(*)                        AS employee_count,
    ROUND(AVG(gross_salary), 2)     AS avg_gross,
    MIN(gross_salary)               AS min_salary,
    MAX(gross_salary)               AS max_salary,
    RANK() OVER (ORDER BY AVG(gross_salary) DESC) AS salary_rank
FROM vw_payroll_full
GROUP BY grade_code, grade_level
ORDER BY salary_rank;


-- ------------------------------------------------
-- 4. TOP EARNER PER DEPARTMENT
-- ------------------------------------------------
SELECT
    department,
    full_name,
    gross_salary,
    net_salary
FROM (
    SELECT
        department,
        full_name,
        gross_salary,
        net_salary,
        RANK() OVER (PARTITION BY department ORDER BY gross_salary DESC) AS rnk
    FROM vw_payroll_full
) ranked
WHERE rnk = 1;


-- ------------------------------------------------
-- 5. RUNNING TOTAL OF NET SALARY BY DEPARTMENT
-- ------------------------------------------------
SELECT
    department,
    full_name,
    net_salary,
    SUM(net_salary) OVER (
        PARTITION BY department
        ORDER BY emp_id
    ) AS running_total
FROM vw_payroll_full
ORDER BY department, emp_id;

-- ------------------------------------------------
-- 6. STORED PROCEDURE - PAYROLL REPORT BY DEPARTMENT
-- ------------------------------------------------
CREATE OR REPLACE FUNCTION get_payroll_report(p_department VARCHAR)
RETURNS TABLE (
    full_name       TEXT,
    grade_code      VARCHAR,
    gross_salary    NUMERIC,
    tax_deduction   NUMERIC,
    pension_deduction NUMERIC,
    net_salary      NUMERIC,
    payment_status  VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        v.full_name,
        v.grade_code,
        v.gross_salary,
        v.tax_deduction,
        v.pension_deduction,
        v.net_salary,
        v.payment_status
    FROM vw_payroll_full v
    WHERE v.department = p_department
    ORDER BY v.gross_salary DESC;
END;
$$ LANGUAGE plpgsql;

-- Usage:
SELECT * FROM get_payroll_report('FINANCE');
SELECT * FROM get_payroll_report('HR');