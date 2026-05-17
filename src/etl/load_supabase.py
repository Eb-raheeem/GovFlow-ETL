import os
import io
import csv
import boto3
import psycopg2
from psycopg2.extras import execute_values
from dotenv import load_dotenv

load_dotenv()

conn = psycopg2.connect(os.getenv("DATABASE_URL"))
cur = conn.cursor()
s3 = boto3.client("s3", region_name=os.getenv("AWS_REGION"))


def read_csv_from_s3() -> list[dict]:
    response = s3.get_object(Bucket=os.getenv(
        "S3_BUCKET_NAME"), Key="processed/payroll.csv")
    content = response["Body"].read().decode("utf-8")
    reader = csv.DictReader(io.StringIO(content))
    return list(reader)


def load_dimensions(records: list[dict]):
    # dim_employee
    employees = {r["emp_id"]: r for r in records}.values()
    execute_values(cur, """
        INSERT INTO dim_employee (emp_id, first_name, last_name, start_date)
        VALUES %s
        ON CONFLICT (emp_id) DO NOTHING
    """, [(e["emp_id"], e["first_name"], e["last_name"], e["start_date"]) for e in employees])

    # dim_department
    execute_values(cur, """
        INSERT INTO dim_department (dept_name)
        VALUES %s
        ON CONFLICT (dept_name) DO NOTHING
    """, [(d,) for d in {r["department"] for r in records}])

    # dim_grade
    execute_values(cur, """
        INSERT INTO dim_grade (grade_code, grade_level)
        VALUES %s
        ON CONFLICT (grade_code) DO NOTHING
    """, [(g, int(g[-1:])) for g in {r["grade"] for r in records}])

    # dim_pay_period
    execute_values(cur, """
        INSERT INTO dim_pay_period (period_code, year, month)
        VALUES %s
        ON CONFLICT (period_code) DO NOTHING
    """, [(p, int(p[:4]), int(p[4:])) for p in {r["pay_period"] for r in records}])

    conn.commit()
    print("Dimensions loaded")


def load_facts(records: list[dict]):
    cur.execute("SELECT dept_name, dept_id FROM dim_department")
    dept_map = {row[0]: row[1] for row in cur.fetchall()}

    cur.execute("SELECT grade_code, grade_id FROM dim_grade")
    grade_map = {row[0]: row[1] for row in cur.fetchall()}

    cur.execute("SELECT period_code, period_id FROM dim_pay_period")
    period_map = {row[0]: row[1] for row in cur.fetchall()}

    values = [(
        r["emp_id"],
        dept_map[r["department"]],
        grade_map[r["grade"]],
        period_map[r["pay_period"]],
        r["gross_salary"],
        r["tax_deduction"],
        r["pension_deduction"],
        r["net_salary"],
        r["tax_code"],
        r["payment_status"]
    ) for r in records]

    execute_values(cur, """
    INSERT INTO fact_payroll
        (emp_id, dept_id, grade_id, period_id, gross_salary,
         tax_deduction, pension_deduction, net_salary, tax_code, payment_status)
    VALUES %s
    ON CONFLICT (emp_id, period_id) DO NOTHING
    """, values)

    conn.commit()
    print(f"Facts loaded: {len(records)} records")


if __name__ == "__main__":
    records = read_csv_from_s3()
    print(f"Read {len(records)} records from S3")
    load_dimensions(records)
    load_facts(records)
    cur.close()
    conn.close()
