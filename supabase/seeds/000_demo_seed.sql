insert into public.profiles (id, email, display_name)
values (
  '00000000-0000-0000-0000-000000000001',
  'demo@adoven.app',
  'Demo User'
)
on conflict (id) do nothing;

insert into public.properties (id, owner_user_id, name, address, created_by)
values (
  '10000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000001',
  'Primary Property',
  'Erf 812, Tugela St, Wana',
  '00000000-0000-0000-0000-000000000001'
)
on conflict (id) do nothing;

insert into public.meters (
  id,
  owner_user_id,
  property_id,
  utility_type,
  meter_number,
  label,
  created_by
)
values (
  '20000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000001',
  '10000000-0000-0000-0000-000000000001',
  'electricity',
  '07123102910',
  'Main meter',
  '00000000-0000-0000-0000-000000000001'
)
on conflict (id) do nothing;
