---
phase: 04-source-mode-readme-launch-hardening
plan: 01
subsystem: skill
tags: [source-mode, skill-md, lazy-load, arc-gate, SKILL-02, SKILL-03]
requires:
  - skill/SKILL.md (Phase 2/3 — flow control, ≤200 line cap)
  - skill/story-arc.md (Phase 2 — arc-table contract, self-review, approval whitelist)
  - skill/interview/handbook.md (Phase 2 — DOC-06 schema reference shape)
  - skill/audit/run.sh (Phase 2 — moat for generated HTML, untouched here)
provides:
  - skill/source-mode.md (NEW lazy-loaded sub-file: ingest → infer type → extract arc → hand off)
  - skill/SKILL.md Step 1 source-mode branch (real, not stub)
  - SKILL-02 mechanical layer (source mode end-to-end)
  - SKILL-03 contract preserved (no silent fallback)
affects:
  - .planning/phases/04-source-mode-readme-launch-hardening/04-03-PLAN.md (pre-merge dry run + post-merge live verification can now exercise source mode)
  - End-user `/deshtml @path` and pasted-prose flows (now wired)
tech-stack:
  added: []
  patterns:
    - "Lazy-load discipline (sub-file read only when its branch fires) — same shape as story-arc.md and interview/handbook.md"
    - "Mechanical decision tree for type detection (concrete content patterns; default-on-ambiguous = handbook)"
    - "Extract-don't-invent arc proposal (every One-sentence cell grounded in source; missing beats SKIPPED, not fabricated)"
    - "Hand-off-not-duplicate (source-mode.md hands off to story-arc.md from Step C onward; no duplicated table schema, self-review, or whitelist)"
    - "Loud fallback only (the single allowed source→interview transition is the <3-beats fallback, announced to the user)"
key-files:
  created:
    - skill/source-mode.md
  modified:
    - skill/SKILL.md (Step 1 only)
decisions:
  - "Type detection priority order: handbook > presentation > pitch > meeting-prep > technical-brief (handbook is also the default-on-ambiguous fallback). Reordered from CONTEXT D4-04's enumeration so the high-signal patterns (4+ H2 headings, slide-shaped fragments) fire before the more generic patterns."
  - "Combined-form Step 1 in SKILL.md (single 'In source mode...' sentence after the three-case detection) used to bring SKILL.md from 200→198 lines, well under the D4-08 ≤200 cap."
  - "Source-mode.md Step C adds an explicit <3-beats LOUD fallback: source→interview transition is permitted only when announced to the user. This is consistent with SKILL-03 (no SILENT fallback) and matches the must_haves' wording in the user prompt."
metrics:
  duration: ~25min
  completed: 2026-04-28
  tasks: 2
  files: 2
---

# Phase 04 Plan 01: source-mode wiring (SKILL-02 mechanical layer) Summary

Source-mode is now a real branch, not a stub: `/deshtml @<path>` and pasted prose >200 chars route to the new `skill/source-mode.md` sub-file at turn 1, which ingests the source, infers the doc type from content shape, extracts a source-grounded arc, and hands off to the unchanged Phase-2 story-arc.md gate.

## What was built

- `skill/source-mode.md` (NEW, 162 lines) — lazy-loaded source-mode branch. Five Steps (A=ingest, B=infer type, C=build arc, D=hand off to story-arc.md, E=return to SKILL.md Step 5) plus a "What this file must NOT do" tail.
- `skill/SKILL.md` Step 1 (modified, file 198/200 lines) — Phase-2 stub message removed; Step 1 now reads `${CLAUDE_SKILL_DIR}/source-mode.md` when source mode triggers and proceeds to Step 5 after arc approval.

## Files shipped

| File | Status | Lines | Notes |
|------|--------|-------|-------|
| `skill/source-mode.md` | NEW | 162 | Within 80-220 budget; below 100-150 target by ~12 lines (lean Step C with loud-fallback) |
| `skill/SKILL.md` | MODIFIED | 198 | Was 200; combined form trimmed Step 1 by 2 net lines |

## D4-04 decision tree (verbatim from `skill/source-mode.md` Step B)

