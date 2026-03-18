$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$migrationDir = Join-Path $root 'supabase\migrations'

if (-not (Test-Path $migrationDir)) {
  throw "Migration directory not found: $migrationDir"
}

$sql = (Get-ChildItem $migrationDir -Filter *.sql | Sort-Object Name | Get-Content -Raw) -join "`n"

$requiredPatterns = @(
  'create table if not exists public\.profiles',
  'create table if not exists public\.properties',
  'create table if not exists public\.meters',
  'create table if not exists public\.meter_readings',
  'create table if not exists public\.purchase_receipts',
  'owner_user_id = auth\.uid\(\)',
  'purchase_receipts_idempotency_key_key unique',
  'idx_meter_readings_meter_id_timestamp',
  'idx_purchase_receipts_meter_id_timestamp',
  'idx_properties_owner_user_id'
)

foreach ($pattern in $requiredPatterns) {
  if ($sql -notmatch $pattern) {
    throw "Missing migration requirement: $pattern"
  }
}

Write-Output 'Migration validation passed.'
