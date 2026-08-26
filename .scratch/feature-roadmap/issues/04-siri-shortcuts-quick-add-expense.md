# 04: Siri/Shortcuts quick-add expense

**What to build:** A user says "Hey Siri, log a $12 lunch expense" (or runs it from Shortcuts), and a real expense transaction is created without opening the app.

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] An App Intent exists that creates a transaction given an amount, and optionally a category/merchant/account
- [ ] The intent is invocable via Siri and appears in the Shortcuts app
- [ ] Running the intent creates a transaction visible in Records afterward
- [ ] Missing/ambiguous parameters (e.g. no amount) prompt the user rather than silently failing
