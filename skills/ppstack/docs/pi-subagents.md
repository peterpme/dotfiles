# Pi subagents, for Petey

Source of truth for how Pi children work. Upstream is [nicobailon/pi-subagents](https://github.com/nicobailon/pi-subagents). We do not fork that package. The installed package owns execution, workflows, contexts, worktrees, missions, councils, waiting, status, recovery, and result delivery.

The parent session is Petey. A subagent is a child Pi process with its own tools and prompt.

## Builtins

The package supplies the normal roles below. Model routing and role overrides live in `pi/settings.json`, not in skill prose or per-run selectors.

| Name | Job | Writes? | Petey use |
|---|---|---|---|
| `scout` | Local recon and compressed handoff | no after our override | Cross-cutting codebase retrieval |
| `worker` | Implement an approved plan | yes | Standard implementation |
| `reviewer` | Independent evidence review | no | Reviews, cross-judging, council counterpoint |
| `oracle` | Second opinion and drift detection | bash only, prompt forbids edits | Inherited-context judgment |
| `delegate` | Thin parent-shaped helper | yes | Only when parent-like behavior is intentional |
| `researcher` | Web and documentation brief | notes only | Cited external research |

The package also exposes external CLI adapters (`claude-code`, `codex-exec`, `cursor-agent`, and their `-writer` variants). They take no model or thinking options, so they cannot pin Fable 5.1 or Sol. The **peer-review** skill uses bash lanes for `claude` and `codex` instead, and the configured `reviewer` role for Grok. Never invoke the adapters. The peer-review lanes replace them.

## Discovery

Lowest to highest priority:

1. Package builtins.
2. Other installed packages.
3. `~/.pi/agent/agents/**/*.md`.
4. Project `.pi/agents/**/*.md`.

ppstack agents are linked into the user agent directory. The same runtime `name:` shadows the lower-priority definition. `subagents.agentOverrides` in Pi settings patches a role without copying its agent file.

Do not eject a builtin unless its persona must change. Keep deployment choices in settings and specialist behavior in agent files.

## House agents

| Name | Parent skill | Job | Mutation boundary |
|---|---|---|---|
| `petey-agent` | playbooks | Fresh packet-bound writer; no inherited skills or principles | Normal writer tools |
| `comment-sicko` | **no-comments** | Scoped comment deletion with `how` and `why` available | Comments and resulting whitespace only |
| `test-butcher` | **no-stupid-tests** | Keeps one cut per function, trims tests not worth keeping, flags `MUST KILL` and `NO PROOF` | Test files only, deletions only |
| `council-sol` | councils | Fresh read-only Sol council judgment | No writes |

`comment-sicko` reports structural `MUST KILL` findings but never implements them. The parent verifies only the scoped diff boundary. It does not reimplement Comment Sicko's keep list.

`test-butcher` deletes tests and flags holes. It never writes a test. The parent fills each accepted `NO PROOF` red first through a writer, and verifies only the scoped diff boundary and that the named test command is green after.

## What Petey should call

| Job | Agent |
|---|---|
| Narrow local lookup | Parent `grep`, `find`, and `read` |
| Cross-cutting local retrieval | `scout` |
| Web research | `researcher` |
| Standard implementation | `worker` |
| Packet-bound implementation or prose | `petey-agent` |
| Evidence review | `reviewer` |
| Comment pass | `comment-sicko` |
| Test pass | `test-butcher` |
| Inherited-context judgment | `oracle` |
| Fresh Sol council judgment | `council-sol` |
| Second opinion from another model family | **peer-review**: bash `claude` on Fable 5.1, bash `codex` on Sol, `reviewer` on Grok 4.6 |

Use one async `workflowScript` for composed work. Do not select models per run. Fresh children receive standalone briefs. Give each writer its own checkout or managed worktree.

A writer brief has this packet.

```text
TRACE: paths, symbols, runtime path, and settled decisions
FIRST UNIT: smallest behavior to implement
WRITE SEAM: owned files or module boundary
FIRST CHECK: exact command or surface for that unit
EXPAND ONLY WHEN: failed check or missing fact that permits widening
```

The writer starts at `FIRST UNIT`. It does not repeat broad discovery or redesign settled decisions. Adjacent reads must serve the named write seam. Before a writer starts in a new worktree, the parent verifies dependencies and proves `FIRST CHECK` starts there.

## Skill locations

Petey's inline Principles section is the parent's upfront index. It does not require every principle leaf at startup. When a principle applies to the parent's decision, the parent reads its exact `available_skills` location. Installed principle skills are siblings of `petey`, not children under `petey/principles/`. Never infer a skill path from its name.

Children do not apply principles. `petey-agent` sets `inheritSkills: false` and loads no skills. The parent encodes settled principle decisions in the writer packet.

## Evidence boundary

The parent materializes named paths, patches, command output, and test results before review. Read-only children return `MISSING EVIDENCE` when a required artifact is absent. They do not reconstruct change state through `.git` internals.

Keep discovery inside the repository and named configuration directories. Never widen a failed resource lookup to the user's home directory. Agent profiles own their policy; the parent normally has no reason to locate or read their source files.

## Bounds

Children run until they finish their brief. The one fixed deadline is **peer-review**'s 15-minute lane cap (`timeoutMs: 900000`). Stalled work is caught by the inspection below, not by a clock.

Inspect active async work every minute with `subagent({ action: "status", id })`. Say whether work is in discovery, design, implementation, verification, or done. Done follows verification only. Name elapsed time, artifacts, and whether implementation has started. Stop or steer work that repeats repository discovery, exceeds its named source seam, or has not produced a concrete artifact for that phase.

## How to check

Start a new Pi session after settings or agent changes.

```text
/subagents-models
/subagents-models reviewer
```

Then list available agents and run bounded probes:

```text
Use scout to map one named repository directory. Do not edit.
Use researcher to answer one documentation question with citations.
Run Comment Sicko on one tracked fixture and inspect the host-produced diff.
Run Test Butcher on one fixture with its test command and inspect the host-produced diff.
```

A runtime receipt must show the expected model, thinking level, context, tools, and fallback behavior. A settings change is pending until a restarted Pi process reports it.
