---
name: no-stupid-tests
description: "Spawn Test Butcher on the scoped test files, trim tests that are not worth keeping, then write the real tests it flags as missing. Use for /no-stupid-tests, 'stupid tests', 'slop tests', 'butcher the tests', or before review of any diff that adds or changes tests."
disable-model-invocation: true
---

# No stupid tests

Spawn Test Butcher. Fill the holes it names.

Authoring agents defend their tests the way they defend their comments. A test written by the hand that wrote the code proves the code does what that hand thought. Defer the keep-or-kill judgment to Test Butcher's fresh perspective.

## Scope

Use the caller's named test files, or the test files in the materialized diff, plus the production files they exercise. Name the exact command that runs that scope and nothing more (`bun test <path>`, `pnpm vitest run <file>`, `pytest <file>`). The parent resolves scope and command before launch. Test Butcher never discovers the change set through Git and never guesses the runner.

## Steps

1. Run the scoped command yourself. Green is the precondition. A red suite routes to Bug fix first.
2. Launch one `test-butcher` child through an async `workflowScript` as the sole writer in the target checkout. Pass the named test files, the production files, and the command. Do not restate its rules or select a model.
3. Inspect its report and diff only for the delegation boundary. Only test files changed. No new tests, no rewritten assertions, no renamed cases, no production edits. The command is green after. Resume the same child once with the exact invalid hunk and require restoration. If it fails again, restore only that hunk, report the failed pass, and stop.
4. Accept its keep and delete judgments. Do not re-score survivors.
5. Treat every `MUST KILL` as a structural recommendation, not authority to change application code. When the caller accepts one, run `architect` once if the fix needs a shape, then land the smallest root-cause fix in scope with one writer.
6. Every `NO PROOF` is a hole in the diff's proof. For each accepted flag, write the test red first against the named behavior, then confirm it goes green on the current code (**principle-sequence-verifiable-units**). Delegate to the configured `worker` with the behavior, the symbol, and the command. Review the diff yourself. A `NO PROOF` the caller declines stays in the report as open.
7. Report deletions by smell, survivors, restored hunks, reruns, `MUST KILL` flags and fixes, `NO PROOF` flags and the tests added, and the command result before and after.
