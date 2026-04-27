# Fixture: deshtml-about-itself handbook — expected arc shape

Reference for the human verifier in plan 02-04. The arc the skill proposes
after the interview should resemble this in shape — section count, narrative
thread, terminal punctuation. Exact wording will vary; that's fine. What
matters is the flowing-paragraph diagnostic reads as one coherent story.

## Expected number of rows

6-8 rows. Anything outside that range deserves scrutiny — too few means
sections will run too long for the 960px Handbook layout; too many means
sections are over-fragmented and the causality chain weakens.

## Expected flowing paragraph

Reading the `One sentence` column top-to-bottom, the paragraph should read
something like:

> deshtml is a Claude Code skill that generates story-first HTML documents.
> You install it with one curl-pipe-bash line.
> A run starts with a five-question handbook interview.
> The skill proposes a story arc and gates on your approval.
> Once approved, it generates a single self-contained HTML using the Caseproof Documentation System.
> A post-generation audit rejects design-system drift mechanically.
> Iteration after generation happens via normal Claude conversation.

Acceptable variations: different verbs, different connectives, different
sentence boundaries. NOT acceptable: a paragraph that reads as bullet-points
glued together (causality chain broken), or that introduces a concept not
set up by an earlier sentence.

## Expected section titles (handbook tone)

Should pass the three self-review checks:
- **Tone:** every title describes what IS, not what is great. No "easily,"
  "powerful," "everything you need."
- **Causality chain:** each title follows from the previous. "What it is"
  → "How you install" → "How a run starts" → "The arc gate" → "Render
  and audit" → "Iteration."
- **Name the thing:** every title contains a concrete noun (`skill`, `run`,
  `arc`, `audit`, `iteration`) — not abstract nouns (`shape`, `way`, `idea`).

## What the human verifier looks for

Before typing `approve`:
1. Five columns, in the canonical order — no extra columns.
2. Status lines under each row showing tone/chain/named — at most one
   auto-fix; if more, the interview answers may have leaked pitch tone.
3. The flowing paragraph reads as one story, not seven disconnected sentences.

Before opening the generated HTML:
1. Filename matches `YYYY-MM-DD-<slug>-handbook.html`.
2. `open` succeeded; default browser tab is now showing the file.
3. Absolute path printed on its own line as the LAST output (no banner,
   no celebration emoji, no next-steps suggestion).

In the browser:
1. Side-by-side with `~/work/caseproof/gh-pm/pm/pm-framework/diagrams/pm-system.html`:
   same palette (whites, grays, blue accent), same Inter font, same sidebar
   (220px black), same hero scale (56px h1 / 800 weight / -2.5px letter-spacing),
   same section spacing (70px top, 30px bottom).
2. Components used in the body (cards, compare boxes, highlights, flow
   blocks, etc.) match those in `pm-system.html`.
3. iOS Safari with system dark mode forced ON: file stays light.
