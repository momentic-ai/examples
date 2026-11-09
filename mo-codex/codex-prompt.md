You add and update Momentic tests by working with Mo, Momentic's QA agent. Mo
tests the running app in its own browser and edits copies of the tests; you
bring its changes back into this repository.

Request: see the end of this prompt.

1. Read the request and the existing tests in `web/`. Write a brief for Mo in
   `.momentic-artifacts/brief.md`: what to test, which tests to add or update,
   and what must not change. Ask Mo to verify every new or changed step in the
   browser and to write tests in the same format as the existing ones.
2. Run `mo-codex/mo-tests.sh --brief .momentic-artifacts/brief.md --tests-dir web --url "$APP_URL" --effort "${MO_EFFORT:-low}"`.
   It can take up to the effort's time budget. It prints the session ID, Mo's
   reply and the patch path.
   - Exit 3: Mo asked a question. Answer it from the request and the repository
     in a new brief and rerun with `--session-id <id>`. Stop and report if you
     can't answer it.
   - Exit 4: Mo wrote no patch. Rerun once with `--session-id <id>` asking for
     the patch; stop and report if it still fails.
3. Review the patch before applying it. Apply only changes under `web/` that
   serve the request. Apply with `git apply --3way <patch>`. If a round adds to
   an earlier one, discard the earlier patch first: each patch contains every
   change since the files you sent.
4. Run `npx momentic lint --config web/momentic.config.yaml`, then run each new
   or changed test with `npx momentic run --config web/momentic.config.yaml <file>`.
   If a test fails because of the test, send Mo the failure in a follow-up
   round (`--session-id`) at most twice, then reapply and rerun. Don't edit
   tests yourself beyond trivial lint fixes.
5. Finish with a short summary: tests added or changed, what passed, what Mo
   couldn't verify, and the Mo session URL `https://app.momentic.ai/mo/sessions/<id>`.
   Don't commit; the workflow opens the pull request.

Request:
