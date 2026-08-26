# 01: Fix hardcoded currency symbol

**What to build:** Every screen that displays a monetary amount shows it formatted with the user's actual selected currency (symbol, decimal/thousands separators), not a hardcoded "$".

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] Add Transaction, Account forms, Home, Records, and Reports all render amounts through a currency-aware formatter driven by the user's selected currency
- [ ] Switching the user's currency changes the symbol/formatting shown across the app without an app restart
- [ ] A non-USD currency (e.g. EUR, IDR) displays its correct symbol and separator conventions, not "$"
