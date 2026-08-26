# 10: AI monthly spending insights

**What to build:** The Reports screen shows a short generated narrative summarizing the period's spending (e.g. "You spent 20% more on dining than last month").

**Blocked by:** 07 (On-device natural-language transaction entry)

**Status:** ready-for-agent

- [ ] Reports displays a generated text summary alongside the existing charts/breakdown for the selected period
- [ ] The summary reflects the actual period-over-period numbers already computed by the Reports aggregator
- [ ] Generation runs on-device via Foundation Models, reusing #07's session wrapper
- [ ] A period with no prior data to compare against still shows a sensible summary (no crash, no nonsensical comparison)
