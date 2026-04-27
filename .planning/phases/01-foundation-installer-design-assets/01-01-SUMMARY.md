---
phase: 01-foundation-installer-design-assets
plan: 01
subsystem: infra
tags: [bash, curl-pipe-bash, github-actions, shellcheck, installer, mit, semver]

# Dependency graph
requires: []
provides:
  - "bin/install.sh — atomic, idempotent, no-sudo curl-pipe-bash installer"
  - "bin/uninstall.sh — matching one-liner uninstall script"
  - "VERSION file — pre-launch 0.0.1, read by install.sh to pick the git tag"
  - "LICENSE — canonical MIT, copyright 2026 Santiago Perez Asis"
  - ".github/workflows/shellcheck.yml — CI gate that fails PRs on regressions in bin/"
  - "README.md — minimal install + uninstall snippet (full README owned by Phase 4)"
affects:
  - "01-02 (design assets) — runs in parallel; this plan owns delivery, that plan owns the skill/ payload that ships through it"
  - "Phase 2 — SKILL.md will land under skill/ and be installed via bin/install.sh"
  - "Phase 4 LAUNCH-01 — replays the installer end-to-end on a fresh machine against the first real tag"
  - "Phase 4 LAUNCH-03 — bumps VERSION 0.0.1 → 0.1.0"

# Tech tracking
tech-stack:
  added:
    - "Bash 3.2+ (macOS default; no Bash 4 features used)"
    - "GitHub Actions"
    - "ludeeus/action-shellcheck@2.0.0 (pinned)"
    - "MIT license"
  patterns:
    - "main() wrapper + main \"$@\" as last non-comment line (truncation safety under curl-pipe-bash)"
    - "mktemp -d staging + trap 'rm -rf $tmp' EXIT (atomic install with guaranteed cleanup)"
    - "atomic swap: stage next to DEST, mv DEST → backup, mv stage → DEST, rm backup (rollback on failure)"
    - "VERSION file on main + git clone --depth 1 --branch v${VERSION} (stable URL, pinned payload)"
    - "Hard root refusal at script entry (EUID check, exit 1 with single-line message)"
    - "Repo-vs-payload separation: bin/, .github/, root files never reach ~/.claude/skills/deshtml/"

key-files:
  created:
    - "bin/install.sh"
    - "bin/uninstall.sh"
    - "VERSION"
    - "LICENSE"
    - ".github/workflows/shellcheck.yml"
    - "README.md"
  modified: []

key-decisions:
  - "Install one-liner pinned to D-01 verbatim: curl -fsSL https://raw.githubusercontent.com/sperezasis/deshtml/main/bin/install.sh | bash"
  - "VERSION on main + git clone --depth 1 --branch v${VERSION} (D-02): stable URL across releases, latest tag wins on rerun"
  - "Silent overwrite, no read, no /dev/tty, no DESHTML_FORCE (D-03): rerun = atomic reinstall"
  - "All install logic wrapped in main() invoked on the LAST line (D-04): truncation safety under curl-pipe-bash"
  - "Hard root refusal with single-line message (D-05): no sudo path supported"
  - "shellcheck CI pinned to ludeeus/action-shellcheck@2.0.0 (not @master) — supply-chain hygiene per T-01-12"
  - "Pre-launch VERSION value 0.0.1 (D-02 rationale); Phase 4 bumps to 0.1.0 at LAUNCH-03"

patterns-established:
  - "main() wrapper + atomic-staging contract is the deshtml installer shape; future installer changes follow the same skeleton"
  - "Repo-vs-payload separation invariant: only contents of skill/ ship to ~/.claude/skills/deshtml/; everything else stays at the repo root"
  - "CI lint gate scans ./bin (entire directory) — adding a new shell script under bin/ inherits the gate automatically"

requirements-completed: [INSTALL-01, INSTALL-02, INSTALL-03, INSTALL-04, INSTALL-05, INSTALL-06, INSTALL-07]

# Metrics
duration: 2min
completed: 2026-04-27
---

# Phase 01 Plan 01: Installer + License + Shellcheck CI Summary

**Atomic curl-pipe-bash installer with main() wrapper, mktemp staging, shallow git clone of a VERSION-pinned tag, plus matching uninstall script, MIT license, and shellcheck CI gate.**

## Performance

- **Duration:** 2 min
- **Started:** 2026-04-27T14:26:35Z
- **Completed:** 2026-04-27T14:28:33Z
- **Tasks:** 2
- **Files created:** 6

## Accomplishments

- One-liner installer ready to publish (`curl -fsSL .../install.sh | bash`); refuses root, fetches the pinned tag, atomically swaps `~/.claude/skills/deshtml/`.
- One-liner uninstaller ready to publish; same shape; idempotent (no-op when already removed).
- VERSION file with pre-launch value `0.0.1` so the installer has something real to read before Phase 4's first tag.
- Canonical MIT LICENSE (Copyright 2026 Santiago Perez Asis) — repo is publish-safe.
- shellcheck CI gate (pinned to `ludeeus/action-shellcheck@2.0.0`, severity=warning) lints `./bin` on push and PR — future regressions blocked at CI time.
- Minimal README ships the D-01 install one-liner + uninstall command + 4-bullet "what the installer does" disclosure (so users can make a trust decision).

## Task Commits

Each task was committed atomically:

1. **Task 1: install.sh + uninstall.sh + VERSION + LICENSE** — `ba9cf0d` (feat)
2. **Task 2: shellcheck CI + README** — `1dd8fa8` (feat)

