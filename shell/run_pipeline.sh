#!/bin/bash
# GOVFLOW Pipeline Orchestrator
# Mimics JCL job orchestration in Linux environment

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOG_FILE="$PROJECT_ROOT/logs/pipeline_$(date +%Y%m%d_%H%M%S).log"

mkdir -p "$PROJECT_ROOT/logs"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"; }

log "Pipeline started"

# Step 1 - Generate payroll flat file via COBOL
log "Step 1: Running COBOL payroll generator"
"$PROJECT_ROOT/cobol/generate_payroll"
log "Step 1: Complete"

# Step 2 - Validate output
RECORD_COUNT=$(wc -c < "$PROJECT_ROOT/data/payroll.dat")
log "Step 2: Validated - $RECORD_COUNT bytes generated"

# Step 3 - Checksum for data integrity
CHECKSUM=$(md5 -q "$PROJECT_ROOT/data/payroll.dat")
log "Step 3: MD5 checksum - $CHECKSUM"

# Step 4 - Upload to S3 and transform
log "Step 4: Uploading to S3 and transforming"
cd "$PROJECT_ROOT" && uv run src/etl/upload_s3.py
log "Step 4: Complete"

# Step 5 - Load into Supabase
log "Step 5: Loading into Supabase"
cd "$PROJECT_ROOT" && uv run src/etl/load_supabase.py
log "Step 5: Complete"

log "Pipeline completed successfully"