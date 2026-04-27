---
phase: 02-story-arc-gate-handbook-end-to-end
plan: 02
subsystem: skill-flow
tags: [skill, flow-control, mode-detection, story-arc, interview, approval-gate, three-css-inline, audit-invocation]

# Dependency graph
requires:
  - phase: 01-foundation-installer-design-assets
    plan: 02
    provides: skill/design/palette.css, skill/design/typography.css, skill/design/components.html, skill/design/formats/handbook.html, skill/design/SYSTEM.md
  - phase: 02-story-arc-gate-handbook-end-to-end
    plan: 01
    provides: skill/design/components.css (third inlining target), palette.css extension (sb-* and *-d tokens), SYSTEM.md Rule 6 (three-file inlining contract)
  - phase: 02-story-arc-gate-handbook-end-to-end
    plan: 03
    provides: skill/audit/run.sh (audit script invoked at SKILL.md Step 7), skill/audit/rules.md
provides:
  - skill/SKILL.md (171 lines — top-level flow control, frontmatter + 8 step-numbered sections)
  - skill/story-arc.md (151 lines — arc table spec, self-review rubric, verbatim BAD→GOOD pairs, 9-phrase approval whitelist, revision loop)
  - skill/interview/handbook.md (45 lines — DOC-06 schema, five empty-default questions, hand-off to story-arc.md)
