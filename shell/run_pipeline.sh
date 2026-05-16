#!/bin/bash
# GOVFLOW Pipeline Orchestrator
# Runs COBOL generator, validates output, logs results

set -e  # exit immediately if any command fails

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
RECORD_COUNT=$(wc -l < "$PROJECT_ROOT/data/payroll.dat")
log "Step 2: Validated - $RECORD_COUNT records generated"

# Step 3 - Checksum for data integrity
CHECKSUM=$(md5 -q "$PROJECT_ROOT/data/payroll.dat")
log "Step 3: MD5 checksum - $CHECKSUM"

log "Pipeline completed successfully"