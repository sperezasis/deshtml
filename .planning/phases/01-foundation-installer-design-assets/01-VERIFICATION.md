---
phase: 01-foundation-installer-design-assets
verified: 2026-04-27T00:00:00Z
status: passed
score: 5/5 must-haves verified
overrides_applied: 0
---

# Phase 1: Foundation — Installer + Design Assets Verification Report

**Phase Goal:** A user can install deshtml from a single shell command, and Claude has every verbatim design asset it needs to render Caseproof-faithful HTML once the skill logic exists.

**Verified:** 2026-04-27
**Status:** passed
**Re-verification:** No — initial verification

## Goal Achievement

### Observable Truths (Success Criteria from ROADMAP.md)

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | Pasting the documented one-liner installs deshtml into `~/.claude/skills/deshtml/` with no prompts, no sudo, no follow-up steps | PASSED | `bin/install.sh:10-66` — `main()` runs end-to-end with no `read`/`/dev/tty`; root refused at `bin/install.sh:12` (EUID check); README one-liner matches D-01 verbatim (`README.md:10`) |
| 2 | Re-running install updates in place; killing network mid-install leaves existing install untouched (atomic staging) | PASSED | `bin/install.sh:25-28` — `mktemp -d` + `trap 'rm -rf "$tmp"' EXIT`; `bin/install.sh:42-61` — stage next to DEST, mv DEST → backup, mv stage → DEST, rm backup with rollback on failure (intra-filesystem, POSIX rename(2)-atomic); main() wrapper invoked only on last line (`bin/install.sh:68`) provides truncation safety |
| 3 | Documented uninstall one-liner removes `~/.claude/skills/deshtml/` cleanly and prints confirmation | PASSED | `bin/uninstall.sh:13-19` — `rm -rf "$DEST"` + `echo "Removed $DEST."`; idempotent no-op when absent (`bin/uninstall.sh:13-16`); README publishes both curl-pipe and direct `rm -rf` variants (`README.md:21-29`) |
| 4 | `skill/design/` contains verbatim Caseproof palette CSS, typography CSS, component-library HTML, Handbook 960px skeleton, Overview 1440px skeleton; opening either skeleton in browser visually matches Caseproof references | PASSED | `skill/design/palette.css` (33 lines, 19/19 hex tokens grep-match `~/work/caseproof/DOCUMENTATION-SYSTEM.md`); `skill/design/typography.css:7` (Inter @import D-18 URL byte-for-byte); `skill/design/components.html` (213 lines, 16 component `<section>` IDs covering full allowlist); `skill/design/formats/handbook.html:22-26` (220px sidebar + 960px content); `skill/design/formats/overview.html:16` (1440px container); references byte-identical to canonical sources (`cmp` passes for both pm-system.html and bnp-overview.html); user-confirmed visual gate (Plan 01-02 Task 4) — Chrome + Safari side-by-side compare against `pm-system.html` and `bnp-overview.html` approved |
| 5 | Every design skeleton declares `color-scheme: light` plus `<meta name="color-scheme">` tag and survives forced-dark-mode in iOS Safari | PASSED | `skill/design/palette.css:32` — `color-scheme: light;` in `:root`; `skill/design/formats/handbook.html:6-7` — both `<meta name="color-scheme" content="light">` and `<meta name="supported-color-schemes" content="light">`; same in `skill/design/formats/overview.html:6-7`; `skill/design/components.html:6` — meta tag present; user-confirmed iOS Safari forced-dark-mode test (Plan 01-02 Task 4 visual gate, 01-02-SUMMARY.md:165) — both skeletons stayed light with system Dark Mode ON |

