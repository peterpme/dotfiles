# Bindings

Add bindings to `wrangler.json`, then run `npx wrangler types`. Never hand-write `Env`.

IDs may be omitted for KV, R2, D1, and Queues. Wrangler provisions them on deploy and writes IDs back. Prefer that on new projects.

## Secrets

```json
{
  "secrets": {
    "required": ["API_KEY"]
  }
}
```

```bash
npx wrangler secret put API_KEY
```

Local values go in `.dev.vars`, which is gitignored. When `secrets.required` is set, `wrangler types` types those names and stops inferring secrets from `.dev.vars`.

## KV

```json
{
  "kv_namespaces": [{ "binding": "CACHE" }]
}
```

## D1

```json
{
  "d1_databases": [
    {
      "binding": "DB",
      "database_name": "my-db",
      "migrations_dir": "./migrations"
    }
  ]
}
```

```bash
npx wrangler d1 migrations create my-db initial
npx wrangler d1 migrations apply my-db --local
```

## R2

```json
{
  "r2_buckets": [{ "binding": "BUCKET", "bucket_name": "my-bucket" }]
}
```

## Static assets

```json
{
  "assets": {
    "directory": "./public",
    "binding": "ASSETS"
  }
}
```

Serve with `env.ASSETS.fetch(request)`. This replaces Workers Sites (`site`) and is the default for a static or hybrid app.

## Vars

Non-secrets only.

```json
{
  "vars": {
    "ENVIRONMENT": "production"
  }
}
```

Named `env` blocks do not inherit bindings. Repeat `vars`, KV, D1, and R2 under each environment that needs them.