# Examples

This repo contains usage examples and patterns for the [Momentic CLI](https://momentic.ai/docs/quickstart/cli).

## Examples

### Web

- [Web test](web/) — end-to-end tests for [Swag Labs](https://www.saucedemo.com/), a demo e-commerce app. Includes:
  - `standard-user-purchases` — end-to-end checkout flow (add items, verify cart, complete purchase)
  - `cart-and-sorting-behavior` — verifies sorting changes the view without affecting cart state
  - `input-from-csv-test` — logs in and verifies the products page using credentials supplied via CSV
  - `autoheal-test-authorship-demo` — intentionally fails in a way that should classify as `TEST_AUTHORSHIP` and is meant to be run by the dedicated AI-heal demo workflow
  - **Modules**: `log-in-username-password`, `add-item-to-cart`, `fill-out-personal-info`

### Android

- [Android test](android/) — mobile tests for Android apps. Includes:
  - `android-google-maps` — searches for Italian restaurants in San Francisco and verifies results and restaurant details. The APK can be downloaded [here](https://drive.google.com/file/d/1JEagdPUFJ3jr_Ra4q1ghgGmWcaxhIvZf/view?usp=sharing).
  - `android-contacts` — creates a contact in the Google Contacts app and verifies it, then attempts a call via the phone app
  - **Modules**: `search-restaurants`

### iOS

- [iOS test](ios/) — mobile tests for iOS apps. Includes:
  - `dime-app` — tests onboarding and expense creation in the [Dime](https://apps.apple.com/us/app/dime-budget-expense-tracker/id1635280255) personal finance app
  - `ios-contacts` — creates a contact in the iOS Contacts app and drafts a text message to that contact

### Multi-project

- [Workspace](multi-project-workspace/) — example of managing multiple projects in a single workspace. Includes:
  - `apps/dashboard/google-search` — searches Google from the dashboard project
  - `apps/marketing/variable-showcase` — demonstrates environment variable interpolation across file, shell, and default sources
  - `qa/practice-test-login` — logs into [Practice Test Automation](https://practicetestautomation.com/practice-test-login/) using a shared module
  - **Modules**: `common/practice-test-login`

## CI/CD workflows

- [Amazon Linux](.github/workflows/test-amazon-linux.yml)
- [AI explore (generate tests)](.github/workflows/ai-explore.yml)
- [AI classify (categorize failures)](.github/workflows/ai-classify.yml)
- [AI triage demo](.github/workflows/test-ai-heal-demo.yml)
- [AI-selected tests with a cached code index](.github/workflows/test-ai-select.yml)
- [AI-selected tests with dynamic GitHub Actions shards](.github/workflows/test-ai-select-dynamic.yml)
- [Buildkite AI triage demo](.buildkite/triage-demo.yml)
- [CSV inputs](.github/workflows/test-pr-inputs.yml)
- [Multiple projects](.github/workflows/test-pr-multi-project.yml)
- [Sharding](.github/workflows/test-pr-sharding.yml)
- [Run in a PR](.github/workflows/test-pr.yml)
- [Queue in cloud](.github/workflows/test-prod.yml)
- [CircleCI](.circleci/config.yml)

## AI explore, classify, and triage

These three agents can each run autonomously in GitHub Actions. Explore and
classify are in beta — [contact Momentic](https://momentic.ai/sales) to enable
them for your organization first.

### Explore — generate tests from code changes

The [explore workflow](.github/workflows/ai-explore.yml) runs the explore agent,
which reads a diff, infers the user journeys it affects, drives them in a real
browser, and opens a pull request with the Momentic tests it builds.

- On a `pull_request`, `momentic ai explore diff` explores just that PR's diff
  and suggests new, updated, or deleted tests for it.
- Run manually (`workflow_dispatch`), `momentic ai explore latest` maps the
  whole app to build a first set of tests for a greenfield project.

Both commands take a repo-specific [`explore-prompt.md`](web/explore-prompt.md)
via `--prompt-file`, which tells the agent which app to drive, how to sign in,
and where to save the tests it writes.

The explore PR is opened by the **Momentic GitHub App**, so install that app on
the repository first. Whether the PR is a draft or ready for review, who is
requested as a reviewer, and auto-close behavior are configured per project in
the Momentic dashboard — not in the workflow file.

### Classify — categorize failures

The [classify workflow](.github/workflows/ai-classify.yml) runs the suite with
`--upload-results`, then runs `momentic ai classify --git-commit "$GITHUB_SHA"`
to label every failure for that commit. Classify uses the run archive, the
test's code-index context, and past run history to assign a category (for
example `TEST_AUTHORSHIP` versus a real product issue) plus a short explanation,
so you triage less by hand. Only failed runs are classified — passing runs are
skipped, so it is a no-op on an all-green run. `--save` writes the result back
to each run in Momentic Cloud so you can read it in the dashboard.

You can also classify a single run or a whole run group:

```bash
npx momentic ai classify <run-id-or-url>
npx momentic ai classify --run-group-id <run-group-id>
```

### Triage — fix failing tests

Triage takes classified failures and either fixes the tests (stale descriptions,
small flow changes, flakes) or flags real product issues. The
[AI triage demo](.github/workflows/test-ai-heal-demo.yml) runs an intentionally
failing test and then `momentic ai triage` against the results; the
[Buildkite triage demo](.buildkite/triage-demo.yml) shows the same on Buildkite.
As with explore, whether triage opens a draft or real PR and who reviews it is
configured in the Momentic dashboard.

## AI Select and the code index

The [AI Select workflow](.github/workflows/test-ai-select.yml) checks out full
git history, installs Momentic's code-index tools, and restores the index from
the GitHub Actions cache. It demonstrates both usage modes:

- `momentic ai select --json` prints the selected tests without running them.
- `momentic run . --ai-select` selects and runs the focused test set, falling
  back to the full in-scope set when it cannot produce a safe selection.

The separate
[dynamic matrix workflow](.github/workflows/test-ai-select-dynamic.yml) runs
`momentic ai select --json` once, converts the selected paths into a GitHub
Actions matrix with
[`build-ai-select-matrix.mjs`](.github/scripts/build-ai-select-matrix.mjs), and
passes each shard's explicit paths to `momentic run`.

The workflow also passes application-specific selection guidance:

```bash
npx momentic ai select --json \
  --prompt "Prioritize authentication, cart state, sorting, and checkout behavior affected by this change."
```

`--prompt` augments Momentic's built-in selection instructions. If AI Select
reports that it must fall back to the full suite, the dynamic workflow's matrix
builder includes every in-scope test instead.

For pull requests, AI Select compares the merge base of the PR's target branch
and `HEAD` through `HEAD`, covering the whole PR. For pushes to `main`, it
compares the push event's previous SHA through `HEAD`, covering only the commits
in that push.

AI Select and App Graph are in alpha.
[Contact Momentic](https://momentic.ai/sales) to join the waitlist before using
this workflow.

## Buildkite triage demo

The Buildkite example at [.buildkite/triage-demo.yml](.buildkite/triage-demo.yml) uses a single command step that installs dependencies, runs `web/autoheal-test-authorship-demo.test.yaml`, and then runs `momentic ai triage --quiet` against the resulting archive.

### Buildkite setup

1. Create a `MOMENTIC_API_KEY` in the Momentic dashboard.
2. Create or reuse a Buildkite pipeline for this repository and point it at `.buildkite/triage-demo.yml`.
3. Provide `MOMENTIC_API_KEY` to jobs either as a Buildkite secret named `MOMENTIC_API_KEY` or through your agent environment hook.
4. Make sure the step's `agents.queue` value matches a queue you actually run. The sample uses `linux-small`.

### Execute it

To run the same demo locally before wiring it into Buildkite:

```bash
cd /Users/jkimling/examples
export MOMENTIC_API_KEY=your_api_key_here
.buildkite/scripts/local-triage-demo.sh
```
