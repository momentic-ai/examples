# Momentic examples

This repository contains working Momentic setups for web, Android, iOS,
multi-project workspaces, and common CI systems. Every project uses the CLI
versions pinned in the root [`package.json`](package.json), V2 test files, and AI Action V3
shorthand.

## Prerequisites

- Node.js 22.12 or later in the Node.js 22 line, or Node.js 24 or later
- npm 10.9.2 or a compatible npm 10 release
- A `MOMENTIC_API_KEY` for test execution and AI commands
- An Android or iOS target for mobile tests, either in Momentic Cloud or on a
  local emulator

Install every CLI from the repository root:

```bash
npm ci
```

The root package installs:

| Package | Purpose |
| --- | --- |
| `momentic` | Run, lint, select, classify, and triage web tests |
| `momentic-mobile` | Run and lint Android and iOS tests |
| `@momentic/wizard` | Create Momentic projects and configuration files |
| `qa` | Start and manage Mo QA sessions |

Set your API key before running tests:

```bash
export MOMENTIC_API_KEY=your_api_key_here
```

Lint every example from the repository root:

```bash
npm run lint
```

You can also lint one group:

```bash
npm run lint:web
npm run lint:mobile
npm run lint:workspace
```

## Web examples

The web project targets the
[Vercel Store demo](https://demo.vercel.store/).

| Example | Description |
| --- | --- |
| [`add-products-to-cart.test.yaml`](web/add-products-to-cart.test.yaml) | Calls a shared module twice, changes quantity, and checks the cart subtotal |
| [`search-and-cart-behavior.test.yaml`](web/search-and-cart-behavior.test.yaml) | Searches for a hoodie, opens the product, and checks the cart |
| [`input-from-csv-test.test.yaml`](web/input-from-csv-test.test.yaml) | Declares input defaults and accepts rows from `data/inputs.csv` |
| [`autoheal-test-authorship-demo.test.yaml`](web/autoheal-test-authorship-demo.test.yaml) | Intentionally fails so classification and triage have a test-authorship issue to inspect |
| [`add-product-to-cart.module.yaml`](web/add-product-to-cart.module.yaml) | Reusable product search and add-to-cart module |

Install Chromium once, then run a web test:

```bash
cd web
npx momentic install-browsers chromium
npx momentic run add-products-to-cart.test.yaml
```

Run the normal web examples together. This excludes the intentional triage
failure:

```bash
npx momentic run . --exclude autoheal-test-authorship-demo
```

Run the CSV example with the included fixture:

```bash
npx momentic run \
  --input-csv data/inputs.csv \
  input-from-csv-test.test.yaml
```

The CSV headers match the test parameters:

```csv
QUERY,PRODUCT
shirt,Acme Circles T-Shirt
```

## Android examples

| Example | Description |
| --- | --- |
| [`android-contacts.test.yaml`](android/android-contacts.test.yaml) | Creates a contact, checks its details, and prepares a call without placing it |
| [`android-google-maps.test.yaml`](android/android-google-maps.test.yaml) | Searches for restaurants with a shared module and checks directions and reviews |
| [`search-restaurants.module.yaml`](android/search-restaurants.module.yaml) | Reusable cuisine and city search module |

Run a test on the mobile target configured for your Momentic account:

```bash
cd android
npx momentic-mobile run android-contacts.test.yaml
```

Run the Google Maps example:

```bash
npx momentic-mobile run android-google-maps.test.yaml
```

The Google Maps test uses the `google-maps` asset channel and the `latest` tag.
Change `defaultChannel` and `defaultTag` in the test if your account uses
different asset names.

For a local Android Virtual Device (AVD), provide its ID and an APK when the
test needs an app that is not already installed:

```bash
npx momentic-mobile run android-google-maps.test.yaml \
  --local-avd-id Pixel_8_API_35 \
  --local-apk-path /absolute/path/to/app.apk
```

## iOS examples

| Example | Description |
| --- | --- |
| [`dime-app.test.yaml`](ios/dime-app.test.yaml) | Completes onboarding, records an expense, and checks settings |
| [`ios-contacts.test.yaml`](ios/ios-contacts.test.yaml) | Creates a contact and drafts a message without sending it |

Run an iOS test on the mobile target configured for your Momentic account:

```bash
cd ios
npx momentic-mobile run ios-contacts.test.yaml
```

Run the Dime example:

```bash
npx momentic-mobile run dime-app.test.yaml
```

The Dime test uses the `dime` asset channel. For a local simulator, provide a
device type, runtime, and app path:

```bash
npx momentic-mobile run dime-app.test.yaml \
  --local-ios-device-type "iPhone 16 Pro" \
  --local-ios-version 26.4 \
  --local-app-path /absolute/path/to/Dime.app
```

## Multi-project workspace

The workspace shows three Momentic projects sharing one root dependency
installation:

| Project | Description |
| --- | --- |
| [`apps/dashboard`](multi-project-workspace/apps/dashboard) | Runs a Google search test from its own config |
| [`apps/marketing`](multi-project-workspace/apps/marketing) | Reads values from an env file, interpolation, and the shell |
| [`qa`](multi-project-workspace/qa) | Calls a module from `common/` against Practice Test Automation |

Install Chromium from the workspace, then run each project:

```bash
cd multi-project-workspace
npx momentic install-browsers chromium
```

Run the marketing example by project name and test-name substring:

```bash
VAR_FROM_SHELL=test-var-from-shell \
  npx momentic run --filter marketing variable
```

Run the QA project with an explicit config:

```bash
npx momentic run --config qa/momentic.config.yaml .
```

Run the dashboard project from its directory:

```bash
cd apps/dashboard
npx momentic run google-search.test.yaml
```

## AI test selection

AI test selection reads the current Git diff and returns the tests affected by
the change. Fetch the base branch history before running it locally:

```bash
git fetch origin main
cd web
npx momentic ai select . \
  --base origin/main \
  --json \
  --prompt "Prioritize product search, product details, and cart behavior affected by this change."
```

To select and run tests in one command:

```bash
npx momentic run . --ai-select
```

The examples include two GitHub Actions implementations:

- `test-ai-select.yml` selects and runs tests in one job.
- `test-ai-select-dynamic.yml` converts the JSON selection into a dynamic
  shard matrix.

AI test selection and App Graph are in alpha.
[Contact Momentic](https://momentic.ai/sales) to request access.

## Classification and triage

The web config enables in-run failure classification. Run the intentional
test-authorship failure and save its artifacts:

```bash
cd web
npx momentic run autoheal-test-authorship-demo.test.yaml \
  --output-dir test-results/triage-demo \
  --upload-results
```

Run triage against those artifacts:

```bash
npx momentic ai triage test-results/triage-demo \
  --yes \
  --quiet
```

The Buildkite example wraps these commands in
[`local-triage-demo.sh`](.buildkite/scripts/local-triage-demo.sh):

```bash
.buildkite/scripts/local-triage-demo.sh
```

## Sharding and result merging

Run one half of the web suite:

```bash
cd web
npx momentic run . \
  --exclude autoheal-test-authorship-demo \
  --shard-index 1 \
  --shard-count 2 \
  --output-dir test-results/shard-1
```

Run the second half by changing both `1` values to `2`. Merge the completed
result directories from the `web` directory:

```bash
npx momentic results merge test-results \
  --output-dir test-results/merged
npx momentic results upload test-results/merged
```

The `test-pr-sharding.yml` workflow runs both shards as a matrix, downloads
their artifacts, merges them, and uploads one result set.

## Create a new project

Run the wizard from the repository root and choose the target platform:

```bash
npx momentic-wizard --platform web --cwd ./path/to/project
npx momentic-wizard --platform android --cwd ./path/to/project
npx momentic-wizard --platform ios --cwd ./path/to/project
```

The wizard writes a commented `momentic.config.yaml` and offers the setup
options supported by the installed CLI version.

## Run Mo

The root `qa` package provides the Mo CLI. Sign in once, then start a session
with a concrete testing task:

```bash
npx qa login
npx qa start "Test the checkout flow and report reproducible bugs"
```

Use the session ID returned by `start` to inspect or wait for the run:

```bash
npx qa status SESSION_ID
npx qa wait SESSION_ID
npx qa report SESSION_ID
```

## CI examples

| File | What it demonstrates |
| --- | --- |
| [`.github/workflows/test-pr.yml`](.github/workflows/test-pr.yml) | Web and Android tests on pull requests |
| [`.github/workflows/test-prod.yml`](.github/workflows/test-prod.yml) | Cloud web queueing and Android runs on `main` |
| [`.github/workflows/test-pr-inputs.yml`](.github/workflows/test-pr-inputs.yml) | CSV inputs |
| [`.github/workflows/test-pr-multi-project.yml`](.github/workflows/test-pr-multi-project.yml) | Multiple configs with one root install |
| [`.github/workflows/test-pr-sharding.yml`](.github/workflows/test-pr-sharding.yml) | Parallel shards and result merging |
| [`.github/workflows/test-ai-select.yml`](.github/workflows/test-ai-select.yml) | AI test selection and focused execution |
| [`.github/workflows/test-ai-select-dynamic.yml`](.github/workflows/test-ai-select-dynamic.yml) | AI-selected dynamic matrix shards |
| [`.github/workflows/test-ai-heal-demo.yml`](.github/workflows/test-ai-heal-demo.yml) | Classification and triage |
| [`.github/workflows/test-amazon-linux.yml`](.github/workflows/test-amazon-linux.yml) | Amazon Linux runner setup |
| [`.circleci/config.yml`](.circleci/config.yml) | CircleCI web test execution |
| [`.buildkite/triage-demo.yml`](.buildkite/triage-demo.yml) | Buildkite classification and triage |
| [`bitrise.yml`](bitrise.yml) | Bitrise mobile test execution |

CI installs dependencies from the repository root and invokes the pinned CLIs
with plain `npx`.
