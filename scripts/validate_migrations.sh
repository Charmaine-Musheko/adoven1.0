#!/bin/zsh
set -euo pipefail

MIGRATION_FILE="$(ls supabase/migrations/*_initial_layered_schema.sql | tail -n 1)"

if [[ -z "${MIGRATION_FILE}" ]]; then
  echo "Missing initial layered schema migration."
  exit 1
fi

required_patterns=(
  "create table if not exists public.profiles"
  "create table if not exists public.properties"
  "create table if not exists public.meters"
  "create table if not exists public.meter_readings"
  "create table if not exists public.purchase_receipts"
  "create table if not exists public.usage_snapshots"
  "alter table public.purchase_receipts enable row level security"
  "create policy \"Users can insert receipts for owned meters\""
  "create table if not exists public.audit_events"
)

for pattern in "${required_patterns[@]}"; do
  if ! rg -Fq "${pattern}" "${MIGRATION_FILE}"; then
    echo "Migration validation failed. Missing pattern: ${pattern}"
    exit 1
  fi
done

echo "Migration validation passed: ${MIGRATION_FILE}"
