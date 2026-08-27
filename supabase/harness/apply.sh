#!/usr/bin/env bash
#
# Rebuilds a database from the shim plus every migration, in order.
#
# Used by run_tests.sh for the throwaway test database and by `make db-apply`
# for the development one, so the two can never be built from different steps.
#
# Environment: PGHOST (default /tmp), PGPORT (default 54329), PGUSER (default postgres)

set -euo pipefail

if [ $# -ne 1 ]; then
  echo "usage: apply.sh <database>" >&2
  exit 2
fi
database="$1"

export PGHOST="${PGHOST:-/tmp}"
export PGPORT="${PGPORT:-54329}"
export PGUSER="${PGUSER:-postgres}"

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(dirname "$here")"

psql -X -q -d postgres -v ON_ERROR_STOP=1 \
  -c "drop database if exists ${database} with (force)" \
  -c "create database ${database}"

psql -X -q -d "$database" -v ON_ERROR_STOP=1 -f "$here/supabase_shim.sql"

for migration in "$root"/migrations/*.sql; do
  echo "-- applying $(basename "$migration")"
  psql -X -q -d "$database" -v ON_ERROR_STOP=1 -f "$migration"
done
