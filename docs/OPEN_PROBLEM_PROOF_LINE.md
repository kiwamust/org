# Machine-Verified Open Problem Proof Line

## Purpose

Turn a proof or counterexample candidate into a bounded certificate that can be rejected or
accepted by deterministic machinery. The proof line does not delegate mathematical meaning,
novelty, attribution, or publication authority to a language model.

## Canonical ownership

| system | owns |
| --- | --- |
| Org | executable adapters, role separation, state transitions, UQG and stop conditions |
| Work | original problem interpretation, source inventory, candidate, artifact meaning, uncertainty |
| Data-Evidence | observed run reports, hashes, executable identities, pass/fail lineage |
| Codex | invokes the contract and proposes changes; it is not a long-term authority |

The executable code therefore belongs in this Org repository. A specific mathematical case
belongs under `/Users/kiwamusato/Work/work/org/research/machine-verified-open-problems/`.

## Non-skippable states

```text
candidate
  -> certificate-passed
  -> formally-verified
  -> independently-replayed
  -> mathematically-reviewed
  -> publishable
```

Each transition needs evidence from its own gate. A kernel pass does not establish the last
two states.

## Roles

| role | responsibility | forbidden |
| --- | --- | --- |
| Human Mathematical Owner | statement meaning, primary sources, final acceptance | silent approval |
| Search Maker | candidate generation and search trace | final acceptance of its own candidate |
| Oracle Owner | exact executable obligations | approximate-only pass |
| Formalizer | kernel-checkable certificate | `sorry`, custom `axiom`, `unsafe` |
| Cold Verifier | artifact-only independent replay | maker reasoning or source mutation |
| Literature Reviewer | novelty, attribution, prior work | treating a finite check as priority proof |

Maker and cold verifier use distinct run IDs and distinct algebra implementations. Same-host
execution is recorded as a residual independence limit.

## Current adapter: Jacobian certificate v1

The current adapter accepts exactly a three-variable sparse polynomial map with exact rational
literals. It checks a nonzero constant Jacobian determinant and at least two distinct witnesses
with the same exact image. The cold verifier reconstructs the polynomial engine with
`fractions.Fraction`, generates a Lean certificate from the original AST, and asks the pinned
Lean kernel to check formal differentiation, determinant, distinctness, and collision.

This is not a generic theorem prover. Another problem requires a new ProblemSpec contract,
finite oracle, falsifier set, formal adapter, and independent replay implementation.

## Required negative controls

- inexact literal;
- duplicate witnesses;
- nonconstant or zero Jacobian determinant;
- incorrect collision witness;
- post-manifest mutation;
- unapproved statement with a recomputed manifest;
- unavailable maker runtime producing a structured failure.

Positive success without these controls is not an accepted proof-line run.

## Canonical command

```bash
/opt/homebrew/bin/python3 \
  /Users/kiwamusato/Work/org/ops/open_problem_proof_foundry/run_jacobian_e2e.py \
  --case-root /Users/kiwamusato/Work/work/org/research/machine-verified-open-problems/jacobian \
  --output-root /Users/kiwamusato/Work/work/_data-evidence/open-problem-proof-foundry/jacobian \
  --maker-python /opt/homebrew/Caskroom/miniconda/base/bin/python3 \
  --verifier-python /opt/homebrew/bin/python3 \
  --lean /Users/kiwamusato/.elan/toolchains/leanprover--lean4---v4.31.0/bin/lean
```

The output directory is evidence, not tracked source. The Work case and Org engines are the
reconstructible source.

## Gates and stop conditions

Before tracked mutation or publication workflow, require the Work system RedTeam gate to be
`PASS`. Stop immediately on `BLOCK`, missing child reports, engine disagreement, unexpected
Lean dependencies, failing negative controls, or workspace-integrity errors.

`publishable` additionally requires primary-source review, literature/priority review, signed
external verifier attestation, and active human approval.
