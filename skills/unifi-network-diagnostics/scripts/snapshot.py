#!/usr/bin/env python3
"""Print a bounded, read-only UniFi diagnostic snapshot without exposing credentials."""

from __future__ import annotations

import argparse
import datetime as dt
import json
import os
import ssl
import sys
import urllib.error
import urllib.parse
import urllib.request
from typing import Any
from zoneinfo import ZoneInfo

DEFAULT_CLIENT_MAC = "48:e1:5c:77:6a:14"
DEFAULT_AP_MAC = "9c:05:d6:e0:dc:a4"
TIMEZONE = ZoneInfo("America/Chicago")


def pick(value: dict[str, Any], keys: list[str]) -> dict[str, Any]:
    return {key: value.get(key) for key in keys if key in value}


def local_time(epoch_seconds: float) -> str:
    return dt.datetime.fromtimestamp(epoch_seconds, TIMEZONE).isoformat()


class Unifi:
    def __init__(self) -> None:
        self.base_url = os.environ.get("UNIFI_BASE_URL", "").rstrip("/")
        api_key = os.environ.get("UNIFI_API_KEY", "")
        if not self.base_url or not api_key:
            raise SystemExit("Load UNIFI_BASE_URL and UNIFI_API_KEY into the subprocess environment")
        self.headers = {"Accept": "application/json", "X-API-Key": api_key}
        self.context = ssl.create_default_context()
        self.context.check_hostname = False
        self.context.verify_mode = ssl.CERT_NONE

    def get(self, path: str, params: dict[str, Any] | None = None) -> list[dict[str, Any]]:
        url = f"{self.base_url}/proxy/network/api/s/default{path}"
        if params:
            url += "?" + urllib.parse.urlencode(params)
        request = urllib.request.Request(url, headers=self.headers)
        with urllib.request.urlopen(request, context=self.context, timeout=30) as response:
            return json.load(response).get("data", [])


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--hours", type=int, default=24)
    parser.add_argument("--client-mac", default=DEFAULT_CLIENT_MAC)
    parser.add_argument("--ap-mac", default=DEFAULT_AP_MAC)
    args = parser.parse_args()
    if not 1 <= args.hours <= 720:
        raise SystemExit("--hours must be between 1 and 720")

    unifi = Unifi()
    end_ms = int(dt.datetime.now(dt.timezone.utc).timestamp() * 1000)
    start_ms = end_ms - args.hours * 3_600_000
    target_mac = args.client_mac.lower()

    clients = unifi.get("/stat/sta")
    devices = unifi.get("/stat/device")
    sessions = unifi.get(
        "/stat/session",
        {"mac": target_mac, "start": start_ms // 1000, "end": end_ms // 1000},
    )

    current = [
        pick(
            station,
            [
                "name", "hostname", "mac", "is_wired", "ap_mac", "bssid", "essid",
                "radio", "channel", "channel_width", "signal", "noise", "satisfaction",
                "wifi_tx_retries_percentage", "tx_rate", "rx_rate", "tx_bytes-r",
                "rx_bytes-r", "uptime",
            ],
        )
        for station in clients
        if station.get("mac", "").lower() == target_mac
    ]

    session_rows = []
    for session in sorted(sessions, key=lambda item: item.get("assoc_time", 0)):
        start = session.get("assoc_time", 0)
        duration = session.get("duration", 0)
        session_rows.append(
            {
                "start_local": local_time(start),
                "end_local": local_time(start + duration),
                "duration_seconds": duration,
                "satisfaction_average": session.get("satisfaction_avg"),
                "download_gb": round(session.get("tx_bytes", 0) / 1_000_000_000, 3),
                "is_wired": session.get("is_wired"),
                "ap_mac": session.get("ap_mac"),
            }
        )

    anomalies: dict[str, list[dict[str, Any]]] = {}
    for scale in ("5minutes", "hourly"):
        rows = []
        for record in unifi.get(
            "/stat/anomalies",
            {"scale": scale, "start": start_ms, "end": end_ms},
        ):
            timestamps = [
                value for value in record.get("timestamps", []) if start_ms <= value <= end_ms
            ]
            if timestamps:
                rows.append(
                    {
                        "anomaly": record.get("anomaly"),
                        "mac": record.get("mac"),
                        "count": len(timestamps),
                        "times_local": [local_time(value / 1000) for value in timestamps],
                    }
                )
        anomalies[scale] = rows

    device_rows = []
    for device in devices:
        row = pick(device, ["name", "type", "model", "version", "upgradable", "uptime", "state"])
        if device.get("type") == "uap":
            row["radios"] = [
                pick(
                    radio,
                    [
                        "radio", "channel", "bw", "cu_total", "cu_self_tx", "cu_self_rx",
                        "num_sta", "tx_retries_pct", "satisfaction", "tx_power",
                    ],
                )
                for radio in device.get("radio_table_stats", [])
            ]
            row["uplink"] = pick(
                device.get("uplink", {}),
                ["speed", "full_duplex", "rx_errors", "tx_errors", "rx_dropped", "tx_dropped"],
            )
        device_rows.append(row)

    health_rows = []
    for subsystem in unifi.get("/stat/health"):
        if subsystem.get("subsystem") not in {"wan", "www", "wlan"}:
            continue
        row = pick(
            subsystem,
            ["subsystem", "status", "num_user", "num_ap", "num_disconnected", "latency", "drops"],
        )
        if subsystem.get("subsystem") == "wan":
            wan = subsystem.get("uptime_stats", {}).get("WAN", {})
            row["availability"] = wan.get("availability")
            row["latency_average"] = wan.get("latency_average")
            row["time_period_seconds"] = wan.get("time_period")
        health_rows.append(row)

    neighbors = [
        pick(record, ["bssid", "band", "channel", "bw", "signal", "noise", "oui", "is_rogue"])
        for record in unifi.get("/stat/rogueap")
        if record.get("essid") == "Chestnut Castle"
    ]

    json.dump(
        {
            "window": {
                "hours_requested": args.hours,
                "start_local": local_time(start_ms / 1000),
                "end_local": local_time(end_ms / 1000),
                "timezone": "America/Chicago",
            },
            "target_client": current,
            "target_sessions": session_rows,
            "anomalies": anomalies,
            "devices": device_rows,
            "health": health_rows,
            "same_ssid_neighbors": neighbors,
        },
        sys.stdout,
        indent=2,
        sort_keys=True,
    )
    sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except urllib.error.HTTPError as error:
        sys.stderr.write(f"UniFi API returned HTTP {error.code}\n")
        raise SystemExit(1) from error
    except urllib.error.URLError as error:
        sys.stderr.write(f"Unable to reach UniFi API: {error.reason}\n")
        raise SystemExit(1) from error
