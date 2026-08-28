### Opening a PR

1. Inspect the final diff and confirm the branch contains only the approved scope. Use a separate worktree when unrelated edits exist.
2. Run the packaged parallel cleanup pattern, `unslop`, and `no-comments`. Apply accepted fixes through one writer, then rerun affected checks.
3. Keep commits small, ordered, and independently understandable. Do not stage, commit, push, or open a PR without the caller's authority.
4. Use `type(scope): subject` for titles. Write Why, Scope, Tradeoffs when real, Blast Radius, and Verification sections. State outcomes, not command names alone.
5. Open ready rather than draft. Verify the resulting PR state with `gh pr view`.
6. Opening a PR does not start Babysit. Return the URL and continue the caller's playbook.

A delegated writer returns changed files, checks with exit codes, residual risks, and the PR URL when authorized.
