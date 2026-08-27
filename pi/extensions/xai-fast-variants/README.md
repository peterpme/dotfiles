# xAI Fast Variants

Adds selectable `-fast` variants to Pi's built-in `xai` model catalog.

## Behavior

The extension preserves Pi's normal xAI models and API-key / OAuth authentication. On load and model refresh it:

1. reads Pi's built-in `xai` catalog;
2. keeps Grok models whose `baseUrl` is `api.x.ai` or `cli-chat-proxy.grok.com`;
3. publishes `<model>-fast` variants as a cached dynamic model overlay.

There is no remote catalog. xAI documents Priority Processing on Grok chat models; the overlay does not call xAI to discover capability.

Selecting a Fast variant sends the real upstream model ID with:

```json
{
  "service_tier": "priority"
}
```

The selected model ID retains its `-fast` suffix in Pi's standard model display. The provider stream wrapper applies the upstream ID and service tier to normal turns, automatic and manual compaction, and branch summaries.

This is a speed/queue upgrade (2x token price on xAI), not a different model or thinking level.

## Failure behavior

Previously cached Fast variants remain available if the built-in catalog shrinks to nothing eligible. On a first-run with no Grok models, the normal xAI catalog remains available without Fast variants.

## Development

```bash
npm test
```

Reload Pi with `/reload` after changing the extension.
