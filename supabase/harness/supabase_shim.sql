-- Test-only stand-in for the parts of a Supabase instance that live outside
-- `supabase/migrations/`.
--
-- The migrations are written against a Supabase database: they reference the
-- `auth` schema, `auth.uid()`, and the `anon` / `authenticated` roles, none of
-- which a plain PostgreSQL server has. Normally `supabase start` supplies them
-- inside Docker. This file supplies the same surface on a bare server, so that
-- the RLS suite can run in CI and on a machine with no Docker at all.
--
-- It is deliberately the smallest thing the policies touch. It is never
-- applied to a real project: `supabase db reset` only reads `migrations/` and
-- `seed.sql`, and this file is in neither.
--
-- `auth.uid()` is reproduced exactly as the platform defines it, because the
-- whole point of the suite is to test the policies that call it. Weakening it
-- here would make every test below meaningless.

create schema if not exists auth;
create schema if not exists extensions;

do $$
begin
  if not exists (select from pg_roles where rolname = 'anon') then
    create role anon nologin noinherit;
  end if;
  if not exists (select from pg_roles where rolname = 'authenticated') then
    create role authenticated nologin noinherit;
  end if;
  if not exists (select from pg_roles where rolname = 'service_role') then
    create role service_role nologin noinherit bypassrls;
  end if;
end
$$;

grant usage on schema public     to anon, authenticated, service_role;
grant usage on schema extensions to anon, authenticated, service_role;
grant usage on schema auth       to anon, authenticated, service_role;

-- The columns Rafça's migrations and tests actually name. GoTrue's real table
-- is far wider; the extra columns have no bearing on a row-level policy.
create table if not exists auth.users (
  id                 uuid primary key,
  instance_id        uuid,
  aud                varchar(255),
  role               varchar(255),
  email              varchar(255),
  encrypted_password varchar(255),
  is_anonymous       boolean not null default false,
  raw_app_meta_data  jsonb,
  raw_user_meta_data jsonb,
  created_at         timestamptz,
  updated_at         timestamptz
);

create or replace function auth.uid()
returns uuid
language sql
stable
as $$
  select coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$$;

create or replace function auth.role()
returns text
language sql
stable
as $$
  select coalesce(
    nullif(current_setting('request.jwt.claim.role', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
  )
$$;
