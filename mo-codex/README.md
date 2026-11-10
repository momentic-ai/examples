# Mo + Codex: new and updated tests as a Git patch

Codex briefs [Mo](https://momentic.ai/docs/mo) with the `qa` CLI. Mo tests the
running app, writes and runs the tests, and returns its changes as a Git patch.
Mo needs no GitHub integration or repository access: it sees only the test
files you send.

## How it works

[`mo-tests.sh`](mo-tests.sh):

1. Uploads the tracked files in your tests directory (including uncommitted
   edits, never untracked files such as `.env`) with `qa upload`. Files inside
   git submodules aren't sent.
2. Sends your brief with `qa send`, telling Mo to commit the files as a
   baseline and, when done, write `git diff baseline` to a fresh path.
3. Waits with `qa wait` and downloads the patch with `qa download` to
   `.momentic-artifacts/momentic-tests.patch`.

[`codex-prompt.md`](codex-prompt.md) tells Codex how to write the brief and
answer Mo's questions. Nothing applies the patch; that's up to you.

## Run it locally

From the repository root, with `MOMENTIC_API_KEY` set and Codex installed:

```bash
npm ci
```

```bash
{ cat mo-codex/codex-prompt.md; echo "Add a test that searches for a hoodie and adds it to the cart"; } |
  APP_URL=https://nextjs-commerce.vercel.app/ codex exec -m gpt-6.1-terra --sandbox danger-full-access -
```

Codex needs network access for the `qa` CLI. Review the patch, then apply it
with `git apply .momentic-artifacts/momentic-tests.patch`.

## Run it in GitHub Actions

[`mo-codex-tests.yml`](../.github/workflows/mo-codex-tests.yml) runs the same
flow from **Actions > Mo + Codex tests > Run workflow**. Add `MOMENTIC_API_KEY`
and `OPENAI_API_KEY` as repository secrets.

The run outputs Mo's patch: download the `momentic-tests-patch` artifact, or
read it in the run summary, and apply it with `git apply momentic-tests.patch`.
The workflow doesn't push or open pull requests, and its token is read-only.

## Adapting it

- Point `--tests-dir` and the prompt at your Momentic project directory.
- Raise `--effort` for broader testing; it sets Mo's time budget.
- Download the patch before archiving the session.
