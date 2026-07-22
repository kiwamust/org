#!/usr/bin/env python3
"""SymPy-based maker oracle for the Jacobian pilot.

Candidate input is data, never executable source.  Expressions are reconstructed
only from a validated sparse-polynomial AST.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
import uuid
from fractions import Fraction
from pathlib import Path
from typing import Any

import sympy as sp


RATIONAL_RE = re.compile(r"^-?(?:0|[1-9][0-9]*)(?:/[1-9][0-9]*)?$")


class CandidateError(ValueError):
    pass


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(65536), b""):
            digest.update(chunk)
    return digest.hexdigest()


def exact_fraction(value: Any) -> Fraction:
    if not isinstance(value, str) or not RATIONAL_RE.fullmatch(value):
        raise CandidateError(f"not an exact rational literal: {value!r}")
    return Fraction(value)


def validate(problem: dict[str, Any], candidate: dict[str, Any]) -> None:
    if problem.get("schema_version") != "open-problem-proof-line/problem/v1":
        raise CandidateError("unsupported problem schema")
    if candidate.get("schema_version") != "open-problem-proof-line/candidate/v1":
        raise CandidateError("unsupported candidate schema")
    if candidate.get("problem_id") != problem.get("problem_id"):
        raise CandidateError("candidate targets a different problem")
    if problem.get("statement_gate", {}).get("status") != "pilot-accepted":
        raise CandidateError("problem statement is not accepted for pilot use")
    variables = candidate.get("variables")
    dimension = problem["counterexample_contract"]["dimension"]
    if variables != ["x", "y", "z"] or dimension != 3:
        raise CandidateError("pilot accepts exactly the variables x,y,z in dimension 3")
    coordinates = candidate.get("coordinates")
    if not isinstance(coordinates, list) or len(coordinates) != dimension:
        raise CandidateError("coordinate count does not match dimension")
    if [item.get("name") for item in coordinates] != ["P", "Q", "R"]:
        raise CandidateError("coordinate identifiers must be P,Q,R")
    for coordinate in coordinates:
        terms = coordinate.get("terms")
        if not isinstance(terms, list) or not terms:
            raise CandidateError("every coordinate needs at least one term")
        seen: set[tuple[int, int, int]] = set()
        for term in terms:
            exact_fraction(term.get("coefficient"))
            powers = term.get("powers")
            if (
                not isinstance(powers, list)
                or len(powers) != dimension
                or any(type(power) is not int or power < 0 for power in powers)
            ):
                raise CandidateError("powers must be three nonnegative integers")
            key = tuple(powers)
            if key in seen:
                raise CandidateError("sparse polynomial contains duplicate powers")
            seen.add(key)
    witnesses = candidate.get("witnesses")
    if not isinstance(witnesses, list) or len(witnesses) < 2:
        raise CandidateError("at least two witnesses are required")
    for point in witnesses:
        if not isinstance(point, list) or len(point) != dimension:
            raise CandidateError("each witness must have three coordinates")
        for value in point:
            exact_fraction(value)
    expected_image = candidate.get("expected_image")
    if not isinstance(expected_image, list) or len(expected_image) != dimension:
        raise CandidateError("expected_image must have three coordinates")
    for value in expected_image:
        exact_fraction(value)


def to_sympy_fraction(value: str) -> sp.Rational:
    fraction = exact_fraction(value)
    return sp.Rational(fraction.numerator, fraction.denominator)


def build_coordinate(
    coordinate: dict[str, Any], symbols: tuple[sp.Symbol, ...]
) -> sp.Expr:
    expression: sp.Expr = sp.Integer(0)
    for term in coordinate["terms"]:
        monomial: sp.Expr = to_sympy_fraction(term["coefficient"])
        for symbol, power in zip(symbols, term["powers"], strict=True):
            monomial *= symbol**power
        expression += monomial
    return sp.expand(expression)


def verify(problem: dict[str, Any], candidate: dict[str, Any]) -> dict[str, Any]:
    validate(problem, candidate)
    symbols = tuple(sp.symbols("x y z"))
    coordinates = tuple(
        build_coordinate(coordinate, symbols) for coordinate in candidate["coordinates"]
    )
    determinant = sp.expand(sp.Matrix(coordinates).jacobian(symbols).det())
    jacobian_ok = not determinant.free_symbols and determinant != 0

    witnesses = [tuple(to_sympy_fraction(value) for value in point) for point in candidate["witnesses"]]
    distinct_ok = len(set(witnesses)) >= 2
    images = [
        tuple(sp.expand(expression.subs(dict(zip(symbols, point, strict=True)))) for expression in coordinates)
        for point in witnesses
    ]
    expected_image = tuple(to_sympy_fraction(value) for value in candidate["expected_image"])
    collision_ok = bool(images) and all(image == expected_image for image in images)

    obligations = {
        "exact_sparse_polynomial_map": True,
        "jacobian_determinant_is_nonzero_constant": bool(jacobian_ok),
        "at_least_two_distinct_exact_witnesses": bool(distinct_ok),
        "all_witnesses_have_the_same_exact_image": bool(collision_ok),
    }
    failed = [name for name, passed in obligations.items() if not passed]
    return {
        "status": "pass" if not failed else "fail",
        "obligations": obligations,
        "failed_obligations": failed,
        "observed": {
            "jacobian_determinant": str(determinant),
            "witness_images": [[str(value) for value in image] for image in images],
        },
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--problem", type=Path, required=True)
    parser.add_argument("--candidate", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--run-id")
    args = parser.parse_args()

    run_id = args.run_id or f"maker-{uuid.uuid4()}"
    report: dict[str, Any] = {
        "schema_version": "open-problem-proof-line/maker-report/v1",
        "run_id": run_id,
        "role": "search-maker-oracle",
        "engine": f"sympy-{sp.__version__}",
        "problem_sha256": sha256(args.problem),
        "candidate_sha256": sha256(args.candidate),
    }
    try:
        problem = json.loads(args.problem.read_text(encoding="utf-8"))
        candidate = json.loads(args.candidate.read_text(encoding="utf-8"))
        report.update(verify(problem, candidate))
    except (CandidateError, KeyError, TypeError, json.JSONDecodeError) as error:
        report.update(
            {
                "status": "fail",
                "obligations": {"exact_sparse_polynomial_map": False},
                "failed_obligations": ["exact_sparse_polynomial_map"],
                "error_class": type(error).__name__,
                "error": str(error),
            }
        )

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(json.dumps({"status": report["status"], "run_id": run_id}))
    return 0 if report["status"] == "pass" else 1


if __name__ == "__main__":
    sys.exit(main())
