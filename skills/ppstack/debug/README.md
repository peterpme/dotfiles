# Local Petey diagnostics

`traces/` holds raw session captures from past incidents. `testbed/` runs a sicko or butcher pass on a fixture in a throwaway git repo. Everything in this directory except this file and `.gitignore` is ignored by git.

Improving ppstack from a session goes through `/reflect`, which reads the live transcript. There is no separate problem log. A `problems.tsv` here is the retired log from before that decision.

`testbed/run.sh <skill> <agent> <fixture>...` copies the fixtures into `testbed/runs/<timestamp>/`, initializes git there, and starts Pi with the skill loaded. Fixtures live in `testbed/fixtures/`. Set `TEST_CMD` for a test-file fixture and `PI_HEADLESS=1` for a non-interactive probe.

```bash
testbed/run.sh no-comments comment-sicko fixtures/commented.ts
TEST_CMD='bun test cart.test.ts' testbed/run.sh no-stupid-tests test-butcher fixtures/stupid-tests/cart.ts fixtures/stupid-tests/cart.test.ts
```
