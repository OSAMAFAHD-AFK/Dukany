-- =====================================================================
-- Dukany (دُكاني) — Supabase schema
-- Multi-tenant: every row belongs to a shop, and Row Level Security
-- guarantees a shop only reaches its own rows while its subscription
-- is active. Admins manage shops only (they never read shop ledgers).
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1) Admins & shops
-- ---------------------------------------------------------------------
create table if not exists public.admins (
  user_id    uuid primary key references auth.users (id) on delete cascade,
  created_at timestamptz not null default now()
);

create table if not exists public.shops (
  id                   uuid primary key default gen_random_uuid(),
  owner_id             uuid not null unique references auth.users (id) on delete cascade,
  name                 text not null check (char_length(name) between 2 and 80),
  owner_name           text not null check (char_length(owner_name) between 2 and 80),
  phone                text not null unique check (phone ~ '^[0-9]{9,15}$'),
  is_active            boolean not null default true,
  subscription_ends_at timestamptz not null,
  notes                text check (notes is null or char_length(notes) <= 500),
  created_at           timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- 2) Helper functions (security definer so they can read admins/shops
--    regardless of the caller's RLS view, but they only ever look at
--    the caller's own auth.uid()).
-- ---------------------------------------------------------------------
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (select 1 from public.admins where user_id = auth.uid());
$$;

create or replace function public.current_active_shop_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select id
  from public.shops
  where owner_id = auth.uid()
    and is_active
    and subscription_ends_at > now();
$$;

revoke all on function public.is_admin() from public, anon;
revoke all on function public.current_active_shop_id() from public, anon;
grant execute on function public.is_admin() to authenticated;
grant execute on function public.current_active_shop_id() to authenticated;

-- ---------------------------------------------------------------------
-- 3) Shop data (mirrors the app's local SQLite tables).
--    IDs are generated on the device (UUID v4) so offline rows can be
--    upserted later without conflicts.
--    Composite foreign keys (x_id, shop_id) make it impossible to attach
--    an entry to another shop's customer/supplier.
-- ---------------------------------------------------------------------
create table if not exists public.customers (
  id         uuid primary key,
  shop_id    uuid not null references public.shops (id) on delete cascade,
  name       text not null check (char_length(name) between 1 and 120),
  phone      text check (phone is null or phone ~ '^[0-9]{6,15}$'),
  is_deleted boolean not null default false,
  created_at timestamptz not null,
  updated_at timestamptz not null,
  unique (id, shop_id)
);

create table if not exists public.customer_entries (
  id          uuid primary key,
  shop_id     uuid not null,
  customer_id uuid not null,
  kind        text not null check (kind in ('debt', 'payment')),
  items       jsonb not null default '[]'::jsonb check (jsonb_typeof(items) = 'array'),
  amount      numeric(16, 2) not null check (amount > 0),
  note        text check (note is null or char_length(note) <= 500),
  is_deleted  boolean not null default false,
  created_at  timestamptz not null,
  updated_at  timestamptz not null,
  foreign key (customer_id, shop_id) references public.customers (id, shop_id) on delete cascade
);

create table if not exists public.suppliers (
  id         uuid primary key,
  shop_id    uuid not null references public.shops (id) on delete cascade,
  name       text not null check (char_length(name) between 1 and 120),
  phone      text check (phone is null or phone ~ '^[0-9]{6,15}$'),
  is_deleted boolean not null default false,
  created_at timestamptz not null,
  updated_at timestamptz not null,
  unique (id, shop_id)
);

create table if not exists public.supplier_entries (
  id          uuid primary key,
  shop_id     uuid not null,
  supplier_id uuid not null,
  kind        text not null check (kind in ('invoice', 'payment')),
  amount      numeric(16, 2) not null check (amount > 0),
  image_path  text,
  note        text check (note is null or char_length(note) <= 500),
  is_deleted  boolean not null default false,
  created_at  timestamptz not null,
  updated_at  timestamptz not null,
  foreign key (supplier_id, shop_id) references public.suppliers (id, shop_id) on delete cascade
);

create index if not exists customers_shop_idx        on public.customers (shop_id);
create index if not exists customer_entries_shop_idx on public.customer_entries (shop_id, customer_id);
create index if not exists suppliers_shop_idx        on public.suppliers (shop_id);
create index if not exists supplier_entries_shop_idx on public.supplier_entries (shop_id, supplier_id);

-- ---------------------------------------------------------------------
-- 4) Row Level Security
-- ---------------------------------------------------------------------
alter table public.admins           enable row level security;
alter table public.shops            enable row level security;
alter table public.customers        enable row level security;
alter table public.customer_entries enable row level security;
alter table public.suppliers        enable row level security;
alter table public.supplier_entries enable row level security;

