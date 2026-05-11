-- Demo seed for the layered utility schema.
-- Safe to run multiple times for local/dev environments.

create extension if not exists pgcrypto;

do $$
declare
  demo_user_id constant uuid := '11111111-1111-1111-1111-111111111111';
  water_meter_id bigint;
  electricity_meter_id bigint;
begin
  if not exists (
    select 1
    from auth.users
    where id = demo_user_id
  ) then
    insert into auth.users (
      id,
      instance_id,
      aud,
      role,
      email,
      encrypted_password,
      email_confirmed_at,
      raw_app_meta_data,
      raw_user_meta_data,
      created_at,
      updated_at
    )
    values (
      demo_user_id,
      '00000000-0000-0000-0000-000000000000',
      'authenticated',
      'authenticated',
      'demo@adoven.app',
      crypt('password123', gen_salt('bf')),
      timezone('utc', now()),
      '{"provider":"email","providers":["email"]}'::jsonb,
      '{"full_name":"Demo User"}'::jsonb,
      timezone('utc', now()),
      timezone('utc', now())
    );
  end if;

  insert into public.profiles (id, full_name)
  values (demo_user_id, 'Demo User')
  on conflict (id) do update
  set full_name = excluded.full_name;

  insert into public.properties (id, owner_user_id, address_label, timezone)
  values (
    1,
    demo_user_id,
    'Flat 7, Windhoek West',
    'Africa/Windhoek'
  )
  on conflict (id) do update
  set
    owner_user_id = excluded.owner_user_id,
    address_label = excluded.address_label,
    timezone = excluded.timezone;

  insert into public.meters (
    id,
    property_id,
    utility_type,
    meter_number,
    is_active
  )
  values
    (1, 1, 'water', 'WTR-2048', true),
    (2, 1, 'electricity', 'ELEC-9912', true)
  on conflict (id) do update
  set
    property_id = excluded.property_id,
    utility_type = excluded.utility_type,
    meter_number = excluded.meter_number,
    is_active = excluded.is_active;

  select id
  into water_meter_id
  from public.meters
  where id = 1;

  select id
  into electricity_meter_id
  from public.meters
  where id = 2;

  insert into public.usage_snapshots (
    meter_id,
    period_start,
    period_end,
    units_used,
    estimated_cost
  )
  values
    (water_meter_id, '2026-03-01', '2026-03-31', 18.400, 642.15),
    (electricity_meter_id, '2026-03-01', '2026-03-31', 412.000, 1280.40)
  on conflict (meter_id, period_start, period_end) do update
  set
    units_used = excluded.units_used,
    estimated_cost = excluded.estimated_cost;

  insert into public.meter_readings (
    meter_id,
    reading_value,
    reading_timestamp,
    source,
    created_by
  )
  values
    (water_meter_id, 184.300, '2026-03-01T07:00:00Z', 'manual', demo_user_id),
    (water_meter_id, 202.700, '2026-03-31T18:00:00Z', 'manual', demo_user_id),
    (
      electricity_meter_id,
      5120.000,
      '2026-03-01T07:00:00Z',
      'manual',
      demo_user_id
    ),
    (
      electricity_meter_id,
      5532.000,
      '2026-03-31T18:00:00Z',
      'receipt_import',
      demo_user_id
    )
  on conflict do nothing;

  insert into public.purchase_receipts (
    meter_id,
    meter_number,
    token,
    receipt_number,
    purchase_timestamp,
    amount,
    units,
    utility_provider,
    cents_per_unit,
    vat_amount,
    vat_number,
    customer_name,
    address,
    raw_payload,
    idempotency_key,
    created_by
  )
  values
    (
      electricity_meter_id,
      'ELEC-9912',
      '1234-5678-9012-3456-7890',
      'RCP-2026-0001',
      '2026-04-03T08:15:00Z',
      1280.40,
      412.000,
      'CENORED',
      3.1087,
      0.00,
      'VAT-001',
      'Demo User',
      'Flat 7, Windhoek West',
      'utility=CENORED
meter=ELEC-9912
receipt=RCP-2026-0001
amount=1280.40
units=412.000
token=1234-5678-9012-3456-7890',
      'seed-electricity-2026-04-03',
      demo_user_id
    ),
    (
      water_meter_id,
      'WTR-2048',
      'WATER-TOKEN-APRIL',
      'RCP-2026-0002',
      '2026-04-01T06:45:00Z',
      642.15,
      18.400,
      'City of Windhoek',
      34.8995,
      0.00,
      'VAT-002',
      'Demo User',
      'Flat 7, Windhoek West',
      'utility=City of Windhoek
meter=WTR-2048
receipt=RCP-2026-0002
amount=642.15
units=18.400
token=WATER-TOKEN-APRIL',
      'seed-water-2026-04-01',
      demo_user_id
    )
  on conflict (idempotency_key) do update
  set
    meter_id = excluded.meter_id,
    meter_number = excluded.meter_number,
    token = excluded.token,
    receipt_number = excluded.receipt_number,
    purchase_timestamp = excluded.purchase_timestamp,
    amount = excluded.amount,
    units = excluded.units,
    utility_provider = excluded.utility_provider,
    cents_per_unit = excluded.cents_per_unit,
    vat_amount = excluded.vat_amount,
    vat_number = excluded.vat_number,
    customer_name = excluded.customer_name,
    address = excluded.address,
    raw_payload = excluded.raw_payload,
    created_by = excluded.created_by;
end;
$$;
