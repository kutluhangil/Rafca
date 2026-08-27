-- The public book catalogue (SPINE_BLUEPRINT.md 6.1).
--
-- Read by everyone, written by nobody through the API: Faz 4 loads it with
-- COPY as the service role, which bypasses RLS, and Faz 5's fallback writes
-- back through the match service, also as the service role.

create table public.books_index (
  id           bigserial primary key,
  ol_key       text unique,                 -- Open Library work/edition key
  isbn13       text,
  title        text not null,
  subtitle     text,
  authors      text[] not null default '{}',
  publisher    text,
  publish_year int,
  language     text,                        -- 'tur', 'eng', ...
  cover_url    text,

  -- Trigram surface. unaccent runs before lower() on purpose: the default
  -- unaccent rules fold U+0130 (İ) to I and U+0131 (ı) to i, which is exactly
  -- the Turkish I/İ case SPINE_BLUEPRINT.md 8.2 asks the matcher to handle.
  -- Doing it the other way round would leave lower() to guess, and lower('İ')
  -- yields a two-codepoint sequence that no query would reproduce.
  search_blob  text generated always as (
                 lower(public.spine_unaccent(
                   coalesce(title, '') || ' ' ||
                   public.spine_join_authors(authors)
                 ))
               ) stored,

  search_tsv   tsvector generated always as (
                 to_tsvector('simple',
                   coalesce(title, '') || ' ' ||
                   public.spine_join_authors(authors)
                 )
               ) stored
);

create index books_trgm on public.books_index using gin (search_blob extensions.gin_trgm_ops);
create index books_fts  on public.books_index using gin (search_tsv);
create index books_isbn on public.books_index (isbn13);

alter table public.books_index enable row level security;

create policy "books_index is world readable"
  on public.books_index
  for select
  to anon, authenticated
  using (true);

-- No write policy exists, but a missing policy is easy to add by accident.
-- Removing the privilege makes the catalogue read-only at a second, blunter
-- level: even a mistaken `for all` policy could not grant a write back.
revoke insert, update, delete, truncate on public.books_index from anon, authenticated;
grant select on public.books_index to anon, authenticated;
