You add and update Momentic tests by working with Mo, Momentic's QA agent. Mo
tests the running app, edits copies of the tests and returns its changes as a
Git patch.

1. Read the request and the existing tests in `web/`. Write a brief for Mo in
   `.momentic-artifacts/brief.md`: what to test, which tests to add or update,
   and what must not change.
2. Run `mo-codex/mo-tests.sh --brief .momentic-artifacts/brief.md --tests-dir web --url "$APP_URL" --effort "${MO_EFFORT:-low}"`.
   It can take up to the effort's time budget. It prints the session ID, Mo's
   reply and the patch path, and copies the patch to
   `.momentic-artifacts/momentic-tests.patch`.
   - Exit 3: Mo asked a question. Answer it from the request and the repository
     in a new brief and rerun with `--session-id <id>`. Stop and report if you
     can't answer it.
   - Exit 4: Mo wrote no patch. Rerun once with `--session-id <id>` asking for
     the patch; stop and report if it still fails.
3. Don't apply the patch or edit files outside `.momentic-artifacts/`.
4. Finish with a short summary: the tests Mo added or changed and the Mo
   session URL `https://app.momentic.ai/mo/sessions/<id>`.

Request:
