---
phase: 04-source-mode-readme-launch-hardening
reviewed: 2026-04-27T00:00:00Z
depth: standard
files_reviewed: 4
files_reviewed_list:
  - skill/source-mode.md
  - skill/SKILL.md
  - README.md
  - CHANGELOG.md
findings:
  critical: 0
  high: 0
  medium: 2
  low: 1
  info: 2
  total: 5
status: issues
---

# Phase 4: Code Review Report

**Reviewed:** 2026-04-27
**Depth:** standard
**Files Reviewed:** 4
**Status:** issues

## Summary

Phase 4 ships a tight, well-scoped change set: `skill/source-mode.md` (NEW, 162L) wires the source-mode branch under the SKILL.md ≤200-line cap, `skill/SKILL.md` (198L) flips the Phase-2 stub cleanly, `README.md` (67L) is in handbook tone, and `CHANGELOG.md` (65L) seeds Keep-a-Changelog 1.1.0. Mechanical guardrails all hold:

- SKILL.md = 198 lines (≤200 cap, D4-08 satisfied).
- Banned-pitch-vocabulary regex (`revolutionary|game-changing|breakthrough|next-generation|cutting-edge|seamlessly|effortlessly|in seconds|out of the box|everything you need|easily|powerful`) returns **0 hits** across all 4 files.
- Install + uninstall one-liners in README.md are byte-for-byte identical to the URL pattern in `bin/install.sh` (`https://raw.githubusercontent.com/sperezasis/deshtml/main/bin/install.sh`) and the matching uninstall path.
- Detection regex `(^|[[:space:]])@\S+` and SKILL-03 contract literal preserved in SKILL.md Step 1.
- All 9 D4-10 README sections present, in order.
- CHANGELOG `[0.1.0] — TBD` placeholder is intentional (Plan 04-03 Task 2 dates post-merge); approved per summaries.
- Multi-`@` and `@`+prose disambiguation documented twice in source-mode.md (Step A + tail).
- LOUD <3-beats fallback is the only source→interview transition, explicitly announced; SKILL-03 contract preserved.
- Type-detection priority order (handbook > presentation > pitch > meeting-prep > technical-brief) matches the user-prompt override of D4-04.

Two medium findings concern user-facing factual accuracy in README.md: the question count is understated (claims 5, actually 6 = 1 type + 5 interview) and the listed interview topics omit one of the five. One low finding flags an internal handoff inconsistency in `source-mode.md` Step D that would skip the flowing-paragraph diagnostic that the same file's Step C explicitly relies on. Two info findings are non-blocking observations.

## Medium

### MD-01: README understates total question count by one

**File:** `README.md:3, 17`
**Issue:** README states the user answers "five short questions" total, but the actual flow runs 6 questions: 1 doc-type question (SKILL.md Step 2) + 5 interview questions (every `interview/*.md` file has exactly 5 questions per `grep -cE "^[0-9]+\. \*\*"`: handbook=5, pitch=5, technical-brief=5, presentation=5, meeting-prep=5). The numbered list at lines 19-22 reinforces the wrong total: "1. Claude asks the document type" + "2. Claude asks four more questions" → 1 + 4 = 5, but step 2 elides one question.

The first-time reader (Delfi, per D4-09) walks in expecting 5 prompts and gets 6 — minor expectation drift, but a factual claim in the highest-traffic public document. The CHANGELOG correctly says "5-question interview" (line 29) — referring to the interview file's 5 questions, not the total flow. The README is the inconsistent surface.

**Fix:** Change "five short questions" to "six short questions" in two places, and update the numbered list step 2 to enumerate all five interview topics:

```markdown
# Line 3
deshtml is a Claude Code skill — an add-on that gives Claude a specific job to do. You run `/deshtml`, answer six short questions about your topic, approve the proposed story arc, and Claude writes a single self-contained HTML file to the current directory.

# Line 17
Open Claude Code in any directory and type `/deshtml`. The skill walks you through six short questions, then proposes a story arc as a table.

# Line 20 (step 2 of the numbered list)
2. Claude asks five more questions about your audience, your material, your sections, your tone, and any inclusions or exclusions.
```

Alternative if the "5 questions" framing is the desired user-facing story: re-frame the type-pick (Step 2) as "pick a doc type" rather than a "question," and keep "five short questions" referring strictly to the interview. That requires a tone change in line 3 ("pick a doc type and answer five short questions"). Either approach resolves the count mismatch.

### MD-02: README step 2 omits the "Inclusions / exclusions" interview question

**File:** `README.md:20`
**Issue:** The numbered list at line 20 says "Claude asks four more questions about your audience, your material, your sections, and your tone." Each interview file (handbook, pitch, technical-brief, presentation, meeting-prep) actually asks 5 questions; question 5 is "Inclusions / exclusions" (verbatim from `interview/handbook.md:27` — "Inclusions / exclusions. Anything to definitely include or definitely avoid?"). Consistent across all 5 interview files.

This is the same root cause as MD-01 surfaced from a different angle: the README's enumeration of "four more questions" is missing the fifth. A reader who follows the numbered walk-through expects the conversation to end after the tone question and is surprised by an additional ask.

**Fix:** Add the fifth topic to the line-20 enumeration (combined fix with MD-01):

```markdown
2. Claude asks five more questions about your audience, your material, your sections, your tone, and any inclusions or exclusions.
```

