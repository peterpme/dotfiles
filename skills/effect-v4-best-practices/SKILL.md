---
name: effect-v4-best-practices
description: Effect v4 best practices for TypeScript. Use when writing or reviewing Effect programs (Effect.gen, Effect.fn, Layer, Schema, Context.Service, TaggedError, Data.taggedEnum, Effect.forEach, ManagedRuntime, SqlSchema, HttpClient, FetchHttpClient).
---

# Effect v4 best practices

`Effect.Effect<A, E, R>` is a value. Building it does no IO. `A` is success. `E` is acknowledged failure. `R` is services still required. Run at the program edge (`runPromise`, `ManagedRuntime`). Callers either return an Effect or they run it.

## Write

Use `Effect.fn("Name")` or `Effect.gen` for sequential work. `yield*` waits. Name `fn` after the function. Do not write `function foo() { return Effect.gen(...) }`.

Attach catch, span, retry, log with combinators on the outside. Do not nest `flatMap` when a generator is clearer.

`pipe` is combinator chaining. Do not wrap Effect combinators in object-arg helpers. Pipe stays positional.

`pipe(x, f, g)` runs now. You have `x`. `flow(f, g)` returns `(x) => g(f(x))`. Use `flow` only when a combinator wants a function and there is no value yet (`mapRequest`). One function? pass it, neither helper.

## Channels

`map` transforms `A`. On failure it does not run.
`mapError` transforms `E`. On success it does not run.
`catchTag("Foo", ...)` handles one tagged **error** and removes it from `E`. It does not see success data.
`catch` / `matchEffect` belong at the host edge.

Fail with `yield* new SomeError({ ... })` or `Effect.fail`. Returning `{ _tag: "Foo" }` is success, not failure. The host that `ack`s on success will ack that object.

`Effect.tryPromise({ try, catch })`. `throw` inside `try` is the Promise abort. `catch` must return `E`. Callers never see the raw thrown value as `E`.

## `_tag`

Effect’s discriminant. Errors, Schema unions, Data tagged values. Do not add `kind` or `type`.

**Errors.** `Schema.TaggedError<Self>()("ShowNotFound", { showSlug: Schema.String })`. The first string **is** `_tag`. Unique inside the `E` union. Name the class. `catchTag` matches that string. A plain `Error` subclass is not in this system.

