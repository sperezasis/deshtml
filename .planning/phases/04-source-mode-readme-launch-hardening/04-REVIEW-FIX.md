---
phase: 04-source-mode-readme-launch-hardening
fixed_at: 2026-04-27T00:00:00Z
review_path: .planning/phases/04-source-mode-readme-launch-hardening/04-REVIEW.md
iteration: 1
findings_in_scope: 5
fixed: 3
skipped: 2
status: all_addressed
---

# Phase 4: Code Review Fix Report

**Fixed at:** 2026-04-27
**Source review:** `.planning/phases/04-source-mode-readme-launch-hardening/04-REVIEW.md`
**Iteration:** 1

**Summary:**
- Findings in scope: 5 (2 medium, 1 low, 2 info)
- Fixed: 3 (MD-01, MD-02, LO-01)
- Skipped (per reviewer guidance, no code action required): 2 (IN-01, IN-02)

## Fixed Issues

### MD-01 + MD-02: README understates question count and omits the "Inclusions / exclusions" topic

**Files modified:** `README.md`
**Commit:** bc9abbd
**Applied fix:**
- Line 3: "five short questions" → "six short questions" (covers the actual flow: 1 doc-type pick + 5 interview questions).
- Line 17: "five short questions" → "six short questions" (same correction).
- Line 20: "Claude asks four more questions about your audience, your material, your sections, and your tone." → "Claude asks five more questions about your audience, your material, your sections, your tone, and any inclusions or exclusions." (adds the missing fifth interview topic — "Inclusions / exclusions" — verbatim from `interview/handbook.md:27`, consistent across all 5 interview files).

The two findings were merged into a single commit because they share the same fix surface (lines 3, 17, 20 of README.md) and the same root cause (off-by-one in the README's enumeration of the user flow).

**Post-fix verification:**
- Banned-pitch-vocabulary regex (`revolutionary|game-changing|breakthrough|next-generation|cutting-edge|seamlessly|effortlessly|in seconds|out of the box|everything you need|easily|powerful`) re-run on `README.md` → 0 hits.
- 9 D4-10 README sections still present in order: H1 "deshtml" intro + Install + First run + The five doc types + Source mode + Uninstall + Known limitations + Design system + License.

### LO-01: source-mode.md Step D handoff said "from Step C onward" but Step C item 3 relies on story-arc.md Step B's flowing paragraph

**Files modified:** `skill/source-mode.md`
**Commit:** 32ec5b4
**Applied fix:**
- Step D handoff line: "follow it from Step C onward" → "follow it from Step B onward".
- Step D narrative now names the flowing paragraph diagnostic alongside the table format, rendering, self-review, and approval whitelist as part of what story-arc.md owns single-source.
- Concrete numbered substeps renumbered from 4 entries (C, D, E, F) to 5 entries — added "1. Run story-arc.md Step B (render the flowing paragraph) under the arc table." as the first concrete action, then renumbered the existing entries.

This restores the gap-detection signal that source-mode.md Step C item 3 already names, with no other behavioral change. ARC-02 (the flowing paragraph diagnostic) and the user's gap-detection affordance for thin sources are now both present in the source-mode flow.

**Post-fix verification:**
- `skill/SKILL.md` line count unchanged at 198 (≤200 cap, D4-08 satisfied — no edits to SKILL.md).
- `skill/source-mode.md` line count unchanged at 162.
- Re-ran audit on `/tmp/deshtml-fixture/2026-04-28-deshtml-handbook.html` → exit 0 (no regressions; the audit is a generated-output check and source-mode.md is upstream of generation).

## Skipped Issues (per-reviewer guidance, no code action required)

### IN-01: SKILL.md Step 1 case-2 trim guard — V2 fixture suite

**File:** `skill/SKILL.md:21-25`
**Reason:** Reviewer explicitly marked as "Optional V2 — add a fixture at exactly 200 chars and exactly 201 chars to a regression suite when one is created. Not actionable for v0.1.0." No defect; the >200 threshold is documented and the implementation matches. Leaving for V2 regression suite when one is created.
**Original issue:** The file does not include a worked example for the boundary case where stripping `@<path>` plus `<no arguments>` leaves exactly 200 characters of prose (which would route to interview mode, not source mode).

### IN-02: CHANGELOG `[Unreleased]` and `[0.1.0]` ref-link targets precede their existence

**File:** `CHANGELOG.md:64-65`
**Reason:** Reviewer explicitly marked as "Pre-approved per `04-02-SUMMARY.md` 'key-decisions'; not a defect." The `v0.1.0` tag and GitHub Release lands post-merge per Plan 04-03 Tasks 3 and 4. Both ref-links resolve once `git push origin main v0.1.0` and `gh release create v0.1.0` complete. No pre-merge action; orchestrator's post-merge sequence handles it.
**Original issue:** Both ref-link URLs (compare and release-tag) will 404 until the v0.1.0 tag and release exist on GitHub.

---

_Fixed: 2026-04-27_
_Fixer: Claude (gsd-code-fixer)_
_Iteration: 1_
