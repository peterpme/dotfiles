---
name: proof-plan
description: "Write the proof before the code: turn a brief or feature request into the checks that will show it works on the real surface, with the evidence each check saves. Use for /proof-plan, 'how will we know it works', 'define done', 'verification plan', or after /grill and before building anything."
disable-model-invocation: true
---

# Proof plan

Decide how the work will be proven before anyone builds it. Building first and bolting verification on later is the failure this skill exists to prevent. The plan is what Feature step 6 runs and what the PR's Verification section reports.

## Inputs

A brief from **grill**, or the feature request plus this session's trace of the affected code. It needs a done predicate. If there is none, run grill round one for the predicate alone, then continue.

## Steps

1. **Find the surface and its verifier.** The project's verification skill first (`.agents/skills/verify-<app>/`, made by **create-verification-skill**) and its feature map. Name the exact CLI commands that reach the feature. No verification skill means either run **create-verification-skill** now or record `UNAVAILABLE` for that surface and say what would be proven by hand instead. Never claim a live proof you cannot drive.
2. **Turn the predicate into checks.** One box per observable behavior the change adds or alters. Each box names the drive steps as verifier commands, the evidence artifact (screenshot path, log line, response body, database row), and the pass predicate. Include the regression lane against trunk. Run the same scenario on trunk and on head. When trunk lacks the feature, record that fact and gate the behavior the diff adds instead of inventing a trunk result.
3. **Decide which tests earn their place.** A test earns its place when one realistic code change turns it red and a reader can name the behavior from its name (**no-stupid-tests**). List those tests, to be written red first (**tdd**, **principle-sequence-verifiable-units**). Prefer no new test over a bad test.
4. **Perf, when the change touches a path the user waits on.** Metric, probe, trunk baseline measured first, and the rule with the number that fails. Otherwise write `n/a: <reason>`.
5. **Side effects.** Rows inserted, files written, messages sent, state reset. Each one gets a box that reads the real thing, not a proxy (**principle-prove-it-works**).
6. **Write the plan** as a `## Proof` section appended to the brief, or to `docs/briefs/<slug>.md` when there is no brief. Checkboxes only. A box with no evidence path is not a box.

```markdown
## Proof

Tests alone are not sufficient verification. Done means every box below is checked with its evidence.

- [ ] Trunk lane. <scenario> on trunk. Expect <absent or old behavior>. Evidence: <path>.
- [ ] Live 1. <scenario>. Drive: `<verifier command>`. Evidence: <path>. Pass when <predicate>.
- [ ] Live 2. ...
- [ ] Unit. <test file and case>, red first. Run `<command>`.
- [ ] Perf. Metric <what>. Probe <command>. Baseline <trunk value>. Rule <fails when>. Or `n/a: <reason>`.
- [ ] Side effects. <what is read and where>.
```

7. **Hand off.** Feature step 6 works the boxes in order. Opening a PR copies each box and its result into `## Verification`. An unchecked box means the reply says `implemented, unverified` per the petey **Done** rule. Nobody relaxes a box to declare victory.

**Reply:** the plan path, how many boxes and which are `UNAVAILABLE`, the tests that earned their place, and the first thing to build.
