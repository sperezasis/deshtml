---
name: deshtml
description: Generate a story-first HTML document following the Caseproof Documentation System. Use when the user wants a designed, single-file HTML doc — pitch, handbook, technical brief, presentation, or meeting prep. The skill runs an interview, gates on a story arc, and writes a self-contained HTML to the current directory.
disable-model-invocation: true
allowed-tools: Read Write AskUserQuestion Bash(ls *) Bash(test *) Bash(open *) Bash(bash *) Bash(date *) Bash(pwd) Bash(mkdir *) Bash(grep *) Bash(command *) Bash(node *)
---

# deshtml — flow control

The user invoked `/deshtml`. Their argument string was: `$ARGUMENTS`

Follow these steps in order. Each step that says "Read X.md" is the only place
you should read X. Do not read sub-files speculatively (Pitfall 15). Sub-files
own their content; this file owns flow.

## Step 0 — Update notice

Run via Bash:

```bash
node "${CLAUDE_SKILL_DIR}/check-update.js"
```

If it prints a line, surface that line VERBATIM to the user as the first line
of your response. If it prints nothing, proceed silently. Either way, continue
to Step 1. Do not block on this — failures are silent.

## Step 1 — Detect mode

Inspect the literal `$ARGUMENTS` string (it may be empty, may contain `<no arguments>`,
or may contain the user's text — handle all three).

1. If `$ARGUMENTS` matches the regex `(^|[[:space:]])@\S+` → **source mode** (`@<path>` form).
2. Else if `$ARGUMENTS` (with `@\S+` tokens stripped, with the literal text
   `<no arguments>` stripped, and with surrounding whitespace trimmed) is
   longer than 200 characters → **source mode** (pasted prose).
3. Else → continue to Step 1.5 (context detection).

In source mode (cases 1 and 2), read `${CLAUDE_SKILL_DIR}/source-mode.md` now and
follow it end-to-end. Return here only after source-mode.md hands back via
story-arc.md approval; proceed to Step 5 (skip Step 1.5, Step 2, Step 3, Step 4).

Never silently fall back from source mode to interview mode (SKILL-03).

## Step 1.5 — Detect context mode

Look at the prior conversation (the messages exchanged before `/deshtml` was
invoked). Decide: is there enough discussion of the document being created
that Claude can DRAFT the interview answers from context, instead of asking
from scratch?

Concrete signals (any 2 = context mode):
- The user named a document type ("a presentation for X", "a handbook on Y").
- The user described the audience, the content, or the desired structure.
- The user provided a source document (link, paste, mentioned file) earlier.
- The user discussed tone, length, or a specific framing.
- The conversation has substantive subject-matter content the doc would draw on.

Decision:
- 2+ signals present → **context mode**. Read `${CLAUDE_SKILL_DIR}/context-mode.md`
  now and follow it end-to-end. It owns the draft + confirm flow. Return here
  only after context-mode.md hands off via story-arc.md approval; proceed to
  Step 5 (skip Step 2, Step 3, Step 4).
- Fewer than 2 signals → **interview mode**. Continue to Step 2.

Never silently fall back from context mode to interview mode without telling
the user. If context mode triggers and the draft is too thin, context-mode.md
will surface that explicitly and route to Step 2.

## Step 2 — Ask the document type

Use `AskUserQuestion` with `header: "Doc type"`, `question: "What kind of document?"`, `multiSelect: false`, and these four options (the 5th — "meeting prep" — is reachable via the auto-provided "Other" option):

1. "Handbook" — Reference doc; describes how something works.
2. "Pitch" — Persuasive doc; problem → solution → ask.
3. "Presentation" — Live deck, full-viewport slides.
4. "Technical brief" — Decision write-up for engineers.

Map the answer to interview file: handbook→`interview/handbook.md`, pitch→`interview/pitch.md`, presentation→`interview/presentation.md`, technical brief→`interview/technical-brief.md`, "Other" matching `/^meeting[- ]?prep$/i` → `interview/meeting-prep.md`. Any other "Other" text → re-ask once. Second invalid → reply EXACTLY `That is not one of the five document types. Run /deshtml and pick one to continue.` and stop.

## Step 3 — Run the interview

Read `${CLAUDE_SKILL_DIR}/interview/${type}.md` now (where `${type}` is the
kebab-case doc type — `handbook`, `pitch`, `technical-brief`, `presentation`,
or `meeting-prep`). Follow it end-to-end. Each interview file uses
`AskUserQuestion` for closed-shape questions (with sensible default options)
and falls back to plain text for open content (audience prose, takeaways,
free-form material). Return here only after all questions are answered.

Do NOT read `story-arc.md` yet (Pitfall 15).

## Step 4 — Build the story arc

Read `${CLAUDE_SKILL_DIR}/story-arc.md` now. Follow it end-to-end. The user
must approve the arc before this step completes. Return here only after
approval is matched against the whitelist.

Do NOT read `design/*` files yet.

## Step 5 — Compute the filename and check for collisions

1. Get today's date in local time: run `date +%Y-%m-%d` via Bash.
2. Slug = first 4-5 words of the H1 from the approved arc, kebab-cased,
   ASCII only. Lowercase, replace spaces with `-`, strip non-`[a-z0-9-]`,
   no trailing `-`, truncate at the 4th-5th word.
3. Tentative filename: `<date>-<slug>-<type>.html` in the current working
   directory (`<type>` is the kebab-case doc type — `handbook`, `pitch`,
   `technical-brief`, `presentation`, `meeting-prep`). Run `pwd`.
4. Collision check via `test -f`. Append `-2`, `-3`, … keeping `-<type>`:

   ```bash
   target="<date>-<slug>-<type>.html"
   suffix=2
   while test -f "$target"; do
     target="<date>-<slug>-<type>-${suffix}.html"
     suffix=$((suffix + 1))
   done
   ```

   Use the final `$target` for Step 6. Compute its absolute path: `${PWD}/${target}`.

## Step 5b — Select format

Determine which format skeleton Step 6 will use. The decision is mechanical:

1. If the document type from Step 2 == `presentation` → format = `presentation`.
2. Else if the approved arc has 4 or more rows → format = `handbook`.
3. Else → format = `overview`.

Print exactly one line to the user (no other prose, no decoration):

> Format: <format>

Then continue to Step 6.

## Step 6 — Render the HTML

Read these five files in parallel:

- `${CLAUDE_SKILL_DIR}/design/formats/${format}.html` (skeleton)
- `${CLAUDE_SKILL_DIR}/design/palette.css`
- `${CLAUDE_SKILL_DIR}/design/typography.css`
- `${CLAUDE_SKILL_DIR}/design/components.css`
- `${CLAUDE_SKILL_DIR}/design/components.html` (markup allowlist)

Then assemble the output:

1. Replace the `<link rel="stylesheet" href="../palette.css">` and
   `<link rel="stylesheet" href="../typography.css">` lines in the skeleton's
   `<head>` with a single `<style>` block containing, IN THIS ORDER:
   palette.css, blank line, typography.css, blank line, components.css.
   Keep the skeleton's existing inline `<style>` block(s) as additional
   `<style>` block(s) right after — do not merge them with the inlined CSS.

2. Fill each slot comment in the body with content from the approved arc.
   For handbook/overview: section eyebrows, h2s, bodies built only from
   classes in `components.html`.

   When `${format}` is `presentation`, the skeleton has slide-specific slots:
   - `<!-- SLIDE NAV ITEMS SLOT -->` — one `<a class="nav-a" href="#slide-N"><span class="nav-n">N</span></a>` per slide. Active state is set by the navigation script — do not hardcode `class="nav-a active"`.
   - `<!-- SLIDE 1 H1 SLOT -->` (one per arc row) — the slide's H1.
   - `<!-- SLIDE 1 BODY SLOT -->` (one per arc row) — body content from the components.html allowlist.
   - Replace the `BYLINE_LITERAL` token (in the first inline `<style>` block, inside `.slide::before`) with a short byline shown at the top-left of every slide. Default: the document title (the H1). If the user identified a presenter, use `PRESENTER  ·  TITLE` separated by a wide bullet (` · ` with one space on each side, doubled for visual breathing).
   - Presentation is the only format where the audit allows JS. The skeleton ships one official navigation script at the bottom of `<body>`. Leave the script verbatim — do not modify, remove, or duplicate it.

3. Use only classes from the design system. The audit harvests its allowlist
   from `components.html`, `components.css`, `typography.css`, and every
   format skeleton in `design/formats/*.html`.

4. Verify before writing: zero `<link rel="stylesheet"` attributes, zero
   `on*=` event handlers, zero `javascript:` URLs. For `${format}` ≠ `presentation`,
   also zero `<script>` tags. For `${format}` == `presentation`, the output
   contains exactly ONE `<script>` block (the verbatim skeleton script).

5. Write the assembled HTML to the absolute path computed in Step 5.

## Step 7 — Audit

Run the audit script via Bash:

```bash
bash "${CLAUDE_SKILL_DIR}/audit/run.sh" "<absolute-path-from-step-5>"
```

- Exit 0 → continue to Step 8.
- Non-zero → read violations on stderr, regenerate addressing each, write,
  re-run. **Maximum 2 retry rounds.** Round 3 still failing: keep the file,
  surface the verbatim violation list, then continue to Step 8 anyway.

## Step 8 — Open and print path

Run `open "<absolute-path>"` (ignore non-zero exit). Then print the absolute path on its own line — no prefix, no emoji, no banner. The path is the LAST output. Stop.

## Constraints this file enforces

- ≤200 lines, flow control only. Sub-files read on demand.
- Mode detection at turn 1 (source / context / interview) — never silently falls back.
- The arc gate is mechanical (story-arc.md whitelist) — no fuzzy approval.
- Output is self-contained (CSS inlined, no external assets). The audit is the moat — failure is loud.
