#!/usr/bin/env bash
# ops/hooks/pre-gh-check.sh — gh コマンドの安全性検証

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec python3 "$SCRIPT_DIR/pre_gh_policy.py"
