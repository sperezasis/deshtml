# Story arc — table, self-review, and approval gate

SKILL.md reads this file when the interview is complete. Follow it end-to-end.
Return to SKILL.md only after the user has approved the arc. The approval gate
is mechanical (exact-match against the whitelist below); do NOT infer intent.

## Step A — Build the arc

Render a markdown table with EXACTLY these column headers, in this order:

```
| # | Beat | Section | One sentence | Reader feels |
|---|------|---------|--------------|--------------|
```

Rules:
- 5-7 rows for a handbook (matches the Handbook 960px sidebar's section grid).
- `#` is the row number (1, 2, 3, …).
- `Beat` is the narrative role (Hook / Stakes / Setup / Mechanism / Detail / Action / etc.).
- `Section` is the section title that will appear as `<h2>` in the rendered HTML.
- `One sentence` is exactly that — ONE sentence describing what the section delivers.
- `Reader feels` is one to three words about the reader's emotional state at the end of that section.
- No extra columns. No renamed columns. No merged cells.

## Step B — Render the flowing paragraph (ARC-02)

Immediately under the table, render this heading and the joined paragraph.
Tell the user this in one line above the heading: "The paragraph below is your
arc as a single read. If it reads choppy, the arc needs work."

```
## Read the One Sentence column top-to-bottom

<Row 1's One sentence>. <Row 2's One sentence>. … <Row N's One sentence>.
```

Join the `One sentence` cells in row order, with single spaces between sentences,
preserving each sentence's terminal punctuation. This paragraph is the
narrative-gap diagnostic — if it does not read as a coherent story, the arc
is wrong.

## Step C — Self-review (ARC-03)

BEFORE displaying the table to the user, run these three checks privately on
every row. Display the result as a status line under each row in the table.
Use the format:

`   ✓ tone, ✓ chain, ✓ named.`

or for failures:

`   ✗ tone — title "<BAD>" rewritten to "<GOOD>" to match handbook tone.`
`   ✓ chain, ✓ named.`

Failures auto-fix in place — replace the title in the table — but ALWAYS show
the BAD original alongside the GOOD replacement so the user can see what
changed (Pitfall 18 mitigation).

### Check (a) — Handbook tone (describe what IS, don't sell)

Mechanical pre-check first. Flag any title or subtitle containing one of these
pitch-vocabulary words:

    easily, seamlessly, powerful, revolutionary, game-changing, in seconds,
    everything you need, out of the box, effortlessly, breakthrough,
    next-generation, cutting-edge

LLM judgment second. For titles that pass the regex, ask yourself: is this
title describing what IS, or selling a benefit? Use the BAD→GOOD pairs below
as the few-shot.

### Check (b) — Causality chain (each section follows from the previous)

For every adjacent pair (N, N+1), verify section N's `One sentence` sets up
section N+1's. If you could swap N+1 with N+2 without breaking the read, the
chain is broken — flag.

### Check (c) — Name the thing (concrete noun in every title)

Mechanical pre-check: flag titles whose only nouns are abstract:
`shape`, `approach`, `way`, `kind`, `idea`, `thing`, `concept`, `aspect`, `notion`.

LLM judgment second: for titles that pass the regex, ask: what concrete noun
does this title name? If the answer is "the topic of the doc" rather than
a specific section subject, flag.

### The handbook-tone rubric (BAD → GOOD pairs, verbatim from ~/CLAUDE.md)

These five pairs are the calibration set. Compare every flagged title or
subtitle against the pattern of these pairs, not against memorized rules.

| Bad | Good | Why |
|-----|------|-----|
| Read any issue in 3 seconds. | Every issue follows one format. | Bad sells speed (pitch). Good describes the system (handbook). |
| Everything arrives automatically. | One board, built for your team. | Bad is a vague benefit. Good names the thing. |
| Projects have shape. | Every project has a structure. | Bad uses an abstract noun. Good is a structural fact. |
| How teams stay connected. | Cross-team work follows one path. | Bad describes a process. Good states the rule. |
| (subtitle) "And automations that sync them." | (subtitle) "Code repos hold code. Team repos are where your team lives." | Bad subtitle introduces a new concept. Good subtitle unpacks the title's two-types-of-repos claim. |

## Step D — Display and ask for approval

Show the user, in this order:
1. A one-line preface: "Here is the arc. Reply `approve` to generate the HTML, or describe what to change."
2. The arc table with status lines under each row.
3. The "## Read the One Sentence column top-to-bottom" heading and flowing paragraph.
4. A blank line.
5. The same preface again, last: "Reply `approve` or describe what to change."

Then stop. Wait for the user's reply.

## Step E — Approval whitelist (ARC-04)

Normalize the user's reply: trim whitespace, lowercase. Then exact-match
against this whitelist:

- approve
- approved
- looks good
- lgtm
- ship it
- go
- proceed
- aprobado
- dale

Match → return to SKILL.md (proceed to Step 5 — render the HTML).
No-match → revision loop (Step F).

**Do not fuzzy-match. Do not infer intent. Do not interpret enthusiasm.
The mechanical gate IS the moat.** Anything that is not on the whitelist
is treated as a revision request, even if the user wrote "yeah great
let's do it!!!" — interpret that as a revision message, regenerate the
arc, and re-ask.

## Step F — Revision loop (ARC-05)

The user's non-approval reply IS the revision instruction. Take it as
feedback, regenerate the arc table + flowing paragraph + self-review,
and re-display per Step D. Re-ask for approval.

No iteration cap. The loop runs until the user types one of the
whitelist phrases or kills the conversation. SKILL.md does NOT proceed
to Step 5 (render) until approval lands.

## What this file must NOT do

- Must not be inlined into SKILL.md (Pitfall 14 — single source of truth).
- Must not duplicate the approval whitelist anywhere else (Pitfall 14).
- Must not loosen the exact-match gate to fuzzy or semantic match (Pitfall 10).
- Must not skip the self-review when the arc looks "obviously fine."
- Must not auto-fix without showing the BAD→GOOD diff in the status line (Pitfall 18).
