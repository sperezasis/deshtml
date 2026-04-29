# Technical brief interview

SKILL.md reads this file when the user picks `technical brief` as the document type.
Ask the questions in order. Use `AskUserQuestion` for closed-shape questions
(per the "How to ask" line under each question) and plain text input only for
open content. Empty answers are accepted — proceed with the documented
defaults. Do not enforce length, do not retry, do not validate.

Context-mode pre-fill: if SKILL.md routed here through Step 3 after
context-mode.md (Step C-Edit), some answers may already be drafted. For each
pre-filled field, present its drafted value as the FIRST option in the
`AskUserQuestion` call (label suffixed with " (Detected)"). Skip questions
whose answers were confirmed in context-mode.

The schema follows DOC-06's mandate (audience → material → section conventions
→ tone notes → handoff to story-arc) — same shape as `interview/handbook.md`.
Technical briefs are decision write-ups for engineers and typically render as
a 4+ section Handbook (the format auto-selects in SKILL.md Step 5b).

## The 5 questions

1. **Audience.** Which engineers will read this, and what context do they have?
   How to ask: `AskUserQuestion` — header "Audience", options "Same team, knows the codebase", "Adjacent team, needs context", "Future maintainers" (auto-"Other"). Default if blank: "Engineers on the same team, familiar with the codebase but not with this specific decision."

2. **The decision.** What was decided, in one sentence?
   How to ask: plain text input — content the user owns. Default if blank: ask Claude to summarize from the H1 the user implies. Do not block.

3. **Alternatives considered.** Free list — at least 2 options that were on the table and rejected.
   How to ask: `AskUserQuestion` — header "Alts", options "Let Claude propose 2-3", "I'll list them now" (auto-"Other"). If "I'll list them now" → plain text input follows. Default if blank: "Claude proposes 2-3 plausible alternatives derived from the decision context. Mark them as `[derived]`."

4. **Trade-offs that drove the choice.** Free text — what made the decided option win?
   How to ask: plain text input — content the user owns. Default if blank: ask Claude to derive from the alternatives. The trade-offs section is the heart of a tech brief; do not skip it silently — flag with `[derived]`.

5. **Inclusions / exclusions.** Anything to definitely include or definitely avoid?
   How to ask: `AskUserQuestion` — header "Includes", options "None", "I have specific notes" (auto-"Other"). If "I have specific notes" → plain text input follows. Default if blank: skip — no inclusions, no exclusions. Tone-default: "Handbook, not pitch. Describe what IS." Engineers read for facts, not enthusiasm; selling is wrong here.

## Hand-off

After question 5 (or earlier if the user says "go ahead, propose"), do NOT
write HTML. Read `${CLAUDE_SKILL_DIR}/story-arc.md` and follow it end-to-end.
The story-arc gate decides when HTML is allowed.

## What this interview must NOT do

- Do not validate answers. Empty answers proceed with the documented defaults.
- Do not loop on a question. One ask, one answer, move on.
- Do not re-ask the document type. SKILL.md handled that.
- Do not paraphrase the question text.
- Do not mention any other doc type elsewhere.