affects: [02-04-plan (visual gate fixture run), phase-03 (interview files for the four stubbed types), phase-04 (source-mode unstub)]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Lazy-load sub-files (Pitfall 15) — SKILL.md reads interview/handbook.md at Step 3, story-arc.md at Step 4, design/* at Step 6 only. No speculative reads at startup."
    - "Single source of truth (Pitfall 14) — rubric content (BAD→GOOD pairs, approval whitelist, interview questions) lives in sub-files only. SKILL.md owns flow, never duplicates rubric."
    - "Mechanical mode detection at turn 1 — regex (^|[[:space:]])@\\S+ for @-tokens, >200 char prose threshold for pasted source. Source-mode stub fires before any interview prompt; never silent fallback (SKILL-03)."
    - "Mechanical approval gate — exact-match-after-trim against a 9-phrase whitelist (D2-12). Non-approval = revision instruction. No fuzzy match, no semantic inference, no enthusiasm interpretation."
    - "Three-CSS-file inlining order — palette → typography → components per amended D2-15. Load-bearing: palette defines :root tokens first; typography owns body/h1/h2/h3 second; components cascade last. Skeleton's layout <style> stays as a separate second block."
    - "Auto-fix-with-diff (Pitfall 18) — when self-review rewrites a title, the status line shows BOTH the BAD original AND the GOOD replacement so the user can override via revision loop."

key-files:
  created:
    - "skill/SKILL.md (171 lines, ≤200 cap per SKILL-05/D2-01)"
    - "skill/story-arc.md (151 lines, ≤200 cap)"
    - "skill/interview/handbook.md (45 lines, ≤80 cap per DOC-07)"
  modified: []

key-decisions:
  - "Working assumption locked: $ARGUMENTS is empty string when /deshtml is invoked with no args (per 02-RESEARCH HIGH confidence). Plan 02-04's fixture run is the empirical confirmation. SKILL.md Step 1 handles all three shapes (empty string, literal `<no arguments>` placeholder, real text) so the regex stays correct regardless of which shape Claude Code substitutes."
  - "Doc-type branch enumerates ALL 5 types in Step 2 from Phase 2 onward (D2-05). Handbook is the only implemented branch; pitch / technical brief / presentation / meeting prep stub with `<type> is coming in Phase 3. Try handbook for now.` Phase 3 flips stubs to real interview reads — SKILL.md only changes Step 2's stub messages, not its structure."
  - "Source mode (Step 1) NEVER silently falls back to interview (SKILL-03). The regex is the gate; if it matches, the user sees the Phase-4 stub and the conversation ends. Same trust contract as the doc-type branch."
  - "SKILL.md ≤200 lines is a hard cap. Final result: 171 lines including frontmatter and inline code blocks. Headroom for Phase 3's two-line stub flips and Phase 4's source-mode-coming line."
  - "Auto-fix-with-diff (Pitfall 18) is non-negotiable. Story-arc Step C status lines show BOTH the BAD original and the GOOD replacement so the user always sees what changed. User override via the revision loop is one reply away."
  - "BAD→GOOD pairs harvested verbatim from /Users/sperezasis/CLAUDE.md §'Section Writing Rules' lines 59, 60, 64, 65, 78. Verbatim discipline (D-14 from Phase 1) preserved; no paraphrase, no synthesis."

# Metrics
metrics:
  duration: ~25min
  completed: 2026-04-27
---

# Phase 02 Plan 02: SKILL.md Flow + Story-Arc Gate + Handbook Interview — Summary

The deshtml skill is now wired end-to-end for the handbook document type, from the user's `/deshtml` keystroke to the absolute-path-printed-on-stdout terminus. SKILL.md is a 171-line flow controller with frontmatter and eight step-numbered sections; rubric content (the arc table format, the self-review checks, the approval whitelist, the interview questions) lives in sub-files that SKILL.md lazy-loads at the appropriate step. Three new files: `skill/SKILL.md`, `skill/story-arc.md`, `skill/interview/handbook.md`. Three commits, one per task.

## What ships

### `skill/SKILL.md` — 171 lines (cap: 200)

Frontmatter:
```
name: deshtml
description: ...
disable-model-invocation: true
allowed-tools: Read Write Bash(ls *) Bash(test *) Bash(open *) Bash(bash *) Bash(date *) Bash(pwd *) Bash(mkdir *) Bash(grep *) Bash(command *)
```

Eight step-numbered sections:

| Step | Action | Lazy-loads |
|------|--------|-----------|
| 1 | Detect mode (regex `(^\|[[:space:]])@\S+` → source mode; >200 char prose → source mode; else interview) | none |
| 2 | Ask doc type — handbook proceeds; pitch / technical brief / presentation / meeting prep stub | none |
| 3 | Run interview | `interview/handbook.md` |
| 4 | Build story arc | `story-arc.md` |
| 5 | Compute filename `YYYY-MM-DD-<slug>-handbook.html` with -2/-3 collision loop | none |
| 6 | Render HTML — inline three CSS files in palette → typography → components order | `design/formats/handbook.html`, `design/palette.css`, `design/typography.css`, `design/components.css`, `design/components.html` |
| 7 | Run audit (`bash audit/run.sh <path>`); max 2 retry rounds; failure is loud | `audit/run.sh` |
| 8 | `open <path>` then path on its own line as LAST output (no emoji, no banner) | none |

### `skill/story-arc.md` — 151 lines (cap: 200)

Six step blocks (A–F): build the arc table, render the flowing paragraph, run self-review on every row, display + ask for approval, exact-match approval whitelist, revision loop.

The 5-column arc table header is canonical and locked:
```
| # | Beat | Section | One sentence | Reader feels |
```

### `skill/interview/handbook.md` — 45 lines (cap: 80)

Five questions in DOC-06 schema order — Audience, Material, Sections, Tone notes, Inclusions / exclusions — each with a documented empty-answer default. Hand-off to `${CLAUDE_SKILL_DIR}/story-arc.md` after Q5.

## Mode-detection regex and its three handled cases

Step 1 inspects the literal `$ARGUMENTS` string and handles three substitution shapes:

| Shape | Trigger | Branch |
|-------|---------|--------|
| Empty string | `/deshtml` with no args (working assumption) | Interview mode |
| Literal `<no arguments>` placeholder | (in case Claude Code's renderer ever emits this) | Stripped before length check; interview mode |
| Real user text | `/deshtml @file.md` or `/deshtml <pasted prose>` | Source-mode regex `(^\|[[:space:]])@\S+` OR >200-char prose threshold → source-mode stub |

The regex `(^|[[:space:]])@\S+` matches `@` only when it's at start-of-string or preceded by whitespace, so it doesn't false-fire on email addresses inside prose. The >200-char prose threshold (after stripping `@\S+` tokens) catches pasted source even when no `@<path>` is present.

**Working assumption (HIGH confidence per 02-RESEARCH):** `$ARGUMENTS` is the empty string when `/deshtml` is invoked with no args. Plan 02-04's fixture run is the empirical confirmation. The Step 1 logic handles all three shapes regardless, so if `<no arguments>` ever shows up, it's already covered.

## Five doc types enumerated in Step 2

| Type | Status | Behavior |
|------|--------|----------|
| handbook | implemented | Continue to Step 3 (interview) |
| pitch | stubbed | Reply `pitch is coming in Phase 3. Try handbook for now.` Stop. |
| technical brief | stubbed | Reply `technical brief is coming in Phase 3. Try handbook for now.` Stop. |
| presentation | stubbed | Reply `presentation is coming in Phase 3. Try handbook for now.` Stop. |
| meeting prep | stubbed | Reply `meeting prep is coming in Phase 3. Try handbook for now.` Stop. |

Phase 3 flips stubs to real interview reads — SKILL.md only changes Step 2's branch arms. The structure is locked.

## Three-CSS-file inlining order (Step 6, amended D2-15)

```
<style>
  /* a) palette.css verbatim */
  :root { --fg-main: #f5f5f7; --bg-main: #1c1c1e; ... }
  ...

  /* c) typography.css verbatim */
  @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap');
  body { font-family: 'Inter', system-ui, sans-serif; ... }
  h1 { font-size: 80px; ... }
  ...

  /* e) components.css verbatim */
  .sidebar { width: 240px; ... }
  .hero { padding: 96px 0; ... }
  ...
</style>
<style>
  /* skeleton's existing layout block — kept as a SECOND <style> after */
</style>
```

Order is load-bearing: palette defines `:root` tokens first; typography owns body/h1/h2/h3 second; components cascade last. Per SYSTEM.md Rule 6 (locked in plan 02-01).

## Audit invocation contract with plan 02-03

Step 7 invokes:
```bash
bash "${CLAUDE_SKILL_DIR}/audit/run.sh" "<absolute-path-from-step-5>"
```

Contract:
- Exit 0 → continue to Step 8 (open + print path).
- Non-zero → read violations on stderr, regenerate addressing each, write again, re-run audit. Max 2 retry rounds.
- Round 3 still fails → keep file, surface verbatim violation list to user, continue to Step 8 anyway. Failure is loud — never silently delivered with violations.

The audit script implements four rules: hex-outside-`:root`, class-allowlist (harvested live from components.html + typography.css), banned-tags, leftover `<link rel=stylesheet>`. See 02-03-SUMMARY.md for the full contract.

## 9-phrase approval whitelist (D2-12)

Story-arc.md Step E exact-matches (case-insensitive, trim, lowercase) against:

```
- approve
- approved
- looks good
- lgtm
- ship it
- go
- proceed
- aprobado
- dale
```

**Mechanical gate IS the moat.** Anything not on the whitelist is a revision request, even if the user wrote "yeah great let's do it!!!" — interpreted as revision feedback, regenerate the arc, re-ask.

## 5 BAD→GOOD pairs (verbatim from `/Users/sperezasis/CLAUDE.md` §"Section Writing Rules")

| Source line | Bad | Good |
|-------------|-----|------|
| Line 59 | Read any issue in 3 seconds. | Every issue follows one format. |
| Line 60 | Everything arrives automatically. | One board, built for your team. |
| Line 64 | Projects have shape. | Every project has a structure. |
| Line 65 | How teams stay connected. | Cross-team work follows one path. |
| Line 78 | (subtitle) "And automations that sync them." | (subtitle) "Code repos hold code. Team repos are where your team lives." |

Verbatim discipline (D-14 from Phase 1) preserved.

## What plan 02-04's fixture run must verify

End-to-end interactive flow:
1. **Interview launches on no-args.** `/deshtml` with empty `$ARGUMENTS` → Step 1 routes to interview mode → Step 2 asks doc type. Confirms working assumption about empty-arg behavior.
2. **Source-mode stub fires for `@<path>`.** `/deshtml @somefile.md` → Step 1 regex hits → "Source mode is coming in Phase 4." reply, then stop. No interview launch.
3. **Source-mode stub fires for >200-char prose.** Pasted long text → Step 1 length threshold hits → same Phase-4 stub.
4. **Doc-type stub fires for non-handbook.** User picks `pitch` → Step 2 reply `pitch is coming in Phase 3. Try handbook for now.` then stop. No silent handbook fallback.
5. **Arc gate blocks generation.** User completes interview, sees arc table, types non-approval → Step 4 routes to revision loop → SKILL.md never reaches Step 5/6/7/8.
6. **Approval unblocks.** User types `approve` (or any of 9 whitelist phrases) → Step 4 returns to SKILL.md → Step 5 computes filename → Step 6 renders → Step 7 audits → Step 8 opens + prints path.
7. **Audit retries on injected violations.** Force a hex-outside-`:root` or banned-tag violation → audit exit ≠ 0 → SKILL.md regenerates → re-runs audit → max 2 retry rounds. Loud failure on round 3.
8. **Output is self-contained and visually matches `pm-system.html`.** All three CSS files inlined, zero `<link rel="stylesheet"`, zero `<script>`. Visual diff against `pm-system.html` is the final gate.

## Deviations from Plan

### Auto-fixed issues

**1. [Rule 1 - Bug in plan verify regex] Task 1 forbidden-doc-type check too greedy**
- **Found during:** Task 1 verification.
- **Issue:** The plan's `<verify>` block runs `! command grep -qiE 'pitch|technical brief|presentation|meeting prep' skill/interview/handbook.md` to ensure the file mentions zero other doc types. But the file content the plan prescribes contains the verbatim CLAUDE.md tone phrase "Handbook, not pitch. Describe what IS." The regex matches "pitch" inside that tone phrase, so the verify command fails despite the file being correct per acceptance_criteria intent ("File mentions zero of the four other doc TYPES"). The "pitch" inside "not pitch" is a tone instruction (handbook tone vs. pitch tone), not a reference to the pitch doc type.
- **Fix:** Confirmed substantively that the only "pitch" hit in the file is the verbatim tone phrase (line 25); zero references to the pitch / technical brief / presentation / meeting prep doc types. Acceptance criteria satisfied; verify regex is the bug.
- **Files modified:** none (file content as-prescribed).
- **Commit:** `721d4cc`.

**2. [Rule 1 - Bug in plan verify regex] Task 2 BSD-grep flag-parse failure**
- **Found during:** Task 2 verification.
- **Issue:** The plan's `<verify>` block runs `command grep -qF '- approve' skill/story-arc.md` (and similar for the 9 whitelist phrases). BSD `grep` (macOS default) parses `-` as the start of a flag, so `'- approve'` fails as `grep: invalid option --  '`. Same bug is in plan 02-03's verify block (preempted there; see 02-03-SUMMARY.md deviation #2).
- **Fix:** Used `command grep -qF -- '- approve' skill/story-arc.md` (the `--` separator stops flag parsing). All 9 whitelist phrases verified plus 5 BAD→GOOD pairs plus 3 self-review check labels.
- **Files modified:** none (file content as-prescribed).
- **Commit:** `de61e51`.

### No architectural deviations.
### No auth gates.
### No deferred items.

## Self-Check: PASSED

Files created and committed:
- `skill/interview/handbook.md` — FOUND (45 lines, commit `721d4cc`)
- `skill/story-arc.md` — FOUND (151 lines, commit `de61e51`)
- `skill/SKILL.md` — FOUND (171 lines, commit `ae4ff61`)

Commits in branch:
- `721d4cc` — FOUND
- `de61e51` — FOUND
- `ae4ff61` — FOUND

Line caps:
- SKILL.md ≤ 200 → 171 ✓
- story-arc.md ≤ 200 → 151 ✓
- interview/handbook.md ≤ 80 → 45 ✓

Constraint checks:
- SKILL.md inlines zero rubric content (no whitelist phrases, no BAD→GOOD pairs, no interview questions) ✓
- SKILL.md enumerates all 5 doc types in Step 2 (D2-05) ✓
- SKILL.md detects source mode at turn 1 with the regex `(^|[[:space:]])@\S+` (D2-04 / SKILL-03) ✓
- SKILL.md invokes `bash skill/audit/run.sh` at Step 7 (D2-20) ✓
- SKILL.md inlines palette → typography → components in that order at Step 6 (amended D2-15) ✓
- story-arc.md contains all 9 approval phrases from D2-12 ✓
- story-arc.md contains all 5 verbatim BAD→GOOD pairs from CLAUDE.md (D2-14) ✓
- interview/handbook.md has exactly 5 questions in DOC-06 schema order (DOC-07) ✓
