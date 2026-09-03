# Local Petey diagnostics

`problems.tsv` is the durable problem log, one row per incident with `ts`, `kind`, `problem`, `fix`, `status`, `target`, `trace`. The **debugger** skill owns the format and its per-session sibling beside each Pi session file. `traces/` stores raw evidence. Everything in this directory except this file and `.gitignore` is ignored by git.

Run `/petey-debug [label]` to capture the current parent session. It copies the session JSONL into `traces/` and appends an untriaged `capture` row. Triage by editing that row's `fix`, `status`, and `target`. Redact a copy before sharing a trace. Keep the raw capture unchanged.

`testbed/run.sh <skill> <agent> <fixture>...` copies the fixtures into a throwaway git repo under `testbed/runs/<timestamp>/` and starts Pi there with the skill loaded. Fixtures live in `testbed/fixtures/`. Set `TEST_CMD` for a test-file fixture and `PI_HEADLESS=1` for a non-interactive probe.

```bash
testbed/run.sh no-comments comment-sicko fixtures/commented.ts
TEST_CMD='bun test cart.test.ts' testbed/run.sh no-stupid-tests test-butcher fixtures/stupid-tests/cart.ts fixtures/stupid-tests/cart.test.ts
```
