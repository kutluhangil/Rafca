# Rafça build entry points.
#
# `make eval` is the regression gate from SPINE_BLUEPRINT.md section 10: it
# re-runs the whole capture pipeline over spike/dataset and fails when accuracy
# drops more than 3 points below the last recorded report.

.PHONY: eval eval-build test analyze clean db-start db-stop db-test db-apply index-ingest index-bench match-golden

VISION_BIN := spike/tool/vision_ocr

# Local PostgreSQL for the Supabase migrations. `supabase start` is the
# canonical stack and stays that way; these targets are the same schema on a
# plain server, which is what CI runs and what a machine without Docker gets.
PG_BIN   ?= /opt/homebrew/opt/postgresql@17/bin
PGDATA   ?= $(CURDIR)/../.rafca-pgdata
GO_BIN   ?= /opt/homebrew/bin
PGHOST   ?= /tmp
PGPORT   ?= 54329
PGUSER   ?= postgres
DEV_DB   ?= rafca
DATABASE_URL ?= postgres://$(PGUSER)@localhost:$(PGPORT)/$(DEV_DB)?host=$(PGHOST)

$(VISION_BIN): spike/tool/vision_ocr.swift
	swiftc -O -o $(VISION_BIN) spike/tool/vision_ocr.swift

eval-build: $(VISION_BIN)

eval: eval-build
	cd spike && dart run bin/spike.dart --crops

test:
	cd packages/spine_clustering && dart test
	cd spike && dart test

analyze:
	cd packages/spine_clustering && dart analyze
	cd spike && dart analyze

db-start:
	@test -d $(PGDATA) || $(PG_BIN)/initdb -D $(PGDATA) -U postgres --locale=en_US.UTF-8 -E UTF-8
	$(PG_BIN)/pg_ctl -D $(PGDATA) -o "-p $(PGPORT) -k $(PGHOST)" -l $(PGDATA)/server.log start

db-stop:
	$(PG_BIN)/pg_ctl -D $(PGDATA) stop

db-test:
	PATH=$(PG_BIN):$$PATH PGHOST=$(PGHOST) PGPORT=$(PGPORT) supabase/harness/run_tests.sh

# The development database, rebuilt from the same steps as the test one.
db-apply:
	PATH=$(PG_BIN):$$PATH PGHOST=$(PGHOST) PGPORT=$(PGPORT) supabase/harness/apply.sh $(DEV_DB)

index-ingest:
	PATH=$(PG_BIN):$(GO_BIN):$$PATH PGHOST=$(PGHOST) PGPORT=$(PGPORT) \
	  PGUSER=$(PGUSER) PGDATABASE=$(DEV_DB) services/index/scripts/ingest.sh

index-bench:
	cd services/index && $(GO_BIN)/go run ./cmd/index-bench -database-url "$(DATABASE_URL)"

# The section 9 regression gate. It runs against its own database, rebuilt from
# the migrations on every run: the fixture bands only hold when books_index
# contains the fixture catalogue and nothing else, so it must never be pointed
# at $(DEV_DB).
GOLDEN_DB ?= rafca_golden

match-golden:
	PATH=$(PG_BIN):$$PATH PGHOST=$(PGHOST) PGPORT=$(PGPORT) supabase/harness/apply.sh $(GOLDEN_DB)
	cd services/match && RAFCA_GOLDEN_DATABASE_URL="postgres://$(PGUSER)@localhost:$(PGPORT)/$(GOLDEN_DB)?host=$(PGHOST)" \
	  $(GO_BIN)/go test ./internal/matcher/

clean:
	rm -rf spike/out $(VISION_BIN)
