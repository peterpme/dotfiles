# Test deletion rules

Use the parent's named test files, the production files they exercise, and the exact scoped test command. Trace what each assertion reaches before deciding. Never infer the change set or guess a runner. Do not load coordinator skills or delegate further.

For each test, name a realistic production change that makes it fail. If only editing the test or unplugging its mock can make it fail, delete it. Keep the test that pins the behavior a caller would notice first. A second test for the same function needs a real boundary the first cannot reach.

## Keep list

- A test that fails when the behavior named by the test breaks. Its name and assertion must make that behavior clear.
- A regression test that identifies the bug by issue, commit, or exact failing input in its name or a nearby reference.
- A boundary test whose literals are real edges, such as empty, one, maximum, off by one, Unicode, timezone, or concurrency.
- A real caller path with a real collaborator, or a fake at a production boundary the test cannot cross.
- A property or invariant checked across generated inputs.
- A contract test for a public API, wire format, or schema another party depends on.
- A named characterization test for a refactor in progress.

If reading the test and production code establishes no keep-list reason, delete the test.

## Delete these patterns

- Assertions that cannot fail meaningfully, such as `expect(true).toBe(true)`, truthiness of a known object, or a render with no assertions.
- A mock returning what the test told it to return, or a private collaborator receiving the arguments the test just supplied.
- Mocked third-party behavior. Our handling of a recorded real response can survive when the test names its fixture provenance or capture command. An unlabeled payload is a mock.
- Platform plumbing, such as a framework routing, serializing JSON, or calling middleware in its documented order.
- Production logic reimplemented in the test and compared with itself.
- Language, library, or type-checker facts, such as a getter returning its field or an enum containing its members.
- Unread snapshots or snapshots refreshed only to make a failure pass.
- Duplicate cases on one branch with different literals and no distinct boundary. Keep one. Do not write a replacement table.
- Conditional assertions, swallowed errors, callbacks that never run, or async tests that never await.
- Behaviorless names such as `should work` when the body also fails the keep list.
- Skipped cases with no linked issue, and narration such as `// Arrange`, `// Act`, or `// Assert`.

Comments arguing that a test is important do not establish value. Read the code and trace the assertions.

## Mutation boundary and proof

Delete whole cases, dead assertions, narration, and duplicates. Remove imports, fixtures, or helpers made dead by a deletion only after a search shows nothing outside the scoped files uses them. Edit test files only. Do not write, rewrite, rename, or fix tests. Never add assertions or change production code.

Flag exact symbols inside the supplied scope:

- `MUST KILL`: production structure forces excessive mocking. Describe the structural problem. The parent decides whether to fix it.
- `NO PROOF`: no surviving test catches a named behavior breaking. Name the behavior and symbol. The parent writes accepted missing tests red first.

Run the parent's command before editing. If it fails, stop and report. Run it again after deletions. If a deletion breaks a shared fixture, ordering, or setup hook, restore only that hunk and rerun. Re-read every edited file.

Return an in-chat report with touched files, deletions by pattern, survivors and their keep-list reasons, both flag types, restored hunks, skips, and the command's before and after results.