**Internal success unions.** `Data.TaggedEnum` plus `Data.taggedEnum` constructors. `Published({ episodeKey, rowCount })` sets `_tag`. Do not write `{ _tag: "Published" as const }`. `as const` is TypeScript widening, not Effect. It means you skipped a constructor. Official pattern: [Data tagged unions](https://effect.website/docs/data-types/data/).

**Unknown input.** `Schema.TaggedStruct` / `Schema.TaggedUnion` / `Schema.Union` of `_tag: Schema.Literal(...)`. Decode at the boundary (`Schema.decodeUnknownEffect`). Construct with `make` or `satisfies typeof X.Type`. Schema is for untrusted data. Do not Schema-decode values you just built.

Same field name on errors, transcript results, and process outcomes is required. They are different unions. They are not one enum.

Once a caller switches on success `_tag`, the union needs constructors. If `A` is discarded (ack and ignore), an untyped object is a smell, not a Schema requirement.

## Services

`Context.Service<Self, Shape>()("owner/path/Name")`. The string is the runtime map key. Unique in the process, including libraries (`effect/Path`, `@bp/worker/services/Database`). Not an import. Short names (`"Database"`) collide.

`Service.of({ ... })` builds the implementation inside a Layer.
`yield* Service` or `Service.use(f)` looks it up at run time.

`Layer.succeed` when the impl is already a value. Method IO (`queue.send`, a closed-over string) does not change that. `Layer.effect` when construction itself `yield*`s another service. `Layer.provide` fills `R`. Close over the yielded client/sql in the layer so public methods stay `R = never`. `yield*` inside each method leaks that service into every caller. Tests provide a different Layer. Do not `vi.mock`.

Hover the Effect. If a service is used, it appears in `R` until a Layer provides it. You do not have to annotate the return type. Inference is the docs.

## Collections

`function*` for control flow is fine. Do not use generators, `Chunk`, or `Stream` to transform in-memory lists.

`xs.map(f)` when `f` is pure.
`Effect.forEach(xs, f)` when `f` returns an Effect (IO, or decode that can fail).

Fail review on:

```ts
Effect.forEach(xs, (x) => Effect.succeed(pure(x)))
Effect.forEach(xs, (x) => Effect.sync(() => pure(x)))
```

That is `xs.map(pure)`.

Fail the same pattern inside `gen` (`out.push(yield* Effect.succeed(...))` over a list).

Convert `Set` / `Map` / string to `T[]` once if you are about to map. Do not walk iterables as a data pipeline.

## SQL

Driver rows are `{ readonly [column: string]: unknown }`. A sql tagged template is `Effect<ReadonlyArray<Row>, SqlError>`. Zero rows is success with `[]`, not failure. Do not add a type parameter on the template (`sql<Row>`). That is a lie. Decode with Schema.

`SqlSchema` (`effect/unstable/sql/SqlSchema`) is encode request, run `sql`, decode rows.

- `findAll` empty array
- `findOneOption` missing row as `Option`
- `findOne` / `findNonEmpty` missing row as `NoSuchElementError` on `E`
- `void` for INSERT/UPDATE with no row decode

Build the `SqlSchema` function once inside `Layer.effect` (closes over `sql`, keeps encode/decode). That is the `*Query`. Put `Effect.fn("Service.method")` around the call. That is the method on `Service.of`. `fn` adds the span. `mapError` there rewrites `SqlError | SchemaError` to the service error once. `findOneOption` becomes `| null` with `Effect.map(Option.getOrNull)` only if the Shape still uses null.

```ts
const findEpisodeQuery = SqlSchema.findOneOption({
  Request: Schema.Struct({ episodeKey: Schema.String }),
  Result: EpisodeRow,
  execute: (request) => sql`
    SELECT * FROM episodes WHERE episode_key = ${request.episodeKey} LIMIT 1
  `,
})
const findEpisode = Effect.fn("Database.findEpisode")((input: { episodeKey: string }) =>
  findEpisodeQuery(input).pipe(
    Effect.map(Option.getOrNull),
    Effect.mapError((cause) => new DatabaseError({ operation: "findEpisode", cause })),
  ),
)
```

Do not rebuild `SqlSchema.findAll({...})` inside the `fn` on every call. Do not `mapError` on every tagged template when the method already maps `E`.

No-arg queries are one Effect value, not a pair. `SqlSchema.findAll({ Request: Schema.Void, ... })().pipe(mapError, withSpan)`.

`sql.batch` is not SqlSchema. Keep the batch, `mapError` once.
JSON columns are a second Schema hop after the row decode (`fromJsonString` / `decodeEffect` when the value is already `Encoded`).
Missing-row as a domain error (`EpisodeNotFound`) belongs in the route, not in SqlSchema. Database returns `[]` / `Option` / `null`.

## HTTP

Global `fetch` inside `Effect.tryPromise` is leftover. Outbound is `effect/unstable/http`: `HttpClient`, `HttpClientRequest`, `HttpClientResponse`. Transport is `FetchHttpClient.layer` (`globalThis.fetch`). It is not a host binding and takes no `Env`. Not `@effect/platform-cloudflare`. Not inbound `HttpRouter`.

`HttpClient` is the run, like `sql`. It is not SqlSchema. The request value is the encode. `schemaBodyJson` / `response.json` is the decode hop, after you know the status.

`yield* HttpClient.HttpClient` at construction (`Layer.effect`). The barrel export is the module; the tag is `HttpClient.HttpClient`. `mapRequest(namedFn)` for vendor defaults (base URL, API key, Accept). Provide `FetchHttpClient.layer` on that vendor layer so methods stay `R = never`. One shared `FetchHttpClient.layer` at the runtime edge is enough once two services need HTTP. Tests swap `FetchHttpClient.Fetch`, or fake the domain service.

GET: `client.get(path, { urlParams })`.
POST: `HttpClientRequest.post(path).pipe(HttpClientRequest.bodyJson(body), Effect.flatMap(client.execute))`. Prefer `bodyJson` over `bodyJsonUnsafe`.

HTTP contract: non-2xx is `E`. Map to the service error once (`ProviderError` or equivalent). `retryable` only for 429 and `>= 500`. 2xx is `A` as a response. If 2xx bodies differ (202 job id vs 200 payload), branch on `status` before `schemaBodyJson`. Do not put quota/payment 4xx on `A` as a success tag. That is `E` with `retryable: false`.

`filterStatusOk` on the shared client is fine once non-2xx is always failure. It does not replace 2xx body branching.

`retryable` is only what `Effect.retry({ while: (e) => e.retryable })` reads. A queue that `retry()`s every failure is a different policy. Do not assume they match.

A helper that always reads JSON and maps to `ProviderError` is local to that vendor (`provider: "…"`). Not part of FetchHttpClient. `HttpApiClient` is for an API you own. Third-party JSON APIs stay `HttpClient`.

## Review

- Hover `R` and `E`. Missing service in `R` means it will defect at run. New error class without a `catchTag` update means an edge that claimed exhaustiveness is lying.
- `catchTag` is the error channel. Success `_tag` is `switch` / `Data.taggedEnum` `$match`.
- Context key is path-shaped and unique. Copy-paste of a service class that keeps the old key is two types, one slot.
- `Effect.forEach` mapper is only `succeed` / `sync` of a pure function → reject.
- `{ _tag: "X" as const }` → reject. Use a constructor or `satisfies` a named tagged type.
- Global `fetch` in `tryPromise` on the worker → reject. `HttpClient` + `FetchHttpClient`. 4xx on `A` as a success tag → reject unless a caller degrades on that tag.

## Lint

AST can flag `Effect.forEach` whose callback is exactly `Effect.succeed(...)` or `Effect.sync(...)`. Put that next to `effect-hygiene` when the repo has custom oxlint.

AST cannot prove an arbitrary Effect is pure. Do not ship a rule that claims to. This skill is the review net for mixed callbacks and `gen` loops.

Type-aware “`E` is `never` and `R` is `never`” is a possible follow-up, not a substitute for the succeed-only AST rule.
