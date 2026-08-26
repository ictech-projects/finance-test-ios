# 07: On-device natural-language transaction entry

**What to build:** A user types or speaks a free-form sentence like "coffee $5.50 at Starbucks yesterday" into the Add Transaction screen, and it parses into a draft transaction (amount, merchant, category guess, date) for the user to confirm.

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] A text entry point on Add Transaction accepts free-form natural language
- [ ] Foundation Models parses the input into amount, merchant/description, and a date, populating the existing form fields
- [ ] Parsing runs on-device (no network call for the parsing step)
- [ ] Ambiguous or unparseable input leaves the form in its normal empty/manual state rather than crashing or silently guessing
