# 14: New-user setup dead ends (currency → account)

**What to build:** A freshly registered user can get from "just signed up" to "logged my first
expense" without hitting a dead end. Today they cannot: the backend reports
`on_board_required: true` with zero user-currencies and zero accounts, and every entry point
refuses them with an error that names a prerequisite but doesn't take them to it.

Observed on a real device against the live backend (2026-08-27):

- More → Accounts → add account → **"Couldn't Save — Add a currency before creating an
  account."** No way to act on it from that screen; the user has to already know the currency
  screen exists under More → Currency.
- Siri "Log an expense in finance-test-ios" → **"Add an account in the app before logging an
  expense."** Following that instruction leads straight into the dead end above.

So a new user is told to do something they cannot do, twice, with no route forward. The
currency and account screens themselves both work fine (More → Currency → "Add Currency"
against a 33-currency catalog, then More → Accounts) — the gap is purely that nothing guides
the user there, and the errors are terminal instead of actionable.

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] A newly registered account can reach a state where logging a transaction succeeds, without the user needing prior knowledge of the currency-before-account ordering
- [ ] The "add a currency first" condition is actionable where it is raised — the user can get to currency setup from the point of failure rather than only reading about it
- [ ] Siri/Shortcuts quick-add (ticket 04) surfaces a next step the user can actually follow when setup is incomplete, rather than pointing at a blocked action
- [ ] An already-set-up user sees no new prompts or interruption in either flow

**Notes for whoever picks this up:**

- The backend exposes `on_board_required` on `GET /auth/profile` — worth deciding whether this
  should drive a real first-run setup flow rather than patching each error site individually.
- `POST /user-currencies` takes `currency_id` (required), plus optional `exchange_rate` and
  `is_anchor`; the app already has `UserCurrencyRepository.createUserCurrency`, and
  `GET /currencies` returns a 33-entry catalog, so no new data layer work is needed.
- The existing error text comes from `AccountFormViewModel`'s default-currency resolution and
  from `FinanceIntentError.noAccountAvailable` (ticket 04). Both are accurate, just terminal.
- Don't auto-pick a currency on the user's behalf without a product decision — which currency
  a user anchors to is meaningful, not a detail to guess.