## Low

### LO-01: source-mode.md Step D handoff says "from Step C onward" but Step C item 3 relies on story-arc.md Step B

**File:** `skill/source-mode.md:99-104, 113-115`
**Issue:** `source-mode.md` Step C item 3 (line 93-95) explicitly anchors the gap-detection pattern on story-arc.md's Step B output:

```
3. If a beat has insufficient source content to extract a representative
   sentence, SKIP that beat. Do NOT fabricate. The flowing paragraph in
   story-arc.md Step B is the gap-detection signal; if it reads broken, the
   user's revision message can re-add the beat with new source material.
```

But Step D (line 114-115) tells Claude to enter `story-arc.md` "from Step C onward":

```
Read ${CLAUDE_SKILL_DIR}/story-arc.md now and follow it from Step C onward —
Step A (build the arc) is what THIS file just did,
```

`story-arc.md` Step B IS the flowing paragraph (story-arc.md:25-40) — the very diagnostic Step C item 3 names. If Claude literally skips Step B per Step D's text, the user never sees the flowing paragraph and the "gap-detection signal" Step C item 3 promises does not exist for source-mode users.

The numbered list immediately after (source-mode.md:122-132) only enumerates Step C, D, E, F — confirming the literal reading. Two Phase 2 contracts depend on Step B firing for source-mode arcs:
- ARC-02 (the flowing paragraph diagnostic) — currently effectively skipped for source mode.
- The user's `gap-detection` affordance for thin sources that survived the >3-beats fallback but still have sparse beats.

This was not caught in the pre-merge dry-run because the dry-run fixtures had ≥3 well-formed beats; the diagnostic's absence only matters for borderline-thin sources.

Severity is Low (not Medium) because the Phase-2 self-review (story-arc.md Step C) still runs and the approval gate (Step E) still fires — the user can still reject the arc — but the documented gap-detection signal is missing from the source-mode flow as written.

**Fix:** Change Step D's handoff to read "from Step B onward" (or render Step B inline before handing off). The narrative correction in source-mode.md:

```markdown
## Step D — Hand off to story-arc.md

Read `${CLAUDE_SKILL_DIR}/story-arc.md` now and follow it from Step B onward —
Step A (build the arc) is what THIS file just did, but the flowing paragraph
diagnostic, the table format and column contract, the rendering, the
self-review, and the approval whitelist all stay single-source in story-arc.md.
The arc table you display follows story-arc.md's exact column format
(`# | Beat | Section | One sentence | Reader feels`).

Concretely:
1. Run story-arc.md Step B (render the flowing paragraph) under the arc table.
2. Run story-arc.md Step C (self-review) on every row of the arc.
3. Render per story-arc.md Step D (display + ask for approval).
4. Apply story-arc.md Step E (approval whitelist) — exact-match against the
   whitelist. Do not fuzzy-match.
5. Loop on revision per story-arc.md Step F if the user requests changes.
   Revision messages may include type corrections ("this should be a pitch"
   or "this is actually a presentation") — re-run Step B's decision tree
   with the user's hint as a forced override, then rebuild the arc per
   Step C.
```

This restores the gap-detection signal Step C item 3 already names, with no other behavioral change.

## Info

### IN-01: SKILL.md Step 1 case-2 trim guard

**File:** `skill/SKILL.md:21-25`
**Issue:** Case 2 ("else if `$ARGUMENTS` ... is longer than 200 characters") describes stripping `@\S+` tokens, the literal `<no arguments>`, and trimming whitespace before measuring length. This logic is correct, but the file does not include a worked example for the boundary case where stripping the `@<path>` token plus `<no arguments>` leaves exactly 200 characters of prose (which would route to interview mode, not source mode). Strict ">200" is what's documented; the implementation matches; no defect — but Phase-2 contract testers may want a fixture at 199/200/201 chars to confirm boundary behavior. Out of scope for this phase per the planning summaries; flagging only because the >200 threshold is the single threshold that mode detection turns on.

**Fix:** Optional V2 — add a fixture at exactly 200 chars and exactly 201 chars to a regression suite when one is created. Not actionable for v0.1.0.

### IN-02: CHANGELOG `[Unreleased]` link target precedes its existence

**File:** `CHANGELOG.md:64`
**Issue:** The ref-link `[Unreleased]: https://github.com/sperezasis/deshtml/compare/v0.1.0...HEAD` will 404 until the `v0.1.0` tag actually lands on `main` (Plan 04-03 Task 3, post-merge). Same for `[0.1.0]: https://github.com/sperezasis/deshtml/releases/tag/v0.1.0` (line 65) until `gh release create v0.1.0` runs (Task 4).

The phase summary explicitly approves the TBD date placeholder (`## [0.1.0] — TBD`) and the `Plan 04-03 Task 2 fills in the actual release date post-tag, in the same commit that bumps VERSION 0.0.1 → 0.1.0`. The two ref-links break briefly between merge and tag-push but resolve once the orchestrator's post-merge sequence completes. Pre-approved per `04-02-SUMMARY.md` "key-decisions"; not a defect.

**Fix:** None required pre-merge. Post-merge orchestrator should verify both URLs resolve after `git push origin main v0.1.0` and `gh release create v0.1.0` complete (CDN lag tolerated, per Plan 04-03 Task 3 spec).

---

_Reviewed: 2026-04-27_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
