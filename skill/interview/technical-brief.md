# Technical brief interview

SKILL.md reads this file when the user picks `technical brief` as the document type.
Ask the questions one at a time, in order. Wait for each answer before asking
the next. Empty answers are accepted — proceed with sensible defaults. Do
not enforce length, do not retry, do not validate. The arc-gate is where
quality is enforced, not the interview.

The schema follows DOC-06's mandate (audience → material → section conventions
→ tone notes → handoff to story-arc) — same shape as `interview/handbook.md`.
Technical briefs are decision write-ups for engineers and typically render as
a 4+ section Handbook (the format auto-selects in SKILL.md Step 5b).

## The 5 questions

1. **Audience.** Which engineers will read this, and what context do they have? One or two lines.
   (Default if blank: "Engineers on the same team, familiar with the codebase but not with this specific decision.")

2. **The decision.** What was decided, in one sentence?
   (Default if blank: ask Claude to summarize from the H1 the user implies. Do not block.)

3. **Alternatives considered.** Free list — at least 2 options that were on the table and rejected.
   (Default if blank: "Claude proposes 2-3 plausible alternatives derived from the decision context. Mark them as `[derived]` so the user can correct.")

4. **Trade-offs that drove the choice.** Free text — what made the decided option win?
   (Default if blank: ask Claude to derive from the alternatives. The trade-offs section is the heart of a tech brief; do not skip it silently — flag with `[derived]`.)

5. **Inclusions / exclusions.** Anything to definitely include or definitely avoid?
   (Default if blank: skip — no inclusions, no exclusions. Tone-default applies: "Handbook, not pitch. Describe what IS." — verbatim from CLAUDE.md. Engineers read for facts, not enthusiasm; selling is wrong here.)

## Hand-off

After question 5 (or earlier if the user says "go ahead, propose"), do NOT
write HTML. Read `${CLAUDE_SKILL_DIR}/story-arc.md` and follow it end-to-end.
The story-arc gate decides when HTML is allowed.

## What this interview must NOT do

- Do not validate answers ("that's too short", "please clarify"). Empty
  answers proceed with the documented defaults.
- Do not loop on a question. One ask, one answer, move on.
- Do not re-ask the document type. SKILL.md handled that — by the time
  Claude is reading this file, technical brief is already locked.
- Do not paraphrase the questions. The wording is the contract.
- Do not mention any other doc type elsewhere. Those are stubbed in SKILL.md.
