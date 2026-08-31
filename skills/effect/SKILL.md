---
name: effect
description: Effect v4 rules for TypeScript. Use when writing or reviewing Effect programs (Effect.gen, Effect.fn, Layer, Schema, Context.Service, TaggedError, Data.taggedEnum, Effect.forEach, ManagedRuntime).
---

# Effect

`Effect.Effect<A, E, R>` is a value. Building it does no IO. `A` is success. `E` is acknowledged failure. `R` is services still required. Run at the program edge (`runPromise`, `ManagedRuntime`). Callers either return an Effect or they run it.

## Write

Use `Effect.fn("Name")` or `Effect.gen` for sequential work. `yield*` waits. Name `fn` after the function. Do not write `function foo() { return Effect.gen(...) }`.

Attach catch, span, retry, log with combinators on the outside. Do not nest `flatMap` when a generator is clearer.

`pipe` is combinator chaining. Do not wrap Effect combinators in object-arg helpers. Pipe stays positional.

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

`Layer.succeed` when the impl is already a value. `Layer.effect` when construction needs other services. `Layer.provide` fills `R`. Tests provide a different Layer. Do not `vi.mock`.

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

## Review

- Hover `R` and `E`. Missing service in `R` means it will defect at run. New error class without a `catchTag` update means an edge that claimed exhaustiveness is lying.
- `catchTag` is the error channel. Success `_tag` is `switch` / `Data.taggedEnum` `$match`.
- Context key is path-shaped and unique. Copy-paste of a service class that keeps the old key is two types, one slot.
- `Effect.forEach` mapper is only `succeed` / `sync` of a pure function → reject.
- `{ _tag: "X" as const }` → reject. Use a constructor or `satisfies` a named tagged type.

## Lint

AST can flag `Effect.forEach` whose callback is exactly `Effect.succeed(...)` or `Effect.sync(...)`. Put that next to `effect-hygiene` when the repo has custom oxlint.

AST cannot prove an arbitrary Effect is pure. Do not ship a rule that claims to. This skill is the review net for mixed callbacks and `gen` loops.

Type-aware “`E` is `never` and `R` is `never`” is a possible follow-up, not a substitute for the succeed-only AST rule.
