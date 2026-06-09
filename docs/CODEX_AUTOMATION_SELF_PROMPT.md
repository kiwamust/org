# Codex Automation — Org Self-Prompt

## Schedule

Run this Codex Automation every day:

- 08:00 JST
- 13:00 JST
- 19:00 JST

## Purpose

Org should prompt the user with the next directive candidate instead of waiting for the user to manually inspect org state.

This automation is presentation-only. It observes state, compresses the next useful directive candidate, and asks for approval. It must not mutate GitHub, Work Vault, or local git state.

## Prompt

```text
Open /Users/kiwamusato/Work/org/org.

You are running the Codex Automation for org self-prompting.

Goal:
Observe org state and present the next directive candidate that org should ask the user to approve.

Required steps:
1. Inspect git status.
2. Run:
   bash ops/self-prompt.sh
3. If the command fails because GitHub cannot be observed, report that observation failed and do not fabricate a candidate.
4. If it succeeds, summarize the top candidate using org-self-prompt.

Strict constraints:
- Do not create Issues.
- Do not change labels.
- Do not close Issues.
- Do not write to Work Vault.
- Do not commit.
- Do not push changes.
- Do not quote confidential Work content.

Return exactly:
1. Observed signal
2. Recommended directive candidate
3. Why now
4. Approval question

The approval question must be explicit and should ask whether org-dispatch may proceed.
```

## Approval Question Pattern

```text
この directive 候補を org-dispatch に渡して、体制提案まで進めてよいですか？
```

## Repository Contract

GitHub Actions must not be used for this loop. Scheduled execution belongs to Codex Automation so the prompt appears in the user's active work surface.

Repo-side files only define and test the automation contract:

- `ops/self-prompt.sh`: proposal-only candidate generator
- `ops/test_self_prompt.sh`: self-prompt behavior tests
- `ops/test_self_prompt_automation.sh`: Codex Automation contract test
