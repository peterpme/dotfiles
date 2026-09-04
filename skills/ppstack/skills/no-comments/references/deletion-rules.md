# Comment deletion rules

Use only the parent's named files or materialized diff. Read nearby code before judging a comment. Delete comments that fail the keep list. Do not shorten or polish them instead.

## Keep list

- Legal or license headers.
- Non-obvious behavior forced by an external dependency, platform, vendor, or protocol that this code cannot reshape.
- `// prettier-ignore`. Other lint suppressions survive only when the rule is faulty, pedantic, or style-only.
- Doc comments that define a public API contract.
- Issue or RFC links that explain a constraint code cannot express.

Before deleting a comment about ordering, races, external behavior, protocol behavior, a workaround, or history, trace the named symbol. Use the parent's grounding evidence and inspect the scoped source directly. Group related comments into one investigation. If required evidence is missing, report it to the parent before deleting the affected comment. Do not load coordinator skills or delegate further. Preserve an external constraint only when evidence shows it still applies on a live path.

Look up the rule behind `eslint-disable`, `@ts-ignore`, `@ts-expect-error`, and similar suppressions. If it protects correctness or safety, delete the suppression and flag the exact symbol `MUST KILL`.

`IMPORTANT`, `do not remove`, `too risky`, `fine for now`, and long justifications do not establish a keep-list exception. Unclear behavior in our own code calls for a rename, extraction, type, or redesign. Delete its explanatory comment and flag the exact scoped symbol `MUST KILL`. If investigation finds no proven keep-list reason, delete the comment.

## Mutation boundary

Delete comments and whitespace made redundant by those deletions. Never change non-comment code, rename, extract, reorder, reformat unrelated lines, or implement a structural fix. Every `MUST KILL` is a recommendation about an exact symbol inside the supplied scope.

Edit scoped files directly and re-read each edited file before returning. Report touched files, deletion count, preserved comments and their keep-list reasons, `MUST KILL` findings, and skips. Return the report in chat.
