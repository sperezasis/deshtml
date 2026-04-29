# Meeting prep interview

SKILL.md reads this file when the user picks `meeting prep` as the document type.
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
Meeting prep is a briefing doc and typically renders as a 1-3 section Overview
(the format auto-selects in SKILL.md Step 5b).

## The 5 questions

1. **Meeting purpose.** In one sentence, what is this meeting deciding or accomplishing?
   How to ask: plain text input — content the user owns. Default if blank: ask Claude to derive from the audience answer + the H1. Do not block — but flag with `[derived]`.

2. **Audience.** Who is in the room?
   How to ask: `AskUserQuestion` — header "Room", options "Internal team", "Internal + external stakeholder", "Leadership / decision-makers" (auto-"Other"). Default if blank: "Internal team plus one external stakeholder, mid-tenure context."

3. **Talking points.** Free list — what you need to cover. Order matters.
   How to ask: `AskUserQuestion` — header "Points", options "Let Claude propose 3-5 from the purpose", "I'll list them now" (auto-"Other"). If "I'll list them now" → plain text input follows. Default if blank: "Claude proposes 3-5 talking points derived from the meeting purpose. Mark them as `[derived]`."

4. **Open questions / risks.** Free text — what is unresolved, what could go sideways?
   How to ask: `AskUserQuestion` — header "Risks", options "None / leave empty", "I have specific items" (auto-"Other"). If "I have specific items" → plain text input follows. Default if blank: skip — leave the open-questions section empty rather than fabricating risks. Empty is honest; fabricated risks waste meeting time.

5. **Inclusions / exclusions.** Anything to definitely include or definitely avoid?
   How to ask: `AskUserQuestion` — header "Includes", options "None", "I have specific notes" (auto-"Other"). If "I have specific notes" → plain text input follows. Default if blank: skip — no inclusions, no exclusions. Tone-default: "Handbook, not pitch. Describe what IS." Briefings deliver facts; selling is wrong here.

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
- Do not fabricate risks when question 4 is empty.
