# Handbook interview

SKILL.md reads this file when the user picks `handbook` as the document type.
Ask the questions one at a time, in order. Wait for each answer before asking
the next. Empty answers are accepted — proceed with sensible defaults. Do
not enforce length, do not retry, do not validate. The arc-gate is where
quality is enforced, not the interview.

The schema follows DOC-06's mandate (audience → material → section conventions
→ tone notes → handoff to story-arc) so plan 03's other interviews can mirror
this shape.

## The five questions

1. **Audience.** Who is the reader? One line is plenty.
   (Default if blank: "Someone unfamiliar with the topic, reading the handbook to get oriented.")

2. **Material.** What is the document about? One to three sentences.
   (Default if blank: ask Claude to summarize from the audience answer plus the H1 the user implies. Do not block on this.)

3. **Sections.** What sections do you imagine? Free list, or "let Claude propose."
   (Default if blank: "Claude proposes." Claude proposes 5-7 beats sized for the 960px Handbook layout.)

4. **Tone notes.** Anything specific about voice or register?
   (Default if blank: "Handbook, not pitch. Describe what IS." — verbatim from CLAUDE.md.)

5. **Inclusions / exclusions.** Anything to definitely include or definitely avoid?
   (Default if blank: skip — no inclusions, no exclusions.)

## Hand-off

After question 5 (or earlier if the user says "go ahead, propose"), do NOT
write HTML. Read `${CLAUDE_SKILL_DIR}/story-arc.md` and follow it end-to-end.
The story-arc gate decides when HTML is allowed.

## What this interview must NOT do

- Do not validate answers ("that's too short", "please clarify"). Empty
  answers proceed with the documented defaults.
- Do not loop on a question. One ask, one answer, move on.
- Do not re-ask the document type. SKILL.md handled that — by the time
  Claude is reading this file, handbook is already locked.
- Do not paraphrase the questions. The wording is the contract; tone
  notes inherit from CLAUDE.md, and the user's expectations match.
- Do not mention any other doc type elsewhere. Those are stubbed in SKILL.md.
