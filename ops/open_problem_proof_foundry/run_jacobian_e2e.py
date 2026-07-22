#!/usr/bin/env python3
"""Run the Jacobian source-to-certificate-to-cold-replay adapter E2E."""

from __future__ import annotations

import argparse
import copy
import hashlib
import json
import shutil
import subprocess
import sys
import uuid
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(65536), b""):
            digest.update(chunk)
    return digest.hexdigest()


def write_json(path: Path, value: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def set_path(document: Any, path: list[Any], value: Any) -> None:
    cursor = document
    for key in path[:-1]:
        cursor = cursor[key]
    cursor[path[-1]] = value


def run_process(command: list[str]) -> subprocess.CompletedProcess[str]:
    return subprocess.run(command, text=True, capture_output=True, timeout=90, check=False)


def load_report_or_process_failure(
    path: Path, process: subprocess.CompletedProcess[str], role: str
) -> dict[str, Any]:
    if path.is_file():
        return json.loads(path.read_text(encoding="utf-8"))
    return {
        "status": "fail",
        "role": role,
        "failed_obligations": ["execution_environment_available"],
        "error_class": "MissingChildReport",
        "error": (process.stderr or process.stdout or "child process produced no report")[-2000:],
    }


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Verify a Work-owned Jacobian case with Org-owned engines."
    )
    parser.add_argument(
        "--case-root",
        type=Path,
        required=True,
        help="Work directory containing problem.json, source-statement.md, candidates/, and mutants/",
    )
    parser.add_argument(
        "--output-root",
        type=Path,
        required=True,
        help="Data-Evidence directory that receives immutable per-run evidence",
    )
    parser.add_argument(
        "--engine-root",
        type=Path,
        default=Path(__file__).resolve().parent,
        help="Org engine directory; defaults to this script's directory",
    )
    parser.add_argument("--lean", type=Path, required=True)
    parser.add_argument("--maker-python", type=Path, default=Path(sys.executable))
    parser.add_argument("--verifier-python", type=Path, default=Path(sys.executable))
    parser.add_argument(
        "--failure-executable",
        type=Path,
        default=Path("/usr/bin/false"),
        help="Executable used to prove child-runtime failure is reported fail-closed",
    )
    args = parser.parse_args()
    case_root = args.case_root.resolve()
    output_root = args.output_root.resolve()
    engine_root = args.engine_root.resolve()
    maker_script = engine_root / "maker_oracle.py"
    verifier_script = engine_root / "cold_verify.py"
    problem_path = case_root / "problem.json"
    source_path = case_root / "source-statement.md"
    candidate_path = case_root / "candidates/canonical.json"
    mutant_paths = sorted((case_root / "mutants").glob("*.json"))

    required_paths = [
        maker_script,
        verifier_script,
        problem_path,
        source_path,
        candidate_path,
    ]
    missing = [str(path) for path in required_paths if not path.is_file()]
    if missing:
        parser.error("missing required path(s): " + ", ".join(missing))
    if not mutant_paths:
        parser.error(f"no negative controls found under {case_root / 'mutants'}")

    execution_id = uuid.uuid4().hex
    maker_run_id = f"maker-{uuid.uuid4()}"
    verifier_run_id = f"verifier-{uuid.uuid4()}"
    timestamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    run_dir = output_root / f"{timestamp}-{execution_id[:8]}"
    run_dir.mkdir(parents=True, exist_ok=False)

    report: dict[str, Any] = {
        "schema_version": "open-problem-proof-line/e2e-report/v1",
        "execution_id": execution_id,
        "started_at": datetime.now(timezone.utc).isoformat(),
        "risk_class": "tracked-engine-and-work-artifact; local-evidence-output",
        "governance_constraint": "require a current RedTeam PASS before tracked mutation or publication workflow",
        "evidence_authentication": "sha256-integrity-only; signed external attestation pending",
        "stages": {},
        "maker_run_id": maker_run_id,
        "verifier_run_id": verifier_run_id,
        "execution_environment": {
            "runner_python": sys.executable,
            "maker_python": str(args.maker_python.resolve()),
            "verifier_python": str(args.verifier_python.resolve()),
            "failure_executable": str(args.failure_executable.resolve()),
            "lean": str(args.lean.resolve()),
            "engine_root": str(engine_root),
            "case_root": str(case_root),
            "output_root": str(output_root),
        },
    }

    canonical_report_path = run_dir / "maker-canonical.json"
    canonical_process = run_process(
        [
            str(args.maker_python.resolve()),
            str(maker_script),
            "--problem",
            str(problem_path),
            "--candidate",
            str(candidate_path),
            "--output",
            str(canonical_report_path),
            "--run-id",
            maker_run_id,
        ]
    )
    canonical_report = load_report_or_process_failure(
        canonical_report_path, canonical_process, "search-maker-oracle"
    )
    report["stages"]["maker_canonical"] = {
        "status": canonical_report["status"],
        "returncode": canonical_process.returncode,
        "report_sha256": sha256(canonical_report_path) if canonical_report_path.is_file() else None,
    }

    unavailable_report_path = run_dir / "maker-unavailable-runtime.json"
    unavailable_process = run_process(
        [
            str(args.failure_executable.resolve()),
            str(maker_script),
            "--problem",
            str(problem_path),
            "--candidate",
            str(candidate_path),
            "--output",
            str(unavailable_report_path),
            "--run-id",
            f"maker-unavailable-{uuid.uuid4()}",
        ]
    )
    unavailable_report = load_report_or_process_failure(
        unavailable_report_path, unavailable_process, "search-maker-unavailable-runtime"
    )
    unavailable_failed_closed = (
        unavailable_process.returncode != 0
        and unavailable_report.get("status") == "fail"
        and unavailable_report.get("error_class") == "MissingChildReport"
        and "execution_environment_available"
        in unavailable_report.get("failed_obligations", [])
    )
    report["stages"]["maker_environment_control"] = {
        "status": "pass" if unavailable_failed_closed else "fail",
        "observed_child_status": unavailable_report.get("status"),
        "error_class": unavailable_report.get("error_class"),
        "failed_obligations": unavailable_report.get("failed_obligations", []),
    }

    base_candidate = json.loads(candidate_path.read_text(encoding="utf-8"))
    negative_results = []
    for mutant_path in mutant_paths:
        mutant = json.loads(mutant_path.read_text(encoding="utf-8"))
        candidate = copy.deepcopy(base_candidate)
        mutation = mutant["mutation"]
        set_path(candidate, mutation["path"], mutation["value"])
        mutated_candidate_path = run_dir / "mutants" / f"{mutant['mutant_id']}.candidate.json"
        mutated_report_path = run_dir / "mutants" / f"{mutant['mutant_id']}.report.json"
        write_json(mutated_candidate_path, candidate)
        process = run_process(
            [
                str(args.maker_python.resolve()),
                str(maker_script),
                "--problem",
                str(problem_path),
                "--candidate",
                str(mutated_candidate_path),
                "--output",
                str(mutated_report_path),
                "--run-id",
                f"maker-mutant-{uuid.uuid4()}",
            ]
        )
        mutant_report = load_report_or_process_failure(
            mutated_report_path, process, "search-maker-mutant-oracle"
        )
        expected_failure = mutant["expected_failed_obligation"]
        rejected_as_expected = (
            process.returncode != 0
            and mutant_report["status"] == "fail"
            and expected_failure in mutant_report.get("failed_obligations", [])
        )
        negative_results.append(
            {
                "mutant_id": mutant["mutant_id"],
                "status": "pass" if rejected_as_expected else "fail",
                "expected_failed_obligation": expected_failure,
                "observed_failed_obligations": mutant_report.get("failed_obligations", []),
                "report_sha256": sha256(mutated_report_path) if mutated_report_path.is_file() else None,
            }
        )
    report["stages"]["negative_controls"] = {
        "status": "pass" if all(item["status"] == "pass" for item in negative_results) else "fail",
        "count": len(negative_results),
        "results": negative_results,
    }

    bundle = run_dir / "cold-bundle"
    bundle.mkdir()
    shutil.copy2(problem_path, bundle / "problem.json")
    shutil.copy2(candidate_path, bundle / "candidate.json")
    shutil.copy2(source_path, bundle / "source-statement.md")
    input_manifest = {
        "schema_version": "open-problem-proof-line/input-manifest/v1",
        "maker_run_id": maker_run_id,
        "verifier_run_id": verifier_run_id,
        "files": {
            "problem.json": sha256(bundle / "problem.json"),
            "candidate.json": sha256(bundle / "candidate.json"),
            "source-statement.md": sha256(bundle / "source-statement.md"),
        },
    }
    write_json(bundle / "input-manifest.json", input_manifest)
    verifier_report_path = run_dir / "verifier-report.json"
    verifier_process = run_process(
        [
            str(args.verifier_python.resolve()),
            str(verifier_script),
            "--bundle",
            str(bundle),
            "--lean",
            str(args.lean.resolve()),
            "--output",
            str(verifier_report_path),
            "--run-id",
            verifier_run_id,
        ]
    )
    verifier_report = load_report_or_process_failure(
        verifier_report_path, verifier_process, "cold-input-deterministic-verifier"
    )
    report["stages"]["cold_replay"] = {
        "status": verifier_report["status"],
        "returncode": verifier_process.returncode,
        "report_sha256": sha256(verifier_report_path) if verifier_report_path.is_file() else None,
    }

    tampered_bundle = run_dir / "tampered-bundle"
    shutil.copytree(bundle, tampered_bundle)
    tampered_candidate_path = tampered_bundle / "candidate.json"
    tampered_candidate_path.write_text(
        tampered_candidate_path.read_text(encoding="utf-8") + "\n", encoding="utf-8"
    )
    tamper_report_path = run_dir / "tamper-verifier-report.json"
    tamper_process = run_process(
        [
            str(args.verifier_python.resolve()),
            str(verifier_script),
            "--bundle",
            str(tampered_bundle),
            "--lean",
            str(args.lean.resolve()),
            "--output",
            str(tamper_report_path),
            "--run-id",
            f"verifier-tamper-{uuid.uuid4()}",
        ]
    )
    tamper_report = load_report_or_process_failure(
        tamper_report_path, tamper_process, "cold-input-tamper-control"
    )
    tamper_rejected = (
        tamper_process.returncode != 0
        and tamper_report.get("status") == "fail"
        and "input hash mismatch" in tamper_report.get("error", "")
    )
    report["stages"]["manifest_tamper_control"] = {
        "status": "pass" if tamper_rejected else "fail",
        "observed_verifier_status": tamper_report.get("status"),
        "error_class": tamper_report.get("error_class"),
    }

    unapproved_bundle = run_dir / "unapproved-statement-bundle"
    shutil.copytree(bundle, unapproved_bundle)
    unapproved_problem_path = unapproved_bundle / "problem.json"
    unapproved_problem = json.loads(unapproved_problem_path.read_text(encoding="utf-8"))
    unapproved_problem["statement_gate"]["status"] = "unreviewed"
    write_json(unapproved_problem_path, unapproved_problem)
    unapproved_manifest_path = unapproved_bundle / "input-manifest.json"
    unapproved_manifest = json.loads(unapproved_manifest_path.read_text(encoding="utf-8"))
    unapproved_manifest["files"]["problem.json"] = sha256(unapproved_problem_path)
    write_json(unapproved_manifest_path, unapproved_manifest)
    unapproved_report_path = run_dir / "unapproved-statement-verifier-report.json"
    unapproved_process = run_process(
        [
            str(args.verifier_python.resolve()),
            str(verifier_script),
            "--bundle",
            str(unapproved_bundle),
            "--lean",
            str(args.lean.resolve()),
            "--output",
            str(unapproved_report_path),
            "--run-id",
            f"verifier-statement-gate-{uuid.uuid4()}",
        ]
    )
    unapproved_report = load_report_or_process_failure(
        unapproved_report_path, unapproved_process, "cold-input-statement-gate-control"
    )
    statement_gate_rejected = (
        unapproved_process.returncode != 0
        and unapproved_report.get("status") == "fail"
        and "statement gate is not accepted" in unapproved_report.get("error", "")
    )
    report["stages"]["statement_gate_control"] = {
        "status": "pass" if statement_gate_rejected else "fail",
        "observed_verifier_status": unapproved_report.get("status"),
        "error_class": unapproved_report.get("error_class"),
    }
    engines_agree = (
        canonical_report.get("status") == "pass"
        and verifier_report.get("status") == "pass"
        and canonical_report.get("observed") == verifier_report.get("observed")
    )
    report["stages"]["engine_agreement"] = {
        "status": "pass" if engines_agree else "fail",
        "maker_engine": canonical_report.get("engine"),
        "verifier_engine": verifier_report.get("engine"),
    }

    stage_statuses = [stage["status"] for stage in report["stages"].values()]
    report["status"] = "pass" if stage_statuses and all(status == "pass" for status in stage_statuses) else "fail"
    report["finished_at"] = datetime.now(timezone.utc).isoformat()
    report["publication_status"] = (
        "not-publishable-until-primary-source-mathematical-review-and-signed-attestation"
    )
    report["artifact_hashes"] = {
        "problem": sha256(problem_path),
        "candidate": sha256(candidate_path),
        "source_statement": sha256(source_path),
        "maker_report": sha256(canonical_report_path) if canonical_report_path.is_file() else None,
        "verifier_report": sha256(verifier_report_path) if verifier_report_path.is_file() else None,
    }
    final_report_path = run_dir / "e2e-report.json"
    write_json(final_report_path, report)
    print(json.dumps({"status": report["status"], "report": str(final_report_path), "execution_id": execution_id}, indent=2))
    return 0 if report["status"] == "pass" else 1


if __name__ == "__main__":
    sys.exit(main())
