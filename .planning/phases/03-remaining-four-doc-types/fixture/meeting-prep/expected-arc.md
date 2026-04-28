# Fixture: meeting-prep — expected arc shape

## Expected number of rows

3 rows: context → demo flow → anticipated questions. <3 means a beat is
missing; >3 means the briefing is too long for a 30-min walkthrough.

## Expected format auto-selection (D3-01)

Step 5b should print exactly one line:

> Format: overview

Because: type=meeting-prep is NOT presentation; arc has <4 rows → overview.

## Expected flowing paragraph

> deshtml is a Claude Code skill that turns ideas into designed HTML
> documents. We install it on Delfi's machine, run /deshtml on a topic
> she picks, walk through the arc gate together, and open the generated
> HTML side-by-side with a Caseproof reference. Anticipated questions
> include "can I skip the arc step" (no — that's the moat) and "what
> happens if the audit fails" (we show that live).

Acceptable variations: any phrasing that lands the context-flow-questions
structure. NOT acceptable: meeting-prep that reads as a marketing pitch
(verbatim CLAUDE.md tone — Pattern 8 meeting-prep row).

## Expected section titles (verbatim CLAUDE.md handbook tone)

Same calibration as tech-brief: handbook in TITLES and BODY. Briefings
deliver facts; selling is wrong here. Self-review surfaces ≥0 fixes; >1
suggests pitch tone leaked into the answers.

Concrete-noun audit: every title names a thing (`context`, `walk-through`,
`questions`).

## Visual diff target (Overview format)

Side-by-side with `~/work/caseproof/gh-pm/pm/bnp/.planning/figma/bnp-overview.html`:
same palette, same Inter font, same hero scale (1440px linear, no sidebar),
same section spacing (80px / 120px container).

Sequential-read note (D3-22): pitch.html and meeting-prep.html BOTH render as
Overview. The verifier reads them in sequence — they should NOT feel
interchangeable. The questions surface different material:
- Pitch: ask + problem + solution.
- Meeting prep: meeting purpose + talking points + open questions/risks.

If the two reads feel the same, the interview-questions are too similar
(Pitfall 19) — fix by tightening the question wording, not by changing
the visual gate.

iOS Safari forced-dark-mode: stays light.

## What the verifier looks for

Before `approve`:
1. Five columns.
2. EXACTLY 3 rows.
3. `Format: overview`.
4. Status lines all green (any auto-fix suggests the meeting-prep tone
   slipped — re-ask).
5. Flowing paragraph reads as a briefing, not a sales pitch.

Before opening:
1. Filename matches `YYYY-MM-DD-<slug>-meeting-prep.html`.
2. NO sidebar (Overview).
3. Compare to bnp-overview.html: visual layers match.

Sequential-read check (after all four fixtures generated):
1. Open pitch.html, technical-brief.html, presentation.html, meeting-prep.html
   side-by-side.
2. Read top-to-bottom. Each should be distinguishable by H1, by section
   structure, by content density, by tone.
3. If any two feel like the same document with different filenames →
   Pitfall 19 surfaced; fix the interview-questions in plan 03-02 and
   re-run that fixture only.
