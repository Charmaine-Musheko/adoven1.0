create extension if not exists pgcrypto;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

create or replace function public.audit_purchase_receipt_changes()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  event_name text;
begin
  event_name := case
    when tg_op = 'INSERT' then 'purchase_receipt_created'
    when new.correction_of_receipt_id is distinct from old.correction_of_receipt_id then 'purchase_receipt_corrected'
    else 'purchase_receipt_updated'
  end;

  insert into public.audit_events (
    id,
    owner_user_id,
    entity_type,
    entity_id,
    event_type,
    details,
    created_at
  )
  values (
    gen_random_uuid(),
    new.owner_user_id,
    'purchase_receipt',
    new.id,
    event_name,
    jsonb_build_object(
      'receipt_number', new.receipt_number,
      'meter_number', new.meter_number,
      'amount_minor_units', new.amount_minor_units
    ),
    timezone('utc', now())
  );

  return new;
end;
$$;

create table if not exists public.profiles (
  id uuid primary key,
  email text not null unique,
  display_name text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.properties (
  id uuid primary key default gen_random_uuid(),
  owner_user_id uuid not null,
  name text not null,
  address text not null default '',
  created_by uuid,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.meters (
  id uuid primary key default gen_random_uuid(),
  owner_user_id uuid not null,
  property_id uuid not null references public.properties(id) on delete cascade,
  utility_type text not null check (utility_type in ('water', 'electricity')),
  meter_number text not null,
  label text not null,
  created_by uuid,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.meter_readings (
  id uuid primary key default gen_random_uuid(),
  owner_user_id uuid not null,
  meter_id uuid not null references public.meters(id) on delete cascade,
  reading_value numeric(18, 3) not null,
  reading_timestamp timestamptz not null,
  notes text not null default '',
  created_by uuid,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.purchase_receipts (
  id uuid primary key default gen_random_uuid(),
  owner_user_id uuid not null,
  meter_id uuid not null references public.meters(id) on delete cascade,
  correction_of_receipt_id uuid references public.purchase_receipts(id),
  meter_number text not null,
  provider_name text not null,
  token text not null,
  purchase_timestamp timestamptz not null,
  amount_minor_units bigint not null,
  units_purchased numeric(18, 2) not null,
  cents_per_unit numeric(18, 2),
  vat_minor_units bigint not null default 0,
  vat_number text not null default '',
  receipt_number text not null,
  customer_name text not null default '',
  address text not null default '',
  raw_payload text not null,
  idempotency_key text not null,
  created_by uuid,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint purchase_receipts_idempotency_key_key unique (idempotency_key)
);

create table if not exists public.usage_snapshots (
  id uuid primary key default gen_random_uuid(),
  owner_user_id uuid not null,
  meter_id uuid not null references public.meters(id) on delete cascade,
  snapshot_month date not null,
  total_units numeric(18, 2) not null default 0,
  total_spend_minor_units bigint not null default 0,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint usage_snapshots_month_meter_key unique (meter_id, snapshot_month)
);

create table if not exists public.audit_events (
  id uuid primary key default gen_random_uuid(),
  owner_user_id uuid not null,
  entity_type text not null,
  entity_id uuid not null,
  event_type text not null,
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now())
);

create index if not exists idx_properties_owner_user_id
  on public.properties (owner_user_id);

create index if not exists idx_meter_readings_meter_id_timestamp
  on public.meter_readings (meter_id, reading_timestamp desc);

create index if not exists idx_purchase_receipts_meter_id_timestamp
  on public.purchase_receipts (meter_id, purchase_timestamp desc);

create index if not exists idx_meters_owner_user_id
  on public.meters (owner_user_id);

create index if not exists idx_purchase_receipts_owner_user_id
  on public.purchase_receipts (owner_user_id);

create index if not exists idx_audit_events_owner_user_id
  on public.audit_events (owner_user_id, created_at desc);

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
before update on public.profiles
for each row execute procedure public.set_updated_at();

drop trigger if exists properties_set_updated_at on public.properties;
create trigger properties_set_updated_at
before update on public.properties
for each row execute procedure public.set_updated_at();

drop trigger if exists meters_set_updated_at on public.meters;
create trigger meters_set_updated_at
before update on public.meters
for each row execute procedure public.set_updated_at();

drop trigger if exists meter_readings_set_updated_at on public.meter_readings;
create trigger meter_readings_set_updated_at
before update on public.meter_readings
for each row execute procedure public.set_updated_at();

drop trigger if exists purchase_receipts_set_updated_at on public.purchase_receipts;
create trigger purchase_receipts_set_updated_at
before update on public.purchase_receipts
for each row execute procedure public.set_updated_at();

drop trigger if exists usage_snapshots_set_updated_at on public.usage_snapshots;
create trigger usage_snapshots_set_updated_at
before update on public.usage_snapshots
for each row execute procedure public.set_updated_at();

drop trigger if exists purchase_receipts_audit_trigger on public.purchase_receipts;
create trigger purchase_receipts_audit_trigger
after insert or update on public.purchase_receipts
for each row execute procedure public.audit_purchase_receipt_changes();

alter table public.profiles enable row level security;
alter table public.properties enable row level security;
alter table public.meters enable row level security;
alter table public.meter_readings enable row level security;
alter table public.purchase_receipts enable row level security;
alter table public.usage_snapshots enable row level security;
alter table public.audit_events enable row level security;

drop policy if exists profiles_select_own on public.profiles;
create policy profiles_select_own on public.profiles
for select using (id = auth.uid());

drop policy if exists profiles_insert_own on public.profiles;
create policy profiles_insert_own on public.profiles
for insert with check (id = auth.uid());

drop policy if exists profiles_update_own on public.profiles;
create policy profiles_update_own on public.profiles
for update using (id = auth.uid()) with check (id = auth.uid());

drop policy if exists properties_own_all on public.properties;
create policy properties_own_all on public.properties
for all using (owner_user_id = auth.uid()) with check (owner_user_id = auth.uid());

drop policy if exists meters_own_all on public.meters;
create policy meters_own_all on public.meters
for all using (owner_user_id = auth.uid()) with check (owner_user_id = auth.uid());

drop policy if exists meter_readings_own_all on public.meter_readings;
create policy meter_readings_own_all on public.meter_readings
for all using (owner_user_id = auth.uid()) with check (owner_user_id = auth.uid());

drop policy if exists purchase_receipts_own_all on public.purchase_receipts;
create policy purchase_receipts_own_all on public.purchase_receipts
for all using (owner_user_id = auth.uid()) with check (owner_user_id = auth.uid());

drop policy if exists usage_snapshots_own_select on public.usage_snapshots;
create policy usage_snapshots_own_select on public.usage_snapshots
for all using (owner_user_id = auth.uid()) with check (owner_user_id = auth.uid());

drop policy if exists audit_events_own_select on public.audit_events;
create policy audit_events_own_select on public.audit_events
for select using (owner_user_id = auth.uid());

drop policy if exists audit_events_own_insert on public.audit_events;
create policy audit_events_own_insert on public.audit_events
for insert with check (owner_user_id = auth.uid());
