### Feature

**You own the design.** Name the shape, then implement.

1. Walk the affected subsystem. Cite the files that will change.
2. Name the data shape and its organizing structure before writing logic.
3. Throughput checkpoint as four todos. Use `n/a: <reason>` rather than dropping one:
   - Blocking first steps.
   - Independent workstreams.
   - Shared mutable state. Split it if two writers would collide.
   - Smallest safe decomposition. If one worker is best, name why.
4. Delegate implementation to `pp-agent` if present, else `worker`. Scope: files, named shape, success criteria. Review the diff.
5. Verify on the real artifact.
6. Run **Opening a PR**.

**Reply:** what you built, what you chose and why, open decisions.
