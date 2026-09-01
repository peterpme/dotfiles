---
name: unifi-network-diagnostics
description: "Peter's UniFi home-network investigation. Family Room Apple TV Netflix buffering, U6 Pro RF utilization, ASUS interference tests, WAN health, and switch link problems. Use only when explicitly invoked (/skill:unifi-network-diagnostics)."
disable-model-invocation: true
---

# UniFi network diagnostics

## Start here

Read `$HOME/Projects/unifi/LOG.md` completely before querying the controller. Treat it as the durable investigation record.

## Credential rules

- Never open, print, quote, log, or save `.env` contents.
- Never display `UNIFI_API_KEY` or `UNIFI_BASE_URL`.
- Load `$HOME/Projects/unifi/.env` only into a subprocess environment used for API calls.
- Never save raw UniFi device responses. They may contain authentication, SSH, syslog, adoption, or guest-access material.
- Use read-only API calls unless the user explicitly authorizes a configuration change.
- Explain any disruptive diagnostic and get approval before running it.

## Take a snapshot

```bash
PROJECT="$HOME/Projects/unifi"
SKILL="$HOME/dotfiles/skills/unifi-network-diagnostics"
set -a
source "$PROJECT/.env"
set +a
python3 "$SKILL/scripts/snapshot.py" --hours 72
```

The helper prints a bounded JSON snapshot and never prints credentials. Use `--hours 24` for the latest day. Use `--client-mac` only when investigating a different client. Cwd does not have to be the UniFi repo.

## Investigation workflow

1. Read `$HOME/Projects/unifi/LOG.md`.
2. Ask for the exact local buffering time when available.
3. Run the snapshot helper for a window that covers the event.
4. Correlate the event across:
   - Client association and session boundaries.
   - Low PHY rate, Wi-Fi retries, and TCP latency.
   - AP utilization and association-time anomalies.
   - Current signal, noise, link rates, and retry percentage.
   - AP Ethernet uplink speed and errors.
   - WAN availability and latency.
5. Separate observations from hypotheses. Do not call the ASUS the exact cause without an A/B test.
6. Prefer controlled tests:
   - ASUS radios off while the TV remains on Wi-Fi.
   - Then Ethernet to the TV if buffering remains.
7. Update `$HOME/Projects/unifi/LOG.md` after each meaningful test or configuration change. Add:
   - Date and local time.
   - What changed.
   - Test duration and Netflix title or workload if known.
   - Exact buffering times.
   - Relevant metrics and anomalies.
   - Conclusion and next test.
8. Keep the log concise. Preserve prior evidence and mark disproven hypotheses instead of deleting history.

## Interpretation rules

- Strong RSSI does not guarantee throughput. Airtime congestion, retries, low PHY rates, and reassociation can stall traffic.
- An AP utilization anomaly does not identify the responsible client, interferer, or radio band by itself.
- The TV can suffer from ASUS co-channel traffic without associating with the ASUS.
- A current healthy snapshot does not disprove an intermittent evening problem.
- Ethernet bypasses Wi-Fi interference, roaming, PHY-rate, and retry problems. If Ethernet also buffers, investigate Netflix, tvOS, DNS, CDN routing, and WAN behavior.
- UniFi five-minute anomaly retention may be shorter than requested. Hourly anomaly records can cover a longer period.
- Session churn on phones can be normal. Repeated short sessions on a stationary streaming device during active traffic deserve attention.

## Known target

- Family Room Apple TV MAC: `48:e1:5c:77:6a:14`
- U6 Pro MAC: `9c:05:d6:e0:dc:a4`
- Controller timezone: `America/Chicago`
- Project: `$HOME/Projects/unifi`

Do not expose other client identifiers in user-facing answers unless they are needed to explain a finding.
