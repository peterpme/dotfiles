# Local model names

Pretty URLs, no port:

```
http://qwen38-27b.ai.peterp.local/v1
```

Two files, two jobs. Both stay on this computer:

```
/etc/hosts          this name → 127.0.0.1     (only names you list)
Caddyfile           bind 127.0.0.1:80 → which port
mlx on 127.0.0.1:18765
```

`bind 127.0.0.1` (Caddy) and `--host 127.0.0.1` (mlx) keep Wi‑Fi out.
The hostname alone does not. After `sudo brew services reload caddy`,
`lsof` must show `127.0.0.1:80`, never `*:80`.

After a reload, this must say `127.0.0.1:80`, never `*:80`:

```bash
lsof -nP -iTCP:80 -sTCP:LISTEN
lsof -nP -iTCP:18765 -sTCP:LISTEN   # only when the model is on
```

No dnsmasq. No wildcard. A random `foo.ai.peterp.local` is just a normal DNS lookup, not this Mac.

## First-time setup

Needs Homebrew `caddy`.

```bash
~/dotfiles/caddy/setup.sh
sudo sh -c 'grep -q qwen38-27b.ai.peterp.local /etc/hosts || cat ~/dotfiles/caddy/hosts >> /etc/hosts'
sudo brew services start caddy
ping -c 1 qwen38-27b.ai.peterp.local
```

`setup.sh` only symlinks this Caddyfile to `/opt/homebrew/etc/Caddyfile`.

Caddy is a **LaunchDaemon** (starts at boot, as root) because `:80` needs root.
That is what `sudo brew services start caddy` installed. You do **not** want
`brew services start caddy` without sudo — that is a login agent and cannot bind `:80`.

```bash
# already done if you used sudo start:
ls /Library/LaunchDaemons/homebrew.mxcl.caddy.plist

# still running after a reboot?
curl -sS -o /dev/null -w '%{http_code}\n' http://qwen38-27b.ai.peterp.local/v1/models
# 502 = Caddy up, model off.  connection refused = Caddy not running.
```

If you already started dnsmasq for this, you can drop it:

```bash
sudo brew services stop dnsmasq
brew uninstall dnsmasq
sudo rm -f /etc/resolver/ai.peterp.local
```

## Add another model

1. Run it on a new loopback port (18766, …).
2. One line in `Caddyfile` `map`:

```
other.ai.peterp.local 127.0.0.1:18766
```

3. One line in `hosts`, then append it the same way (or edit `/etc/hosts` by hand):

```
127.0.0.1 other.ai.peterp.local
```

4. `sudo brew services reload caddy`
5. Client URL: `http://other.ai.peterp.local/v1`

Both lists stay explicit. Forget the hosts line → name won't resolve. Forget the Caddy line → Caddy says unknown host.

## Day to day

| | |
|---|---|
| Edit routes | `~/dotfiles/caddy/Caddyfile` then `sudo brew services reload caddy` |
| Edit names | `~/dotfiles/caddy/hosts` and the matching `/etc/hosts` line |
| This 27B | menubar **MLX** or `~/models/mlx-server on\|off` |
| Pi | `/model` → mlx |

## Broken?

```bash
# 1. Name → this Mac?
ping -c 1 qwen38-27b.ai.peterp.local
# expect 127.0.0.1
# if not, the hosts line is missing.

# 2. Caddy on :80?
curl -sS -D- -o /dev/null http://qwen38-27b.ai.peterp.local/v1/models | head
# refused → sudo brew services restart caddy
# ls -l /opt/homebrew/etc/Caddyfile  must point here

# 3. Model process up?
~/models/mlx-server status
curl -sS http://127.0.0.1:18765/v1/models

# 4. Caddy says "unknown model host"?
# Map line missing, or forgot to reload.
```

## Don’t

- Don’t bind the model to `0.0.0.0`.
- Don’t edit `/opt/homebrew/etc/Caddyfile` — it’s a symlink. Edit here.
