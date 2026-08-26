# 09: Smart category auto-suggestion

**What to build:** While adding a transaction, the category field suggests a likely category based on the user's own transaction history, which the user can accept or override.

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] Entering a description/merchant on Add Transaction surfaces a suggested category before the user manually picks one
- [ ] The suggestion is derived from the user's own past transactions with similar descriptions, not a fixed static mapping
- [ ] The user can override the suggestion with any other category
- [ ] With no transaction history, no suggestion is shown (no crash, no wrong default)
