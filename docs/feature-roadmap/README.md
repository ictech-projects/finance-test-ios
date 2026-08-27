# Feature roadmap tickets

Thirteen tracer-bullet tickets covering the AI / Siri / Foundation Models / Widgets / App
Intents / Lock Screen widget / Control Center / Spotlight / Localization feature roadmap.
Each ticket in `issues/` is a self-contained vertical slice: one fresh session should be able
to pick it up, build it, and demo it without needing the others open at the same time.

Numbering is dependency order (blockers first) - `NN` is a stable short ID, so referring to
"ticket 07" or "ticket 12" is enough.

| # | Ticket | Blocked by |
|---|---|---|
| 01 | [Fix hardcoded currency symbol](issues/01-fix-hardcoded-currency-symbol.md) | None |
| 02 | [Balance/Net Worth Home Screen widget](issues/02-balance-net-worth-widget.md) | None |
| 03 | [Spending-by-Category + Lock Screen widgets](issues/03-spending-category-and-lock-screen-widgets.md) | 02 |
| 04 | [Siri/Shortcuts quick-add expense](issues/04-siri-shortcuts-quick-add-expense.md) | None |
| 05 | [Control Center "Add Expense" control](issues/05-control-center-add-expense-control.md) | 04 |
| 06 | [Siri/Shortcuts balance & spend queries](issues/06-siri-shortcuts-balance-spend-queries.md) | 04 |
| 07 | [On-device natural-language transaction entry](issues/07-natural-language-transaction-entry.md) | None |
| 08 | [Receipt scanning → auto-fill](issues/08-receipt-scanning-auto-fill.md) | 07 |
| 09 | [Smart category auto-suggestion](issues/09-smart-category-auto-suggestion.md) | None |
| 10 | [AI monthly spending insights](issues/10-ai-monthly-spending-insights.md) | 07 |
| 11 | [Spotlight search for transactions/accounts](issues/11-spotlight-search-transactions-accounts.md) | None |
| 12 | [Additional language localization](issues/12-additional-language-localization.md) | None |
| 13 | [Conversational Siri chaining (stretch)](issues/13-conversational-siri-chaining.md) | 04 |
| 14 | [New-user setup dead ends (currency → account)](issues/14-new-user-setup-dead-ends.md) | None |
| 15 | [Transactions use global category ids instead of the user's own](issues/15-transactions-use-global-category-ids.md) | None — **blocks 04** |

**Picking up a ticket:** any ticket whose "Blocked by" tickets are already done is on the
frontier and ready to go - currently that's 01, 02, 07, 09, 11, 12, 14, and 15. Check a ticket's
box items off as you satisfy them; this repo doesn't yet auto-update ticket status, so mark it
done in the file itself when you finish.

Tickets 14 and 15 were both found while manually verifying ticket 04 against the live backend —
15 is a blocking bug (transaction creation fails outright), so it lands before ticket 04's PR.

Published via [`to-tickets`](https://github.com/mattpocock/skills) in local-markdown mode
(no issue tracker is wired up for this repo yet - see `/setup-matt-pocock-skills` if you want
these as real GitHub issues instead).
