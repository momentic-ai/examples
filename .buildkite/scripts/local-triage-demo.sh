#!/usr/bin/env bash
set -euo pipefail

: "${MOMENTIC_API_KEY:?MOMENTIC_API_KEY must be set in Buildkite secrets or the agent environment}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
RESULTS_DIR="test-results/triage-demo"

cd "$ROOT_DIR"

npm ci

cd web

npx momentic install-browsers chromium
npx momentic run autoheal-test-authorship-demo.test.yaml \
  --output-dir "$RESULTS_DIR" \
  --upload-results

npx momentic ai triage "$RESULTS_DIR" \
  --yes \
  --quiet \
  --timeout-minutes "${MOMENTIC_TRIAGE_TIMEOUT_MINUTES:-10}"
