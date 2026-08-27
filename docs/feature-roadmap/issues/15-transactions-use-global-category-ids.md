# 15: Transactions use global category ids instead of the user's own

**What to build:** Creating a transaction succeeds, and every screen that shows a transaction's
category shows the real category name. Today neither works, because the app sends and matches
the wrong kind of category id.

The backend has two distinct category concepts:

| Concept | Source | Example id |
|---|---|---|
| Global catalog | `GET /categories` (`CategoryResource`) | `01kx5bvwt57jf06wcny42g0mkj` |
| The user's own | `/sync/pull` → `user_categories` (`UserCategoryResource`) | `01m0s1az8672abeymv2v0g7qhs` |

A transaction's `category_id` **must** reference the user's own category. The app uses the
global catalog everywhere in the transaction domain, so:

- Creating a transaction fails with `Validation failed.` /
  `"The selected account or category is invalid."` — reproduced from the app on a real device,
  and proven by replaying the identical `/sync/push` payload with only `category_id` swapped to
  a `user_categories` id, which returned `"status": "applied"`.
- Transactions that *do* exist resolve to "Uncategorized" in the UI, because the display lookup
  is keyed by global ids while stored transactions carry user-category ids.

**The correct source already exists in the app** and is already used by the Categories screen
(`CategoryManagementViewModel`): `UserCategoryRepository.getUserCategories()`, which pulls
`user_categories` via `/sync/pull`. There is no `GET /user-categories` endpoint — `/sync/pull`
is the only source.

**Blocked by:** None (can start immediately)

**Blocks:** Ticket 04 (Siri quick-add expense, [PR #25](https://github.com/ictech-projects/finance-test-ios/pull/25)) — that feature cannot create a transaction until this is fixed.

**Status:** ready-for-agent

- [ ] Creating a transaction from the Add Transaction screen succeeds against the live backend
- [ ] Creating an expense via the Siri/Shortcuts quick-add intent succeeds against the live backend
- [ ] A transaction's category name/icon/colour renders correctly in Records and on Home (not "Uncategorized")
- [ ] The Reports category breakdown attributes transactions to the correct categories
- [ ] The Categories management screen keeps working (it already uses the correct source — don't regress it)

**The four call sites that use the wrong source:**

| Site | Consequence |
|---|---|
| `AddTransactionViewModel` (category picker + `CreateTransaction.categoryId`) | create fails |
| `AddExpenseIntentHandler` (ticket 04) | Siri create fails |
| `CategoryAccountDisplayResolver` ← `HomeViewModel`, `RecordsViewModel` | shows "Uncategorized" |
| `ReportsAggregator` ← `ReportsDefaultRepository` | breakdown unattributed |

**Notes for whoever picks this up:**

- `CategoryAccountDisplayResolver` and `ReportsAggregator` are *typed* to
  `TransactionCategory.Response.CategoryItem`, so this is not a one-line swap — the type flowing
  through those call sites changes to `Sync.Response.UserCategoryItem` (or a shared abstraction
  over both), and their existing tests change with it.
- Worth deciding deliberately whether the global catalog still has any legitimate use in the
  transaction domain, or whether it belongs only to the Categories management screen (where it
  is shown alongside the user's own categories on purpose).
- `Sync.Response.UserCategoryItem` carries `id`, `name`, `type`, `icon`, `color` — the same
  display fields the resolver needs, so no data is lost by switching.
