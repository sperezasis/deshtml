# Presentation interview

SKILL.md reads this file when the user picks `presentation` as the document type.
Ask the questions one at a time, in order. Wait for each answer before asking
the next. Empty answers are accepted — proceed with sensible defaults. Do
not enforce length, do not retry, do not validate. The arc-gate is where
quality is enforced, not the interview.

The schema follows DOC-06's mandate (audience → material → section conventions
→ tone notes → handoff to story-arc) — same shape as `interview/handbook.md`.
Presentations always render in the Presentation format (full-viewport slides,
scroll-snap, anchor nav) regardless of section count — SKILL.md Step 5b
short-circuits to format=presentation when type=presentation (D3-01).

## The 5 questions

1. **Audience.** Who is watching this deck? One line.
   (Default if blank: "A small group seeing the deck live, with the presenter narrating.")

2. **The takeaway.** In one sentence, what should the audience leave with?
   (Default if blank: ask Claude to derive from the H1 + audience. The takeaway is the takeaway slide; do not skip it silently — flag with `[derived]`.)

3. **Slide outline.** Free list of slide titles in order, or "let Claude propose."
   (Default if blank: "Claude proposes." Claude proposes 4-7 slides sized for live presentation — opening, context, mechanism, evidence, takeaway. Each slide is one beat.)

4. **Tone.** Anything specific about voice or register for the slide body?
   (Default if blank: "Handbook tone in TITLES — describe what IS, never sell. Body may run more energetic — slides reward visual punch — but never pitch-y. Direct nouns, short clauses." Title-tone discipline always wins; the story-arc self-review pass enforces this on every section title regardless of doc type.)

5. **Inclusions / exclusions.** Anything to definitely include or definitely avoid?
   (Default if blank: skip — no inclusions, no exclusions.)

## Hand-off

After question 5 (or earlier if the user says "go ahead, propose"), do NOT
write HTML. Read `${CLAUDE_SKILL_DIR}/story-arc.md` and follow it end-to-end.
The story-arc gate decides when HTML is allowed. Each arc row corresponds to
one slide; the slide count is the arc row count. The slide counter is wired
automatically by the format skeleton (CSS `counter-increment`).

## What this interview must NOT do

- Do not validate answers ("that's too short", "please clarify"). Empty
  answers proceed with the documented defaults.
- Do not loop on a question. One ask, one answer, move on.
- Do not re-ask the document type. SKILL.md handled that — by the time
  Claude is reading this file, presentation is already locked.
- Do not paraphrase the questions. The wording is the contract.
- Do not mention any other doc type elsewhere. Those are stubbed in SKILL.md.
- Do not propose more than 7 slides on the empty-default path. Live decks
  with 8+ slides typically lose the audience; 4-7 is the operating range.