**Score:** 5/5 truths verified

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `bin/install.sh` | atomic, idempotent, no-sudo curl-pipe-bash installer | VERIFIED | 68 lines; main() wrapper + main "$@" on last line; mktemp staging + EXIT trap; `git clone --depth 1 --branch "v${version}"`; atomic swap with rollback; root refusal at line 12 |
| `bin/uninstall.sh` | matching one-liner uninstall | VERIFIED | 22 lines; idempotent (exit 0 if absent); confirmation message |
| `VERSION` | pre-launch tag | VERIFIED | `0.0.1` (Phase 4 LAUNCH-03 bumps to 0.1.0) |
| `LICENSE` | canonical MIT, copyright 2026 Santiago Perez Asis | VERIFIED | 22 lines, exact MIT text |
| `.github/workflows/shellcheck.yml` | CI gate, severity=warning, pinned action | VERIFIED | `ludeeus/action-shellcheck@2.0.0` pinned; scandir `./bin`; severity warning |
| `README.md` | minimal install + uninstall snippet | VERIFIED | 33 lines; D-01 install one-liner verbatim at line 10; uninstall snippets at lines 22-29 |
| `skill/design/palette.css` | verbatim Caseproof palette + color-scheme | VERIFIED | 33 lines; 19 hex tokens, all grep-match canonical DOCUMENTATION-SYSTEM.md; color-scheme: light at line 32 |
| `skill/design/typography.css` | Inter @import + fallback chain + type scale | VERIFIED | 51 lines; D-18 URL byte-for-byte at line 7; full fallback chain at line 10 |
| `skill/design/components.html` | closed allowlist of 16 components | VERIFIED | 213 lines; 16 `<section id>` blocks (cg, cmp, collapse, donut, dtree, flow, hl, ic, issue-flow, lane, persona-grid, role-grid, stats, tag, tb, tip) |
| `skill/design/formats/handbook.html` | 220px sidebar + 960px content skeleton | VERIFIED | 66 lines; sidebar at line 16-21; main margin-left:220px + max-width:960px at line 22-26 |
| `skill/design/formats/overview.html` | no-sidebar 1440px linear | VERIFIED | 43 lines; `.container { max-width: 1440px; ... padding: 80px 120px; }` at line 16 |
| `skill/design/SYSTEM.md` | one-page index | VERIFIED | 44 lines; tables for Tokens / Components / Format Skeletons / References + 5 rules |
| `skill/design/references/pm-system.reference.html` | byte-faithful Handbook ground truth | VERIFIED | 1726 lines; `cmp` against `~/work/caseproof/gh-pm/pm/pm-framework/diagrams/pm-system.html` PASSES |
| `skill/design/references/bnp-overview.reference.html` | byte-faithful Overview ground truth | VERIFIED | 772 lines; `cmp` against `~/work/caseproof/gh-pm/pm/bnp/.planning/figma/bnp-overview.html` PASSES |

### Key Link Verification

| From | To | Via | Status | Details |
|------|----|----|--------|---------|
| `bin/install.sh` | GitHub raw VERSION | `curl -fsSL "$RAW_VERSION_URL"` | WIRED | Line 19; trimmed via `tr -d '[:space:]'`; empty-result guarded at line 20-23 |
| `bin/install.sh` | git tag `v${version}` | `git clone --depth 1 --branch` | WIRED | Line 32; failure path at line 33-35 |
| `bin/install.sh` | `~/.claude/skills/deshtml/` | `cp -R` to stage + atomic `mv` swap | WIRED | Lines 44-61; stage and DEST share parent (intra-filesystem rename) |
| `bin/install.sh` | trap cleanup | `trap 'rm -rf "$tmp"' EXIT` | WIRED | Line 28; cleanup runs on any exit path |
| `formats/handbook.html` | `palette.css`, `typography.css` | `<link rel="stylesheet" href="../palette.css">` | WIRED | Lines 9-10 |
| `formats/overview.html` | `palette.css`, `typography.css` | `<link rel="stylesheet" href="../palette.css">` | WIRED | Lines 9-10 |
| `components.html` | `palette.css`, `typography.css` | `<link rel="stylesheet" href="../palette.css">` | WIRED | Lines 8-9 |
| `.github/workflows/shellcheck.yml` | `bin/` | `scandir: ./bin` | WIRED | Line 20; runs on push and PR to main |

### Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
|----------|---------------|--------|---------------------|--------|
| `install.sh` | `$version` | `curl $RAW_VERSION_URL` (live VERSION file) | Yes — VERSION file contains `0.0.1` | FLOWING (note: live URL not yet exercised end-to-end; deferred to Phase 4 LAUNCH-01) |
| `install.sh` | `$tmp/deshtml/skill` | `git clone --depth 1 --branch v${version}` | Yes — repo `skill/` directory exists with 8 files | FLOWING (note: tag `v0.0.1` does not yet exist; first real exercise is Phase 4 LAUNCH-01) |
| `formats/handbook.html` | rendered output | `palette.css` + `typography.css` via `<link>` | Yes — referenced files exist with real content | FLOWING |
| `formats/overview.html` | rendered output | `palette.css` + `typography.css` via `<link>` | Yes — referenced files exist with real content | FLOWING |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| `install.sh` last non-comment line is `main "$@"` (truncation safety) | `tail -3 bin/install.sh` | `main "$@"` is last line | PASS |
| `install.sh` does not call `read` (D-03) | `grep -n "\bread\b" bin/install.sh` | no matches | PASS |
| No `<script>` tags in design fragments | `grep "<script\|javascript:" skill/design/{palette.css,typography.css,components.html,formats/*.html}` | no matches | PASS |
| Repo-vs-payload separation: no `.sh` or `.yml` under `skill/` | `find skill -type f \( -name "*.sh" -o -name "*.yml" \)` | empty | PASS |
| All 19 palette hex tokens match canonical source | `grep -F` each hex against DOCUMENTATION-SYSTEM.md | 19/19 OK | PASS |
| Inter @import URL is D-18 byte-for-byte | `grep -F "fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" skill/design/typography.css` | match | PASS |
| References byte-identical to canonical sources | `cmp` against canonical | both PASS | PASS |
| Color-scheme dual hardening present | `grep "color-scheme" skill/design/...` | meta tags + CSS in all skeletons + components.html + palette.css | PASS |
| 16 component sections present in allowlist | `grep -c "<section" components.html` | 16 | PASS |
| End-to-end install against live URL (curl-pipe-bash) | curl + git clone v0.0.1 | not executable — tag `v0.0.1` does not yet exist; live URL un-exercised | SKIP (deferred to Phase 4 LAUNCH-01 by design) |

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|-------------|-------------|--------|----------|
| INSTALL-01 | 01-01 | Single curl-pipe-bash install, no prompts, no sudo, no follow-up | SATISFIED | `bin/install.sh` end-to-end main(); root refusal; no `read` |
| INSTALL-02 | 01-01 | Drops payload into `~/.claude/skills/deshtml/` only | SATISFIED | DEST=`$HOME/.claude/skills/deshtml`; only `skill/` copied (D-10) |
| INSTALL-03 | 01-01 | Atomic — dropped network never half-installs | SATISFIED | mktemp staging + EXIT trap + intra-filesystem mv swap |
| INSTALL-04 | 01-01 | Idempotent — rerun updates in place | SATISFIED | Backup-and-swap with rollback on failure |
| INSTALL-05 | 01-01 | Refuses root, prints friendly explanation | SATISFIED | `bin/install.sh:12-15` |
| INSTALL-06 | 01-01 | One-liner uninstall with confirmation | SATISFIED | `bin/uninstall.sh` + README |
| INSTALL-07 | 01-01 | After install, `/deshtml` available without restart | SATISFIED (structural) | Skill payload lands at correct user-scope path; full end-to-end behavior verified at Phase 4 LAUNCH-01 |
| DESIGN-01 | 01-02 | Hex literals only inside palette.css | SATISFIED | All 19 hex literals confined to `skill/design/palette.css`; SYSTEM.md rule 1 enforces |
| DESIGN-02 | 01-02 | Typography from Caseproof system (Inter + fallback) | SATISFIED | `typography.css:7` D-18 URL + fallback chain at line 10 |
| DESIGN-03 | 01-02 | Closed component allowlist | SATISFIED | `components.html` 16 sections; SYSTEM.md rule 2 |
| DESIGN-05 | 01-02 | Verbatim CSS/HTML files for Claude to paste | SATISFIED | All 8 design fragments verbatim from canonical source; references byte-identical |
| DESIGN-07 | 01-02 | `color-scheme: light` + meta tag for dark-mode resilience | SATISFIED | Dual hardening present in all skeletons + components.html; user-confirmed iOS Safari test |

