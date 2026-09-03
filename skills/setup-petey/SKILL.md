---
name: setup-petey
description: Install or verify Petey's tracked Pi model routing. Use when setting up Petey, changing role routing, or checking role models after a Pi restart.
disable-model-invocation: true
---

# Set up Petey

Use `pi/settings.json` as the routing source. This skill does not carry a second routing table.

## Apply

1. Read `pi/settings.json`, the live Pi settings file, and `pi/models.json`. Preserve every unrelated live setting. Merge only the tracked top-level settings and `subagents.agentOverrides` entries into the canonical file.
2. Show every agent override with its model, thinking level, context, tools, and fallback status. Apply changes named in the invocation. For a bare `/setup-petey`, ask whether to keep the displayed mapping or change specific roles. The checked-in settings are the defaults. The skill carries no fallback table.
3. Run `pi --list-models`. Resolve every configured override model to an exact provider and model row. Stop before writing if any selector is missing or ambiguous.
4. Run a tiny no-tools launch for each distinct selector. A registry row without a successful launch is not available. Keep native priority mode off unless its supported provider selector passes this probe.
5. Confirm implementation and Grok review overrides have an empty fallback list. Confirm retrieval, research, implementation, review, prose, comment cleanup, and `council-sol` use fresh context. Confirm `oracle` uses forked context. Confirm read-only profiles have no mutation tools and `comment-sicko` and `test-butcher` have only the mutation tools their passes require.
6. Run `bash install.sh skills`. This preserves unrelated Pi skills, links the canonical settings and model registry, and removes retired duplicate agents.
7. Report the exact selectors checked and tell the user to restart Pi. Do not claim the live runtime changed before restart.

## Verify after restart

1. Run the package doctor and live model report.
2. Probe each configured role with a bounded task. Inspect its resolved model, thinking level, context, tools, fallback status, and priority-mode status in the runtime receipt.
3. For `scout`, verify read-only tools, bounded returned text, and no project writes. For `researcher`, require source citations. For implementation and review, use a disposable worktree or a read-only task. For council runs, give every selected advisor the same neutral decision brief and confirm `oracle` appears only when inherited context matters.
4. Run a malformed workflow validation probe and confirm it starts no child. Run one async workflow and confirm completion delivery reaches the parent without status polling or transcript scraping.
5. Save run ids and receipts under ignored `skills/ppstack/debug/traces/pi-only-eval/`. Record failures and fixes as rows in `skills/ppstack/debug/problems.tsv` through the **debugger** skill's helper.
6. Report failures as runtime failures. Do not rewrite package orchestration to hide them.
