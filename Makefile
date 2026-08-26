# Rafça build entry points.
#
# `make eval` is the regression gate from SPINE_BLUEPRINT.md section 10: it
# re-runs the whole capture pipeline over spike/dataset and fails when accuracy
# drops more than 3 points below the last recorded report.

.PHONY: eval eval-build test analyze clean

VISION_BIN := spike/tool/vision_ocr

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

clean:
	rm -rf spike/out $(VISION_BIN)
