#!/usr/bin/env python3
"""Start one interactive helper in the caller's Herdr tab."""

import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import uuid


ROUTES = {
    "pi": ("pi", []),
    "codex": ("codex", []),
    "claude": ("claude", []),
    "grok": ("pi", ["--provider", "xai", "--model", "grok-4.6"]),
}


def herdr(*args):
    result = subprocess.run(
        ["herdr", *args], capture_output=True, text=True, timeout=45
    )
    if result.returncode:
        raise RuntimeError(result.stderr.strip() or result.stdout.strip() or f"herdr exited {result.returncode}")
    payload = json.loads(result.stdout)
    if "error" in payload:
        raise RuntimeError(json.dumps(payload["error"]))
    return payload["result"]


def prompt_for(task, skills):
    if not task.strip():
        raise ValueError("Task must not be empty")
    paths = []
    for skill in skills:
        path = Path(skill).expanduser().resolve(strict=True)
        if not path.is_file() or path.name != "SKILL.md":
            raise ValueError(f"Expected a SKILL.md file: {path}")
        if path.parent.name in {"petey-pi", "setup-petey-pi", "spawn-subagent"}:
            raise ValueError(f"Coordinator skill cannot be assigned to a helper: {path}")
        paths.append(str(path))
    instructions = [
        "You are a helper in a fresh Herdr session. Work only on the task below.",
        "Do not load petey-pi or Pi coordinator workflows. Follow the scoped brief instead.",
        "Do not delegate further. Do not commit, push, or edit outside the assigned scope unless the task explicitly authorizes it.",
        "Read the named skills before working. Resolve their relative references from each skill's directory.",
        "If required evidence is missing, report MISSING EVIDENCE. Do not search outside the repository and named paths.",
        "Return your result, changed paths, checks actually run, and any blockers. Do not claim success from terminal state.",
    ]
    if paths:
        instructions += ["Skills to read:", *[f"- {json.dumps(p)}" for p in paths]]
    return "\n".join(instructions) + "\n\nTask:\n" + task


def choose_direction(layout, pane_id):
    pane = next((p for p in layout["panes"] if p["pane_id"] == pane_id), None)
    if pane is None:
        raise ValueError(f"Caller pane {pane_id} is missing from its layout")
    rect = pane["rect"]
    return "right" if rect["width"] >= 2 * rect["height"] else "down"


def launch(args):
    prompt = prompt_for(args.task, args.skill)
    kind, native_args = ROUTES[args.agent]
    if args.agent == "pi" and os.environ.get("PI_PROVIDER") and os.environ.get("PI_MODEL"):
        native_args = ["--provider", os.environ["PI_PROVIDER"], "--model", os.environ["PI_MODEL"]]
        if os.environ.get("PI_REASONING_LEVEL"):
            native_args += ["--thinking", os.environ["PI_REASONING_LEVEL"]]
    if args.dry_run:
        return {"kind": kind, "args": native_args, "cwd": str(Path.cwd()), "prompt": prompt}
    if os.environ.get("HERDR_ENV") != "1":
        raise ValueError("Not inside Herdr. Attach to Herdr and retry; no pane was created.")
    for binary in ("herdr", kind):
        if not shutil.which(binary):
            raise ValueError(f"Missing executable: {binary}; no pane was created")

    name = "helper-" + uuid.uuid4().hex[:12]
    pane = None
    stage = "current"
    try:
        current = herdr("pane", "current", "--current")["pane"]["pane_id"]
        direction = args.direction
        if direction is None:
            stage = "layout"
            layout = herdr("pane", "layout", "--pane", current)["layout"]
            direction = choose_direction(layout, current)
        stage = "split"
        pane = herdr(
            "pane", "split", "--pane", current, "--direction", direction,
            "--cwd", str(Path.cwd()), "--env", "PPSTACK_SUBAGENT=1", "--no-focus",
        )["pane"]["pane_id"]
        stage = "start"
        command = ["agent", "start", name, "--kind", kind, "--pane", pane, "--timeout", "30000"]
        if native_args:
            command += ["--", *native_args]
        herdr(*command)
        stage = "prompt"
        result = herdr("agent", "prompt", name, prompt)
        return {"status": "submitted", "name": name, "pane": pane, "agent": args.agent, "argv": [kind, *native_args], "herdr": result}
    except (RuntimeError, OSError, ValueError, KeyError, subprocess.TimeoutExpired) as error:
        # A timed-out mutation may have succeeded. Never retry it or destroy its pane.
        raise RuntimeError(json.dumps({
            "status": "needs-attention", "stage": stage, "name": name, "pane": pane,
            "error": str(error),
            "recovery": "Inspect Herdr agent get/read and pane list. Do not rerun the launcher or resend the task until you know whether it was delivered. Existing panes are retained.",
        })) from error


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--task", required=True)
    parser.add_argument("--agent", choices=ROUTES, default="pi")
    parser.add_argument("--skill", action="append", default=[], metavar="SKILL.md")
    parser.add_argument("--direction", choices=["right", "down"])
    parser.add_argument("--dry-run", action="store_true", help="Print the brief and route without contacting Herdr")
    args = parser.parse_args()
    try:
        print(json.dumps(launch(args)))
    except (RuntimeError, OSError, ValueError, KeyError, subprocess.TimeoutExpired) as error:
        print(str(error), file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
