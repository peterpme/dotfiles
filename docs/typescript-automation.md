# TypeScript automation

Use TypeScript for repository automation and Pi extensions.

## Rules

- Put executable repository automation under `scripts/` as `.ts` files.
- Put Pi extensions under `pi/extensions/` as `.ts` files.
- Run executable TypeScript with `bun run <path>`.
- Start executable scripts with `#!/usr/bin/env bun`.
- Keep source as TypeScript. Do not commit generated JavaScript beside it.
- Use `.test.ts` for tests and run them with `bun test`.
- Run `bun run scripts/check-typescript-automation.ts` before committing automation changes.

`Bun` executes TypeScript but does not replace static type checking. Add a pinned TypeScript and ESLint toolchain only when the repository adopts a root package manifest and lockfile. Do not use an unpinned `bunx` invocation as a commit gate.

The current installed Bun is 1.3.14. Upgrade and pin Bun 1.4 separately after that runtime is installed and its existing extension tests pass.
