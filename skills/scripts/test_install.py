import json
import os
from pathlib import Path
import re
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[2]
INSTALLER = ROOT / "skills/scripts/link-skills.sh"


class InstallTest(unittest.TestCase):
    def test_pi_only_migration_removes_owned_links_and_preserves_foreign_resources(self):
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            old_skill = ROOT / "skills/ppstack/skills/petey"
            homes = [".agents/skills", ".pi/agent/skills", ".claude/skills", ".codex/skills", ".cursor/skills"]
            for relative in homes:
                target = home / relative
                target.mkdir(parents=True)
                (target / "petey").symlink_to(old_skill)
                (target / "setup-petey").symlink_to(ROOT / "skills/setup-petey")
                (target / "third-party").symlink_to(home / "missing-vendor-skill")
            foreign_how = home / ".pi/agent/skills/how"
            foreign_how.symlink_to(home / "vendor-how")
            real = home / ".claude/skills/my-skill"
            real.mkdir()
            (real / "SKILL.md").write_text("keep me")
            agents = home / ".pi/agent/agents"
            agents.mkdir()
            (agents / "comment-sicko.md").symlink_to(ROOT / "skills/ppstack/agents/comment-sicko.md")
            (agents / "custom.md").write_text("keep me")
            env = {**os.environ, "HOME": str(home)}
            for _ in range(2):
                result = subprocess.run(["bash", str(INSTALLER)], env=env, capture_output=True, text=True)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual((home / ".pi/agent/skills/petey-pi").resolve(), ROOT / "skills/ppstack/skills/petey-pi")
                self.assertEqual((home / ".pi/agent/skills/spawn-subagent").resolve(), ROOT / "skills/spawn-subagent")
                self.assertEqual((home / ".pi/agent/skills/setup-petey-pi").resolve(), ROOT / "skills/setup-petey-pi")
                self.assertEqual((home / ".agents/skills/cloudflare-setup").resolve(), ROOT / "skills/cloudflare-setup")
                for relative in homes:
                    self.assertFalse((home / relative / "petey").is_symlink())
                    self.assertFalse((home / relative / "setup-petey").is_symlink())
                    self.assertTrue((home / relative / "third-party").is_symlink())
                self.assertFalse((home / ".agents/skills/petey-pi").exists())
                self.assertFalse((agents / "comment-sicko.md").is_symlink())
                self.assertEqual((agents / "custom.md").read_text(), "keep me")
                self.assertEqual((real / "SKILL.md").read_text(), "keep me")
                self.assertEqual(os.readlink(foreign_how), str(home / "vendor-how"))
                self.assertIn("third-party skill link", result.stderr)

    def test_pi_config_and_docs_have_no_retired_runtime_calls_or_broken_links(self):
        settings = json.loads((ROOT / "pi/settings.json").read_text())
        self.assertNotIn("subagents", settings)
        self.assertNotIn("npm:pi-subagents", settings["packages"])
        for path in (ROOT / "skills").rglob("*.md"):
            text = path.read_text()
            self.assertNotRegex(text, r"workflowScript|runs\.(?:run|all|lanes)\(|subagent\(\{|pi-subagents|/petey/", str(path))
            if path.name == "SKILL.md":
                self.assertTrue(text.startswith("---\n"), str(path))
                self.assertRegex(text, r"(?m)^description: .+", str(path))
                self.assertIn(f"name: {path.parent.name}\n", text, str(path))
            for reference in re.findall(r"\]\(([^)]+)\)", text):
                target = reference.split("#")[0]
                if not target or "://" in target or target == "url" or target.startswith(("/", "mailto:")) or "<" in target:
                    continue
                self.assertTrue((path.parent / target).exists(), f"{path}: {reference}")

    def test_refuses_whole_directory_symlinks_before_removing_anything(self):
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            (home / ".agents").mkdir()
            (home / ".agents/skills").symlink_to(ROOT / "skills", target_is_directory=True)
            result = subprocess.run(["bash", str(INSTALLER)], env={**os.environ, "HOME": str(home)}, capture_output=True, text=True)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("destination directory is a symlink", result.stderr)
            self.assertTrue((ROOT / "skills/cloudflare-setup/SKILL.md").is_file())


if __name__ == "__main__":
    unittest.main()
