---
name: cloudflare-setup
description: Use when creating a new worker or wrangler file.
---

# Cloudflare setup

House defaults for a Worker. Official `cloudflare` / `wrangler` / `workers-best-practices` skills are a product catalog and still show `wrangler.toml` in places. This file wins on the config filename. After setup, those skills are fine for CLI verbs and product APIs.

Write the files. Do not run `create-cloudflare` or `wrangler init`. Both are interactive and emit `wrangler.jsonc`.

New work is a Worker. Static files go in `assets`. Start a Pages project only when the user names Pages.

## House defaults

| Knob | Value |
|------|--------|
| Config file | `wrangler.json` only |
| `compatibility_date` | today, `YYYY-MM-DD` |
| Language | TypeScript |
| Types | `wrangler types` → `worker-configuration.d.ts` |
| Observability | `{ "enabled": true }` |
| Wrangler | `^4`, installed as a devDependency |

Never write `wrangler.toml`. Convert it to `wrangler.json` and delete the toml. Rewrite `wrangler.jsonc` as `wrangler.json`. One config file only.

`nodejs_compat` is already on for dates of `2026-08-04` or later. Official review snippets still paste the flag. Leave it, add it, or omit it. Do not migrate a project just to change that flag.

## Skeleton

```json
{
  "$schema": "./node_modules/wrangler/config-schema.json",
  "name": "my-worker",
  "main": "src/index.ts",
  "compatibility_date": "2026-08-26",
  "observability": {
    "enabled": true
  }
}
```

Replace the date with today. Replace `name` with a workers.dev-safe name: lowercase, digits, dashes, no underscores.

```ts
export default {
  async fetch(request, env, ctx): Promise<Response> {
    return new Response("ok");
  },
} satisfies ExportedHandler<Env>;
```

`Env` comes from `worker-configuration.d.ts`. Never hand-write it. Re-run `wrangler types` after every binding change.

```json
{
  "compilerOptions": {
    "target": "es2024",
    "lib": ["es2024"],
    "module": "es2022",
    "moduleResolution": "Bundler",
    "strict": true,
    "noEmit": true,
    "isolatedModules": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["worker-configuration.d.ts", "src/**/*.ts"]
}
```

```json
{
  "private": true,
  "scripts": {
    "dev": "wrangler dev",
    "deploy": "wrangler deploy",
    "types": "wrangler types",
    "typecheck": "wrangler types && tsc --noEmit"
  },
  "devDependencies": {
    "typescript": "^5",
    "wrangler": "^4"
  }
}
```

Do not add `@cloudflare/workers-types`. `wrangler types` generates runtime types for this Worker's date and flags.

```
node_modules
.wrangler
.dev.vars
.dev.vars.*
!.dev.vars.example
```

Secrets live in `.dev.vars` locally and `wrangler secret put` remotely. Bindings recipes are in [bindings.md](bindings.md).

## Steps

### 1. Pick the branch

Look at the target directory.

- No Worker config, and the user wants a Worker → **new**.
- `wrangler.toml`, `wrangler.jsonc`, or a `compatibility_date` before `2026-01-01` → **migrate**.
- A JS/TS app with no Worker yet → **new**, inside that app if it is already Node, otherwise see placement below.

Placement for **new**:

- Repo already has `package.json` at the Worker root → stay there.
- Repo is Python, Rust, or otherwise not Node → put the Worker in `worker/` unless the user names a path.
- A `site/` of static HTML is not a Worker. Do not overwrite it.

**Done when:** branch and directory are chosen.

### 2. Install wrangler

Detect the package manager from the lockfile (`pnpm-lock.yaml`, `yarn.lock`, `bun.lockb`/`bun.lock`, else npm). In a polyglot `worker/` folder with no lockfile, use npm.

```bash
npm install -D wrangler@latest typescript
```

Adapt the install to the detected manager. Require Wrangler 4.

**Done when:** `wrangler` is in `devDependencies` and `npx wrangler --version` prints v4.

### 3. Write or rewrite the config

**New.** Write the skeleton `wrangler.json`, `src/index.ts`, `tsconfig.json`, `package.json` scripts, and `.gitignore` entries above.

**Migrate.** Translate keys as-is into `wrangler.json`. Set `compatibility_date` to today. Add `observability.enabled` if missing. Delete `wrangler.toml` and `wrangler.jsonc`.

One config file, named `wrangler.json`.

**Done when:** the directory has exactly `wrangler.json` and the date is today.

### 4. Generate types

```bash
npx wrangler types
```

Confirm `worker-configuration.d.ts` exists and is in `tsconfig.json` `include`. Commit the file. Add `npx wrangler types --check` to CI when the repo has CI.

**Done when:** `tsc --noEmit` is clean and the handler uses `satisfies ExportedHandler<Env>` with no local `interface Env`.

### 5. Smoke

```bash
npx wrangler deploy --dry-run
```

Do not deploy unless the user asked. `wrangler whoami` only if they want a live deploy and auth is unclear.

**Done when:** the dry run succeeds.

## After setup

Bindings, assets, and secrets: [bindings.md](bindings.md).

CLI after that: the official `wrangler` skill is fine. Do not copy a `wrangler.toml` sample out of it.