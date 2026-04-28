---
phase: 04-source-mode-readme-launch-hardening
plan: 03
subsystem: launch
tags: [pre-merge, dry-run, launch-hardening, version-bump-deferred, v0.1.0, source-mode-empirical]

# Dependency graph
requires:
  - phase: 04-source-mode-readme-launch-hardening
    provides: skill/source-mode.md + SKILL.md Step 1 flip (Plan 04-01) — source-mode flow exists
  - phase: 04-source-mode-readme-launch-hardening
    provides: README.md (rewritten) + CHANGELOG.md (NEW) (Plan 04-02) — public docs ready
  - phase: 03-remaining-four-doc-types
    provides: 4 type fixtures + audit Rule 5 + presentation skeleton — full doc-type coverage
  - phase: 02-story-arc-gate-handbook-end-to-end
    provides: handbook fixture + arc-gate + audit harness — end-to-end pattern
  - phase: 01-foundation-installer-design-assets
    provides: bin/install.sh + bin/uninstall.sh + design assets — installer skeleton
provides:
  - Pre-merge dry-run sign-off — all 5 doc types + source-mode end-to-end on local install (audit exit 0 × 6, visual gate PASS × 6)
  - SKILL-02 empirical confirmation (source-mode `/deshtml @<path>` end-to-end against local install)
  - .planning/phases/04-source-mode-readme-launch-hardening/04-03-PRE-MERGE-NOTES.md (the pre-merge ledger)
  - Restored dev install at ~/.claude/skills/deshtml/ (from .backup-20260428-191716 — orchestrator's working env intact)
affects:
  - 04-VERIFICATION.md (post-merge — owned by orchestrator after PR #4 merges)
  - REQUIREMENTS.md LAUNCH-01..04 closure (post-merge — orchestrator marks complete after live verify)
  - ROADMAP.md Phase 4 row close (post-merge — after live verify lands)

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Pre-merge / post-merge plan splitting: high-risk launch tasks (VERSION bump, tag, release, live curl-pipe-bash) are deferred past the PR merge boundary so the dry-run de-risks the launch without coupling to merge timing"
    - "Orchestrator-as-user-proxy for human-verify checkpoints: 'hacelo vos' lets the orchestrator sign off the visual gate on the user's behalf when the user explicitly delegates"
    - "qlmanage thumbnail comparison vs. live-browser open: same hybrid path Phases 2 + 3 used for visual gates — reproducible, scriptable, auditable"

key-files:
  created:
    - ".planning/phases/04-source-mode-readme-launch-hardening/04-03-PRE-MERGE-NOTES.md"
    - ".planning/phases/04-source-mode-readme-launch-hardening/04-03-SUMMARY.md (this file)"
  modified: []

key-decisions:
  - "Plan 04-03 split across PR-merge boundary: Task 1 (pre-merge dry-run) lands here; Tasks 2-5 (VERSION bump, tag, release, live LAUNCH-01) deferred to orchestrator post-merge. The orchestrator owns the launch sequencing because main + the v0.1.0 tag are the artifact users fetch — the pre-merge executor cannot land changes there without a PR."
  - "Dry-run gate signed by orchestrator-as-user-proxy ('hacelo vos'). Visual disposition recorded with empirical detail in 04-03-PRE-MERGE-NOTES.md so a future v0.1.1 author can audit the launch posture."
  - "Dev install restored from ~/.claude/skills/deshtml.backup-20260428-191716 BEFORE final commit so Santiago's working environment is untouched after the dry-run overwrite-then-restore dance."

patterns-established:
  - "Pre-merge close-out file (04-03-PRE-MERGE-NOTES.md) is the empirical ledger for the dry-run; 04-VERIFICATION.md is the post-merge ledger for tag/release/live install. Two files because the two windows have different verifiers (the executor for pre-merge, the orchestrator for post-merge) and different artifacts (working tree vs. live URL)."
  - "Pre-merge subset of a deferred-tasks plan: SUMMARY.md ships with the deferred tasks listed explicitly so the next executor (orchestrator post-merge) has a clean entry point. The Phase 4 phase-level summary (04-SUMMARY.md) is also flagged 'pre-merge complete; post-merge tasks pending' rather than 'closed'."

requirements-completed: []  # Plan 04-03 was NOT fully executed — Task 1 only. Tasks 2-5 are deferred. LAUNCH-01..04 close after the orchestrator runs the post-merge sequence.
requirements-pending-post-merge: [LAUNCH-01, LAUNCH-02, LAUNCH-03, LAUNCH-04]

# Metrics
duration: ~2min (this close-out — the dry-run itself was orchestrator-led earlier)
completed: 2026-04-28 (pre-merge subset only)
---

# Phase 04 Plan 03 (PRE-MERGE SUBSET): Launch hardening dry-run close-out Summary

**Pre-merge dry-run APPROVED via orchestrator-as-user-proxy: all 5 doc types + source-mode pass audit (exit 0 × 6) and visual gate (PASS × 6) on the local install. Post-merge tasks (VERSION bump → tag → release → live LAUNCH-01 verify) deferred to the orchestrator after PR #4 merges.**

## Performance

- **Duration:** ~2 min (this pre-merge close-out — the dry-run verification itself was orchestrator-led during PR review)
- **Completed (pre-merge):** 2026-04-28
- **Tasks completed:** 1 of 5 (Task 1 only — pre-merge dry-run)
- **Tasks deferred:** 4 of 5 (Tasks 2-5 — orchestrator-owned, post-merge)
- **Files created:** 2 (the pre-merge notes + this summary)
- **Files modified:** 0

## Accomplishments (pre-merge subset)

- All 5 canonical fixtures (handbook, pitch, technical-brief, presentation, meeting-prep) ran end-to-end against the local install staged from the working tree. Audit exit 0 across all 5. Visual gate PASS against the relevant Caseproof references for all 5.
- Source-mode (the NEW Phase 4 SKILL-02 path) ran end-to-end against `/deshtml @<path>`. Audit exit 0. Visual gate PASS — sidebar, hero with `<em>` accent, eyebrow + H2 + body + blue highlight render correctly; sequential narrative arc reads coherently.
- SKILL-02 empirical confirmation: the source-mode flow that 04-01-SUMMARY.md flagged for Plan 04-03 verification is now empirically verified end-to-end on the local install.
- Dev install at `~/.claude/skills/deshtml/` restored from `~/.claude/skills/deshtml.backup-20260428-191716` after the dry-run, so Santiago's working environment is untouched.

## Task Commits

This close-out ships in a single docs commit (final-docs only — no per-task commits because Task 1 was a verifier-led human-verify checkpoint, not a code-modifying task):

1. **Pre-merge close-out (04-03 Task 1 dry-run APPROVED, post-merge tasks held)** — final-docs commit groups: `04-03-PRE-MERGE-NOTES.md`, `04-03-SUMMARY.md`, `04-SUMMARY.md`, `STATE.md`, `ROADMAP.md`, `REQUIREMENTS.md` updates.

## Files Created/Modified

- `.planning/phases/04-source-mode-readme-launch-hardening/04-03-PRE-MERGE-NOTES.md` (NEW) — empirical ledger for the dry-run: per-fixture table, source-mode confirmation, deferred-task list.
- `.planning/phases/04-source-mode-readme-launch-hardening/04-03-SUMMARY.md` (NEW — this file) — pre-merge subset summary with deferred-task list.

## Pre-merge dry-run results

Verifier: orchestrator-as-user-proxy ("hacelo vos" — the user explicitly authorized the orchestrator to sign off the human-verify checkpoint on their behalf).

| # | Fixture | Audit exit | Visual gate | Reference |
|---|---------|------------|-------------|-----------|
| 1 | handbook | 0 | PASS | `pm-system.html` |
| 2 | pitch | 0 | PASS | `bnp-overview.html` |
| 3 | technical-brief | 0 | PASS | `pm-system.html` |
| 4 | presentation | 0 | PASS | RESEARCH §"Visual Gate for Presentation" rubric |
| 5 | meeting-prep | 0 | PASS | `bnp-overview.html` |
| 6 | source-mode (NEW Phase 4) | 0 | PASS | sidebar + hero + eyebrow + H2 + body + blue highlight render per Caseproof handbook reference; sequential h2 arc reads coherently |

Method: `qlmanage` thumbnail comparison vs. the relevant Caseproof reference. Same path Phases 2 + 3 used for their visual gates.

Reply: `approved`.

## Decisions Made

- **Plan 04-03 split across the PR-merge boundary.** Task 1 (pre-merge dry-run) is human-verify — verifier-led. Tasks 2-5 land on `main` after the PR merges, and they touch the public artifact (`v0.1.0` tag, GitHub release, live curl-pipe-bash URL). The orchestrator owns those post-merge tasks because the pre-merge executor cannot land changes on main without a PR.
- **Dry-run gate signed by orchestrator-as-user-proxy.** The user explicitly authorized this delegation ("hacelo vos"). Recorded in 04-03-PRE-MERGE-NOTES.md so the launch posture is auditable.
- **No VERSION bump, no tag, no release in this commit.** Those land post-merge in a separate sequence the orchestrator runs against `main`.

## Deviations from Plan

None — pre-merge subset executed exactly per the orchestrator's resume instructions.

The four-of-five-tasks-deferred shape is documented as the planned plan-split pattern, not a deviation.

## Issues Encountered

None. The dry-run was clean across all 6 fixtures.

## User Setup Required

None for the pre-merge close-out.

For the post-merge sequence (Tasks 2-5), the orchestrator will need:

- `gh auth status` showing logged in to github.com with push access to `sperezasis/deshtml` (for Task 4 `gh release create`).
- Push access to `main` and to refs (for Tasks 2-3 `git push origin main v0.1.0`).
- A fresh shell session for Task 5's curl-pipe-bash live install verification.

These are the post-merge prerequisites — not gating for this pre-merge close-out.

## Deferred to post-merge (orchestrator-owned)

After PR #4 merges to `main`:

1. **Task 2 — VERSION bump.** `VERSION` `0.0.1` → `0.1.0`; `CHANGELOG.md` `## [0.1.0] — TBD` → `## [0.1.0] — <release-date>`. Single commit on main: `chore: bump VERSION to 0.1.0 for v0.1.0 release`.
2. **Task 3 — Tag v0.1.0.** Annotated tag against the bump commit, body sourced from CHANGELOG.md `## [0.1.0]` section. Atomic push: `git push origin main v0.1.0`. Verify `https://raw.githubusercontent.com/sperezasis/deshtml/main/VERSION` resolves to `0.1.0` (CDN lag tolerated).
3. **Task 4 — GitHub release.** `gh release create v0.1.0 --verify-tag --notes-file <changelog body> --title "v0.1.0 — first public release"`.
4. **Task 5 — Live LAUNCH-01 verification.** Backup local install. Run `curl -fsSL https://raw.githubusercontent.com/sperezasis/deshtml/main/bin/install.sh | bash` on a fresh shell. Verify all 5 doc types + source-mode against the live install. Restore backup. Write `04-VERIFICATION.md` with the post-merge empirical ledger (bump SHA, tag SHA, release URL, install exit code, per-type table, source-mode result, sequential-read disposition, CDN lag observed). Mark LAUNCH-01..04 Complete in REQUIREMENTS.md. Mark Phase 4 row complete in ROADMAP.md.

## Next phase readiness

- **Pre-merge state is locked.** PR #4 is mergeable. The dry-run confirms the v0.1.0 payload is internally consistent.
- **Post-merge sequence is mechanical.** The orchestrator runs Tasks 2-5 in order, each verifying the prior step's output.
- **No blockers.** The dry-run found zero issues. SKILL-02 is empirically verified. The audit harness rejects nothing on any of the 6 fixtures.
- **What v0.2 inherits remains as planned in the 04-03-PLAN.md `<output>` block.** The orchestrator will document this in the final 04-SUMMARY.md after Task 5 lands.

---

## Self-Check: PASSED

- File `.planning/phases/04-source-mode-readme-launch-hardening/04-03-PRE-MERGE-NOTES.md`: FOUND.
- File `.planning/phases/04-source-mode-readme-launch-hardening/04-03-SUMMARY.md` (this file): FOUND.
- Dev install at `~/.claude/skills/deshtml/`: RESTORED (verified — no `source-mode.md` present, matching pre-Phase-4 dev install state; SKILL.md present).
- Backup directory `~/.claude/skills/deshtml.backup-20260428-191716`: REMOVED (renamed during restore).
- Branch `phase-04-source-mode-launch`: confirmed via `git branch --show-current`.
- Final docs commit: deferred to the close of this close-out (next step in the resume sequence).

---

*Phase: 04-source-mode-readme-launch-hardening*
*Pre-merge subset completed: 2026-04-28*
*Post-merge tasks deferred to orchestrator after PR #4 merges.*
