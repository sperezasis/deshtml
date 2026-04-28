---
phase: 03-remaining-four-doc-types
plan: 02
subsystem: skill/interview
tags: [interview, doc-types, schema, prompt-engineering, markdown]

# Dependency graph
requires:
  - phase: 02-story-arc-gate-handbook-end-to-end
    provides: interview/handbook.md (DOC-06 schema reference, ≤5 question cap, empty-default policy)
  - phase: 03-remaining-four-doc-types
    provides: 03-01 wired SKILL.md Step 3 to read interview/${type}.md (kebab-case for two-word types)
provides:
  - skill/interview/pitch.md (Pitch interview, 5 questions, Overview-format expected)
  - skill/interview/technical-brief.md (Technical-brief interview, 5 questions, Handbook-format expected)
  - skill/interview/presentation.md (Presentation interview, 5 questions, Presentation format always)
  - skill/interview/meeting-prep.md (Meeting-prep interview, 5 questions, Overview-format expected)
  - DOC-06 schema satisfied across all 5 interview files (handbook + 4 new)
affects: [03-03 audit harvester (independent), 03-04 per-type fixtures (depends on this), 04 source-mode (consumes the same arc gate)]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Schema-lineage comment in opening prose (anchors each interview file to handbook.md as DOC-06 source of truth — Pitfall 20 mitigation)"
    - "[derived] annotation pattern (engineer-honest signal that a value was inferred, not user-provided — introduced in technical-brief, reused in meeting-prep)"
    - "Type-specific extra prohibitions in must-NOT-do section (presentation: max 7 slides; meeting-prep: do not fabricate risks)"

key-files:
  created:
    - skill/interview/pitch.md (47 lines)
    - skill/interview/technical-brief.md (45 lines)
    - skill/interview/presentation.md (50 lines)
    - skill/interview/meeting-prep.md (47 lines)
  modified: []

key-decisions:
  - "Meeting-prep question order leads with Meeting purpose (not Audience) — purpose anchors briefings while Audience anchors the other three. DOC-06 mandates the five fields appear, not their internal order."
  - "Pitfall 19 mitigation: 12 of 20 question labels are unique per file. Only Audience and Inclusions/exclusions are shared (schema fields). The other 12 labels are demonstrably type-specific (The ask / The problem / Your solution; The decision / Alternatives considered / Trade-offs; The takeaway / Slide outline / Tone; Meeting purpose / Talking points / Open questions / risks)."
  - "Tone calibration per RESEARCH §Pattern 8: technical-brief and meeting-prep use the verbatim CLAUDE.md phrase ('Handbook, not pitch. Describe what IS.') because engineers and briefing readers reward fact-density. Pitch and presentation document title-handbook / body-energetic divergence — selling is OK in body prose, never in section titles."
  - "[derived] annotation pattern is shared across technical-brief and meeting-prep but anchored on different questions. Tech-brief: alternatives + trade-offs. Meeting-prep: meeting purpose + talking points. Same signal ('Claude inferred this'), different surfaces."
  - "All four files mention zero of the OTHER doc types by name. Each is single-purpose. The only cross-references are inside the verbatim CLAUDE.md tone phrase ('Handbook, not pitch') which uses 'pitch' as a tone descriptor, not a doc-type reference."

patterns-established:
  - "DOC-06 schema preserved verbatim across 5 interview files: title → opening prose with schema-lineage comment → ## The N questions → ## Hand-off → ## What this interview must NOT do."
  - "Each file ≤80 lines (handbook is 45, the others 45-50). DOC-07's lean shape produces lean files; padding violates the moat."
  - "Hand-off contract is uniform across all 5: instruct Claude to read ${CLAUDE_SKILL_DIR}/story-arc.md after questions complete. The arc gate is universal — no per-type branching at this layer."

requirements-completed: [DOC-01, DOC-03, DOC-04, DOC-05, DOC-06]

# Metrics
duration: ~10min
completed: 2026-04-28
---

# Phase 03 Plan 02: Four Type-Tailored Interview Files Summary

**Four kebab-cased interview files (pitch, technical-brief, presentation, meeting-prep) ship the type-distinctive question sets that DOC-06's uniform schema requires, completing the interview layer the SKILL.md Step 3 router (wired in plan 03-01) reads from.**

## Performance

- **Duration:** ~10 min
- **Started:** 2026-04-28T11:45:22Z
- **Completed:** 2026-04-28T11:48:37Z
- **Tasks:** 4 of 4
- **Files modified:** 4 created, 0 modified

## Accomplishments

