# Local Petey diagnostics

`PETEY-LOG.md` indexes incidents and fixes. `traces/` stores raw evidence. Both paths are ignored by Git.

Run `/petey-debug [label]` to capture the current parent session. Redact a copy before sharing a trace. Keep the raw capture unchanged.

`sicko-testbed/run.sh <skill> <agent> <fixture>...` copies the fixtures into a throwaway git repo under `sicko-testbed/runs/<timestamp>/` and starts Pi there with the skill loaded. Fixtures live in `sicko-testbed/fixtures/`. Set `TEST_CMD` for a test-file fixture and `PI_HEADLESS=1` for a non-interactive probe. Everything in this directory except this file and `.gitignore` is ignored.
