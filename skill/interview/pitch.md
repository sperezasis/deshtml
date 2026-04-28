# Pitch interview

SKILL.md reads this file when the user picks `pitch` as the document type.
Ask the questions one at a time, in order. Wait for each answer before asking
the next. Empty answers are accepted — proceed with sensible defaults. Do
not enforce length, do not retry, do not validate. The arc-gate is where
quality is enforced, not the interview.

The schema follows DOC-06's mandate (audience → material → section conventions
→ tone notes → handoff to story-arc) — same shape as `interview/handbook.md`.
Pitch is structured as problem → solution → ask, and typically renders as a
1-3 section Overview (the format auto-selects in SKILL.md Step 5b).

## The 5 questions

1. **Audience.** Who is hearing this pitch? One line is plenty.
   (Default if blank: "A small-team decision-maker who hasn't seen this idea yet.")

2. **The ask.** What specific outcome do you want from this audience? One sentence.
   (Default if blank: "An explicit yes to building / buying / approving the proposal as described.")

3. **The problem.** In 1-2 sentences, what is broken without your solution?
   (Default if blank: "The audience has the problem already — they may not have named it. Claude proposes a 1-sentence framing from the ask.")

4. **Your solution.** In 1-2 sentences, what you are offering, in plain terms.
   (Default if blank: ask Claude to derive from the audience answer + the ask. Do not block.)

5. **Inclusions / exclusions.** Anything to definitely include or definitely avoid?
   (Default if blank: skip — no inclusions, no exclusions. Tone-default applies: section TITLES describe what IS (handbook tone); the BODY may run direct and confident — selling is OK in body prose, never in titles.)

## Hand-off

After question 5 (or earlier if the user says "go ahead, propose"), do NOT
write HTML. Read `${CLAUDE_SKILL_DIR}/story-arc.md` and follow it end-to-end.
The story-arc gate decides when HTML is allowed. The arc gate's title-tone
self-review applies even when this interview's body-tone default is more
energetic — TITLES always describe what IS, regardless of doc type.

## What this interview must NOT do

- Do not validate answers ("that's too short", "please clarify"). Empty
  answers proceed with the documented defaults.
- Do not loop on a question. One ask, one answer, move on.
- Do not re-ask the document type. SKILL.md handled that — by the time
  Claude is reading this file, pitch is already locked.
- Do not paraphrase the questions. The wording is the contract.
- Do not mention any other doc type elsewhere. Those are stubbed in SKILL.md.
