# Prompt: Add Engineering Manager Skill to a Project and Open a Separate PR

```text
You are an engineering agent or maintainer working in this repository.

Goal:
Add a reusable engineering manager skill/prompt package to this project in a separate pull request. This PR should only add the manager skill/rules and supporting documentation. It should not implement unrelated product changes.

Source skill content:
Use the engineering-manager skill content provided in this conversation or available in the local file/archive I gave you. If the project has an existing skills, prompts, agent-rules, `.agents`, `.devin`, `.cursor`, `.claude`, `.codex`, `.github`, or docs convention, install it there. Otherwise, create a lightweight location such as:
- .agents/skills/engineering-manager/
- .codex/skills/engineering-manager/
- .claude/skills/engineering-manager/
or, if this repo already uses agent skills:
- skills/engineering-manager/

Required files:
1. A main manager skill/instruction file that explains when to use the manager workflow.
2. A reusable manager prompt template.
3. A prompt for applying the manager workflow to complex PRs.
4. Optional README entry if the repo has a docs/index pattern.

Behavior the skill must encode:
- act as manager first
- spawn focused specialist agents or assign focused human reviewers
- require findings before implementation
- create a concrete checklist
- implement in small reviewable batches
- run repo-native validation commands
- open/update a PR
- resolve actionable review comments and CI failures
- treat low-signal automated comments with judgment
- run a final independent audit by an agent that did not write the implementation
- do not claim completion without validation evidence

Implementation steps:
1. Inspect the repo for existing agent/skill/prompt conventions.
2. Choose the least surprising install path.
3. Add the engineering-manager skill files.
4. Keep the content generic and reusable. Do not hard-code project-specific assumptions into the reusable skill.
5. Run formatting/lint checks if docs or markdown checks exist.
6. Commit the changes on a separate branch.
7. Push the branch.
8. Open a PR with a description that includes:
   - where the skill was installed
   - how to use it
   - validation run
   - note that this PR is intentionally separate from product implementation work

Branch name suggestion:
chore/add-engineering-manager-skill

PR title suggestion:
Add reusable engineering manager skill

Do not modify app/product code in this PR.
```
