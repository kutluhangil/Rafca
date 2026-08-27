-- Faz 3 acceptance (SPINE_BLUEPRINT.md 9, FAZ 3): no query returns another
-- user's row.
--
-- The test does not trust the policies to be read correctly. It signs in as one
-- user and then tries, from that seat, every way a row could leak: an unfiltered
-- select, a select that names the other user's primary key, an insert that
-- claims the other user's id, and an update and a delete aimed straight at the
-- other user's rows. It finishes by checking from outside that the other user's
-- rows are still there and unchanged.
--
-- Run with: supabase test db

begin;

create extension if not exists pgtap with schema extensions;

-- pgTAP lives in `extensions`, like every other Supabase extension. Every table
-- below is schema-qualified, so putting `extensions` first costs nothing and
-- makes plan()/is()/throws_ok() resolvable.
set local search_path to extensions, public;

select plan(17);

-- Two accounts. `a` is anonymous, which is what a first-run Rafça user is.
insert into auth.users (id, instance_id, aud, role, email, encrypted_password, is_anonymous, created_at, updated_at)
values
  ('11111111-1111-1111-1111-111111111111', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', null,                'x', true,  now(), now()),
  ('22222222-2222-2222-2222-222222222222', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'b@example.test',     'x', false, now(), now());

insert into public.books_index (ol_key, title, authors, language)
values ('/works/OL1W', 'Tutunamayanlar', array['Oğuz Atay'], 'tur');

insert into public.shelves (id, user_id, name) values
  ('a1111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', 'Salon'),
  ('b2222222-2222-2222-2222-222222222222', '22222222-2222-2222-2222-222222222222', 'Ofis');

insert into public.user_books (id, user_id, manual_title, confidence, shelf_id) values
  ('a3333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111', 'A kitabı', 'matched', 'a1111111-1111-1111-1111-111111111111'),
  ('b4444444-4444-4444-4444-444444444444', '22222222-2222-2222-2222-222222222222', 'B kitabı', 'review',  'b2222222-2222-2222-2222-222222222222');

insert into public.scans (id, user_id, detected_count, matched_count) values
  ('a5555555-5555-5555-5555-555555555555', '11111111-1111-1111-1111-111111111111', 9, 7),
  ('b6666666-6666-6666-6666-666666666666', '22222222-2222-2222-2222-222222222222', 4, 4);

-- Scratch space for the row counts of the attempts made further down, created
-- while still the session owner so the impersonated role only has to write to
-- it.
create table public.rls_attempt (label text primary key, affected bigint);
grant select, insert on public.rls_attempt to authenticated;

-- ---------------------------------------------------------------- as user A
set local role authenticated;
set local request.jwt.claims to '{"sub":"11111111-1111-1111-1111-111111111111","role":"authenticated"}';

-- A scalar subquery over more than one row raises, so each of these asserts the
-- count and the identity at once.
select is(
  (select id from public.profiles),
  '11111111-1111-1111-1111-111111111111'::uuid,
  'profiles: an unfiltered select returns only the caller''s profile'
);

select is(
  (select id from public.shelves),
  'a1111111-1111-1111-1111-111111111111'::uuid,
  'shelves: an unfiltered select returns only the caller''s shelf'
);

select is(
  (select id from public.user_books),
  'a3333333-3333-3333-3333-333333333333'::uuid,
  'user_books: an unfiltered select returns only the caller''s book'
);

select is(
  (select id from public.scans),
  'a5555555-5555-5555-5555-555555555555'::uuid,
  'scans: an unfiltered select returns only the caller''s scan'
);

-- Naming the other user's primary key directly must not reach around the policy.
select is(
  (select count(*) from public.shelves where id = 'b2222222-2222-2222-2222-222222222222'),
  0::bigint,
  'shelves: selecting the other user''s row by id returns nothing'
);

select is(
  (select count(*) from public.user_books where id = 'b4444444-4444-4444-4444-444444444444'),
  0::bigint,
  'user_books: selecting the other user''s row by id returns nothing'
);

select is(
  (select count(*) from public.scans where id = 'b6666666-6666-6666-6666-666666666666'),
  0::bigint,
  'scans: selecting the other user''s row by id returns nothing'
);

select throws_ok(
  $$insert into public.shelves (user_id, name)
    values ('22222222-2222-2222-2222-222222222222', 'çalınmış raf')$$,
  '42501',
  null,
  'shelves: writing a row owned by another user is refused'
);

-- An update or delete the policy hides is not an error, it is a no-op. That is
-- the quieter failure, so it is asserted by row count.
--
-- A data-modifying CTE cannot sit inside a subquery, so the four attempts run
-- in one plpgsql block that records `row_count` for each. The scratch table is
-- created by the session owner and rolled back with the rest of the
-- transaction; RLS is not enabled on it, so it cannot hide its own contents.
do $attempts$
declare
  affected bigint;
begin
  update public.shelves set name = 'ele geçirildi'
    where id = 'b2222222-2222-2222-2222-222222222222';
  get diagnostics affected = row_count;
  insert into public.rls_attempt values ('shelves update', affected);

  delete from public.shelves
    where id = 'b2222222-2222-2222-2222-222222222222';
  get diagnostics affected = row_count;
  insert into public.rls_attempt values ('shelves delete', affected);

  update public.user_books set status = 'read'
    where id = 'b4444444-4444-4444-4444-444444444444';
  get diagnostics affected = row_count;
  insert into public.rls_attempt values ('user_books update', affected);

  delete from public.user_books
    where id = 'b4444444-4444-4444-4444-444444444444';
  get diagnostics affected = row_count;
  insert into public.rls_attempt values ('user_books delete', affected);
end
$attempts$;

select is(
  (select affected from public.rls_attempt where label = 'shelves update'),
  0::bigint,
  'shelves: updating the other user''s row changes nothing'
);

select is(
  (select affected from public.rls_attempt where label = 'shelves delete'),
  0::bigint,
  'shelves: deleting the other user''s row removes nothing'
);

select is(
  (select affected from public.rls_attempt where label = 'user_books update'),
  0::bigint,
  'user_books: updating the other user''s row changes nothing'
);

select is(
  (select affected from public.rls_attempt where label = 'user_books delete'),
  0::bigint,
  'user_books: deleting the other user''s row removes nothing'
);

select is(
  (select count(*) from public.books_index),
  1::bigint,
  'books_index: the catalogue is readable by a signed-in user'
);

select throws_ok(
  $$insert into public.books_index (title) values ('uydurma')$$,
  '42501',
  null,
  'books_index: a signed-in user cannot write to the catalogue'
);

-- ------------------------------------------------------------- as anonymous
set local role anon;
set local request.jwt.claims to '{"role":"anon"}';

select throws_ok(
  $$select * from public.shelves$$,
  '42501',
  null,
  'shelves: the pre-sign-in role cannot read user data at all'
);

select is(
  (select count(*) from public.books_index),
  1::bigint,
  'books_index: the catalogue is readable before sign-in'
);

-- ------------------------------------------------------- back to the owner
reset role;
reset request.jwt.claims;

select is(
  (select count(*) from public.shelves    where user_id = '22222222-2222-2222-2222-222222222222')
  + (select count(*) from public.user_books where user_id = '22222222-2222-2222-2222-222222222222')
  + (select count(*) from public.scans      where user_id = '22222222-2222-2222-2222-222222222222'),
  3::bigint,
  'the other user''s three rows survived every attempt untouched'
);

select * from finish();

rollback;