All 12 requirements assigned to Phase 1 are SATISFIED.

### Anti-Patterns Found

None.

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| — | — | No TODO/FIXME/HACK/PLACEHOLDER comments outside legitimate `<!-- ... SLOT -->` markers (intentional skeleton placeholders for Phase 2 to fill) | — | — |

Skeleton `SLOT` comments in `formats/handbook.html` and `formats/overview.html` are intentional and documented (Phase 2 fills them); not a stub.

### Human Verification Required

None — the visual gate that would normally require human verification (Success Criteria 4 and 5) was already executed and explicitly approved by Santiago during Plan 01-02 Task 4 prior to this verification run. Documented evidence:

- **Chrome side-by-side:** `formats/handbook.html` vs `pm-system.html`, then `formats/overview.html` vs `bnp-overview.html` — structural shells match (220px sidebar + 960px Handbook; no-sidebar 1440px Overview); no wrong colors, font weights, or spacing.
- **Safari side-by-side:** Same comparisons, same result.
- **iOS Safari forced-dark-mode:** Both format skeletons stayed light with system Dark Mode ON, confirming dual hardening (CSS `color-scheme: light` + `<meta name="color-scheme">` + `<meta name="supported-color-schemes">`) works.
- **Recorded in:** `01-02-SUMMARY.md` lines 159-168 ("Visual Gate Result (D-19, Task 4) — APPROVED by Santiago").

The end-to-end live curl-pipe-bash install against the public URL is **intentionally deferred to Phase 4 LAUNCH-01** per ROADMAP.md cross-phase dependencies — no tagged release exists yet and the live URL re-test is the launch hardening gate.

### Gaps Summary

No gaps. All 5 ROADMAP success criteria are backed by file-level evidence in the codebase, all 12 Phase 1 requirements are satisfied, all artifact wiring is sound, and the user-confirmed visual gate covers the two visually-dependent criteria (4 and 5) that cannot be verified by grep alone.

Two notes that are not gaps but worth recording:

1. **SUMMARY commit hashes drift.** `01-01-SUMMARY.md` claims commits `ba9cf0d` (Task 1) and `1dd8fa8` (Task 2). Actual git log shows the equivalent commits as `7cd290e` (`feat(01-01): add atomic curl-pipe-bash installer + uninstaller + VERSION + LICENSE`) and `c8efa92` (`feat(01-01): wire shellcheck CI + minimal README install/uninstall snippet`). File contents and scope match exactly — only the hashes differ. Likely the SUMMARY was drafted before a metadata-commit reshuffle. Cosmetic; does not affect goal achievement.
2. **End-to-end live install is not exercised yet.** No `v0.0.1` git tag exists; the install one-liner has not been run against the live URL on a fresh machine. This is intentional — Phase 4 LAUNCH-01 is the gate that runs that test, with maximum exposure to the atomic-staging pattern before public release. Phase 1's success criteria are about the installer existing, being structurally correct, and the design assets being verbatim — not about a tagged live install.

---

*Verified: 2026-04-27*
*Verifier: Claude (gsd-verifier)*
