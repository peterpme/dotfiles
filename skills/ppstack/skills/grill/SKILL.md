---
name: grill
description: "Interview the user round by round until a plan, feature, or idea has no silently assumed branch left, then hand back a design brief with a done predicate. Use for /grill, 'grill me', 'think this through with me', 'poke holes in this', or any new project or feature the user has not fully specified."
disable-model-invocation: true
---

# Grill

Interview the user until the design has no branch you are guessing at. The output is a brief that the Feature playbook and the **proof-plan** skill consume. Not code. Not a plan file with steps.

## The tree

Map the idea as a design tree. Every decision branches into the decisions that hang off it. Work the tree in rounds. The frontier is every decision whose prerequisites are already settled, the questions you can ask now without guessing at answers you have not heard. Ask the whole frontier in one round, numbered, each with your recommended answer. Then wait. Each answer reshapes the tree and pushes the frontier outward. A question whose answer depends on another question still open in this round belongs to a later round.

Format a round like this.

```
❓ **Q1** - **<question title>**: <question body, choices when they help>

➡️ <your recommended answer, and why in one line>

---

❓ **Q2** - ...
```

## Three kinds of question

Sort every candidate question before you ask it.

- **A fact about the environment.** What the code does today, what the API returns, what the file contains, what the library supports. Yours to find. Use this session's `grep`, `find`, and `read`, or a fresh `scout` for cross-cutting retrieval. Never put a fact to the user. A running lookup is an unsettled prerequisite, so only the questions downstream of it wait.
- **An empirical question.** Does this layout work, is this fast enough, does the library behave that way, does the eval separate. Not the user's either. Route it to the Prototype playbook (`petey/playbooks/prototype.md`) and let the result decide.
- **A product or preference call** no lookup or experiment settles. The user's. Ask it, recommend, wait.

## Strong mode

`/grill strong`, or any grill that **night-watch** starts, drafts each round with a stronger model than this session's. Hand the current tree (settled decisions, open frontier, facts found so far) to the Claude lane in **peer-review**'s `references/agents.tsv` at `--effort high` (rounds want speed, review keeps max), ask it for the next frontier with a recommendation per question, then relay the round to the user in the format above and record the answers yourself. You still sort the questions and run the lookups. The strong model proposes, this session conducts.

## Round one is first principles

Start from the problem, not from the user's proposed solution. Round one always covers these, whatever the idea.

1. Who is this for, and what changes for them the day it ships.
2. What is true today that must stay true. The invariants.
3. What data shape sits at the center, and what structure organizes it (**principle-model-the-domain**). Every actor, state, and transition gets a one-word name a domain expert would use. An awkward name is a wrong shape.
4. What is explicitly out.
5. How we will know it is done. A falsifiable predicate, not a feeling.
6. What the smallest version that is already useful looks like.

Round two applies the systems lens to whatever survived round one.

1. Where is the source of truth for this state, and who else writes it (**principle-separate-before-serializing-shared-state**).
2. Which module owns the new behavior, and what boundary does data cross to reach it (**principle-boundary-discipline**).
3. What breaks at ten times the load, the data, or the users, and what breaks at zero.
4. Which decisions are one-way doors. Those get a prototype, and an **architect** pass only if the shape is still contested after it. Reversible decisions get a default and move on.
5. How does this fail, and who notices first. If the answer is "the user", name the check that would notice sooner.
6. What existing thing could be deleted if this lands (**principle-subtract-before-you-add**).
7. What would show, three months in, that this shape was the wrong call, and what is the earliest signal of it. That signal goes in the brief's Risks.
8. Make the case for the opposite shape, or for doing nothing, and name the evidence that rules it out.

If the proposed solution cannot answer question 1 of round one, say so in the recommendation. Recommend not building it when that is your honest read, and name the cheaper thing that gets most of the value (**principle-laziness-protocol**, **principle-subtract-before-you-add**). Agreement is not the default.

## Finish

The session is done when the frontier is empty and nothing is silently assumed. Confirm shared understanding, then write the brief to `docs/briefs/<slug>.md` unless the user names another path or asks for it in chat.

```markdown
# <Idea> brief

## Problem and who it is for
## Invariants
## Data shape
## Non-goals
## Decisions
One line each: the choice, the alternative rejected, why.
## Open questions routed to prototype
## Done predicate
## Risks
```

Do not build. The next step is **proof-plan**, which turns the done predicate into the checks before any code exists. Offer it.

**Reply:** the brief path, rounds run, and the decisions grilling changed from the user's first framing.
