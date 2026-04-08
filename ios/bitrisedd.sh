#!/usr/bin/env bash
set -ex

TAG="latest"
RESULTS_DIR="test-results"
mkdir -p "$RESULTS_DIR"

test_failures=""
all_results=""

APP="modules"
CHANNEL="checkers"
APP_PATH="../../../../../Downloads/dd.app"

echo "========================================"
echo "Processing $APP (channel: $CHANNEL, tag: $TAG)"
echo "========================================"

set +e
npx momentic-mobile run "./$APP/" \
--channel "$CHANNEL" \
--tag "$TAG" \
--name "Storefront Nightly - $APP" \
--upload-results \
--output-dir "$RESULTS_DIR/$APP" \
-y
EXIT_CODE=$?
set -e

METADATA="$RESULTS_DIR/$APP/metadata.json"
MAX_WAIT=1800
WAITED=0
POLL_INTERVAL=30

while true; do
if [[ -f "$METADATA" ]]; then
    RUN_STATUS=$(python3 -c "import json; print(json.load(open('$METADATA'))['status'])" 2>/dev/null || echo "UNKNOWN")
else
    RUN_STATUS="NO_RESULTS"
fi

if [[ "$RUN_STATUS" != "RUNNING" ]]; then
    break
fi

if [[ $WAITED -ge $MAX_WAIT ]]; then
    echo "Timed out after ${MAX_WAIT}s waiting for $APP to finish (still RUNNING)"
    RUN_STATUS="TIMEOUT"
    break
fi

echo "Status is RUNNING, waiting... (${WAITED}s / ${MAX_WAIT}s)"
sleep $POLL_INTERVAL
WAITED=$((WAITED + POLL_INTERVAL))
done

echo "Exit code: $EXIT_CODE, Run status: $RUN_STATUS"

if [[ "$RUN_STATUS" == "PASSED" ]]; then
all_results="$all_results\n:white_check_mark: $APP: passed"
else
test_failures="$test_failures $APP"
all_results="$all_results\n:x: $APP: $RUN_STATUS (exit=$EXIT_CODE)"
fi

envman add --key MOMENTIC_TEST_RESULTS --value "$all_results"
envman add --key MOMENTIC_TEST_FAILURES --value "$test_failures"

if [[ -n "$test_failures" ]]; then
    echo "Test failures:$test_failures"
fi