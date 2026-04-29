# Handbook interview

SKILL.md reads this file when the user picks `handbook` as the document type.
Ask the questions in order. Use `AskUserQuestion` for closed-shape questions
(per the "How to ask" line under each question) and plain text input only for
open content. Empty answers are accepted — proceed with the documented
defaults. Do not enforce length, do not retry, do not validate. The arc-gate
is where quality is enforced, not the interview.

Context-mode pre-fill: if SKILL.md routed here through Step 3 after
context-mode.md (Step C-Edit), some answers may already be drafted. For each
pre-filled field, present its drafted value as the FIRST option in the
`AskUserQuestion` call (label suffixed with " (Detected)") so the user can
accept it with one click. Skip questions whose answers were confirmed in
context-mode.

The schema follows DOC-06's mandate (audience → material → section conventions
→ tone notes → handoff to story-arc) so plan 03's other interviews mirror
this shape.

## The 5 questions

1. **Audience.** Who is the reader? One line is plenty.
   How to ask: `AskUserQuestion` — header "Audience", options "Internal team", "Leadership / decision-makers", "External stakeholder / client" (auto-"Other" for free text). Default if blank: "Someone unfamiliar with the topic, reading the handbook to get oriented."

2. **Material.** What is the document about? One to three sentences.
   How to ask: plain text input — the user must speak the subject matter. Default if blank: ask Claude to summarize from the audience answer plus the H1 the user implies. Do not block.

3. **Sections.** What sections do you imagine? Free list, or "let Claude propose."
   How to ask: `AskUserQuestion` — header "Sections", options "Let Claude propose 5-7 beats", "I'll list them now" (auto-"Other"). If "I'll list them now" → plain text input follows. Default if blank: "Claude proposes."

4. **Tone notes.** Anything specific about voice or register?
   How to ask: `AskUserQuestion` — header "Tone", options "Default (handbook tone — describe what IS)", "More formal", "More casual" (auto-"Other"). Default if blank: "Handbook, not pitch. Describe what IS." — verbatim from CLAUDE.md.

5. **Inclusions / exclusions.** Anything to definitely include or definitely avoid?
   How to ask: `AskUserQuestion` — header "Includes", options "None", "I have specific notes" (auto-"Other"). If "I have specific notes" → plain text input follows. Default if blank: skip — no inclusions, no exclusions.

## Hand-off

After question 5 (or earlier if the user says "go ahead, propose"), do NOT
write HTML. Read `${CLAUDE_SKILL_DIR}/story-arc.md` and follow it end-to-end.
The story-arc gate decides when HTML is allowed.

## What this interview must NOT do

- Do not validate answers ("that's too short", "please clarify"). Empty
  answers proceed with the documented defaults.
- Do not loop on a question. One ask, one answer, move on.
- Do not re-ask the document type. SKILL.md handled that.
- Do not paraphrase the question text. The wording is the contract; the
  "How to ask" line specifies the AskUserQuestion options to render.
- Do not mention any other doc type elsewhere.
