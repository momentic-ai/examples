#!/usr/bin/env bash
set -euo pipefail

: "${MOMENTIC_API_KEY:?MOMENTIC_API_KEY must be set in Buildkite secrets or the agent environment}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
RESULTS_DIR="test-results/autoheal-demo"
CLASSIFICATION_FILE="${RESULTS_DIR}/classification.json"

cd "$ROOT_DIR"

npm ci

cd web

npx momentic install-browsers chromium
rm -rf "$RESULTS_DIR"

set +e
npx momentic run autoheal-test-authorship-demo.test.yaml \
  --output-dir "$RESULTS_DIR" \
  --upload-results
run_status=$?
set -e

if [ ! -d "$RESULTS_DIR" ]; then
  echo "Momentic run did not produce $RESULTS_DIR, so skipping classification/healing."
  exit "$run_status"
fi

# Save a dry-run triage artifact so Buildkite shows the classification output directly.
npx momentic ai triage "$RESULTS_DIR" \
  --dry-run \
  --json \
  --no-upload | tee "$CLASSIFICATION_FILE"

npx momentic ai triage "$RESULTS_DIR" \
  --yes \
  --timeout-minutes "${MOMENTIC_HEAL_TIMEOUT_MINUTES:-10}"
