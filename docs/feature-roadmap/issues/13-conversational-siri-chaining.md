# 13: Conversational Siri chaining (stretch)

**What to build:** A user makes a multi-step request to Siri (e.g. "add a $20 grocery expense, then tell me my remaining budget for the month") and Siri chains the app's individual intents to fulfill it.

**Blocked by:** 04 (Siri/Shortcuts quick-add expense)

**Status:** ready-for-agent

- [ ] At least one multi-step request successfully chains two or more of the app's App Intents in a single Siri interaction
- [ ] Siri's response reflects the actual result of the chained actions
- [ ] A request Siri cannot fully resolve degrades gracefully (asks for clarification) rather than silently failing partway
