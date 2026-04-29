#!/usr/bin/env bash
# deshtml uninstaller — removes ~/.claude/skills/deshtml/, the local cache,
# and any leftover SessionStart hook from v0.4.0–v0.4.2.
set -euo pipefail

DEST="$HOME/.claude/skills/deshtml"

main() {
  if [ "${EUID:-$(id -u)}" -eq 0 ]; then
    echo "Do not run as root." >&2
    exit 1
  fi

  # Clean up legacy hook from v0.4.0–v0.4.2 (silent on missing).
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

  rm -rf "$HOME/.cache/deshtml"

  if [ ! -e "$DEST" ]; then
    echo "deshtml is not installed at $DEST. Hooks/cache cleaned up if present."
    exit 0
  fi

  rm -rf "$DEST"
  echo "Removed $DEST."
}

main "$@"
