### Worktree and simulator cleanup

1. Record disk usage and run the repository worktree audit script. Enumerate paths from `git worktree list`.
2. Cross-check candidates against active Pi runs, mission records, branches, PRs, and uncommitted work.
3. Use fresh read-only `scout` lanes for large session or mission evidence. A tool's safe label is advice, not deletion authority.
4. Ask before deleting uncommitted work or any worktree still tied to active work. Name untracked scratch files before removal.
5. Remove only the confirmed set, prune Git metadata, and measure disk usage again.
6. Treat simulator runtimes, derived build data, and package caches as separate cleanup classes with their own authority checks.

Reply with disk usage before and after, reclaimed space, removed paths, and held paths with reasons.
