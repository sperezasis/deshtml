#!/usr/bin/env bash
# deshtml uninstaller — removes ~/.claude/skills/deshtml/, unregisters the
# SessionStart update-check hook, removes the hook scripts.
set -euo pipefail

DEST="$HOME/.claude/skills/deshtml"
HOOKS_DIR="$HOME/.claude/hooks"

main() {
  if [ "${EUID:-$(id -u)}" -eq 0 ]; then
    echo "Do not run as root." >&2
    exit 1
  fi

  # Unregister the SessionStart hook before deleting the helper script.
  if [ -f "$HOOKS_DIR/deshtml-register-hook.js" ] && command -v node >/dev/null 2>&1; then
    node "$HOOKS_DIR/deshtml-register-hook.js" unregister "$HOME/.claude/settings.json" || true
  fi

  # Remove the hook scripts (cosmetic — they don't run without the settings.json entry).
  rm -f "$HOOKS_DIR/deshtml-check-update.js" "$HOOKS_DIR/deshtml-register-hook.js"

  # Remove the cache.
  rm -rf "$HOME/.cache/deshtml"

  if [ ! -e "$DEST" ]; then
    echo "deshtml is not installed at $DEST. Hooks cleaned up if present."
    exit 0
  fi

  rm -rf "$DEST"
  echo "Removed $DEST and unregistered hook."
}

main "$@"
