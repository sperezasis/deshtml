# Presentation interview

SKILL.md reads this file when the user picks `presentation` as the document type.
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
Presentations always render in the Presentation format regardless of section
count — SKILL.md Step 5b short-circuits to format=presentation when
type=presentation.

## The 5 questions

1. **Audience.** Who is watching this deck? One line.
   How to ask: `AskUserQuestion` — header "Audience", options "Decision-maker (boss / exec)", "Team / colleagues", "External stakeholder / client" (auto-"Other"). Default if blank: "A small group seeing the deck live, with the presenter narrating."

2. **The takeaway.** In one sentence, what should the audience leave with?
   How to ask: plain text input — content the user owns. Default if blank: ask Claude to derive from the H1 + audience. Do not skip silently — flag with `[derived]`.

3. **Slide outline.** Free list of slide titles in order, or "let Claude propose."
   How to ask: `AskUserQuestion` — header "Slides", options "Let Claude propose 4-7 slides", "I'll list them now" (auto-"Other"). If "I'll list them now" → plain text input follows. Default if blank: "Claude proposes." Do not propose more than 7 slides on the empty-default path — live decks with 8+ lose the audience.

4. **Tone.** Anything specific about voice or register for the slide body?
   How to ask: `AskUserQuestion` — header "Tone", options "Default (handbook titles, energetic body)", "More formal", "More casual" (auto-"Other"). Default if blank: "Handbook tone in TITLES — describe what IS, never sell. Body may run more energetic — slides reward visual punch — but never pitch-y." Title-tone discipline always wins; the story-arc self-review enforces it.

5. **Inclusions / exclusions.** Anything to definitely include or definitely avoid?
   How to ask: `AskUserQuestion` — header "Includes", options "None", "I have specific notes" (auto-"Other"). If "I have specific notes" → plain text input follows. Default if blank: skip — no inclusions, no exclusions.

## Hand-off

After question 5 (or earlier if the user says "go ahead, propose"), do NOT
write HTML. Read `${CLAUDE_SKILL_DIR}/story-arc.md` and follow it end-to-end.
The story-arc gate decides when HTML is allowed. Each arc row corresponds to
one slide; the slide count is the arc row count.

## What this interview must NOT do

- Do not validate answers. Empty answers proceed with the documented defaults.
- Do not loop on a question. One ask, one answer, move on.
- Do not re-ask the document type. SKILL.md handled that.
- Do not paraphrase the question text.
- Do not mention any other doc type elsewhere.
- Do not propose more than 7 slides on the empty-default path.