```
1. Source contains 4+ H2 headings AND ("how to" OR reference-shape language:
   "this section describes", "the system uses", "every <noun>")
   → type = handbook

2. Source contains slide-shaped fragments — numbered slides like "Slide 1",
   "Slide 2", OR "next slide" cues, OR a sequence of short H1 + bullet pairs
   → type = presentation

3. Source contains ("we propose" OR "we're proposing" OR "we recommend") AND
   has an audience-mention (e.g., "for our team", "for the CTO", "for
   leadership") AND has ask language ("greenlight", "approve", "let me",
   "fund", "pilot")
   → type = pitch

4. Source is bullet/list-heavy (>50% of non-heading lines start with a list
   marker) AND contains ("agenda" OR "talking points" OR "meeting" OR
   "discuss")
   → type = meeting-prep

5. Source contains 2+ fenced code blocks AND ("decision" OR "trade-off" OR
   "alternative" OR "we chose" OR "rationale")
   → type = technical-brief

6. None of the above → type = handbook
```

Print line: `Detected type: <type>` — exactly one line, no question, no decoration.

## SKILL.md Step 1 source-mode branch (verbatim after the flip)

```markdown
## Step 1 — Detect mode

Inspect the literal `$ARGUMENTS` string (it may be empty, may contain `<no arguments>`,
or may contain the user's text — handle all three).

1. If `$ARGUMENTS` matches the regex `(^|[[:space:]])@\S+` → **source mode** (`@<path>` form).
2. Else if `$ARGUMENTS` (with `@\S+` tokens stripped, with the literal text
   `<no arguments>` stripped, and with surrounding whitespace trimmed) is
   longer than 200 characters → **source mode** (pasted prose).
3. Else → **interview mode**. Continue to Step 2.

In source mode (cases 1 and 2), read `${CLAUDE_SKILL_DIR}/source-mode.md` now and
follow it end-to-end. Return here only after source-mode.md hands back via
story-arc.md approval; proceed to Step 5 (skip Step 2, Step 3, Step 4).

Never silently fall back from source mode to interview mode (SKILL-03).
```

## Byte-for-byte preservation confirmed

- Detection regex `(^|[[:space:]])@\S+` preserved byte-for-byte (verified via `grep -qF`).
- SKILL-03 contract literal `Never silently fall back from source mode to interview mode (SKILL-03)` preserved byte-for-byte.
- `>200-char prose` branch preserved (now case 2 of the three-case detection).
- All other Steps (2, 3, 4, 5, 5b, 6, 7, 8) and the Constraints block unchanged.
- Frontmatter (`name: deshtml`, `disable-model-invocation: true`, etc.) unchanged.

## V1 limitations documented in `source-mode.md` (OQ-3 / OQ-4 resolutions)

- **Multi-`@` form (OQ-3):** only the FIRST `@<path>` token in `$ARGUMENTS` is honored; subsequent `@<path>` tokens are ignored. Documented in Step A and again in the "What this file must NOT do" tail.
- **`@<path>` + prose collision (OQ-4):** if `$ARGUMENTS` contains BOTH a `@<path>` token AND >200 chars of prose, the `@<path>` form wins (first-match); the accompanying prose is ignored. Documented in Step A and again in the "must NOT do" tail.

Both resolutions match the user-prompt directive ("first match wins").

## Loud fallback path (the only source→interview transition)

`source-mode.md` Step C step 5 specifies: if fewer than 3 beats survive extraction, STOP and emit a LOUD notice (`Source has fewer than 3 extractable beats — falling back to interview mode.`), then read `interview/handbook.md`. This is consistent with SKILL-03 — the contract forbids SILENT fallback; an announced fallback is allowed and is the safety valve for genuinely thin sources. Mentioned explicitly in the prompt's `important_context`.

## Deviations from Plan

### Auto-fixed issues

