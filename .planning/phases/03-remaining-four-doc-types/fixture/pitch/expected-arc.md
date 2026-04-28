# Fixture: pitch — expected arc shape

Reference for the human verifier in plan 03-04 Task 2. The arc the skill
proposes after the pitch interview should resemble this in shape.

## Expected number of rows

3 rows. Pitch is problem → solution → ask. <3 means a beat is missing;
>3 deserves scrutiny — pitch length is what makes pitch (not handbook).

## Expected format auto-selection (D3-01)

Step 5b should print exactly one line:

> Format: overview

Because: type=pitch is NOT presentation; arc has <4 rows → falls through
to overview. If verifier sees `Format: handbook`, the arc has too many
rows (likely the interview answers leaked extra material — re-ask the
user to trim, or accept the auto-selection and edit the arc to land
overview).

## Expected flowing paragraph

Reading the `One sentence` column top-to-bottom should read something like:

> Designed docs are how my team's work gets noticed; we don't have time
> to design every doc. deshtml is a Claude Code skill that produces
> designed HTML from a 5-question interview. We pilot deshtml on our team
> for one quarter, or fund building it in our stack.

Acceptable variations: any phrasing that lands the three-beat narrative.
NOT acceptable: a paragraph that reads as bullet points (causality chain
broken).

## Expected section titles (handbook tone in TITLES; pitch tone OK in body)

Should pass the three self-review checks (story-arc.md):
- **Tone:** every TITLE describes what IS, never sells. No "10x", "revolutionary",
  "game-changing." (Pitch's BODY may read more direct/confident — that's the
  Pattern 8 divergence — but TITLES still inherit handbook tone.)
- **Causality chain:** problem → solution → ask. Each follows from the previous.
- **Name the thing:** every title contains a concrete noun (`docs`, `skill`, `pilot`).

## Visual diff target (Overview format)

Side-by-side with `~/work/caseproof/gh-pm/pm/bnp/.planning/figma/bnp-overview.html`:
same palette, same Inter font, same hero scale (1440px linear, no sidebar),
same section spacing (80px / 120px container per overview.html). Components
used in body should match those in `bnp-overview.html` (cards, hero, dividers).

iOS Safari forced-dark-mode test: stays light (DESIGN-07 carry-over).

## What the verifier looks for

Before typing `approve`:
1. Five columns (canonical order from story-arc.md).
2. EXACTLY 3 rows.
3. `Format: overview` printed below the arc table BEFORE rendering.
4. Status lines under each row showing tone/chain/named (auto-fix surfaces if needed).
5. Flowing paragraph reads as a coherent ask, not a bullet list.

Before opening the generated HTML:
1. Filename matches `YYYY-MM-DD-<slug>-pitch.html`.
2. `open` succeeded.
3. Absolute path printed on its own line LAST (no banner, no emoji).

In the browser:
1. NO sidebar (Overview = no `<aside class="sidebar">`).
2. Same palette as bnp-overview.html.
3. Body tone may run direct/confident (pitch divergence) — section TITLES
   still describe what IS.
