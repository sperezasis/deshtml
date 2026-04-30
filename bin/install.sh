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
  #
  #    Stage and backup names use a leading dot and a `_install_` infix so they
  #    do NOT share the `deshtml.` prefix in the skills directory. If the script
  #    is killed mid-swap and a stage/backup directory survives, Claude Code's
  #    slash-command resolver would otherwise register e.g. `/deshtml.old.12345`
  #    and shadow `/deshtml` via prefix-match. Hidden names sidestep that.
  #    Both paths remain in `$(dirname "$DEST")` so `mv` stays atomic
  #    (same filesystem).
  mkdir -p "$(dirname "$DEST")"
  local stage backup skills_dir
  skills_dir="$(dirname "$DEST")"
  stage="$(mktemp -d "${skills_dir}/.deshtml_install_stage.XXXXXX")"
  backup="${skills_dir}/.deshtml_install_backup.$$"

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

  # 6. Write the installed-version marker. Read by skill/check-update.js
  #    (invoked at /deshtml Step 0) to compare against upstream and surface a
  #    one-line update notice when a newer version is available.
  echo "$version" > "$DEST/.version"

  # 7. Clean up legacy hook from v0.4.0–v0.4.2 (best-effort, silent on missing).
  #    The v0.4.x line shipped a SessionStart hook in ~/.claude/hooks/ + a
  #    settings.json entry. v0.4.3 moved the check into the skill itself, so
  #    older installs need their hook removed to avoid stale + invasive output.
  rm -f "$HOME/.claude/hooks/deshtml-check-update.js" "$HOME/.claude/hooks/deshtml-register-hook.js"
  if command -v node >/dev/null 2>&1 && [ -f "$HOME/.claude/settings.json" ]; then
    SETTINGS_PATH="$HOME/.claude/settings.json" node -e '
      const fs=require("fs");
      const p=process.env.SETTINGS_PATH;
      try{
        const s=JSON.parse(fs.readFileSync(p,"utf8"));
        if(!s||typeof s!=="object")return;
        const isOurs=e=>e&&Array.isArray(e.hooks)&&e.hooks.some(h=>h&&typeof h.command==="string"&&h.command.includes("deshtml-check-update"));
        if(s.hooks&&Array.isArray(s.hooks.SessionStart)){
          s.hooks.SessionStart=s.hooks.SessionStart.filter(e=>!isOurs(e));
          if(s.hooks.SessionStart.length===0)delete s.hooks.SessionStart;
          if(Object.keys(s.hooks).length===0)delete s.hooks;
          const tmp=p+".tmp."+process.pid;
          fs.writeFileSync(tmp,JSON.stringify(s,null,2));
          fs.renameSync(tmp,p);
        }
      }catch{}
    ' 2>/dev/null || true
  fi

  # 8. Clean up orphaned stage/backup dirs from killed-mid-flight installs of
  #    v0.4.3 and earlier (best-effort, silent on missing). Those releases used
  #    `${DEST}.old.$$` and `${DEST}.installing.XXXXXX`, which share the
  #    `deshtml.` prefix and end up registered as `/deshtml.old.NNNNN`-style
  #    slash commands by Claude Code, shadowing `/deshtml` via prefix-match.
  #    A successful install today implies any siblings are leftovers, not in use.
  rm -rf "$(dirname "$DEST")"/deshtml.old.* "$(dirname "$DEST")"/deshtml.installing.* 2>/dev/null || true

  # 9. Confirm
  echo "deshtml v${version} installed to $DEST"
  echo "Run /deshtml in Claude Code to start."
}

main "$@"