**1. [Rule 2 — Documented LOUD fallback for thin source]**
- **Found during:** Task 1 drafting; the user prompt's `important_context` flagged this as a required affordance ("If <3 beats survive, fall back to interview mode with a LOUD notice — the only allowed source→interview transition").
- **Issue:** The plan's `<action>` block did NOT explicitly enumerate the <3-beats fallback in Step C; only the user-prompt context did.
- **Fix:** Added Step C item 5 (LOUD fallback path) and called it out in the "must NOT do" tail as an explicit exception ("the one allowed source→interview transition is the <3-beats fallback in Step C, and it is LOUD").
- **Files modified:** `skill/source-mode.md`
- **Commit:** `bbd3d96`

**2. [Rule 3 — Combined-form Step 1 to land ≤200 lines]**
- **Found during:** Task 2 — SKILL.md was 200 lines (not 198 as the plan stated), so the naïve replacement (separate "Read source-mode.md" sentences in each branch) would have exceeded the cap.
- **Issue:** Plan stated "current line count is 198/200, so the flip lands at ≤200." Actual was 200/200; naïve replacement = 202.
- **Fix:** Used the plan's documented combined-form contingency (single shared "In source mode (cases 1 and 2)..." sentence after the three-case detection). Result: 198 lines, net -2 lines from the original.
- **Files modified:** `skill/SKILL.md`
- **Commit:** `7843764`

### Type-detection priority order

The CONTEXT D4-04 enumerates the type rules in this order: technical-brief → pitch → handbook → presentation → meeting-prep → handbook (default). The user-prompt `important_context` overrides this with: handbook > presentation > pitch > meeting-prep > technical-brief (handbook = safe fallback).

I implemented the user-prompt order — high-signal patterns (4+ H2 headings, slide-shaped fragments) fire BEFORE more generic patterns (we propose / agenda / code blocks). This avoids false positives where a handbook draft happens to include a `we propose` sentence or a code block in passing. Documented in the "decisions" frontmatter field.

## Authentication gates

None.

## Verification

Both task `<verify>` blocks passed:

- Task 1: `wc -l skill/source-mode.md` = 162 lines (within 80-220). All required literals present (`# Source mode`, `SKILL-02`, `SKILL-03`, all five Step headings, "What this file must NOT do", `File not found:`, `Detected type:`, all five doc-type names, `story-arc.md`, `Step 5b`).
- Task 2: `wc -l skill/SKILL.md` = 198 lines (≤200). Stub `Source mode is coming in Phase 4` removed. `source-mode.md` reference present. Detection regex preserved byte-for-byte. SKILL-03 literal preserved byte-for-byte. All eight Step headings + frontmatter (`name: deshtml`, `disable-model-invocation: true`) intact.

End-to-end empirical verification of the source-mode flow is owned by Plan 04-03 (pre-merge dry run + post-merge live verification on a fresh-machine install).

## What Plan 04-03 inherits

- A working source-mode flow on the local install at `~/.claude/skills/deshtml/` once the install is refreshed via `cp -R skill/* ~/.claude/skills/deshtml/`.
- The new `skill/source-mode.md` is part of the install payload (covered by `bin/install.sh`'s `cp -R skill/* ${target}/` from Phase 1).
- The Phase-2 SKILL-03 contract held byte-for-byte through the flip.

## What Plan 04-03 must verify against the LIVE URL

This plan did NOT verify (out of scope per Plan 04-03's ownership):

- `/deshtml @path/to/draft.md` actually reads the file via Claude's Read tool on a fresh machine.
- `/deshtml @nonexistent.md` actually emits `File not found: ${path}` and stops (no silent fallback).
- The pasted-prose >200-char branch actually fires source mode (regex behavior was preserved byte-for-byte but not empirically retested).
- The type-detection decision tree picks the expected type for at least one canonical source per type.
- The arc gate (story-arc.md approval whitelist) still fires correctly when called from source-mode.md vs. interview mode.

## Self-Check: PASSED

- File `skill/source-mode.md`: FOUND (162 lines).
- File `skill/SKILL.md`: FOUND (198 lines, ≤200 cap).
- Commit `bbd3d96` (Task 1): FOUND in git log.
- Commit `7843764` (Task 2): FOUND in git log.
- All Task 1 verify-block literals present (verified via grep run inline).
- All Task 2 verify-block literals present (verified via grep run inline).
