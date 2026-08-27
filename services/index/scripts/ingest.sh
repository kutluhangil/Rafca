#!/usr/bin/env bash
#
# Loads the Open Library subset into books_index (SPINE_BLUEPRINT.md, FAZ 4).
#
# The dumps are downloaded once into WORK_DIR and reused; the three ol-index
# passes are cheap to repeat, a 12 GB download is not. Resuming a partial
# download is `curl -C -`'s job, not this script's.
#
# Environment:
#   WORK_DIR   where dumps and intermediates live (default ../.rafca-work)
#   PGHOST PGPORT PGUSER PGDATABASE   standard libpq variables
#   LANGUAGES  language codes to keep, priority first (default tur,eng)
#   MAX_PER_LANGUAGE  cap per language, 0 for no cap (default 1500000)

set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
service="$(dirname "$here")"
repo="$(cd "$service/../.." && pwd)"

WORK_DIR="${WORK_DIR:-$repo/../.rafca-work}"
LANGUAGES="${LANGUAGES:-tur,eng}"
MAX_PER_LANGUAGE="${MAX_PER_LANGUAGE:-1500000}"
export PGHOST="${PGHOST:-/tmp}"
export PGPORT="${PGPORT:-54329}"
export PGUSER="${PGUSER:-postgres}"
export PGDATABASE="${PGDATABASE:-rafca}"

mkdir -p "$WORK_DIR"

editions="$WORK_DIR/editions.txt.gz"
authors="$WORK_DIR/authors.txt.gz"
records="$WORK_DIR/records.jsonl"
author_keys="$WORK_DIR/author_keys.txt"
author_names="$WORK_DIR/author_names.tsv"
copy_file="$WORK_DIR/books_index.tsv"

echo "==> building ol-index"
(cd "$service" && go build -o "$WORK_DIR/ol-index" ./cmd/ol-index)

download() {
  local url="$1" target="$2"
  if [ -s "$target" ]; then
    echo "==> reusing $(basename "$target")"
    return
  fi
  echo "==> downloading $(basename "$target")"
  curl -sSL --retry 3 -C - "$url" -o "$target"
}

download https://openlibrary.org/data/ol_dump_editions_latest.txt.gz "$editions"
download https://openlibrary.org/data/ol_dump_authors_latest.txt.gz "$authors"

# Each pass is skipped when its output is already there, for the same reason the
# dumps are kept: a run interrupted in the loading step should not have to scan
# 12 GB again to get back to where it stopped. Delete an intermediate to force
# the pass that writes it.
if [ -s "$records" ] && [ -s "$author_keys" ]; then
  echo "==> reusing $(basename "$records")"
else
  echo "==> filtering editions"
  "$WORK_DIR/ol-index" filter \
    -in "$editions" -out "$records" -author-keys "$author_keys" \
    -languages "$LANGUAGES" -max-per-language "$MAX_PER_LANGUAGE"
fi

if [ -s "$author_names" ]; then
  echo "==> reusing $(basename "$author_names")"
else
  echo "==> resolving author names"
  "$WORK_DIR/ol-index" authors -in "$authors" -keys "$author_keys" -out "$author_names"
fi

if [ -s "$copy_file" ]; then
  echo "==> reusing $(basename "$copy_file")"
else
  echo "==> writing COPY text"
  "$WORK_DIR/ol-index" join -in "$records" -names "$author_names" -out "$copy_file"
fi

# The trigram and full-text indexes are dropped for the load and rebuilt after.
# Building a GIN index once over the finished table is minutes; maintaining it
# row by row through a COPY of this size is hours. The definitions are read out
# of the migration that creates them rather than repeated here, so this script
# cannot drift from the schema. They are read from the file and not from
# pg_indexes because a run interrupted between the drop and the rebuild leaves a
# catalogue that no longer holds them, and the next run would rebuild nothing.
echo "==> reading index definitions"
index_defs="$WORK_DIR/books_index_indexes.sql"
grep -hE '^create index (books_trgm|books_fts) ' \
  "$repo"/supabase/migrations/*_books_index.sql > "$index_defs"
found=$(wc -l < "$index_defs" | tr -d ' ')
if [ "$found" -ne 2 ]; then
  echo "ingest: expected books_trgm and books_fts in the books_index migration, found $found definition(s)" >&2
  exit 1
fi

echo "==> loading"
# The catalogue is merged, not replaced. user_books rows point at books_index by
# id, so a truncate-and-reload would either be refused by the foreign key or
# silently repoint someone's library at a different book. Staging plus an upsert
# on ol_key keeps existing ids stable across a refresh.
psql -X -q -v ON_ERROR_STOP=1 <<PSQL
set maintenance_work_mem = '1GB';

drop table if exists books_index_staging;
create unlogged table books_index_staging (
  ol_key       text,
  isbn13       text,
  title        text,
  subtitle     text,
  authors      text[],
  publisher    text,
  publish_year int,
  language     text,
  cover_url    text
);

\copy books_index_staging from '$copy_file'

drop index if exists public.books_trgm;
drop index if exists public.books_fts;

-- The dump can carry the same edition key twice across a revision boundary.
-- distinct on picks one deterministically instead of letting the upsert hit the
-- same row twice in one statement, which Postgres refuses outright.
insert into public.books_index
       (ol_key, isbn13, title, subtitle, authors, publisher, publish_year, language, cover_url)
select distinct on (ol_key)
       ol_key, isbn13, title, subtitle, authors, publisher, publish_year, language, cover_url
  from books_index_staging
 where ol_key is not null
 order by ol_key
on conflict (ol_key) do update set
  isbn13       = excluded.isbn13,
  title        = excluded.title,
  subtitle     = excluded.subtitle,
  authors      = excluded.authors,
  publisher    = excluded.publisher,
  publish_year = excluded.publish_year,
  language     = excluded.language,
  cover_url    = excluded.cover_url;

\i $index_defs
analyze public.books_index;
drop table books_index_staging;
PSQL

psql -X -q -t -A -v ON_ERROR_STOP=1 -c \
  "select 'loaded ' || count(*) || ' rows' from public.books_index"
