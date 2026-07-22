#!/usr/bin/env python3
"""Static and CLI contract tests for the open-problem proof line."""

from __future__ import annotations

import json
import subprocess
import sys
import unittest
from pathlib import Path


ORG_ROOT = Path(__file__).resolve().parents[1]
ENGINE_ROOT = ORG_ROOT / "ops/open_problem_proof_foundry"
SKILL_ROOT = ORG_ROOT / "plugins/org/skills/org-machine-proof"
WORK_CASE = Path(
    "/Users/kiwamusato/Work/work/org/research/"
    "machine-verified-open-problems/jacobian"
)


class ProofFoundryContractTest(unittest.TestCase):
    def test_canonical_layout_exists(self) -> None:
        required = [
            ORG_ROOT / "docs/OPEN_PROBLEM_PROOF_LINE.md",
            ENGINE_ROOT / "run_jacobian_e2e.py",
            ENGINE_ROOT / "maker_oracle.py",
            ENGINE_ROOT / "cold_verify.py",
            SKILL_ROOT / "SKILL.md",
            WORK_CASE / "problem.json",
            WORK_CASE / "source-statement.md",
            WORK_CASE / "candidates/canonical.json",
        ]
        self.assertEqual([], [str(path) for path in required if not path.is_file()])

    def test_runner_exposes_split_roots(self) -> None:
        completed = subprocess.run(
            [sys.executable, str(ENGINE_ROOT / "run_jacobian_e2e.py"), "--help"],
            text=True,
            capture_output=True,
            check=False,
        )
        self.assertEqual(0, completed.returncode, completed.stderr)
        self.assertIn("--case-root", completed.stdout)
        self.assertIn("--output-root", completed.stdout)
        self.assertIn("--engine-root", completed.stdout)
        self.assertIn("--failure-executable", completed.stdout)

    def test_tracked_sources_do_not_depend_on_temporary_pilot(self) -> None:
        for path in ENGINE_ROOT.glob("*.py"):
            self.assertNotIn("/private/tmp/open-problem-proof-foundry", path.read_text())

    def test_skill_eval_set_is_parseable(self) -> None:
        data = json.loads((SKILL_ROOT / "evals/evals.json").read_text())
        self.assertEqual("org-machine-proof", data["skill_name"])
        self.assertEqual(3, len(data["evals"]))


if __name__ == "__main__":
    unittest.main()
