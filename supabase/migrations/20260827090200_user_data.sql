-- Per-user data (SPINE_BLUEPRINT.md 6.1).
--
-- Every table here is fenced by `auth.uid() = user_id`, with a separate policy
-- per command. RLS is enabled in the same migration that creates the table so
-- there is no window, not even between two migrations, in which a user table
-- exists unprotected.
--
-- Note what is absent: no image column anywhere. Shelf photos and spine crops
-- stay on the device (SPINE_BLUEPRINT.md 5); the only thing that ever reaches
-- a server is OCR plain text, and that goes to the match service, not here.

create table public.profiles (
  id           uuid primary key references auth.users (id) on delete cascade,
  display_name text,
  created_at   timestamptz not null default now()
);

create table public.shelves (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references auth.users (id) on delete cascade,
  name       text not null,
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);

create table public.user_books (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references auth.users (id) on delete cascade,
  book_id      bigint references public.books_index (id),  -- null: manual entry
  manual_title text,
  manual_author text,
  shelf_id     uuid references public.shelves (id) on delete set null,
  status       text not null default 'unread' check (status in ('unread', 'reading', 'read')),
  confidence   text not null check (confidence in ('matched', 'review', 'unknown')),
  spine_color  text,                                       -- #RRGGBB, for ShelfStrip
  added_at     timestamptz not null default now(),

  -- A row is either a catalogue hit or a hand-typed book. Neither means the
  -- card has nothing to render, which is a bug upstream, not a state to store.
  constraint user_books_identifies_a_book
    check (book_id is not null or manual_title is not null),

  -- Catalogue hits are unique per user. Manual entries have a null book_id and
  -- are therefore never in conflict with each other, which is what lets a user
  -- own two different hand-typed copies.
  unique (user_id, book_id)
);

create table public.scans (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null references auth.users (id) on delete cascade,
  detected_count int,
  matched_count  int,
  created_at     timestamptz not null default now()
);

create index shelves_user     on public.shelves (user_id, sort_order);
create index user_books_user  on public.user_books (user_id, added_at desc);
create index user_books_shelf on public.user_books (shelf_id);
create index user_books_book  on public.user_books (book_id);
create index scans_user       on public.scans (user_id, created_at desc);

alter table public.profiles   enable row level security;
alter table public.shelves    enable row level security;
alter table public.user_books enable row level security;
alter table public.scans      enable row level security;

-- profiles is keyed by the user id itself, so its fence reads `id` where the
-- other three read `user_id`.
create policy "profiles owner select" on public.profiles
  for select to authenticated using ((select auth.uid()) = id);
create policy "profiles owner insert" on public.profiles
  for insert to authenticated with check ((select auth.uid()) = id);
create policy "profiles owner update" on public.profiles
  for update to authenticated using ((select auth.uid()) = id) with check ((select auth.uid()) = id);
create policy "profiles owner delete" on public.profiles
  for delete to authenticated using ((select auth.uid()) = id);

create policy "shelves owner select" on public.shelves
  for select to authenticated using ((select auth.uid()) = user_id);
create policy "shelves owner insert" on public.shelves
  for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "shelves owner update" on public.shelves
  for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "shelves owner delete" on public.shelves
  for delete to authenticated using ((select auth.uid()) = user_id);

create policy "user_books owner select" on public.user_books
  for select to authenticated using ((select auth.uid()) = user_id);
create policy "user_books owner insert" on public.user_books
  for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "user_books owner update" on public.user_books
  for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "user_books owner delete" on public.user_books
  for delete to authenticated using ((select auth.uid()) = user_id);

create policy "scans owner select" on public.scans
  for select to authenticated using ((select auth.uid()) = user_id);
create policy "scans owner insert" on public.scans
  for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "scans owner update" on public.scans
  for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "scans owner delete" on public.scans
  for delete to authenticated using ((select auth.uid()) = user_id);

grant select, insert, update, delete on public.profiles   to authenticated;
grant select, insert, update, delete on public.shelves    to authenticated;
grant select, insert, update, delete on public.user_books to authenticated;
grant select, insert, update, delete on public.scans      to authenticated;

-- Anonymous sign-in produces a real auth.users row, so `anon` is the
-- pre-sign-in role and has no business in user data at all.
revoke all on public.profiles, public.shelves, public.user_books, public.scans from anon;

-- A profile row is created with the account rather than on first write, so
-- that an anonymous user who scans offline and syncs later never races the
-- foreign keys that hang off it.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id) values (new.id);
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
