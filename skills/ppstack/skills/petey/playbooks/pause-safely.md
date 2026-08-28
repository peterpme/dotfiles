### Pause safely

1. Finish or back out of the current atomic step. Start no new work.
2. Use runtime stop controls for children that must stop. Leave safe async work attached to its mission when it should continue.
3. Make edits durable only within existing commit and push authority. Otherwise leave the working tree untouched and record its exact state.
4. Update mission state with the intent, verified progress, current branch and worktree, linked run ids, next ready action, key files, risks, and owner decisions.
5. Write a separate resume note when mission state is unavailable. Point to an existing decision trail instead of duplicating it.

Reply with the current phase, durable state, active runs, tree state, mission or note path, and first resume action.
