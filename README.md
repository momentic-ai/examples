# Examples

This repo contains usage examples and patterns for the [Momentic CLI](https://momentic.ai/docs/quickstart/cli).

## Repository structure

This repo is a [pnpm workspace](https://pnpm.io/workspaces). Each example directory is its own package with its own `package.json`:

- [`web/`](web/) — depends on [`momentic`](https://www.npmjs.com/package/momentic)
- [`ios/`](ios/) — depends on [`momentic-mobile`](https://www.npmjs.com/package/momentic-mobile)
- [`android/`](android/) — depends on [`momentic-mobile`](https://www.npmjs.com/package/momentic-mobile)
- [`multi-project-workspace/`](multi-project-workspace/) — depends on [`momentic`](https://www.npmjs.com/package/momentic)

### Getting started

```bash
pnpm install
```

Running `pnpm install` anywhere in the repo installs dependencies for all workspace packages.

### Upgrading Momentic

Because each example directory has its own `package.json`, you can upgrade the Momentic configuration in place:

```bash
cd web # or ios, android, multi-project-workspace
npx momentic@latest upgrade
```

For the mobile examples, `npx momentic-mobile@latest` provides the equivalent mobile CLI commands.

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
- [AI triage demo](.github/workflows/test-ai-heal-demo.yml)
- [Buildkite AI triage demo](.buildkite/triage-demo.yml)
- [CSV inputs](.github/workflows/test-pr-inputs.yml)
- [Multiple projects](.github/workflows/test-pr-multi-project.yml)
- [Sharding](.github/workflows/test-pr-sharding.yml)
- [Run in a PR](.github/workflows/test-pr.yml)
- [Queue in cloud](.github/workflows/test-prod.yml)
- [CircleCI](.circleci/config.yml)

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
export MOMENTIC_API_KEY=your_api_key_here
.buildkite/scripts/local-triage-demo.sh
```
