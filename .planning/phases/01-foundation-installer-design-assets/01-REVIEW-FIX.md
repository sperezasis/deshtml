---
phase: 01-foundation-installer-design-assets
fixed_at: 2026-04-27T16:00:00Z
review_path: .planning/phases/01-foundation-installer-design-assets/01-REVIEW.md
iteration: 1
findings_in_scope: 7
fixed: 7
skipped: 0
status: all_fixed
---

# Phase 1: Code Review Fix Report

**Fixed at:** 2026-04-27T16:00:00Z
**Source review:** `.planning/phases/01-foundation-installer-design-assets/01-REVIEW.md`
**Iteration:** 1

**Summary:**
- Findings in scope: 7 (3 medium, 2 low, 2 info)
- Fixed: 7
- Skipped: 0

All seven findings were addressed in six atomic commits (MD-01 + LO-02 fixed together because they touch the same atomic-swap block and the LO-02 mktemp change is the structural prerequisite for MD-01's signal-safe trap). Both info-level findings were resolved by documenting the accepted decision in code and in `SYSTEM.md` per user direction.

## Fixed Issues

### MD-03: Hex literal in handbook.html skeleton violates the audit rule

**Files modified:** `skill/design/formats/handbook.html`
**Commit:** `b263eda`
**Applied fix:** Replaced `color: #c7c7cc;` on `.sidebar` with `color: var(--g4);` (the existing palette token, exact value match `#C7C7CC`). Verified against `pm-system.html` — `#c7c7cc` only appears there as a hover color on `.nav-a:hover`, never on `.sidebar` itself; the literal was a Phase-1 inaccuracy. Phase 2's DESIGN-06 audit will now pass on this skeleton.

### MD-02: Silenced `git clone` stderr hides root cause

**Files modified:** `bin/install.sh`
**Commit:** `a5e8eaa`
**Applied fix:** Replaced `git clone ... >/dev/null 2>&1 || { ... }` with an `if ! git clone ... >/dev/null; then ...` block. Stderr is no longer silenced, so users see git's diagnostic output (network error, missing tag, DNS, auth) directly. Added a "See git output above for the cause." pointer to the existing failure message. shellcheck-clean.

### LO-01: VERSION content is interpolated without format validation

**Files modified:** `bin/install.sh`
**Commit:** `c3032cb`
**Applied fix:** Added a semver regex check (`^[0-9]+\.[0-9]+\.[0-9]+$`) immediately after the empty-string check. Malformed VERSION (comment, `v` prefix, multi-line) now produces a precise error pointing at the actual cause instead of surfacing as the same vague clone failure as a network problem. Mirrors the format already enforced on the local `VERSION` file by Plan 01-01's acceptance check.

### MD-01 + LO-02: Signal-safe atomic swap with mktemp -d staging (combined)

**Files modified:** `bin/install.sh`
**Commit:** `8510bdf`
**Applied fix:** Restructured the atomic-swap block so the two findings reinforce each other:

- **LO-02 (staging via mktemp -d):** `local stage="${DEST}.installing.$$"` + defensive `rm -rf "$stage"` was replaced with `stage="$(mktemp -d "${DEST}.installing.XXXXXX")"`. PID-collision surface across reboots is now zero. Because `mktemp -d` returns an empty directory and `cp -R` needs the destination not to exist, we `rmdir "$stage"` immediately before `cp -R`.

- **MD-01 (signal-safe trap):** Replaced the `tmp`-only trap with a compound trap registered AFTER `stage` and `backup` are computed. The new trap:
  1. Removes `$tmp` and `$stage` if they exist.
  2. If `$backup` exists and `$DEST` does NOT, restores `$backup` -> `$DEST` (covers SIGINT/SIGTERM/OOM kill arriving between `mv "$DEST" "$backup"` and `mv "$stage" "$DEST"`).
  3. Removes `$backup` afterwards.

Threat T-01-02's "atomic swap with rollback" claim now holds for signal interruption, not just non-zero `mv` exit. Plan 01-01's full acceptance check re-runs cleanly (`grep -q "trap 'rm -rf"` still passes, `tail -1` still returns `main "$@"`, no Bash 4 features, no `read`).

### IN-01: Format skeletons reference CSS via `<link>`, not inline `<style>`

**Files modified:** `skill/design/SYSTEM.md`
**Commit:** `367b38a`
**Applied fix:** Per D-12 ("either is fine; pick the simpler one") Phase 1 chose paste time. The skeletons keep their `<link>` tags so Phase 1's D-19 visual gate can render them directly via `file://`. Added rule #6 to `SYSTEM.md` "Rules Phase 2 must respect" making the inline-at-paste-time contract explicit and requiring Phase 2's audit to grep for zero `<link rel="stylesheet"` occurrences. This converts an implicit hand-off into a documented acceptance check.

### IN-02: components.html viewer-style block is harmless dev-only chrome

**Files modified:** `skill/design/components.html`, `.planning/phases/01-foundation-installer-design-assets/01-REVIEW.md`
**Commit:** `b021f87`
**Applied fix:** Per user direction, the dev chrome stays. Added an inline comment to the `<style>` block in `components.html` documenting that the rules are dev-only viewer chrome scoped to body/section in this file, NOT part of the component allowlist, and never copied into generated output (Phase 2 reads markup, not styling, from this file). Recorded the ACCEPTED decision in REVIEW.md so future reviews see the rationale.

## Skipped Issues

None.

---

_Fixed: 2026-04-27T16:00:00Z_
_Fixer: Claude (gsd-code-fixer)_
_Iteration: 1_
