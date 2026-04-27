#!/usr/bin/env bash
# deshtml uninstaller — removes ~/.claude/skills/deshtml/ and confirms.
set -euo pipefail

DEST="$HOME/.claude/skills/deshtml"

main() {
  if [ "${EUID:-$(id -u)}" -eq 0 ]; then
    echo "Do not run as root." >&2
    exit 1
  fi

  if [ ! -e "$DEST" ]; then
    echo "deshtml is not installed at $DEST."
    exit 0
  fi

  rm -rf "$DEST"
  echo "Removed $DEST."
}

main "$@"
