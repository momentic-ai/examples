# Mo + Codex: new and updated tests without GitHub

Codex briefs [Mo](https://momentic.ai/docs/mo) with the `qa` CLI, Mo tests the
running app and edits a copy of your Momentic tests, and Codex applies Mo's
changes as a Git patch, then lints and runs them. Mo needs no GitHub
integration or repository access: it sees only the test files you send.

## How it works

[`mo-tests.sh`](mo-tests.sh) does the file transfer:

1. Packs the tracked files in your tests directory (including uncommitted
   edits, never untracked files such as `.env`) and uploads them with
   `qa upload`.
2. Sends your brief with `qa send`, telling Mo to commit the files as a
   baseline and, when done, write `git diff baseline` to a fresh path.
3. Waits with `qa wait` and downloads the patch with `qa download`.

The patch shows edits and deletions, not just new files, and
`git apply --3way` flags conflicts with changes made while Mo worked.
[`codex-prompt.md`](codex-prompt.md) tells Codex how to write the brief, review
and apply the patch, and send Mo follow-ups when a test fails.

## Run it locally

From the repository root, with `MOMENTIC_API_KEY` set and Codex installed:

```bash
npm ci
npx momentic install-browsers chromium
```

```bash
{ cat mo-codex/codex-prompt.md; echo "Add a test that searches for a hoodie and adds it to the cart"; } |
  APP_URL=https://nextjs-commerce.vercel.app/ codex exec -m gpt-6.1-terra --sandbox danger-full-access -
```

Codex needs network access for the `qa` CLI and `momentic run`. Review the
changes under `web/` and commit them yourself.

## Run it in GitHub Actions

[`mo-codex-tests.yml`](../.github/workflows/mo-codex-tests.yml) runs the same
flow from **Actions > Mo + Codex tests > Run workflow**. Add `MOMENTIC_API_KEY`
and `OPENAI_API_KEY` as repository secrets.

The run outputs the changed tests as a Git patch: download the
`momentic-tests-patch` artifact, or read it in the run summary, and apply it
with `git apply momentic-tests.patch`. The workflow doesn't push or open pull
requests, and its token is read-only. To open a pull request automatically, add
a job that applies the artifact and pushes a branch.

## Adapting it

- Point `--tests-dir` and the prompt at your Momentic project directory.
- Raise `--effort` for broader testing; it sets Mo's time budget.
- Mo writes the patch because the brief asks it to. When it doesn't, the script
  exits 4 and Codex asks again in the same session.
- Download the patch before archiving the session.
- Mo checks each step with browser previews but can't run `momentic run` in
  its sandbox, so Codex runs the changed tests before you see them.