- Plan 03-04's per-type fixture run (Wave 2) is unblocked — all 4 routes that SKILL.md Step 3 expects now resolve to real files.
- DOC-06 (uniform interview schema across all 5 doc types) is now satisfied — handbook.md plus the four new files share the same six-section structure (title, opening prose, ## The N questions, ## Hand-off, ## What this interview must NOT do, plus per-question default clauses).
- Pitfall 19 (type-labeled clones) mitigated empirically — 12 of 20 question labels are unique per file. Only Audience and Inclusions/exclusions are shared schema fields.
- Pitfall 20 (silent schema drift) mitigated structurally — every file's opening prose contains the schema-lineage comment referencing both `interview/handbook.md` and `DOC-06`.

## Task Commits

Each task was committed atomically:

1. **Task 1: Write skill/interview/pitch.md** — `a5d3da4` (feat)
2. **Task 2: Write skill/interview/technical-brief.md** — `93bb430` (feat)
3. **Task 3: Write skill/interview/presentation.md** — `8922a71` (feat)
4. **Task 4: Write skill/interview/meeting-prep.md** — `88088a3` (feat)

**Plan metadata:** _(this commit, includes SUMMARY.md + STATE.md + ROADMAP.md updates)_

## Files Created

- `skill/interview/pitch.md` (47 lines) — Pitch-tailored interview. Sequences audience → the ask → the problem → solution → tone-defaults handoff. Body tone may run sales-y; section TITLES inherit handbook tone (describe what IS).
- `skill/interview/technical-brief.md` (45 lines) — Technical-brief-tailored interview. Sequences audience → decision → alternatives → trade-offs → tone-defaults. Engineers read for facts; tone-default is the verbatim CLAUDE.md handbook phrase. Introduces the `[derived]` annotation pattern.
- `skill/interview/presentation.md` (50 lines) — Presentation-tailored interview. Sequences audience → takeaway → slide outline → tone (energetic body; handbook titles) → inclusions. Documents D3-01 (format=presentation forced regardless of section count) and the arc-row → slide mapping. Includes a 6th must-NOT-do prohibition: max 7 slides on the empty-default path.
- `skill/interview/meeting-prep.md` (47 lines) — Meeting-prep-tailored interview. Sequences meeting purpose → audience → talking points → open questions/risks → tone-defaults. Briefings deliver facts; verbatim CLAUDE.md tone phrase. Question order intentionally leads with Meeting purpose (not Audience) — purpose anchors briefings. Includes a 6th must-NOT-do prohibition: do not fabricate risks.

## Per-File Schema Field Coverage

All 5 interview files (handbook + 4 new) cover the DOC-06 schema fields:

| File | Audience | Material/Decision/Takeaway/Purpose | Sections | Tone | Inclusions / handoff |
|------|----------|------------------------------------|----------|------|----------------------|
| handbook.md | Q1 Audience | Q2 Material | Q3 Sections | Q4 Tone notes | Q5 + Hand-off |
| pitch.md | Q1 Audience | Q3 The problem + Q4 Your solution | Q2 The ask anchors arc | Q5 default clause | Q5 + Hand-off |
| technical-brief.md | Q1 Audience | Q2 The decision | Q3 Alternatives + Q4 Trade-offs | Q5 default clause | Q5 + Hand-off |
| presentation.md | Q1 Audience | Q2 The takeaway | Q3 Slide outline | Q4 Tone | Q5 + Hand-off |
| meeting-prep.md | Q2 Audience | Q1 Meeting purpose | Q3 Talking points + Q4 Open questions | Q5 default clause | Q5 + Hand-off |

## Type-Distinctive Question Labels (Pitfall 19 mitigation)

| File | Type-distinctive labels |
|------|--------------------------|
| pitch.md | The ask, The problem, Your solution |
| technical-brief.md | The decision, Alternatives considered, Trade-offs that drove the choice |
| presentation.md | The takeaway, Slide outline, Tone |
| meeting-prep.md | Meeting purpose, Talking points, Open questions / risks |

Only `Audience` and `Inclusions / exclusions` are shared across files (schema fields). The other 12 labels are demonstrably type-specific.

## Tone-Default Calibration (RESEARCH §Pattern 8)

| File | Tone calibration |
|------|------------------|
| handbook.md | Verbatim CLAUDE.md ("Handbook, not pitch. Describe what IS.") |
| technical-brief.md | Verbatim CLAUDE.md ("Handbook, not pitch. Describe what IS.") |
| meeting-prep.md | Verbatim CLAUDE.md ("Handbook, not pitch. Describe what IS.") |
| pitch.md | Title-handbook / body-energetic divergence (selling OK in body, never in titles) |
| presentation.md | Title-handbook / body-energetic divergence (slides reward visual punch in body) |

3 of 5 files use the verbatim phrase. 2 of 5 document the title-handbook / body-energetic divergence. Both groups preserve title-tone discipline (titles describe what IS).

## Decisions Made

See `key-decisions` in frontmatter. Most consequential:

- Meeting-prep leads with Meeting purpose (not Audience) — DOC-06 mandates field presence, not field order.
- `[derived]` annotation introduced in technical-brief, reused in meeting-prep — same engineer-honest signal anchored on different questions per type.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 — Plan verify-block bug] Plan's negation regex collides with mandated verbatim phrase**
- **Found during:** Task 2 (technical-brief.md) and Task 4 (meeting-prep.md)
- **Issue:** The plan's `<verify>` block negation regex `! command grep -qiE '^.*\bpitch\b|...'` (Task 2) and `! command grep -qiE '\bpitch\b|...'` (Task 4) flags ANY line containing the word `pitch` as a forbidden cross-doc-type reference. But the plan's `<action>` mandates the verbatim CLAUDE.md tone phrase "Handbook, not pitch. Describe what IS." which contains the word `pitch` as a TONE descriptor (not a doc-type reference). The verify regex is internally inconsistent with the action content the plan requires verbatim.
- **Same pattern in Task 3 (presentation.md):** the plan's mandated tone-default text contains "but never pitch-y" — also flagged by the negation.
- **Fix:** Followed the `<action>` content verbatim (per D-14 / D2-14 verbatim discipline, which the plan explicitly invokes). Verified the substantive acceptance criteria pass for all four files: zero references to OTHER doc types AS DOC TYPES. The only `pitch` and `pitch-y` occurrences are inside the verbatim CLAUDE.md tone phrase, which are tone descriptors, not doc-type references. Confirmed by manual cross-type grep that excludes the verbatim phrase line.
- **Files modified:** None (plan content was correct as written; the verify regex is the inconsistent piece).
- **Verification:** All substantive acceptance criteria from each task's `<acceptance_criteria>` block pass (file existence, ≤80 lines, exactly 5 questions, all required labels present, schema-lineage comment present, hand-off contract intact, tone phrase verbatim, no Q6+).
- **Committed in:** 93bb430 (Task 2), 8922a71 (Task 3), 88088a3 (Task 4) — the files themselves are correct.
- **Recommendation for plan 03-03:** the schema-drift check (RESEARCH §Pattern 9 / OQ-1) should NOT use a flat `\bpitch\b` negation. It should check that no line OUTSIDE the verbatim CLAUDE.md tone phrase context references another doc type by name. Specifically: scan question labels and prose, but skip lines matching the verbatim phrase `Handbook, not pitch. Describe what IS.` and `pitch-y` (the documented body-tone descriptor in presentation.md).

