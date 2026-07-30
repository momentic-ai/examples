This repo has one web application under test: **Swag Labs**, a demo e-commerce
storefront. When tests run, the app is served at the URL below — target it, not
any local dev-server URL.

- Swag Labs — a demo e-commerce store (login, product list, sorting, cart,
  checkout) at https://www.saucedemo.com/. Tests MUST use
  https://www.saucedemo.com/ as their base URL. Sign in first using the module
  named `log-in-username-password` (id: 68aab6c6-21e6-4e0b-a8cf-217765f4fb1f),
  which authenticates as the `standard_user`. That user can reach the full
  storefront: inventory, item detail, cart, and the multi-step checkout.

When identifying changed user journeys, map each in-scope diff to a Swag Labs
flow (auth, product sorting/filtering, cart state, or checkout) so the explorer
drives the right part of the store.

Place new tests in the `web/` folder alongside the existing `*.test.yaml` and
`*.module.yaml` files. HARD RULE: every generated test and module path must be
under `web/`. Reuse the existing modules (`log-in-username-password`,
`add-item-to-cart`, `fill-out-personal-info`) instead of re-authoring their
steps when a journey needs them.

HARD RULE: any throwaway test created as a side effect of exploring must be
written to the gitignored `momentic/junk/` folder. Naming a file `junk-*` does
NOT satisfy this — it must live under `momentic/junk/`.

Quirks to watch out for:
- Swag Labs resets state per session; there is no externally-persisted data to
  randomize.
- `standard_user` is the happy-path account. Do not switch to the
  `problem_user`, `locked_out_user`, or `performance_glitch_user` accounts
  unless a diff specifically targets those behaviors.
