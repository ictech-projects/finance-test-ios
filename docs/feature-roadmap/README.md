# Feature roadmap tickets

Tracer-bullet tickets covering the AI / Siri / Foundation Models / Widgets / App Intents /
Lock Screen widget / Control Center / Spotlight / Localization feature roadmap, plus fixes
found while building them. Each ticket in `issues/` is a self-contained vertical slice: one
fresh session should be able to pick it up, build it, and demo it without needing the others
open at the same time.

Numbering is dependency order (blockers first) - `NN` is a stable short ID, so referring to
"ticket 07" or "ticket 12" is enough.

| # | Ticket | Blocked by | Status |
|---|---|---|---|
| 01 | [Fix hardcoded currency symbol](issues/01-fix-hardcoded-currency-symbol.md) | None | **Merged** - [PR #27](https://github.com/ictech-projects/finance-test-ios/pull/27) |
| 02 | [Balance/Net Worth Home Screen widget](issues/02-balance-net-worth-widget.md) | None | Ready |
| 03 | [Spending-by-Category + Lock Screen widgets](issues/03-spending-category-and-lock-screen-widgets.md) | 02 | Blocked |
| 04 | [Siri/Shortcuts quick-add expense](issues/04-siri-shortcuts-quick-add-expense.md) | None | **Merged** - [PR #25](https://github.com/ictech-projects/finance-test-ios/pull/25) |
| 05 | [Control Center "Add Expense" control](issues/05-control-center-add-expense-control.md) | 04 | In review |
| 06 | [Siri/Shortcuts balance & spend queries](issues/06-siri-shortcuts-balance-spend-queries.md) | 04 | Ready |
| 07 | [On-device natural-language transaction entry](issues/07-natural-language-transaction-entry.md) | None | Ready |
| 08 | [Receipt scanning → auto-fill](issues/08-receipt-scanning-auto-fill.md) | 07 | Blocked |
| 09 | [Smart category auto-suggestion](issues/09-smart-category-auto-suggestion.md) | None | Ready |
| 10 | [AI monthly spending insights](issues/10-ai-monthly-spending-insights.md) | 07 | Blocked |
| 11 | [Spotlight search for transactions/accounts](issues/11-spotlight-search-transactions-accounts.md) | None | Ready |
| 12 | [Additional language localization](issues/12-additional-language-localization.md) | None | Ready |
| 13 | [Conversational Siri chaining (stretch)](issues/13-conversational-siri-chaining.md) | 04 | Ready (wants 06 first in practice - chaining needs a second intent to chain *to*) |
| 14 | [New-user setup dead ends (currency → account)](issues/14-new-user-setup-dead-ends.md) | None | Ready |
| 15 | [Transactions use global category ids instead of the user's own](issues/15-transactions-use-global-category-ids.md) | None | **Merged** - [PR #26](https://github.com/ictech-projects/finance-test-ios/pull/26) |

**Picking up a ticket:** any ticket whose "Blocked by" tickets are already done is on the
frontier and ready to go - currently that's 02, 06, 07, 09, 11, 12, 13, and 14 (05 is in
review; 01, 04 and 15 are merged). Check a ticket's box items off as you satisfy them; this
repo doesn't yet auto-update ticket status, so mark it done in the file itself when you finish.

Ticket 14's file lives on the `feature/new-user-onboarding-setup` branch and hasn't landed on
`development` yet.

Tickets 14 and 15 were both found while manually verifying ticket 04 against the live backend.
15 was a blocking bug (transaction creation failed outright) and landed first.

### Ticket 04 reference: the App Shortcut phrases

Delivered as `AddExpenseIntent` + `FinanceAppShortcuts` (`Common/AppIntents/`). The exact Siri
phrases registered for it (no manual Shortcut authoring needed - these show up automatically
in the Shortcuts app once the app has launched once):

```
"Log an expense in finance-test-ios"
"Add an expense in finance-test-ios"
"Track an expense in finance-test-ios"
"Record an expense in finance-test-ios"
```

Shortcuts app entry: **Log Expense** (credit-card icon). Saying any phrase, or running the
shortcut manually, prompts for an amount if one wasn't given (App Intents does this natively
for a required, non-optional parameter) and optionally accepts a merchant/note, category, and
account by name.

Published via [`to-tickets`](https://github.com/mattpocock/skills) in local-markdown mode
(no issue tracker is wired up for this repo yet - see `/setup-matt-pocock-skills` if you want
these as real GitHub issues instead).

### Ticket 05 reference: the widget extension

Ticket 05 created the app's first extension target, `finance-test-iosWidgets` (bundle id
`com.indie.finance-test-ios.Widgets`, `@main` is `FinanceWidgetBundle`). Tickets 02 and 03 should
add their widgets to that same bundle rather than making another target.

Code shared between the app and the extension lives in `finance-test-iosShared/` - a third
synchronized folder compiled into both targets. The extension links none of the app's
networking/repository code, so everything in there has to stay Foundation-only.
