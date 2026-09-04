### Multi-phase or multi-PR plan

Write a plan for work spanning phases or PRs. The plan is the deliverable. Do not implement until the user authorizes execution.

1. Ground the affected code and dependencies. Use **how** where the current session has not traced the system. For parallel exploration, load **spawn-subagent** and follow [the delegation contract](../../../docs/subagents.md). Helpers receive neutral briefs, portable skill paths, and no-edits instructions.
2. Settle empirical questions with a scoped prototype. Record what it proves and what remains unknown. Ask the user about product choices that evidence cannot settle.
3. Split the work into independently verifiable units. Order dependencies explicitly. Name each unit's file scope, behavior, verification, and integration boundary. Parallel writes require explicitly requested or approved worktrees. Otherwise plan sequential writers in one checkout.
4. Write the plan under the repository's `docs/` directory unless the user names another path. Use the skeleton below and remove irrelevant blocks. Match verification to the change. Behavioral work needs real-surface proof. Performance claims need a baseline, repeatable probe, and threshold. Missing access stays `UNAVAILABLE`.
5. Name the Pi parent's execution playbook: [Autopilot-full](autopilot-full.md), [Autopilot-stack](autopilot-stack.md), or [Orchestrate](orchestrate.md). The parent translates its steps into neutral helper briefs. Helpers never load the coordinator playbook.
6. Run the repository's plan validator if available. Otherwise check paths, dependencies, scope, and proof requirements directly. Write through **technical-writing** and **unslop**.
7. Return the plan, verification result, settled decisions, and unresolved questions. Execution and integration remain with the Pi parent. Do not promise unattended continuation after a session ends.

```markdown
# <Project> plan

<What changes, for whom, and the done condition.>

## Execution

- Pi parent playbook: <absolute path>.
- Authorization and user review gates: <actions and boundaries>.
- Checkout ownership: <one writer at a time, or explicitly approved worktrees>.
- Order: <units and dependencies>.

## <Unit>

- Depends on: <unit or none>.
- Scope: <files and symbols>.
- Change: <behavior and data shape>.
- Proof: <command or real surface, expected result, evidence>.
- Performance, when relevant: <baseline, probe, and threshold>.
- Review gate, when required: <what the user reviews before landing>.
- Integration: <verified commit the parent integrates, intended base>.

## Open questions

<Unknowns, prototype evidence, rejected alternatives, and remaining user decisions.>
```
