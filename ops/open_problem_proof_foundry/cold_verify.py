#!/usr/bin/env python3
"""Cold-input verifier using exact Fraction sparse-polynomial arithmetic."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import subprocess
import sys
import uuid
from fractions import Fraction
from pathlib import Path
from typing import Any


RATIONAL_RE = re.compile(r"^-?(?:0|[1-9][0-9]*)(?:/[1-9][0-9]*)?$")
IDENT_RE = re.compile(r"^[A-Za-z][A-Za-z0-9_]*$")
Exponent = tuple[int, int, int]
Polynomial = dict[Exponent, Fraction]


class VerificationError(ValueError):
    pass


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(65536), b""):
            digest.update(chunk)
    return digest.hexdigest()


def parse_fraction(value: Any) -> Fraction:
    if not isinstance(value, str) or not RATIONAL_RE.fullmatch(value):
        raise VerificationError(f"invalid exact rational: {value!r}")
    return Fraction(value)


def normalize(poly: Polynomial) -> Polynomial:
    return {powers: coefficient for powers, coefficient in poly.items() if coefficient}


def add(left: Polynomial, right: Polynomial) -> Polynomial:
    result = dict(left)
    for powers, coefficient in right.items():
        result[powers] = result.get(powers, Fraction(0)) + coefficient
    return normalize(result)


def neg(poly: Polynomial) -> Polynomial:
    return {powers: -coefficient for powers, coefficient in poly.items()}


def sub(left: Polynomial, right: Polynomial) -> Polynomial:
    return add(left, neg(right))


def mul(left: Polynomial, right: Polynomial) -> Polynomial:
    result: Polynomial = {}
    for lp, lc in left.items():
        for rp, rc in right.items():
            powers = tuple(a + b for a, b in zip(lp, rp, strict=True))
            result[powers] = result.get(powers, Fraction(0)) + lc * rc
    return normalize(result)


def derivative(poly: Polynomial, variable: int) -> Polynomial:
    result: Polynomial = {}
    for powers, coefficient in poly.items():
        exponent = powers[variable]
        if exponent == 0:
            continue
        next_powers = list(powers)
        next_powers[variable] -= 1
        key = tuple(next_powers)
        result[key] = result.get(key, Fraction(0)) + coefficient * exponent
    return normalize(result)


def determinant3(matrix: list[list[Polynomial]]) -> Polynomial:
    a, b, c = matrix[0]
    d, e, f = matrix[1]
    g, h, i = matrix[2]
    return add(sub(mul(a, sub(mul(e, i), mul(f, h))), mul(b, sub(mul(d, i), mul(f, g)))), mul(c, sub(mul(d, h), mul(e, g))))


def evaluate(poly: Polynomial, point: tuple[Fraction, Fraction, Fraction]) -> Fraction:
    value = Fraction(0)
    for powers, coefficient in poly.items():
        term = coefficient
        for coordinate, exponent in zip(point, powers, strict=True):
            term *= coordinate**exponent
        value += term
    return value


def load_candidate(problem: dict[str, Any], candidate: dict[str, Any]) -> tuple[list[Polynomial], list[tuple[Fraction, Fraction, Fraction]], tuple[Fraction, Fraction, Fraction]]:
    if problem.get("schema_version") != "open-problem-proof-line/problem/v1":
        raise VerificationError("unsupported problem schema")
    if candidate.get("schema_version") != "open-problem-proof-line/candidate/v1":
        raise VerificationError("unsupported candidate schema")
    if candidate.get("problem_id") != problem.get("problem_id"):
        raise VerificationError("problem ID mismatch")
    if problem.get("statement_gate", {}).get("status") != "pilot-accepted":
        raise VerificationError("statement gate is not accepted for pilot use")
    if candidate.get("variables") != ["x", "y", "z"]:
        raise VerificationError("cold verifier accepts only x,y,z")
    if problem["counterexample_contract"].get("dimension") != 3:
        raise VerificationError("cold verifier accepts only dimension 3")
    coordinates_data = candidate.get("coordinates")
    if not isinstance(coordinates_data, list) or len(coordinates_data) != 3:
        raise VerificationError("expected three coordinate polynomials")
    coordinates: list[Polynomial] = []
    for expected_name, coordinate in zip(("P", "Q", "R"), coordinates_data, strict=True):
        if coordinate.get("name") != expected_name or not IDENT_RE.fullmatch(expected_name):
            raise VerificationError("coordinate name mismatch")
        terms = coordinate.get("terms")
        if not isinstance(terms, list) or not terms:
            raise VerificationError("empty coordinate polynomial")
        polynomial: Polynomial = {}
        for term in terms:
            coefficient = parse_fraction(term.get("coefficient"))
            powers = term.get("powers")
            if not isinstance(powers, list) or len(powers) != 3 or any(type(x) is not int or x < 0 for x in powers):
                raise VerificationError("invalid exponent vector")
            key = tuple(powers)
            if key in polynomial:
                raise VerificationError("duplicate exponent vector")
            polynomial[key] = coefficient
        coordinates.append(normalize(polynomial))
    raw_witnesses = candidate.get("witnesses")
    if not isinstance(raw_witnesses, list) or len(raw_witnesses) < 2:
        raise VerificationError("too few witnesses")
    witnesses: list[tuple[Fraction, Fraction, Fraction]] = []
    for point in raw_witnesses:
        if not isinstance(point, list) or len(point) != 3:
            raise VerificationError("invalid witness dimension")
        witnesses.append(tuple(parse_fraction(value) for value in point))
    raw_image = candidate.get("expected_image")
    if not isinstance(raw_image, list) or len(raw_image) != 3:
        raise VerificationError("invalid expected image")
    expected_image = tuple(parse_fraction(value) for value in raw_image)
    return coordinates, witnesses, expected_image


def fraction_text(value: Fraction) -> str:
    return str(value.numerator) if value.denominator == 1 else f"{value.numerator}/{value.denominator}"


def lean_fraction(value: Fraction) -> str:
    if value.denominator == 1:
        return f"({value.numerator} : Rat)"
    return f"(({value.numerator} : Rat) / {value.denominator})"


def lean_polynomial(poly: Polynomial) -> str:
    terms: list[str] = []
    for powers in sorted(poly, reverse=True):
        coefficient = poly[powers]
        factors = [f"{name}^{power}" if power != 1 else name for name, power in zip(("x", "y", "z"), powers, strict=True) if power]
        if factors:
            terms.append(" * ".join([lean_fraction(coefficient), *factors]))
        else:
            terms.append(lean_fraction(coefficient))
    return " + ".join(terms) if terms else "(0 : Rat)"


def lean_polynomial_data(poly: Polynomial) -> str:
    rows = []
    for powers in sorted(poly, reverse=True):
        coefficient = lean_fraction(poly[powers])
        rows.append(
            "  { coefficient := "
            + coefficient
            + f", px := {powers[0]}, py := {powers[1]}, pz := {powers[2]} }}"
        )
    return "[\n" + ",\n".join(rows) + "\n]"


def generate_lean(coordinates: list[Polynomial], witnesses: list[tuple[Fraction, Fraction, Fraction]], expected_image: tuple[Fraction, Fraction, Fraction], determinant: Fraction) -> str:
    derivatives = [[derivative(poly, axis) for axis in range(3)] for poly in coordinates]
    names = ("P", "Q", "R")
    lines = [
        "import Init.Data.Rat",
        "import Init.Grind",
        "import Init.GrindInstances.Ring.Rat",
        "",
        "namespace JacobianPilot",
        "",
        "structure Term3 where",
        "  coefficient : Rat",
        "  px : Nat",
        "  py : Nat",
        "  pz : Nat",
        "deriving Repr",
        "",
        "abbrev Poly3 := List Term3",
        "",
        "def Term3.eval (t : Term3) (x y z : Rat) : Rat :=",
        "  t.coefficient * x^t.px * y^t.py * z^t.pz",
        "",
        "def Poly3.eval (p : Poly3) (x y z : Rat) : Rat :=",
        "  p.foldl (fun acc term => acc + term.eval x y z) 0",
        "",
        "def Term3.derivative (axis : Fin 3) (t : Term3) : Option Term3 :=",
        "  match axis with",
        "  | 0 => if t.px = 0 then none else some { t with coefficient := t.coefficient * t.px, px := t.px - 1 }",
        "  | 1 => if t.py = 0 then none else some { t with coefficient := t.coefficient * t.py, py := t.py - 1 }",
        "  | 2 => if t.pz = 0 then none else some { t with coefficient := t.coefficient * t.pz, pz := t.pz - 1 }",
        "",
        "def Poly3.derivative (axis : Fin 3) (p : Poly3) : Poly3 :=",
        "  p.filterMap (Term3.derivative axis)",
        "",
    ]
    for name, poly in zip(names, coordinates, strict=True):
        poly_name = name.lower() + "Poly"
        lines.extend(
            [
                f"def {poly_name} : Poly3 := {lean_polynomial_data(poly)}",
                "",
                f"def {name} (x y z : Rat) : Rat := {poly_name}.eval x y z",
                "",
                f"theorem {name}_expanded (x y z : Rat) : {name} x y z = {lean_polynomial(poly)} := by",
                f"  simp [{name}, Poly3.eval, Term3.eval, {poly_name}]",
                "  grind",
                "",
            ]
        )
    derivative_lemma_names = []
    for row_name, row in zip(names, derivatives, strict=True):
        poly_name = row_name.lower() + "Poly"
        for axis, (variable_name, derivative_poly) in enumerate(zip(("x", "y", "z"), row, strict=True)):
            function_name = f"d{row_name}d{variable_name}"
            lemma_name = function_name + "_expanded"
            derivative_lemma_names.append(lemma_name)
            lines.extend(
                [
                    f"def {function_name} (x y z : Rat) : Rat :=",
                    f"  ({poly_name}.derivative {axis}).eval x y z",
                    "",
                    f"theorem {lemma_name} (x y z : Rat) :",
                    f"    {function_name} x y z = {lean_polynomial(derivative_poly)} := by",
                    f"  simp [{function_name}, Poly3.derivative, Term3.derivative, Poly3.eval, Term3.eval, {poly_name}]",
                    "  grind",
                    "",
                ]
            )
    lines.extend(
        [
            "def det3 (a b c d e f g h i : Rat) : Rat :=",
            "  a * (e * i - f * h) - b * (d * i - f * g) + c * (d * h - e * g)",
            "",
            "def jacDet (x y z : Rat) : Rat :=",
            "  det3 (dPdx x y z) (dPdy x y z) (dPdz x y z)",
            "       (dQdx x y z) (dQdy x y z) (dQdz x y z)",
            "       (dRdx x y z) (dRdy x y z) (dRdz x y z)",
            "",
            f"theorem jacobian_determinant_constant (x y z : Rat) : jacDet x y z = {lean_fraction(determinant)} := by",
            "  unfold jacDet det3",
            "  rw [" + ", ".join(derivative_lemma_names) + "]",
            "  grind",
            "",
            "structure Point3 where",
            "  x : Rat",
            "  y : Rat",
            "  z : Rat",
            "deriving Repr, DecidableEq",
            "",
            "theorem point3_ext (a b : Point3)",
            "    (hx : a.x = b.x) (hy : a.y = b.y) (hz : a.z = b.z) : a = b := by",
            "  cases a",
            "  cases b",
            "  cases hx",
            "  cases hy",
            "  cases hz",
            "  rfl",
            "",
            "def F (p : Point3) : Point3 :=",
            "  { x := P p.x p.y p.z, y := Q p.x p.y p.z, z := R p.x p.y p.z }",
            "",
        ]
    )
    for index, point in enumerate(witnesses):
        lines.append(f"def p{index} : Point3 := {{ x := {lean_fraction(point[0])}, y := {lean_fraction(point[1])}, z := {lean_fraction(point[2])} }}")
    lines.extend(
        [
            f"def target : Point3 := {{ x := {lean_fraction(expected_image[0])}, y := {lean_fraction(expected_image[1])}, z := {lean_fraction(expected_image[2])} }}",
            "",
            "theorem witnesses_distinct : p0 ≠ p1 := by",
            "  intro h",
            "  have hx := congrArg Point3.x h",
            "  unfold p0 p1 at hx",
            "  grind",
            "",
        ]
    )
    for index in range(len(witnesses)):
        lines.extend(
            [
                f"theorem collision_{index} : F p{index} = target := by",
                "  apply point3_ext",
                "  · unfold F p" + str(index) + " target; rw [P_expanded]; grind",
                "  · unfold F p" + str(index) + " target; rw [Q_expanded]; grind",
                "  · unfold F p" + str(index) + " target; rw [R_expanded]; grind",
                "",
            ]
        )
    lines.extend(
        [
            "theorem internal_counterexample_certificate :",
            "    (∀ x y z : Rat, jacDet x y z = " + lean_fraction(determinant) + ") ∧",
            "    p0 ≠ p1 ∧ F p0 = target ∧ F p1 = target := by",
            "  exact ⟨jacobian_determinant_constant, witnesses_distinct, collision_0, collision_1⟩",
            "",
            "#print axioms jacobian_determinant_constant",
            "#print axioms witnesses_distinct",
            "#print axioms collision_0",
            "#print axioms internal_counterexample_certificate",
            "",
            "end JacobianPilot",
            "",
        ]
    )
    return "\n".join(lines)


def verify_manifest(bundle: Path) -> dict[str, Any]:
    manifest_path = bundle / "input-manifest.json"
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    for relative_path, expected_hash in manifest.get("files", {}).items():
        actual_path = bundle / relative_path
        if not actual_path.is_file() or sha256(actual_path) != expected_hash:
            raise VerificationError(f"input hash mismatch: {relative_path}")
    return manifest


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--bundle", type=Path, required=True)
    parser.add_argument("--lean", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--run-id")
    args = parser.parse_args()
    run_id = args.run_id or f"verifier-{uuid.uuid4()}"
    report: dict[str, Any] = {
        "schema_version": "open-problem-proof-line/verifier-report/v1",
        "run_id": run_id,
        "role": "cold-input-deterministic-verifier",
        "engine": "python-fractions-sparse-polynomial+lean-kernel",
        "reasoning_access": "artifact-only",
        "independence_limit": "same host and orchestrator; distinct run ID and algebra engine",
    }
    try:
        verify_manifest(args.bundle)
        problem_path = args.bundle / "problem.json"
        candidate_path = args.bundle / "candidate.json"
        problem = json.loads(problem_path.read_text(encoding="utf-8"))
        candidate = json.loads(candidate_path.read_text(encoding="utf-8"))
        coordinates, witnesses, expected_image = load_candidate(problem, candidate)
        jacobian = [[derivative(poly, variable) for variable in range(3)] for poly in coordinates]
        determinant_poly = determinant3(jacobian)
        constant_key = (0, 0, 0)
        jacobian_ok = set(determinant_poly) == {constant_key} and determinant_poly[constant_key] != 0
        determinant = determinant_poly.get(constant_key, Fraction(0))
        distinct_ok = len(set(witnesses)) >= 2
        images = [tuple(evaluate(poly, point) for poly in coordinates) for point in witnesses]
        collision_ok = bool(images) and all(image == expected_image for image in images)
        obligations = {
            "exact_sparse_polynomial_map": True,
            "jacobian_determinant_is_nonzero_constant": jacobian_ok,
            "at_least_two_distinct_exact_witnesses": distinct_ok,
            "all_witnesses_have_the_same_exact_image": collision_ok,
        }
        failed = [name for name, passed in obligations.items() if not passed]
        if failed:
            raise VerificationError("failed exact obligations: " + ",".join(failed))

        formal_dir = args.bundle / "formal"
        formal_dir.mkdir(parents=True, exist_ok=True)
        lean_path = formal_dir / "JacobianPilot.lean"
        lean_source = generate_lean(coordinates, witnesses, expected_image, determinant)
        lean_path.write_text(lean_source, encoding="utf-8")
        forbidden = []
        if re.search(r"(?m)^\s*axiom\b", lean_source):
            forbidden.append("axiom-declaration")
        if re.search(r"\bsorry\b", lean_source):
            forbidden.append("sorry")
        if re.search(r"(?m)^\s*unsafe\b", lean_source):
            forbidden.append("unsafe-declaration")
        if forbidden:
            raise VerificationError("forbidden Lean construct: " + ",".join(forbidden))
        if not args.lean.is_file():
            raise VerificationError("pinned Lean executable does not exist")
        completed = subprocess.run(
            [str(args.lean), lean_path.name],
            cwd=formal_dir,
            text=True,
            capture_output=True,
            timeout=60,
            check=False,
        )
        lean_output = completed.stdout + completed.stderr
        if completed.returncode != 0:
            raise VerificationError("Lean kernel rejected certificate: " + lean_output[-2000:])
        audit_bodies = re.findall(r"depends on axioms: \[([^\]]*)\]", lean_output)
        if len(audit_bodies) < 4:
            raise VerificationError("Lean proof audit did not report four theorem dependency sets")
        allowed_axioms = {"propext", "Classical.choice", "Quot.sound"}
        observed_axioms: set[str] = set()
        for body in audit_bodies:
            observed_axioms.update(item.strip() for item in body.split(",") if item.strip())
        unexpected_axioms = sorted(observed_axioms - allowed_axioms)
        if unexpected_axioms:
            raise VerificationError("unexpected Lean axiom dependencies: " + ",".join(unexpected_axioms))
        report.update(
            {
                "status": "pass",
                "obligations": obligations,
                "observed": {
                    "jacobian_determinant": fraction_text(determinant),
                    "witness_images": [[fraction_text(value) for value in image] for image in images],
                },
                "formal": {
                    "lean_executable": str(args.lean),
                    "lean_source_sha256": sha256(lean_path),
                    "formal_derivative_definition": "kernel-reduced-from-sparse-polynomial-AST",
                    "proof_audit_theorem_count": 4,
                    "foundational_axiom_allowlist": sorted(allowed_axioms),
                    "observed_foundational_axioms": sorted(observed_axioms),
                    "unexpected_axioms": [],
                    "forbidden_constructs": [],
                },
                "artifact_hashes": {
                    "problem.json": sha256(problem_path),
                    "candidate.json": sha256(candidate_path),
                    "formal/JacobianPilot.lean": sha256(lean_path),
                },
            }
        )
    except (VerificationError, KeyError, TypeError, json.JSONDecodeError, subprocess.TimeoutExpired) as error:
        report.update({"status": "fail", "error_class": type(error).__name__, "error": str(error)})

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(json.dumps({"status": report["status"], "run_id": run_id}))
    return 0 if report["status"] == "pass" else 1


if __name__ == "__main__":
    sys.exit(main())
