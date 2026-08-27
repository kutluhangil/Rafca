#!/usr/bin/env bash
#
# Runs supabase/tests against a plain PostgreSQL server.
#
# `supabase test db` is the canonical way to run these, and it stays that way.
# This script is the same suite without Docker: it builds a scratch database,
# applies the shim, applies every migration in order, then runs each test file
# and fails on the first `not ok` pgTAP emits.
#
# Environment:
#   PGHOST (default /tmp)  PGPORT (default 54329)  PGUSER (default postgres)
#   TEST_DB (default rafca_test)

set -euo pipefail

export PGHOST="${PGHOST:-/tmp}"
export PGPORT="${PGPORT:-54329}"
export PGUSER="${PGUSER:-postgres}"
TEST_DB="${TEST_DB:-rafca_test}"

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(dirname "$here")"

"$here/apply.sh" "$TEST_DB"

status=0
for test_file in "$root"/tests/*.sql; do
  echo "-- running $(basename "$test_file")"
  # The suite is expected to be self-contained: it opens its own transaction and
  # rolls back, so tests cannot see each other's fixtures.
  if ! output="$(psql -X -q -t -A -d "$TEST_DB" -v ON_ERROR_STOP=1 -f "$test_file" 2>&1)"; then
    echo "$output"
    status=1
    continue
  fi
  echo "$output"
  if grep -qE '^not ok' <<<"$output"; then
    status=1
  fi
done

exit "$status"