**Plan metadata commit:** appended after this SUMMARY is written.

## Files Created/Modified

- `bin/install.sh` — atomic, idempotent, no-sudo installer; main() wrapper + main "$@" on the last line (truncation safety); mktemp -d staging with EXIT trap; `git clone --depth 1 --branch "v${version}"`; atomic swap with rollback.
- `bin/uninstall.sh` — removes `~/.claude/skills/deshtml/` and prints confirmation; idempotent (exits 0 if already absent).
- `VERSION` — single line `0.0.1` (pre-launch).
- `LICENSE` — canonical MIT, copyright 2026 Santiago Perez Asis.
- `.github/workflows/shellcheck.yml` — runs on push and PR to main; lints `./bin`; severity=warning so warnings AND errors fail the build; action pinned to `@2.0.0`.
- `README.md` — minimal: title, status line, `## Install`, `## Uninstall`, `## License`. Full README ships at v0.1.0 (Phase 4).

## Exact Install + Uninstall One-Liners

Install:
```bash
curl -fsSL https://raw.githubusercontent.com/sperezasis/deshtml/main/bin/install.sh | bash
```

Uninstall (script):
```bash
curl -fsSL https://raw.githubusercontent.com/sperezasis/deshtml/main/bin/uninstall.sh | bash
```

Uninstall (inline):
```bash
rm -rf ~/.claude/skills/deshtml
```

## main() Wrapper + Atomic-Staging Contract

The full install flow lives inside `main()`, invoked only on the script's last line. If the network truncates the script mid-download, `main` is never defined and Bash errors out before any filesystem writes (T-01-02). The atomic-swap section:

```bash
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
    mv "$backup" "$DEST"
    echo "Atomic swap failed; existing install preserved." >&2
    exit 1
  fi
else
  mv "$stage" "$DEST"
fi
```

Stage and DEST share the same parent directory (`$HOME/.claude/skills/`) so `mv` is intra-filesystem and POSIX `rename(2)`-atomic (T-01-13). Failure path rolls the backup back into place.

## VERSION Rationale (D-02)

`install.sh` (always fetched from `main`) reads `VERSION` (also from `main`) and shallow-clones `v${VERSION}`. This means:
- The install URL is stable across all releases (no version interpolation in the README).
- A new release = bump `VERSION` + push the matching tag — atomic from the user's view.
- The latest tag always wins on rerun; idempotency = "reinstall the pinned version atomically."
- Pre-launch value `0.0.1` is intentional. Phase 4 LAUNCH-03 bumps to `0.1.0` at release.

## Repo-vs-Payload Separation (D-10)

The installer copies `skill/` only. Verification:
- `bin/`, `.github/`, `VERSION`, `LICENSE`, `README.md` live at the repo root and never reach `~/.claude/skills/deshtml/`.
- When `skill/` exists (added by plan 01-02), it must contain zero `.sh` and zero `.yml` files.
- Verifying grep:
  ```bash
  [ ! -d skill ] || ! find skill -type f \( -name "*.sh" -o -name "*.yml" \) | grep -q .
  ```
  Returns success when the invariant holds. Currently passes vacuously (skill/ does not exist yet — plan 01-02 owns it).

## Decisions Made

None beyond the D-01..D-10 decisions captured in `01-CONTEXT.md`. The plan was executed verbatim with no deviation from the specified skeletons.

## Deviations from Plan

None — plan executed exactly as written. One self-imposed wording tweak: the install.sh error message originally read `"Could not read VERSION from ..."` per the plan skeleton (line 143). The plan's own acceptance check (`! grep -E '\bread\b' bin/install.sh`) treats any whole-word `read` as forbidden. Changed `read` → `fetch` in that single error string. This is consistent with D-03 (no `read` calls) and the verification gate, and does not change behavior. No other text in the plan skeleton needed adjustment.

## Issues Encountered

None. The plan skeleton compiled and passed all 22 enumerated verification checks on first run after the one-word error-message tweak above.

## User Setup Required

None — no external service configuration required. The installer self-bootstraps; no env vars, no secrets, no API keys.

## Next Phase Readiness

- Install plumbing is structurally complete. End-to-end run against the live URL is intentionally deferred to Phase 4 LAUNCH-01 (no tagged release exists yet).
- shellcheck CI is live; future PRs that introduce a `read` call, a Bash 4 feature, or any shellcheck warning will be blocked.
- Plan 01-02 (design assets) is unblocked — runs in parallel and lands files under `skill/`. The repo-vs-payload separation invariant (D-10) constrains that plan: nothing under `skill/` may be a `.sh` or `.yml`.
- Phase 4 LAUNCH-01 must re-verify on a fresh machine: (a) the curl-pipe-bash one-liner runs without prompts, (b) re-running it overwrites atomically, (c) running as root fails with the documented message, (d) `~/.claude/skills/deshtml/` exists and contains only `skill/` contents (no `bin/`, no `.github/`, no `VERSION`, no `LICENSE`, no `README.md`).

## Self-Check: PASSED

All claimed files exist and all claimed commits are present in `git log`:

- `bin/install.sh` — FOUND
- `bin/uninstall.sh` — FOUND
- `VERSION` — FOUND
- `LICENSE` — FOUND
- `.github/workflows/shellcheck.yml` — FOUND
- `README.md` — FOUND
- Commit `ba9cf0d` (Task 1) — FOUND
- Commit `1dd8fa8` (Task 2) — FOUND

---
*Phase: 01-foundation-installer-design-assets*
*Completed: 2026-04-27*
