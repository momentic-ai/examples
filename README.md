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
- [AI heal demo](.github/workflows/test-ai-heal-demo.yml)
- [CSV inputs](.github/workflows/test-pr-inputs.yml)
- [Multiple projects](.github/workflows/test-pr-multi-project.yml)
- [Sharding](.github/workflows/test-pr-sharding.yml)
- [Run in a PR](.github/workflows/test-pr.yml)
- [Queue in cloud](.github/workflows/test-prod.yml)
- [CircleCI](.circleci/config.yml)
