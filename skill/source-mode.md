# Source mode — extract-don't-invent arc proposal

SKILL.md reads this file when source mode triggers at turn 1 (`/deshtml @<path>`
or pasted prose >200 characters). Follow it end-to-end. Return to SKILL.md
Step 5 (filename + collision check) only after Step E hands off. The source-mode
branch bypasses the interview entirely (SKILL-02) — never silently falls back
to it (SKILL-03 contract).

## Step A — Ingest the source

Two ingestion shapes. Pick the one that matches `$ARGUMENTS` (the verbatim
arguments the user passed to `/deshtml`).

1. **`@<path>` form.** Extract the FIRST `@<path>` token from `$ARGUMENTS`. The
   path may be relative (resolve against the current working directory) or
   absolute. Use Claude's Read tool against the resolved path. If the file
   does not exist or Read fails, emit EXACTLY this line and STOP:

   ```
   File not found: ${path}
   ```

   Do NOT fall back to interview mode (SKILL-03). Do NOT prompt for a different
   path. Do NOT proceed to Step B.

2. **Pasted-prose form.** If no `@<path>` token is present and `$ARGUMENTS`
   (with the literal text `<no arguments>` stripped and surrounding whitespace
   trimmed) is longer than 200 characters, use the verbatim prompt body as
   the source. No path resolution. No file Read. Treat the prose as the
   source material directly.

**Multi-`@` resolution (V1 limitation):** Only the FIRST `@<path>` token is
honored. Subsequent `@<path>` tokens in `$ARGUMENTS` are ignored. See the
"What this file must NOT do" tail.

**`@<path>` + prose collision (V1 contract):** If `$ARGUMENTS` contains BOTH a
`@<path>` token AND >200 chars of prose, the `@<path>` form wins (first-match).
The accompanying prose is ignored. See the "What this file must NOT do" tail.

## Step B — Infer the document type

Run the source through this decision tree. The first rule that fires wins.
Default-on-ambiguous lands `handbook` (the most general type, safe fallback).

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

Print exactly one line to the user (no other prose, no question, no decoration):

> Detected type: <type>

The user does NOT confirm. If the inference is wrong, the user can include a
correction in their first revision message at the arc gate (Step E) — for
example, "this should be a pitch" — and Claude reroutes the type and
regenerates the arc.

## Step C — Build the source-grounded arc (extract-don't-invent)

Build a story arc table where every `One sentence` cell is GROUNDED in source
content. Concretely:

1. Walk the source top-to-bottom. Identify natural beats — content boundaries
   marked by H2 headings, paragraph breaks, list-section breaks, slide breaks
   (for presentation source), or topic shifts.
2. For each beat, extract a representative sentence (paraphrase or direct
   quote of source material). The `One sentence` cell IS that extracted
   sentence — not a Claude-invented summary.
3. If a beat has insufficient source content to extract a representative
   sentence, SKIP that beat. Do NOT fabricate. The flowing paragraph in
   story-arc.md Step B is the gap-detection signal; if it reads broken, the
   user's revision message can re-add the beat with new source material.
4. Beat count is dictated by the source, not by a target row count. Step 5b
   (format auto-selection in SKILL.md) decides which format the row count
   lands in.
5. **Fallback for thin source:** if fewer than 3 beats survive Step C, STOP
   and emit a LOUD notice to the user: "Source has fewer than 3 extractable
   beats — falling back to interview mode." Then read
   `${CLAUDE_SKILL_DIR}/interview/handbook.md` and continue from there. This
   is the only allowed source-mode → interview-mode transition, and it is
   loud, not silent (SKILL-03 contract preserved).

**Voice rule:** the `One sentence` cells inherit the source's voice (a casual
draft yields casual sentences; a formal spec yields formal sentences). Section
TITLES still follow handbook tone — describe what IS, never sell. This is the
same divergence rule as the interview-mode handbook flow. story-arc.md Step C's
self-review pass enforces the title-tone rule mechanically (pitch-vocabulary
regex + LLM judgment); do NOT short-circuit it because the source is casual.

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

## Step E — Return to SKILL.md

On approval, return to SKILL.md and proceed to Step 5 (filename + collision
check). Step 5b (format auto-selection) and Step 6 (render) run unchanged —
the same mechanical decision tree picks the format from the type and the row
count, exactly as in interview mode. There is no source-mode branch in
Step 5b, Step 6, Step 7, or Step 8.

## What this file must NOT do

- Must not be inlined into SKILL.md (single source of truth; SKILL.md ≤200
  line cap).
- Must not silently fall back to interview mode if `@<path>` resolution fails
  (SKILL-03 contract — emit `File not found: ${path}` and stop).
- Must not invent beats or `One sentence` cells. If the source is thin, the
  arc is thin — let story-arc.md's flowing paragraph surface the gap. The
  one allowed source→interview transition is the <3-beats fallback in
  Step C, and it is LOUD (announced to the user), not silent.
- Must not duplicate story-arc.md's table schema, self-review pass, or
  approval whitelist (single source of truth).
- Must not honor multiple `@<path>` tokens (V1 limitation — first match wins;
  subsequent `@<path>` tokens are ignored).
- Must not merge `@<path>` with simultaneous >200-char prose (V1 contract —
  `@<path>` wins; the prose is ignored).
- Must not ask the user to pick the document type (type is INFERRED in
  Step B, surfaced as `Detected type: <type>`, corrected via revision
  message at the arc gate).
- Must not bypass Step 5b's mechanical format selection (the same decision
  tree fires for source mode as for interview mode).
