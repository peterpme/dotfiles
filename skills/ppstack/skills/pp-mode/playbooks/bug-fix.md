### Bug fix

**You own this task.** Reproduce, then fix. Belt-and-suspenders that "might help" does not ship.

1. Reproduce it yourself. A bug you cannot reproduce, you cannot prove fixed.
2. Form hypotheses and rule them out until one survives. Get runtime evidence. Do not guess.
3. Plan the smallest fix the evidence justifies. Name the data shape if you are changing types or control flow.
4. Delegate implementation to `pp-agent` if present, else `worker`. Review the diff.
5. Verify on the same surface. The original repro now passes.
6. Run **Opening a PR**.

**Reply:** what was broken, root cause, fix, how you verified.