-- Nobody signed out may touch anything.
revoke all on public.admins, public.shops, public.customers, public.customer_entries,
              public.suppliers, public.supplier_entries from anon;

-- admins: a user can only see whether they themselves are an admin.
-- Rows are added manually from the SQL editor (see README).
drop policy if exists "admins read self" on public.admins;
create policy "admins read self" on public.admins
  for select to authenticated
  using (user_id = auth.uid());
revoke insert, update, delete on public.admins from authenticated;

-- shops: owner reads own row (even when suspended, to show the status);
-- admins read and update every row. Inserts happen only in the
-- admin-manage-shops Edge Function with the service role.
drop policy if exists "shops owner read" on public.shops;
create policy "shops owner read" on public.shops
  for select to authenticated
  using (owner_id = auth.uid() or public.is_admin());

drop policy if exists "shops admin update" on public.shops;
create policy "shops admin update" on public.shops
  for update to authenticated
  using (public.is_admin())
  with check (public.is_admin());

revoke insert, update, delete on public.shops from authenticated;
grant update (name, owner_name, is_active, subscription_ends_at, notes) on public.shops to authenticated;

-- Shop ledgers: only the owner of an ACTIVE shop, only its own rows.
-- No delete policy: the app uses soft delete (is_deleted) to keep history.
do $$
declare
  t text;
begin
  foreach t in array array['customers', 'customer_entries', 'suppliers', 'supplier_entries'] loop
    execute format('drop policy if exists "%1$s shop select" on public.%1$I', t);
    execute format('drop policy if exists "%1$s shop insert" on public.%1$I', t);
    execute format('drop policy if exists "%1$s shop update" on public.%1$I', t);

    execute format(
      'create policy "%1$s shop select" on public.%1$I for select to authenticated
         using (shop_id = public.current_active_shop_id())', t);
    execute format(
      'create policy "%1$s shop insert" on public.%1$I for insert to authenticated
         with check (shop_id = public.current_active_shop_id())', t);
    execute format(
      'create policy "%1$s shop update" on public.%1$I for update to authenticated
         using (shop_id = public.current_active_shop_id())
         with check (shop_id = public.current_active_shop_id())', t);

    execute format('revoke delete on public.%I from authenticated', t);
  end loop;
end $$;

-- ---------------------------------------------------------------------
-- 5) Storage: private bucket for supplier invoice photos.
--    Path convention: <shop_id>/<entry_id>.jpg
-- ---------------------------------------------------------------------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('invoices', 'invoices', false, 5242880, array['image/jpeg', 'image/png'])
on conflict (id) do nothing;

drop policy if exists "invoices shop read"   on storage.objects;
drop policy if exists "invoices shop insert" on storage.objects;
drop policy if exists "invoices shop update" on storage.objects;

create policy "invoices shop read" on storage.objects
  for select to authenticated
  using (bucket_id = 'invoices'
         and (storage.foldername(name))[1] = public.current_active_shop_id()::text);

create policy "invoices shop insert" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'invoices'
              and (storage.foldername(name))[1] = public.current_active_shop_id()::text);

create policy "invoices shop update" on storage.objects
  for update to authenticated
  using (bucket_id = 'invoices'
         and (storage.foldername(name))[1] = public.current_active_shop_id()::text)
  with check (bucket_id = 'invoices'
              and (storage.foldername(name))[1] = public.current_active_shop_id()::text);

-- ---------------------------------------------------------------------
-- 6) Table privileges.
--    "Automatically expose new tables" is OFF on this project, so nothing
--    is granted by default. RLS above still decides which ROWS are visible;
--    these grants only decide which roles may touch each table at all.
-- ---------------------------------------------------------------------
grant usage on schema public to anon, authenticated, service_role;

-- Edge Function (service role)
grant all on all tables in schema public to service_role;
grant all on all sequences in schema public to service_role;
grant execute on all functions in schema public to service_role;

-- Signed-in users (shop owners and admins)
grant select on public.admins to authenticated;
grant select on public.shops to authenticated;
grant update (name, owner_name, is_active, subscription_ends_at, notes) on public.shops to authenticated;
grant select, insert, update on
  public.customers, public.customer_entries, public.suppliers, public.supplier_entries
  to authenticated;
