-- Search extensions and the immutable normaliser the catalogue is indexed on.
--
-- SPINE_BLUEPRINT.md 6.1 writes books_index.search_blob as a generated column
-- over unaccent(). That does not compile: unaccent(text) resolves its
-- dictionary at call time and is therefore only STABLE, and Postgres refuses a
-- STABLE function in a generated column or a functional index. The two-argument
-- form, which names the dictionary, is IMMUTABLE. spine_unaccent pins that
-- dictionary so the rest of the schema has one immutable normaliser to use.

create schema if not exists extensions;

create extension if not exists pg_trgm with schema extensions;
create extension if not exists unaccent with schema extensions;

create or replace function public.spine_unaccent(input text)
returns text
language sql
immutable
parallel safe
strict
set search_path = ''
as $$
  select extensions.unaccent('extensions.unaccent'::regdictionary, input);
$$;

comment on function public.spine_unaccent(text) is
  'Accent-stripping normaliser, IMMUTABLE so it can back generated columns and indexes.';

-- array_to_string is STABLE, not IMMUTABLE: in the general case the element
-- type's output function is not guaranteed immutable, so Postgres will not let
-- it into a generated column either. For `text[]` the concern does not apply —
-- text output is immutable — so this wrapper narrows the argument type and
-- states that.
create or replace function public.spine_join_authors(authors text[])
returns text
language sql
immutable
parallel safe
set search_path = ''
as $$
  select coalesce(array_to_string(authors, ' '), '');
$$;

comment on function public.spine_join_authors(text[]) is
  'Joins an author array for indexing, IMMUTABLE where array_to_string is only STABLE.';
