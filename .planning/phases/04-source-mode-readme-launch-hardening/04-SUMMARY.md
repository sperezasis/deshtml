---
phase: 04-source-mode-readme-launch-hardening
status: PRE-MERGE COMPLETE; POST-MERGE LAUNCH PENDING
completed: 2026-04-28 (pre-merge subset)
plans:
  - 04-01-SUMMARY.md  # source-mode wiring (SKILL-02 mechanical layer)
  - 04-02-SUMMARY.md  # README rewrite + CHANGELOG seed (DOCS-01..03)
  - 04-03-SUMMARY.md  # launch hardening — pre-merge subset only (Task 1 dry-run APPROVED, Tasks 2-5 deferred)
plans_complete: 3 (pre-merge close-out)
plans_total: 3
plans_deferred: 0  # all 3 plans have shipped their pre-merge work; only Tasks 2-5 of 04-03 are deferred to the orchestrator post-merge
commits: 7 (excluding pre-merge close-out commit; final-docs commit groups all pre-merge metadata)
duration: ~40min aggregate (across 04-01 + 04-02 + 04-03 pre-merge close-out)
requirements_closed:
  - SKILL-02   # 04-01
  - DOCS-01    # 04-02
  - DOCS-02    # 04-02
  - DOCS-03    # 04-02
requirements_pending_post_merge:
  - LAUNCH-01  # live curl-pipe-bash verification (post-merge — orchestrator)
  - LAUNCH-02  # all-5-types end-to-end on live install (post-merge — orchestrator; pre-merge dry-run was 5/5 PASS but live verification is the closer)
  - LAUNCH-03  # VERSION = 0.1.0 + tag v0.1.0 (post-merge — orchestrator)
  - LAUNCH-04  # GitHub release (post-merge — orchestrator)
---

# Phase 4: Source-Mode + README + Launch Hardening — Phase Summary (PRE-MERGE INTERIM)

**Phase 4 ships the source-mode shortcut, the Delfi-targeted public README, the Keep-a-Changelog v0.1.0 seed, and a fully-verified pre-merge dry-run across all 5 doc types + source-mode. The post-merge launch sequence (VERSION bump → v0.1.0 tag → GitHub release → live LAUNCH-01 verification) is the remaining work, owned by the orchestrator on `main` after PR #4 merges.**

This is an **interim phase summary**. It will be amended to `CLOSED` after the orchestrator runs the post-merge sequence and writes `04-VERIFICATION.md`.

## Phase 4 status: pre-merge complete; post-merge pending

| Stage | Status | Owner | Output |
|-------|--------|-------|--------|
| 04-01 source-mode wiring | Complete | Plan executor | `skill/source-mode.md` (NEW), `skill/SKILL.md` (Step 1 flip) |
| 04-02 README + CHANGELOG | Complete | Plan executor | `README.md` (rewritten, 67L), `CHANGELOG.md` (NEW, 65L) |
| 04-03 launch hardening — pre-merge | Complete | Plan executor (orchestrator-as-user-proxy on dry-run gate) | `04-03-PRE-MERGE-NOTES.md`, `04-03-SUMMARY.md` |
| 04-03 launch hardening — post-merge | **Pending** | Orchestrator on `main` after PR #4 merges | `04-VERIFICATION.md`, VERSION = `0.1.0`, tag `v0.1.0`, GitHub release, REQUIREMENTS.md LAUNCH-01..04 closure |

## What ships pre-merge

The skill payload at `skill/` is now complete for v0.1.0 — source-mode is wired, all 5 doc types still produce Caseproof-faithful HTML, and the audit harness is unchanged (Rule 5 + wildcard harvester from Phase 3).

