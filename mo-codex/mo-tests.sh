#!/usr/bin/env bash
# Sends a Momentic test directory and a brief to Mo, waits, and downloads Mo's
# changes as a Git patch relative to the files you sent.
#
#   mo-codex/mo-tests.sh --brief brief.md [--tests-dir web] [--url URL] [--effort low]
#   mo-codex/mo-tests.sh --brief follow-up.md --session-id <id>   # later round
#
# Prints the session ID and the patch path ($out_dir/momentic-tests.patch). Exits 3 when Mo is waiting
# on a question (answer it with a follow-up round) and 4 when Mo wrote no patch.
set -euo pipefail

tests_dir=web
url=""
effort=low
brief=""
session_id=""
out_dir=.momentic-artifacts

while [[ $# -gt 0 ]]; do
  [[ "$1" == --* && $# -ge 2 ]] || { echo "usage: $0 --brief <file> [--option value ...]" >&2; exit 2; }
  case "$1" in
    --brief) brief="$2"; shift 2 ;;
    --tests-dir) tests_dir="$2"; shift 2 ;;
    --url) url="$2"; shift 2 ;;
    --effort) effort="$2"; shift 2 ;;
    --session-id) session_id="$2"; shift 2 ;;
    --out-dir) out_dir="$2"; shift 2 ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
done
[[ -f "$brief" ]] || { echo "--brief <file> is required" >&2; exit 2; }
brief=$(realpath "$brief")
# Patch paths are relative to the repository root, so --tests-dir is too.
cd "$(git rev-parse --show-toplevel)"

qa() { npx --no-install qa "$@"; }
json_field() { node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{const v=JSON.parse(s)[process.argv[1]];console.log(typeof v==="string"?v:JSON.stringify(v??null))})' "$1"; }

mkdir -p "$out_dir"
# A round that fails must not leave an earlier round's patch as the result.
rm -f "$out_dir/momentic-tests.patch"
remote_tests=/home/user/momentic-tests
# A new name per round, so a round where Mo writes nothing can't return an old patch.
remote_patch="/home/user/momentic-tests-$(date +%s)-$$-$RANDOM.patch"

if [[ -z "$session_id" ]]; then
  # Mo reads only what you send: tracked files in the tests directory, including
  # uncommitted edits, never untracked files such as local .env files.
  archive="$out_dir/momentic-tests-baseline.tgz"
  # Files and symlinks that still exist: skip unstaged deletions, and skip
  # submodules (mode 160000), whose directories can hold untracked files.
  git ls-files -z -s -- "$tests_dir" | while IFS= read -r -d '' entry; do
    path=${entry#*$'\t'}
    [[ ${entry%% *} != 160000 && ( -L "$path" || -f "$path" ) ]] && printf '%s\0' "$path"
  done | tar --null -T - -czf "$archive"

  start_args=(--effort "$effort")
  [[ -n "$url" ]] && start_args+=(--url "$url")
  # Hold Mo until the tests are uploaded; the upload needs the session to exist.
  session_id=$(qa start "${start_args[@]}" \
    "Wait for my next message. I'm uploading our Momentic tests first. Reply 'ready'." |
    json_field sessionId)
  uploaded=$(qa upload "$archive" momentic-tests-baseline.tgz --session-id "$session_id")
  setup="Set up the tests first: mkdir -p $remote_tests && tar -xzf $uploaded -C $remote_tests && cd $remote_tests && git init -q && git add -A && git -c user.name=mo -c user.email=mo@localhost commit -q --allow-empty -m baseline && git tag baseline
The Momentic tests are in $remote_tests/$tests_dir. Edit tests there.

"
else
  setup=""
fi

message="$setup$(cat "$brief")

When you're done, export every change since the baseline, even if you changed nothing:
cd $remote_tests && git add -A && git diff --cached --binary baseline > $remote_patch
Then reply with the patch path and the files it changes."

qa send "$session_id" "$message" >/dev/null
state="$out_dir/mo-session-state.json"
# Exit 2 means Mo needs input and 4 means it was stopped; both are handled below.
wait_status=0
qa wait "$session_id" --json >"$state" || wait_status=$?
[[ $wait_status == 0 || $wait_status == 2 || $wait_status == 4 ]] || exit "$wait_status"
echo "session: $session_id"
echo "mo: $(json_field messages <"$state" | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{const m=JSON.parse(s).filter(x=>x.role==="assistant").at(-1);console.log(m?m.text:"(no reply)")})')"

if [[ "$(json_field status <"$state")" == "needs_you" ]]; then
  echo "Mo is waiting on a question: $(json_field pendingQuestions <"$state")" >&2
  exit 3
fi

local_patch="$out_dir/$(basename "$remote_patch")"
if ! qa download "$remote_patch" --session-id "$session_id" --output "$local_patch" >/dev/null; then
  echo "Mo didn't write $remote_patch. Ask it with a follow-up round." >&2
  exit 4
fi
cp "$local_patch" "$out_dir/momentic-tests.patch"
echo "patch: $out_dir/momentic-tests.patch"
if [[ -s "$local_patch" ]]; then git apply --stat "$local_patch"; else echo "Mo changed no tests."; fi
