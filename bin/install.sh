#!/usr/bin/env bash
# deshtml installer — atomic, idempotent, no-sudo curl-pipe-bash one-liner.
# Source: https://github.com/sperezasis/deshtml
set -euo pipefail

REPO_URL="https://github.com/sperezasis/deshtml.git"
RAW_VERSION_URL="https://raw.githubusercontent.com/sperezasis/deshtml/main/VERSION"
DEST="$HOME/.claude/skills/deshtml"

main() {
  # 1. Refuse root (D-05)
  if [ "${EUID:-$(id -u)}" -eq 0 ]; then
    echo "Do not run as root — deshtml installs into your home directory." >&2
    exit 1
  fi

  # 2. Fetch the pinned tag from the VERSION file on main (D-02)
  local version
  version="$(curl -fsSL "$RAW_VERSION_URL" | tr -d '[:space:]')"
  if [ -z "$version" ]; then
    echo "Could not fetch VERSION from $RAW_VERSION_URL" >&2
    exit 1
  fi
  if ! echo "$version" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
    echo "VERSION file content is not a valid semver: '$version'" >&2
    echo "Expected format MAJOR.MINOR.PATCH (e.g., 0.0.1)." >&2
    exit 1
  fi

  # 3. Stage to a temp dir; trap guarantees cleanup if anything fails (D-04)
  local tmp
  tmp="$(mktemp -d 2>/dev/null || mktemp -d -t deshtml)"
  trap 'rm -rf "$tmp"' EXIT

  # 4. Shallow clone the pinned tag (D-02). Stderr is intentionally NOT silenced
  #    so users can diagnose network / missing-tag / DNS failures themselves.
  echo "Installing deshtml v${version}..."
  if ! git clone --depth 1 --branch "v${version}" "$REPO_URL" "$tmp/deshtml" >/dev/null; then
    echo "Failed to clone deshtml v${version} from $REPO_URL" >&2
    echo "See git output above for the cause." >&2
    exit 1
  fi

  if [ ! -d "$tmp/deshtml/skill" ]; then
    echo "Cloned repo is missing skill/ payload — refusing to install." >&2
    exit 1
  fi

  # 5. Atomic replace: stage payload next to DEST, swap, then delete old (D-03, D-04, D-06)
  mkdir -p "$(dirname "$DEST")"
  local stage="${DEST}.installing.$$"
  rm -rf "$stage"
  cp -R "$tmp/deshtml/skill" "$stage"

  if [ -d "$DEST" ]; then
    local backup="${DEST}.old.$$"
    mv "$DEST" "$backup"
    if mv "$stage" "$DEST"; then
      rm -rf "$backup"
    else
      # Roll back if the swap fails
      mv "$backup" "$DEST"
      echo "Atomic swap failed; existing install preserved." >&2
      exit 1
    fi
  else
    mv "$stage" "$DEST"
  fi

  # 6. Confirm
  echo "deshtml v${version} installed to $DEST"
  echo "Run /deshtml in Claude Code to start."
}

main "$@"
