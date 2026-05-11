create policy "Profiles are self insertable"
on public.profiles
for insert
to authenticated
with check (id = auth.uid());
