#!/usr/bin/env python3
"""Fail-closed policy for Org GitHub CLI tool calls."""

from __future__ import annotations

import json
import re
import shlex
import sys
from typing import Any


ORG_REPO = "kiwamust/org"
GH_WORD_RE = re.compile(r"(?<![A-Za-z0-9_-])gh(?![A-Za-z0-9_-])")
SHELL_OPERATOR_RE = re.compile(r"^[;&|()<>]+$")


def result(decision: str, reason: str | None = None) -> dict[str, str]:
    payload = {"decision": decision}
    if reason:
        payload["reason"] = reason
    return payload


def repo_values(tokens: list[str]) -> list[str]:
    values: list[str] = []
    index = 2
    while index < len(tokens):
        token = tokens[index]
        if token in {"--repo", "-R"}:
            if index + 1 >= len(tokens):
                return ["<missing>"]
            values.append(tokens[index + 1])
            index += 2
            continue
        if token.startswith("--repo="):
            values.append(token.split("=", 1)[1])
        elif token.startswith("-R") and token != "-R":
            values.append(token[2:])
        index += 1
    return values


def evaluate(document: Any) -> dict[str, str]:
    if not isinstance(document, dict):
        return result("block", "Hook input must be a JSON object.")
    if document.get("tool_name") != "Bash":
        return result("approve")

    tool_input = document.get("tool_input")
    command = tool_input.get("command") if isinstance(tool_input, dict) else None
    if not isinstance(command, str) or not command.strip():
        return result("block", "Bash command is missing.")
    if not GH_WORD_RE.search(command):
        return result("approve")

    try:
        lexer = shlex.shlex(command, posix=True, punctuation_chars=";&|()<>")
        lexer.whitespace_split = True
        lexer.commenters = ""
        tokens = list(lexer)
    except ValueError:
        return result("block", "GitHub command could not be parsed safely.")

    if not tokens or tokens[0] != "gh":
        return result("block", "Wrapped or redirected gh commands are not allowed.")
    if any(SHELL_OPERATOR_RE.fullmatch(token) for token in tokens):
        return result("block", "Compound or redirected gh commands are not allowed.")
    if len(tokens) < 2 or tokens[1] not in {"issue", "pr"}:
        return result("block", "Only direct gh issue/pr commands are allowed.")
    if len(tokens) >= 3 and tokens[1:3] == ["issue", "delete"]:
        return result("block", "gh issue delete is forbidden; close the Issue instead.")

    repositories = repo_values(tokens)
    if repositories != [ORG_REPO]:
        return result(
            "block",
            "Exactly one --repo/-R value equal to kiwamust/org is required.",
        )
    return result("approve")


def main() -> int:
    try:
        document = json.load(sys.stdin)
    except (json.JSONDecodeError, UnicodeDecodeError):
        payload = result("block", "Hook input is invalid JSON.")
    else:
        payload = evaluate(document)
    print(json.dumps(payload, ensure_ascii=False, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
