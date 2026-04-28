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

  # 3. Stage to a temp dir; trap guarantees cleanup if anything fails (D-04).
  #    Trap value is captured at set-time (double-quoted) so it survives
  #    main() returning and the local 'tmp' going out of scope under set -u.
  local tmp
  tmp="$(mktemp -d 2>/dev/null || mktemp -d -t deshtml)"
  trap "rm -rf '${tmp}'" EXIT

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

  # 5. Atomic replace: stage payload next to DEST, swap, then delete old (D-03, D-04, D-06).
  #    Uses mktemp -d for the stage path (no PID-collision surface) and a backup
  #    path next to DEST. A signal-safe trap tracks all three paths and restores
  #    from backup if the destination is missing — covers SIGINT/SIGTERM/SIGKILL
  #    arriving inside the swap window (T-01-02 hardening).
  mkdir -p "$(dirname "$DEST")"
  local stage backup
  stage="$(mktemp -d "${DEST}.installing.XXXXXX")"
  backup="${DEST}.old.$$"

  # Replace the tmp-only trap with one that knows about stage + backup.
  # If the script is killed mid-swap (DEST gone, backup present), this restores
  # the original install before exit. Variable values are captured at set-time
  # (double-quoted) so the trap survives main() returning and tmp/stage/backup
  # going out of scope under set -u.
  trap "
    rm -rf '${tmp}' '${stage}' 2>/dev/null
    if [ -d '${backup}' ] && [ ! -d '${DEST}' ]; then
      mv '${backup}' '${DEST}' 2>/dev/null || true
    fi
    rm -rf '${backup}' 2>/dev/null
  " EXIT

  # mktemp -d created an empty directory; remove it so cp -R writes to that exact path.
  rmdir "$stage"
  cp -R "$tmp/deshtml/skill" "$stage"

  if [ -d "$DEST" ]; then
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