```
skill/
├── SKILL.md                          (198 lines, Step 1 flipped to real source-mode load)
├── source-mode.md                    (NEW — 162 lines, lazy-loaded sub-file: ingest → infer type → extract arc → hand off)
├── story-arc.md                      (151 lines, unchanged)
├── interview/                        (5 files, unchanged from Phase 3)
├── audit/                            (run.sh + rules.md, unchanged from Phase 3 — Rule 5 + wildcard glob)
└── design/                           (palette + typography + components + 3 format skeletons, unchanged)
```

The repo-root public docs are now Delfi-targeted and v0.1.0-ready:

```
README.md                              (67 lines — D4-10 9-section public README, replaces the Phase-1 stub)
CHANGELOG.md                           (NEW — 65 lines, Keep-a-Changelog 1.1.0 with [0.1.0] — TBD; date filled post-merge)
VERSION                                (still 0.0.1 pre-merge; orchestrator bumps to 0.1.0 in post-merge Task 2)
```

## The three plans

### Plan 04-01 — Source-mode wiring (2 commits)

See: `04-01-SUMMARY.md`.

`skill/source-mode.md` (NEW, 162 lines, lazy-loaded sub-file with 5-step flow A=ingest, B=infer type, C=build arc, D=hand off to story-arc.md, E=return to SKILL.md Step 5). `skill/SKILL.md` Step 1 flipped from Phase-2 stub (`Source mode is coming in Phase 4`) to real source-mode.md load (combined-form trim landed 200 → 198 lines, ≤200 cap preserved).

D4-04 type-detection priority: handbook > presentation > pitch > meeting-prep > technical-brief (handbook also default-on-ambiguous fallback). D4-05 extract-don't-invent: every One-sentence cell grounded in source; <3-beats triggers LOUD fallback to interview/handbook.md (only allowed source→interview transition; SKILL-03 contract preserved). V1 limitations documented: multi-`@` first-match wins (OQ-3); `@`+prose collision resolves to `@` form (OQ-4).

Detection regex `(^|[[:space:]])@\S+` and SKILL-03 contract literal preserved byte-for-byte through the Step 1 flip.

Closed: SKILL-02 (mechanical layer). End-to-end empirical verification was owned by Plan 04-03; **now confirmed pre-merge** (see Plan 04-03 below).

### Plan 04-02 — README + CHANGELOG seed (2 commits)

See: `04-02-SUMMARY.md`.

`README.md` rewritten end-to-end (Phase-1 stub 34L → Delfi-targeted v0.1.0 public README 67L) with the D4-10 9-section structure: title+lead, Install, First run, The five doc types, Source mode, Uninstall, Known limitations, Design system, License. Verbatim install + uninstall one-liners (D-14 byte-for-byte). All three Known Limitations documented (offline-font fallback, macOS-first auto-open, one-file-per-run). OQ-2 disposition: Caseproof Documentation System credited as text reference (no public URL); V2 carryover recorded. Banned-pitch-vocabulary regex returns 0 hits — handbook-tone moat preserved.

`CHANGELOG.md` NEW (65L) at repo root in Keep-a-Changelog 1.1.0 format with [Unreleased] + [0.1.0] — TBD sections enumerating Phases 1-4 ships; TBD date filled by Plan 04-03 Task 2 post-merge.

Closed: DOCS-01, DOCS-02, DOCS-03.

### Plan 04-03 (PRE-MERGE SUBSET ONLY) — Launch hardening dry-run (final docs commit only — no per-task code commits)

See: `04-03-SUMMARY.md` and `04-03-PRE-MERGE-NOTES.md`.

Pre-merge dry-run executed all 5 canonical fixtures + source-mode end-to-end against the local install (working tree staged via `cp -R skill/ ~/.claude/skills/deshtml/`). Audit exit 0 across all 6 fixtures. Visual gate PASS across all 6 (qlmanage thumbnail comparison vs. the relevant Caseproof reference for each doc type).

Verifier: orchestrator-as-user-proxy ("hacelo vos"). Reply: `approved`.

