# Examples

This repo contains usage examples and patterns for the [Momentic CLI](https://momentic.ai/docs/quickstart/cli).

## Examples

### Web

- [Web test](web/) — end-to-end tests for [Swag Labs](https://www.saucedemo.com/), a demo e-commerce app. Includes:
  - `standard-user-purchases` — end-to-end checkout flow (add items, verify cart, complete purchase)
  - `cart-and-sorting-behavior` — verifies sorting changes the view without affecting cart state
  - `autoheal-test-authorship-demo.test.yaml` — intentionally fails in a way that should classify as `TEST_AUTHORSHIP` and is meant to be run by the dedicated AI-heal demo workflow
  - `kitchen-sink.test.yaml` — reference test that exercises every web v2 step type and every variant of each. Disabled by default; flip `disabled: false` to run.

### Android

- [Android test](android/) — mobile tests for the Google Maps Android app. The APK can be downloaded [here](https://drive.google.com/file/d/1JEagdPUFJ3jr_Ra4q1ghgGmWcaxhIvZf/view?usp=sharing). Includes:
  - `android-google-maps` — searches for Italian restaurants in San Francisco and verifies results and restaurant details
  - `kitchen-sink.test.yaml` — reference test that exercises every Android mobile v2 step type and every variant of each. Uses the Google Contacts app as the test surface.

### iOS

- [iOS test](ios/) — mobile tests for the iOS Contacts and Dime apps. Includes:
  - `ios-contacts` — creates a contact and drafts a text message
  - `dime-app` — exercises the Dime expense tracker
  - `kitchen-sink.test.yaml` — reference test that exercises every iOS mobile v2 step type and every variant of each. Uses the Apple Contacts app as the test surface.

### Multi-project

- [Workspace](multi-project-workspace/) — example of managing multiple projects in a single workspace

## CI/CD workflows

- [Amazon Linux](.github/workflows/test-amazon-linux.yml)
- [AI heal demo](.github/workflows/test-ai-heal-demo.yml)
- [CSV inputs](.github/workflows/test-pr-inputs.yml)
- [Multiple projects](.github/workflows/test-pr-multi-project.yml)
- [Sharding](.github/workflows/test-pr-sharding.yml)
- [Run in a PR](.github/workflows/test-pr.yml)
- [Queue in cloud](.github/workflows/test-prod.yml)
- [CircleCI](.circleci/config.yml)
