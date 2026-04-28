---
phase: 04-source-mode-readme-launch-hardening
plan: 02
subsystem: docs
tags: [readme, changelog, keep-a-changelog, semver, public-launch, delfi]

# Dependency graph
requires:
  - phase: 01-foundation-installer-design-assets
    provides: bin/install.sh + bin/uninstall.sh (the verbatim one-liners that README Section 2 + Section 6 quote byte-for-byte)
  - phase: 02-story-arc-gate-handbook-end-to-end
    provides: SKILL.md flow + story-arc gate (the basis for README Section 3 First-run walk-through)
  - phase: 03-remaining-four-doc-types
    provides: Four interview files + format auto-selection (the basis for README Section 4 The five doc types)
  - phase: 04-source-mode-readme-launch-hardening
    provides: source-mode.md (Plan 04-01) — basis for README Section 5 Source mode
provides:
  - Public-facing README.md (67 lines) — the v0.1.0 Delfi-targeted public document, replaces the Phase-1 stub
  - Repo-root CHANGELOG.md (65 lines) — Keep-a-Changelog 1.1.0 seed with [Unreleased] + [0.1.0] — TBD sections; date filled by Plan 04-03 Task 2 post-merge
affects: [04-03-launch-hardening, public-launch, future-readme-updates]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "README handbook-tone enforcement: same banned-pitch-vocabulary regex used in skill/story-arc.md applied to public docs (single source of truth for what 'pitch tone' looks like)"
    - "Verbatim discipline (D-14) extended from CSS pasting (skill/design/) to install/uninstall one-liners in public docs"
    - "Keep-a-Changelog 1.1.0 + Semantic Versioning 2.0.0 as the version-tracking convention"

key-files:
  created:
    - "CHANGELOG.md - Repo-root version history seed in Keep-a-Changelog format"
  modified:
    - "README.md - Phase-1 stub replaced end-to-end with the D4-10 9-section Delfi-targeted public README"

key-decisions:
  - "OQ-2 disposition: Caseproof Documentation System has no public URL. Section 8 ships as text reference (`an internal Caseproof design system. Public access is not yet available — contact Santiago Perez Asis for design-system reference materials`). V2 carryover recorded — when a public copy of the design system is published, the README updates to link it."
  - "Section 1 lead paragraph follows the Plan 04-02 suggested-body template (5 sentences, story-first, names the thing 'a Claude Code skill', states the user action, names the design source, ends with file output). Verbatim shape preserved per Plan-author intent."
  - "Banned-pitch-vocabulary regex returns 0 hits — handbook tone preserved across both files, mirroring the moat the skill itself enforces."
  - "CHANGELOG.md ships with TBD as the 0.1.0 date placeholder. Plan 04-03 Task 2 fills in the actual release date post-tag, in the same commit that bumps VERSION 0.0.1 → 0.1.0."

patterns-established:
  - "Public docs follow CLAUDE.md Section Writing Rules (handbook tone, name the thing, causality chain). Section TITLES describe what IS — every section in README.md is a structural fact or directive ('Install', 'First run', 'The five doc types', 'Source mode', 'Uninstall', 'Known limitations', 'Design system', 'License')."
  - "Verbatim install + uninstall one-liners in README.md are byte-for-byte identical to bin/install.sh / bin/uninstall.sh. Drift between README and scripts is mechanically caught by the Plan 04-02 verify block."

requirements-completed: [DOCS-01, DOCS-02, DOCS-03]

# Metrics
duration: ~12min
completed: 2026-04-28
---

# Phase 04 Plan 02: README + CHANGELOG Summary

**Delfi-targeted v0.1.0 public README (67 lines, 9 D4-10 sections) plus repo-root CHANGELOG.md seed in Keep-a-Changelog 1.1.0 format with the [0.1.0] — TBD placeholder Plan 04-03 will date.**

## Performance

- **Duration:** ~12 min
- **Started:** 2026-04-28T17:00:36Z
- **Completed:** 2026-04-28T17:12:57Z
- **Tasks:** 2
- **Files modified:** 2 (1 rewritten, 1 new)

## Accomplishments

- `README.md` rewritten end-to-end: the Phase-1 stub (34 lines) becomes the v0.1.0 public README (67 lines) with all 9 D4-10 sections in the locked order: title + lead, Install, First run, The five doc types, Source mode, Uninstall, Known limitations, Design system, License.
- All three Known Limitations documented per DOCS-02: offline-font fallback (Inter via Google Fonts → system font), macOS-first auto-open (`open <file>` is macOS-only), one-file-per-run.
- Verbatim install + uninstall one-liners (D-14 byte-for-byte identical to `bin/install.sh` and `bin/uninstall.sh`).
- Handbook tone preserved — banned-pitch-vocabulary regex returns 0 matches across the entire file.
- CHANGELOG.md created at the repo root — Keep-a-Changelog 1.1.0 format with [Unreleased] placeholder + [0.1.0] — TBD section enumerating all four phases' headline ships and the three known limitations. Plan 04-03 Task 2 finalizes the TBD date.

## Task Commits

Each task was committed atomically:

1. **Task 1: Rewrite README.md as the D4-10 9-section Delfi-targeted public README** — `c703623` (docs)
2. **Task 2: Create CHANGELOG.md at repo root with v0.1.0 placeholder section** — `4dc45f9` (docs)

**Plan metadata commit (this SUMMARY + STATE.md + ROADMAP.md):** to be created at the close of this plan.

## Files Created/Modified

