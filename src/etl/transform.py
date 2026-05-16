from datetime import datetime
from decimal import Decimal
from pathlib import Path


def parse_record(line: str) -> dict:
    return {
        "emp_id":            line[0:6].strip(),
        "first_name":        line[6:16].strip(),
        "last_name":         line[16:26].strip(),
        "grade":             line[26:30].strip(),
        "department":        line[30:40].strip(),
        "start_date":        datetime.strptime(line[40:48], "%Y%m%d").date(),
        "gross_salary":      Decimal(line[48:56]),
        "tax_deduction":     Decimal(line[56:63]),
        "pension_deduction": Decimal(line[63:70]),
        "net_salary":        Decimal(line[70:78]),
        "pay_period":        line[78:84].strip(),
        "tax_code":          line[84:88].strip(),
        "payment_status":    line[88:89].strip(),
    }


def run_etl(filepath: str) -> list[dict]:
    lines = Path(filepath).read_text().splitlines()
    records = [parse_record(line) for line in lines if line.strip()]
    print(f"Transformed {len(records)} records")
    return records


if __name__ == "__main__":
    project_root = Path(__file__).parent.parent.parent
    records = run_etl(str(project_root / "data" / "payroll.dat"))
    print(records[0])
