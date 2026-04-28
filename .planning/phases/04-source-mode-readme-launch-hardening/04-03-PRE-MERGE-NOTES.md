# 04-03 Pre-merge dry-run notes

**Date:** 2026-04-28
**Branch:** `phase-04-source-mode-launch`
**Status:** Pre-merge dry-run **APPROVED**. Post-merge tasks (VERSION bump → tag → release → live LAUNCH-01 verification) are deferred to the orchestrator and will be documented in `04-VERIFICATION.md` after PR #4 merges to main.

---

## Why this file exists

Plan 04-03 is split across the PR-merge boundary:

- **Pre-merge (Task 1).** Dry-run all 5 doc types + source-mode end-to-end against the LOCAL skill install (working tree staged via `cp -R`). This catches breakage BEFORE the PR merges. autonomous=false — visual gate is human-verify.
- **Post-merge (Tasks 2-5).** VERSION bump, v0.1.0 tag, GitHub release, live LAUNCH-01 verification against `https://raw.githubusercontent.com/sperezasis/deshtml/main/bin/install.sh`.

This document records the pre-merge dry-run outcome only. The post-merge ledger lands in `04-VERIFICATION.md` after Task 5 completes.

## Dry-run gate decision

**Verifier:** orchestrator acting as user proxy ("hacelo vos" — the user explicitly authorized the orchestrator to sign off the human-verify checkpoint on their behalf).

**Reply:** `approved`.

**Method:** `qlmanage` thumbnail comparison against the relevant Caseproof reference for each doc type.

## Per-fixture results (pre-merge, local install via `cp -R skill/ ~/.claude/skills/deshtml/`)

| # | Fixture | Audit exit | Visual gate | Reference |
|---|---------|------------|-------------|-----------|
| 1 | handbook (Phase 2 fixture) | 0 | PASS | `pm-system.html` |
| 2 | pitch (Phase 3 fixture) | 0 | PASS | `bnp-overview.html` |
| 3 | technical-brief (Phase 3 fixture) | 0 | PASS | `pm-system.html` |
| 4 | presentation (Phase 3 fixture) | 0 | PASS | RESEARCH §"Visual Gate for Presentation" rubric |
| 5 | meeting-prep (Phase 3 fixture) | 0 | PASS | `bnp-overview.html` |
| 6 | source-mode (NEW — Phase 4 SKILL-02 path) | 0 | PASS | renders correctly: sidebar, hero with em accent, eyebrow + H2 + body + blue highlight; sequential h2 narrative arc reads coherently |

**Disposition:** all six fixtures exit 0 from the audit script and pass the visual gate against their respective references. The skill ships v0.1.0-ready.

## SKILL-02 empirical confirmation

Source-mode is end-to-end verified on the local install:

- `/deshtml @<path>` triggers source mode at turn 1 (no fall-through to interview).
- The `Detected type:` line is printed.
- The arc-table cells are extracted from the source content (no fabrication).
- After `approve`, the file renders correctly through `qlmanage`.
- Audit exit 0.
- Sidebar, hero with `<em>` accent, eyebrow + H2 + body + blue highlight render per the Caseproof handbook reference; the narrative arc reads coherently top-to-bottom.

This closes the empirical-verification dependency `04-01-SUMMARY.md` flagged for Plan 04-03 ("End-to-end empirical verification of the source-mode flow is owned by Plan 04-03").

## Pre-merge state lock

After dry-run approval, the local install was restored from `~/.claude/skills/deshtml.backup-20260428-191716` so the orchestrator's dev install is intact. Santiago's working environment is untouched.

- Backup directory: `~/.claude/skills/deshtml.backup-20260428-191716`
- Restore method: `mv ~/.claude/skills/deshtml.backup-20260428-191716 ~/.claude/skills/deshtml`
- Post-restore state: `SKILL.md` + `audit/` + `design/` + `interview/` + `story-arc.md` (no `source-mode.md`, matching the pre-Phase-4 dev install).

## Deferred (post-merge, orchestrator-owned)

After PR #4 merges, the orchestrator will:

1. **Task 2 — VERSION bump.** `VERSION` `0.0.1` → `0.1.0`; `CHANGELOG.md` `## [0.1.0] — TBD` → `## [0.1.0] — <release-date>`. Single commit on main: `chore: bump VERSION to 0.1.0 for v0.1.0 release`.
2. **Task 3 — Tag v0.1.0.** Annotated tag against the bump commit, body sourced from CHANGELOG.md `## [0.1.0]` section. Atomic push: `git push origin main v0.1.0`.
3. **Task 4 — GitHub release.** `gh release create v0.1.0 --verify-tag --notes-file <changelog body> --title "v0.1.0 — first public release"`.
4. **Task 5 — Live LAUNCH-01 verification.** `curl -fsSL https://raw.githubusercontent.com/sperezasis/deshtml/main/bin/install.sh | bash` on a fresh shell. Backup local install → run all 5 doc types + source-mode against the live install → restore backup. Document in `04-VERIFICATION.md` (the empirical ledger). Mark LAUNCH-01..04 complete in REQUIREMENTS.md. Close Phase 4.

## What this file does NOT cover

- Post-merge tag SHA, release URL, live install one-liner exit code, CDN lag — owned by `04-VERIFICATION.md` after Task 5.
- LAUNCH-01..04 requirement closure — orchestrator marks Complete after live verify lands.
- Phase 4 close — orchestrator marks `[x]` on the ROADMAP.md Phase 4 row after live verify lands.

---

*Pre-merge close-out signed by: orchestrator (user proxy via "hacelo vos") on 2026-04-28.*