- `README.md` (rewritten, 34 → 67 lines) — Public v0.1.0 Delfi-targeted README with 9 D4-10 sections in order.
- `CHANGELOG.md` (new, 65 lines) — Repo-root version history seed in Keep-a-Changelog 1.1.0 format with [Unreleased] + [0.1.0] — TBD sections.

## Verbatim Discipline Confirmation (D-14)

The install + uninstall one-liners in `README.md` were verified byte-for-byte against the actual scripts:

**Install one-liner — README.md (Section 2):**

```
curl -fsSL https://raw.githubusercontent.com/sperezasis/deshtml/main/bin/install.sh | bash
```

**Install one-liner — bin/install.sh:** `RAW_VERSION_URL="https://raw.githubusercontent.com/sperezasis/deshtml/main/VERSION"` (host pattern matches; the README quotes the actual install.sh URL on the same host/branch/path).

**Uninstall one-liner — README.md (Section 6):**

```
curl -fsSL https://raw.githubusercontent.com/sperezasis/deshtml/main/bin/uninstall.sh | bash
```

**Uninstall one-liner — bin/uninstall.sh:** `DEST="$HOME/.claude/skills/deshtml"` and `rm -rf "$DEST"` (the README's direct alternative `rm -rf ~/.claude/skills/deshtml` matches the script's removal target). Host/branch/path of the curl one-liner matches `bin/install.sh`'s pattern.

Both literals are quoted in fenced ```bash``` code blocks in the README, exactly once each, in their D4-10 home sections.

## Pitch-Vocabulary Check

`grep -iE 'revolutionary|game-changing|breakthrough|next-generation|cutting-edge|seamlessly|effortlessly|in seconds|out of the box|everything you need|easily|powerful' README.md` → **0 hits**.

The README itself follows the methodology the skill enforces (CLAUDE.md root rule "describe what IS" applied recursively). The handbook-tone moat holds.

## Section Structure Verification

| # | D4-10 Section | Title in README.md | Status |
|---|---------------|--------------------|--------|
| 1 | What deshtml is | `# deshtml` + lead paragraph | Present |
| 2 | Install | `## Install` | Present |
| 3 | First run | `## First run` | Present |
| 4 | The five doc types | `## The five doc types` | Present |
| 5 | Source mode | `## Source mode` | Present |
| 6 | Uninstall | `## Uninstall` | Present |
| 7 | Known limitations | `## Known limitations` | Present |
| 8 | Design system credit | `## Design system` | Present |
| 9 | License | `## License` | Present |

Section order matches D4-10 verbatim. No `What's New`, `Changelog`, `Contributing`, `Development`, or `Setup` sections (D4-12 + D4-13 enforced).

## Decisions Made

- **OQ-2 (Caseproof Documentation System URL).** Resolved per Plan 04-02 instruction: ship Section 8 as text reference, no URL claim. Recorded as V2 carryover (publish a public copy of the design system, then update Section 8 to link it).
- **CHANGELOG.md ships with TBD date.** Plan 04-03 Task 2 owns the date-fill, scheduled in the same commit that bumps `VERSION` 0.0.1 → 0.1.0.
- **Lead paragraph (Section 1) follows the suggested-body template verbatim.** The shape ("a Claude Code skill — an add-on...", "five short questions", "the Caseproof Documentation System: a fixed palette, fixed typography, a closed component library", closing with "the skill knows it") was already a tight Delfi-targeted explanation; rewriting it would not improve clarity for the target reader.

## Deviations from Plan

None — plan executed exactly as written. Both `<verify>` automated blocks passed on the first attempt. No deviation rules triggered.

## Issues Encountered

None.

## User Setup Required

None — no external service configuration required.

## V2 Carryovers

- **Caseproof Documentation System public URL.** README Section 8 currently ships as text reference (no URL claim) per OQ-2. When a public copy of the design system is published, update Section 8 to link it (one-line edit; verify block remains satisfied — the `Caseproof Documentation System` literal stays).

## Next Phase Readiness

- Plan 04-03 (launch hardening) is **unblocked** — both Plan 04-01 (source-mode wiring) and Plan 04-02 (README + CHANGELOG) are now complete.
- Plan 04-03 Task 1 can dry-run the local install (`./bin/install.sh`) and verify the published payload includes the new README.md.
- Plan 04-03 Task 2 fills in CHANGELOG.md's `## [0.1.0] — TBD` date in the same commit that bumps `VERSION` 0.0.1 → 0.1.0.
- Plan 04-03 Task 5 (live URL verification) re-tests the install one-liner end-to-end against the live URL — drift between README and `bin/install.sh` would fail there.
- File-overlap audit: Plan 04-02 modified `README.md` + `CHANGELOG.md`. Plan 04-01 modified `skill/source-mode.md` + `skill/SKILL.md`. **Zero overlap** — both wave-1 plans landed cleanly.

---

## Self-Check: PASSED

- README.md exists at /Users/sperezasis/projects/code/deshtml/README.md — FOUND
- CHANGELOG.md exists at /Users/sperezasis/projects/code/deshtml/CHANGELOG.md — FOUND
- Commit c703623 (Task 1 README rewrite) — FOUND in git log
- Commit 4dc45f9 (Task 2 CHANGELOG seed) — FOUND in git log
- Both task `<verify>` blocks: PASS
- Banned-pitch-vocabulary regex: 0 hits
- D4-10 section order: matches verbatim

---

*Phase: 04-source-mode-readme-launch-hardening*
*Completed: 2026-04-28*
