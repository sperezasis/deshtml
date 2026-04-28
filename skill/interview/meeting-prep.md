# Meeting prep interview

SKILL.md reads this file when the user picks `meeting prep` as the document type.
Ask the questions one at a time, in order. Wait for each answer before asking
the next. Empty answers are accepted — proceed with sensible defaults. Do
not enforce length, do not retry, do not validate. The arc-gate is where
quality is enforced, not the interview.

The schema follows DOC-06's mandate (audience → material → section conventions
→ tone notes → handoff to story-arc) — same shape as `interview/handbook.md`.
Meeting prep is a briefing doc and typically renders as a 1-3 section
Overview (the format auto-selects in SKILL.md Step 5b).

## The 5 questions

1. **Meeting purpose.** In one sentence, what is this meeting deciding or accomplishing?
   (Default if blank: ask Claude to derive from the audience answer + the H1. Do not block — but flag with `[derived]`.)

2. **Audience.** Who is in the room? One or two lines.
   (Default if blank: "Internal team plus one external stakeholder, mid-tenure context.")

3. **Talking points.** Free list — what you need to cover. Order matters.
   (Default if blank: "Claude proposes 3-5 talking points derived from the meeting purpose. Mark them as `[derived]`.")

4. **Open questions / risks.** Free text — what is unresolved, what could go sideways?
   (Default if blank: skip — leave the open-questions section empty rather than fabricating risks. Empty is honest; fabricated risks waste meeting time.)

5. **Inclusions / exclusions.** Anything to definitely include or definitely avoid?
   (Default if blank: skip — no inclusions, no exclusions. Tone-default applies: "Handbook, not pitch. Describe what IS." — verbatim from CLAUDE.md. Briefings deliver facts; selling is wrong here.)

## Hand-off

After question 5 (or earlier if the user says "go ahead, propose"), do NOT
write HTML. Read `${CLAUDE_SKILL_DIR}/story-arc.md` and follow it end-to-end.
The story-arc gate decides when HTML is allowed.

## What this interview must NOT do

- Do not validate answers ("that's too short", "please clarify"). Empty
  answers proceed with the documented defaults.
- Do not loop on a question. One ask, one answer, move on.
- Do not re-ask the document type. SKILL.md handled that — by the time
  Claude is reading this file, meeting prep is already locked.
- Do not paraphrase the questions. The wording is the contract.
- Do not mention any other doc type elsewhere. Those are stubbed in SKILL.md.
- Do not fabricate risks when question 4 is empty. An empty open-questions
  section is honest; manufactured risks waste the audience's time.
