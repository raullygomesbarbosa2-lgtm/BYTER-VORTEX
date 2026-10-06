-- Execute no SQL Editor do projeto Supabase do Byte Vortex AI.
-- O dono é cadastrado por UUID; e-mail e senha nunca ficam no site público.

create table if not exists public.site_admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);
alter table public.site_admins enable row level security;
revoke all on public.site_admins from anon, authenticated;

grant usage on schema public to anon, authenticated;

create or replace function public.is_site_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.site_admins a
    where a.user_id = (select auth.uid())
  );
$$;
revoke all on function public.is_site_admin() from public;
grant execute on function public.is_site_admin() to authenticated;

create table if not exists public.catalog_items (
  id uuid primary key default gen_random_uuid(),
  title text not null check (char_length(title) <= 100),
  platform text not null check (char_length(platform) <= 60),
  description text not null default '' check (char_length(description) <= 500),
  object_path text not null unique,
  original_filename text not null,
  content_type text not null default 'application/octet-stream',
  created_at timestamptz not null default now()
);
alter table public.catalog_items enable row level security;
grant select on public.catalog_items to anon, authenticated;
grant insert, update, delete on public.catalog_items to authenticated;

drop policy if exists "Public can read catalog" on public.catalog_items;
create policy "Public can read catalog"
  on public.catalog_items for select to anon, authenticated using (true);

drop policy if exists "Owner can add catalog items" on public.catalog_items;
create policy "Owner can add catalog items"
  on public.catalog_items for insert to authenticated
  with check ((select public.is_site_admin()));

drop policy if exists "Owner can update catalog items" on public.catalog_items;
create policy "Owner can update catalog items"
  on public.catalog_items for update to authenticated
  using ((select public.is_site_admin()))
  with check ((select public.is_site_admin()));

drop policy if exists "Owner can delete catalog items" on public.catalog_items;
create policy "Owner can delete catalog items"
  on public.catalog_items for delete to authenticated
  using ((select public.is_site_admin()));

-- Downloads são públicos; escrita e remoção continuam protegidas por RLS.
insert into storage.buckets (id, name, public)
values ('byte-vortex-public', 'byte-vortex-public', true)
on conflict (id) do update set public = true;

drop policy if exists "Public can download Byte Vortex files" on storage.objects;
create policy "Public can download Byte Vortex files"
  on storage.objects for select to anon, authenticated
  using (bucket_id = 'byte-vortex-public');

drop policy if exists "Owner can upload Byte Vortex files" on storage.objects;
create policy "Owner can upload Byte Vortex files"
  on storage.objects for insert to authenticated
  with check (bucket_id = 'byte-vortex-public' and (select public.is_site_admin()));

drop policy if exists "Owner can update Byte Vortex files" on storage.objects;
create policy "Owner can update Byte Vortex files"
  on storage.objects for update to authenticated
  using (bucket_id = 'byte-vortex-public' and (select public.is_site_admin()))
  with check (bucket_id = 'byte-vortex-public' and (select public.is_site_admin()));

drop policy if exists "Owner can delete Byte Vortex files" on storage.objects;
create policy "Owner can delete Byte Vortex files"
  on storage.objects for delete to authenticated
  using (bucket_id = 'byte-vortex-public' and (select public.is_site_admin()));