| # | Fixture | Audit exit | Visual gate | Reference |
|---|---------|------------|-------------|-----------|
| 1 | handbook | 0 | PASS | `pm-system.html` |
| 2 | pitch | 0 | PASS | `bnp-overview.html` |
| 3 | technical-brief | 0 | PASS | `pm-system.html` |
| 4 | presentation | 0 | PASS | RESEARCH §"Visual Gate for Presentation" rubric |
| 5 | meeting-prep | 0 | PASS | `bnp-overview.html` |
| 6 | source-mode (NEW Phase 4) | 0 | PASS | sidebar + hero + eyebrow + H2 + body + blue highlight render per Caseproof handbook reference; sequential h2 arc reads coherently |

**SKILL-02 empirical confirmation:** the source-mode flow that 04-01-SUMMARY.md flagged for Plan 04-03 ("End-to-end empirical verification of the source-mode flow is owned by Plan 04-03") is now empirically verified end-to-end on the local install.

Dev install restored from `~/.claude/skills/deshtml.backup-20260428-191716` after the dry-run — Santiago's working environment is untouched.

Tasks 2-5 (VERSION bump, tag, release, live LAUNCH-01) are deferred to the orchestrator post-merge.

## Total work (pre-merge)

| Metric | Count |
|--------|-------|
| Plans completed (pre-merge) | 3 of 3 (Plans 04-01 + 04-02 fully; Plan 04-03 pre-merge subset) |
| Per-task commits across 04-01 + 04-02 | 4 (`bbd3d96`, `7843764`, `c703623`, `4dc45f9`) |
| Final-docs commits across 04-01 + 04-02 | 2 (`4546782`, `c4b2455`) |
| Pre-merge close-out commit (this commit) | 1 (`docs(04): pre-merge close-out (04-03 Task 1 dry-run APPROVED, post-merge tasks held)`) |
| Files created | 6 (skill/source-mode.md, CHANGELOG.md, 04-03-PRE-MERGE-NOTES.md, 04-03-SUMMARY.md, 04-SUMMARY.md, plus the 04-01-SUMMARY.md + 04-02-SUMMARY.md from prior commits) |
| Files modified | 3 (skill/SKILL.md, README.md, plus STATE.md + ROADMAP.md + REQUIREMENTS.md in this close-out commit) |
| Requirements closed (pre-merge) | 4 (SKILL-02, DOCS-01, DOCS-02, DOCS-03) |
| Requirements pending post-merge | 4 (LAUNCH-01, LAUNCH-02, LAUNCH-03, LAUNCH-04) |
| Aggregate duration (across all 3 plans) | ~40 min |

## Cross-plan deviations

### 1. <3-beats LOUD fallback in source-mode.md (Plan 04-01, Rule 2)

The plan's `<action>` block did NOT explicitly enumerate the <3-beats fallback in Step C of `source-mode.md`; only the user-prompt context flagged it. Auto-fixed in commit `bbd3d96` per Rule 2 (missing critical functionality — without this, source-mode would either fall through silently in violation of SKILL-03 or fabricate beats in violation of D4-05).

### 2. Combined-form Step 1 in SKILL.md (Plan 04-01, Rule 3)

SKILL.md was actually 200 lines (not 198 as the plan stated), so the naïve replacement would have exceeded the ≤200 cap. Used the plan's documented combined-form contingency to land 198 lines net. Auto-fixed in commit `7843764`.

### 3. Plan 04-03 split across PR-merge boundary (orchestration-level)

Tasks 2-5 of Plan 04-03 are deferred to the orchestrator post-merge. This is the planned plan-split pattern — Tasks 2-5 touch the public artifact (`v0.1.0` tag, GitHub release, live curl-pipe-bash URL on `main`), which the pre-merge executor cannot land without a PR. Documented in 04-03-PRE-MERGE-NOTES.md as "deferred to post-merge" rather than as a deviation.

## Phase 4 ROADMAP success criteria — pre-merge status