## Hand-off to Plan 03-04

Plan 03-04's per-type fixture runs need an `interview-answers.md` paste per type (4-5 answers each) to walk a real `/deshtml` invocation through to a generated HTML. Suggested fixture answer sets (one per type):

- **pitch fixture:** audience = "Caseproof leadership"; the ask = "approve a Phase-3 budget bump"; the problem = "Phase 3's four new doc types ship without the type-tailoring layer the interview was supposed to provide"; your solution = "ship the four interview files in Wave 1"; inclusions = (skip).
- **technical-brief fixture:** audience = "engineers on the deshtml repo"; the decision = "use kebab-case filenames for two-word doc types"; alternatives = "snake_case, camelCase, space-separated"; trade-offs = "kebab matches Claude Code skill convention and works without quoting in shell"; inclusions = (skip).
- **presentation fixture:** audience = "Phase 3 status review"; the takeaway = "Wave 1 unblocks Wave 2 — plans 03-02 and 03-03 are independent and ship in parallel"; slide outline = "let Claude propose"; tone = (default); inclusions = (skip).
- **meeting-prep fixture:** meeting purpose = "30-minute Phase 3 retrospective"; audience = "Caseproof internal team"; talking points = "what shipped Wave 1, what's outstanding for Wave 2, fixture run plan"; open questions = (skip — to verify the do-not-fabricate-risks prohibition holds); inclusions = (skip).

The four fixture runs verify D3-22 (sequential read across the 4 outputs catches type-labeled clones if any silently converged).

## Hand-off to Plan 03-03

Plan 03-03 (audit harvester extension) is independent of this plan but related. **Recommendation: SHIP** the schema-drift check (RESEARCH §Pattern 9 / OQ-1) as Audit Rule 5 in Phase 3's audit extension — it's ~20 bash lines and locks D3-10's passive constraint into an active CI check. Use the corrected negation pattern documented in Deviation #1.

## Self-Check: PASSED

- All 4 created files verified to exist:
  - skill/interview/pitch.md (47 lines)
  - skill/interview/technical-brief.md (45 lines)
  - skill/interview/presentation.md (50 lines)
  - skill/interview/meeting-prep.md (47 lines)
- All 4 task commits verified to exist:
  - a5d3da4 (Task 1)
  - 93bb430 (Task 2)
  - 8922a71 (Task 3)
  - 88088a3 (Task 4)
