# Open Problem Proof Foundry engines

This directory is the Org-owned executable surface for machine-verified mathematical
certificates. The current adapter is intentionally limited to the three-variable Jacobian
counterexample contract stored in Work.

Files:

- `run_jacobian_e2e.py`: orchestrates canonical, mutant, tamper, statement-gate, Lean, and
  cross-engine checks;
- `maker_oracle.py`: SymPy search-maker oracle using validated exact sparse-polynomial data;
- `cold_verify.py`: independent `fractions.Fraction` engine and Lean certificate generator.

See `../../docs/OPEN_PROBLEM_PROOF_LINE.md` for ownership, gates, and the canonical command.
Run outputs belong under Work `_data-evidence`; do not commit generated bundles here.
