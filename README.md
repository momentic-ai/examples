# Examples

This repo contains usage examples and patterns for the [Momentic CLI](https://momentic.ai/docs/quickstart/cli).

## Examples

### Web

- [Web test](web/) — end-to-end tests for [Swag Labs](https://www.saucedemo.com/), a demo e-commerce app. Includes:
  - `standard-user-purchases` — end-to-end checkout flow (add items, verify cart, complete purchase)
  - `cart-and-sorting-behavior` — verifies sorting changes the view without affecting cart state

### Android

- [Android test](android/) — mobile tests for the Google Maps Android app. The APK can be downloaded [here](https://drive.google.com/file/d/1JEagdPUFJ3jr_Ra4q1ghgGmWcaxhIvZf/view?usp=sharing). Includes:
  - `android-google-maps` — searches for Italian restaurants in San Francisco and verifies results and restaurant details

### Multi-project

- [Workspace](multi-project-workspace/) — example of managing multiple projects in a single workspace

## CI/CD workflows

- [Amazon Linux](.github/workflows/test-amazon-linux.yml)
- [CSV inputs](.github/workflows/test-pr-inputs.yml)
- [Multiple projects](.github/workflows/test-pr-multi-project.yml)
- [Sharding](.github/workflows/test-pr-sharding.yml)
- [Run in a PR](.github/workflows/test-pr.yml)
- [Queue in cloud](.github/workflows/test-prod.yml)
- [CircleCI](.circleci/config.yml)
