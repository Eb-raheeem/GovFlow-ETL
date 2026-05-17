import boto3
import csv
import os
from pathlib import Path
from dotenv import load_dotenv
from transform import run_etl

load_dotenv()

S3_BUCKET = os.getenv("S3_BUCKET_NAME")
AWS_REGION = os.getenv("AWS_REGION")

s3 = boto3.client("s3", region_name=AWS_REGION)


def upload_raw(filepath: str):
    print("Uploading raw flat file to S3...")
    s3.upload_file(filepath, S3_BUCKET, "raw/payroll.dat")
    print(f"Uploaded: s3://{S3_BUCKET}/raw/payroll.dat")


def upload_processed(records: list[dict]):
    print("Uploading processed CSV to S3...")
    csv_path = Path("/tmp/payroll.csv")
    with open(csv_path, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=records[0].keys())
        writer.writeheader()
        writer.writerows(records)
    s3.upload_file(str(csv_path), S3_BUCKET, "processed/payroll.csv")
    print(f"Uploaded: s3://{S3_BUCKET}/processed/payroll.csv")


if __name__ == "__main__":
    project_root = Path(__file__).parent.parent.parent
    payroll_file = str(project_root / "data" / "payroll.dat")

    records = run_etl(payroll_file)
    upload_raw(payroll_file)
    upload_processed(records)
    print("S3 upload complete.")
