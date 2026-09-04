import importlib.util
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch


spec = importlib.util.spec_from_file_location("spawn", Path(__file__).with_name("spawn.py"))
spawn = importlib.util.module_from_spec(spec)
spec.loader.exec_module(spawn)

# Shapes captured from herdr pane current/layout/split and agent start/prompt.
CURRENT = {"pane": {"pane_id": "w1C:p1"}}
LAYOUT = {"layout": {"panes": [{"pane_id": "w1C:p1", "rect": {"width": 132, "height": 66}}]}}
SPLIT = {"pane": {"pane_id": "w1C:pF"}}
AGENT = {"agent": {"agent_status": "idle", "pane_id": "w1C:pF"}}


def args(**overrides):
    return spawn.argparse.Namespace(**{
        "task": "Review only. Do not edit. $(touch /tmp/never-execute)",
        "agent": "pi", "skill": [], "direction": None, "dry_run": False,
        **overrides,
    })


class SpawnTest(unittest.TestCase):
    def test_routes_submit_literal_brief_to_new_pane_without_wait_or_focus(self):
        for route, expected_kind, expected_args in (
            ("pi", "pi", []), ("codex", "codex", []),
            ("claude", "claude", []),
            ("grok", "pi", ["--", "--provider", "xai", "--model", "grok-4.6"]),
        ):
            with self.subTest(route=route), patch.dict(os.environ, HERDR_ENV="1", PI_PROVIDER="", PI_MODEL=""), \
                    patch.object(spawn.shutil, "which", return_value="/bin/agent"), \
                    patch.object(spawn, "herdr", side_effect=[CURRENT, LAYOUT, SPLIT, AGENT, AGENT]) as api:
                result = spawn.launch(args(agent=route))
                calls = [call.args for call in api.call_args_list]
                self.assertEqual(result["status"], "submitted")
                self.assertEqual(result["pane"], "w1C:pF")
                self.assertEqual(calls[0], ("pane", "current", "--current"))
                self.assertEqual(calls[2], (
                    "pane", "split", "--pane", "w1C:p1", "--direction", "right",
                    "--cwd", str(Path.cwd()), "--env", "PPSTACK_SUBAGENT=1", "--no-focus",
                ))
                self.assertEqual(calls[3], (
                    "agent", "start", result["name"], "--kind", expected_kind,
                    "--pane", "w1C:pF", "--timeout", "30000", *expected_args,
                ))
                self.assertEqual(calls[4], ("agent", "prompt", result["name"], spawn.prompt_for(args().task, [])))

    def test_pi_inherits_parent_model_but_explicit_grok_does_not(self):
        with patch.dict(os.environ, PI_PROVIDER="openai-codex", PI_MODEL="gpt-6-astra", PI_REASONING_LEVEL="low"):
            self.assertEqual(spawn.launch(args(dry_run=True))["args"], [
                "--provider", "openai-codex", "--model", "gpt-6-astra", "--thinking", "low",
            ])
            self.assertEqual(spawn.launch(args(agent="grok", dry_run=True))["args"], [
                "--provider", "xai", "--model", "grok-4.6",
            ])
            self.assertEqual(spawn.launch(args(agent="claude", dry_run=True))["args"], [])
        with patch.dict(os.environ, PI_PROVIDER="", PI_MODEL="gpt-6-astra"):
            self.assertEqual(spawn.launch(args(dry_run=True))["args"], [])

    def test_preflight_failures_do_not_contact_herdr(self):
        with patch.object(spawn, "herdr") as api:
            with patch.dict(os.environ, HERDR_ENV="0"), self.assertRaisesRegex(ValueError, "Not inside Herdr"):
                spawn.launch(args())
            with patch.dict(os.environ, HERDR_ENV="1"), patch.object(spawn.shutil, "which", return_value=None), \
                    self.assertRaisesRegex(ValueError, "Missing executable"):
                spawn.launch(args())
            with self.assertRaises(ValueError):
                spawn.launch(args(task="  "))
            with self.assertRaises(FileNotFoundError):
                spawn.launch(args(skill=["/nonexistent/house-skill/SKILL.md"]))
            api.assert_not_called()

    def test_failures_keep_pane_identity_and_never_retry_mutations(self):
        for failed_stage, responses, expected_calls, pane in (
            ("current", [RuntimeError("caller unavailable")], 1, None),
            ("layout", [CURRENT, {"layout": {"panes": []}}], 2, None),
            ("split", [CURRENT, LAYOUT, subprocess.TimeoutExpired("herdr", 45)], 3, None),
            ("start", [CURRENT, LAYOUT, SPLIT, RuntimeError("agent_not_ready")], 4, "w1C:pF"),
            ("prompt", [CURRENT, LAYOUT, SPLIT, AGENT, RuntimeError("agent_blocked")], 5, "w1C:pF"),
        ):
            with self.subTest(stage=failed_stage), patch.dict(os.environ, HERDR_ENV="1"), \
                    patch.object(spawn.shutil, "which", return_value="/bin/agent"), \
                    patch.object(spawn, "herdr", side_effect=responses) as api, \
                    self.assertRaises(RuntimeError) as error:
                spawn.launch(args())
            report = json.loads(str(error.exception))
            self.assertEqual(report["stage"], failed_stage)
            self.assertEqual(report["pane"], pane)
            self.assertTrue(report["error"])
            self.assertEqual(api.call_count, expected_calls)

    def test_dry_run_resolves_skill_paths_without_contacting_herdr(self):
        with tempfile.TemporaryDirectory() as directory, patch.object(spawn, "herdr") as api:
            skill = Path(directory) / "skill with spaces" / "SKILL.md"
            skill.parent.mkdir()
            skill.write_text("---\nname: example\ndescription: example\n---\nRead only.")
            result = spawn.launch(args(skill=[str(skill)], dry_run=True))
            self.assertIn(str(skill), result["prompt"])
            self.assertIn("Do not delegate further", result["prompt"])
            api.assert_not_called()

    def test_coordinator_skills_cannot_be_assigned_to_helpers(self):
        with tempfile.TemporaryDirectory() as directory:
            skill = Path(directory) / "petey-pi" / "SKILL.md"
            skill.parent.mkdir()
            skill.write_text("Pi coordinator")
            with self.assertRaisesRegex(ValueError, "Coordinator skill"):
                spawn.launch(args(skill=[str(skill)], dry_run=True))

    def test_narrow_pane_splits_down(self):
        self.assertEqual(spawn.choose_direction({"panes": [
            {"pane_id": "other", "rect": {"width": 999, "height": 1}},
            {"pane_id": "caller", "rect": {"width": 60, "height": 66}},
        ]}, "caller"), "down")

    def test_transport_uses_argv_and_surfaces_stderr(self):
        with patch.object(spawn.subprocess, "run", return_value=subprocess.CompletedProcess([], 1, "", '{"error":"blocked"}')) as run:
            with self.assertRaisesRegex(RuntimeError, "blocked"):
                spawn.herdr("agent", "prompt", "helper", "' ; touch /tmp/never-execute")
            self.assertEqual(run.call_args.args[0][-1], "' ; touch /tmp/never-execute")
            self.assertNotIn("shell", run.call_args.kwargs)

    def test_cli_rejects_unknown_agent_before_launch(self):
        result = subprocess.run([
            os.sys.executable, str(Path(spawn.__file__)), "--agent", "unknown", "--task", "test",
        ], capture_output=True, text=True)
        self.assertEqual(result.returncode, 2)
        self.assertIn("invalid choice", result.stderr)


if __name__ == "__main__":
    unittest.main()