| # | Criterion | Pre-merge status |
|---|-----------|------------------|
| 1 | `/deshtml @path/to/draft.md` (or pasted text >200 chars) detected at turn 1 as source mode; never silently falls back to interview | **Pre-merge VERIFIED** — empirically run end-to-end on local install in 04-03 Task 1 |
| 2 | Repo README explains: what deshtml is, install one-liner, basic usage, the 5 doc types, uninstall, Caseproof Documentation System link, Known Limitations | **Pre-merge VERIFIED** — README rewritten in Plan 04-02 with all 9 D4-10 sections + 3 Known Limitations |
| 3 | Install one-liner verified end-to-end via `curl … \| bash` against the live public URL on a fresh machine; `/deshtml` produces all 5 doc types correctly | **Pre-merge: dry-run against local install PASS** (5/5 + source-mode); **post-merge: live URL verification PENDING** (orchestrator Task 5) |
| 4 | Repo has VERSION pinned to `0.1.0`, matching `v0.1.0` git tag, GitHub release with short changelog | **Pending post-merge** — orchestrator Tasks 2-4 |

## What Phase 4 closes (pre-merge)

- **All five doc types are empirically proven on the local install.** Audit exit 0 × 5 + visual gate PASS × 5.
- **Source-mode is empirically proven end-to-end.** SKILL-02 verification dependency from 04-01-SUMMARY.md is now satisfied.
- **Public docs are v0.1.0-ready.** README + CHANGELOG ship; CHANGELOG has [0.1.0] — TBD waiting on the orchestrator's post-merge date-fill.
- **The dry-run de-risks the launch.** Once a `failed:` reply was the goal of Task 1; the actual reply was `approved`. The PR is mergeable.

## What remains post-merge (orchestrator-owned)

After PR #4 merges to `main`, the orchestrator will run:

1. **Task 2 — VERSION bump** (`0.0.1` → `0.1.0`) + CHANGELOG TBD → release date. Single commit on main.
2. **Task 3 — Tag v0.1.0** (annotated, body from CHANGELOG). Atomic push `git push origin main v0.1.0`.
3. **Task 4 — GitHub release** via `gh release create v0.1.0 --verify-tag --notes-file <changelog body>`.
4. **Task 5 — Live LAUNCH-01 verification** via `curl -fsSL https://raw.githubusercontent.com/sperezasis/deshtml/main/bin/install.sh | bash` on fresh shell, all 5 doc types + source-mode against live install, restore backup.
5. **04-VERIFICATION.md** — empirical post-merge ledger (bump SHA, tag SHA, release URL, install exit code, per-type table, source-mode result, sequential-read disposition, CDN lag observed).
6. **Mark LAUNCH-01..04 Complete in REQUIREMENTS.md.**
7. **Mark Phase 4 row complete in ROADMAP.md.**
8. **Amend this 04-SUMMARY.md status from `PRE-MERGE COMPLETE; POST-MERGE LAUNCH PENDING` to `CLOSED`.**

## Self-Check: PASSED

All three per-plan SUMMARY files exist:

- `04-01-SUMMARY.md` — FOUND.
- `04-02-SUMMARY.md` — FOUND.
- `04-03-SUMMARY.md` (this close-out) — FOUND.
- `04-03-PRE-MERGE-NOTES.md` — FOUND.
- `04-SUMMARY.md` (this file) — FOUND.

All Plan 04-01 + 04-02 commits present in `git log` on `phase-04-source-mode-launch`. Pre-merge contract holds end-to-end across all 5 doc types + source-mode. Visual gate APPROVED. Audit exit 0 across all 6 fixtures.

Dev install at `~/.claude/skills/deshtml/`: RESTORED from `.backup-20260428-191716`. Santiago's working environment is untouched.

---
*Phase 4 of 4 — pre-merge complete; post-merge launch tasks pending PR #4 merge.*
*Will be amended to CLOSED after orchestrator runs the post-merge sequence and writes 04-VERIFICATION.md.*
