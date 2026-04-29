---
name: deshtml
description: Generate a story-first HTML document following the Caseproof Documentation System. Use when the user wants a designed, single-file HTML doc — pitch, handbook, technical brief, presentation, or meeting prep. The skill runs an interview, gates on a story arc, and writes a self-contained HTML to the current directory.
disable-model-invocation: true
allowed-tools: Read Write Bash(ls *) Bash(test *) Bash(open *) Bash(bash *) Bash(date *) Bash(pwd) Bash(mkdir *) Bash(grep *) Bash(command *)
---

# deshtml — flow control

The user invoked `/deshtml`. Their argument string was: `$ARGUMENTS`

Follow these steps in order. Each step that says "Read X.md" is the only place
you should read X. Do not read sub-files speculatively (Pitfall 15). Sub-files
own their content; this file owns flow.

## Step 1 — Detect mode

Inspect the literal `$ARGUMENTS` string (it may be empty, may contain `<no arguments>`,
or may contain the user's text — handle all three).

1. If `$ARGUMENTS` matches the regex `(^|[[:space:]])@\S+` → **source mode** (`@<path>` form).
2. Else if `$ARGUMENTS` (with `@\S+` tokens stripped, with the literal text
   `<no arguments>` stripped, and with surrounding whitespace trimmed) is
   longer than 200 characters → **source mode** (pasted prose).
3. Else → **interview mode**. Continue to Step 2.

In source mode (cases 1 and 2), read `${CLAUDE_SKILL_DIR}/source-mode.md` now and
follow it end-to-end. Return here only after source-mode.md hands back via
story-arc.md approval; proceed to Step 5 (skip Step 2, Step 3, Step 4).

Never silently fall back from source mode to interview mode (SKILL-03).

## Step 2 — Ask the document type

This is the first interactive question (SKILL-04). Ask exactly:

> What kind of document? Pick one: **handbook**, **pitch**, **technical brief**, **presentation**, **meeting prep**.

Wait for the user's answer. Normalize: trim whitespace, lowercase.

- `handbook` → continue to Step 3 (load `interview/handbook.md`).
- `pitch` → continue to Step 3 (load `interview/pitch.md`).
- `technical brief` → continue to Step 3 (load `interview/technical-brief.md`).
- `presentation` → continue to Step 3 (load `interview/presentation.md`).
- `meeting prep` → continue to Step 3 (load `interview/meeting-prep.md`).

- Anything else → ask once more, listing the same five options. If the second
  reply is still not in the list, reply with EXACTLY:
  > That is not one of the five document types. Run `/deshtml` and pick one to continue.

  Then stop.

## Step 3 — Run the interview

Read `${CLAUDE_SKILL_DIR}/interview/${type}.md` now (where `${type}` is the
normalized doc type from Step 2 — `handbook`, `pitch`, `technical-brief`,
`presentation`, or `meeting-prep`; note kebab-case for the two-word types).
Follow it end-to-end. Return here only after the user has answered the
questions (or stopped early per that file's instructions).

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
   directory (`<type>` is the kebab-case doc type from Step 2 — `handbook`,
   `pitch`, `technical-brief`, `presentation`, `meeting-prep`). Run `pwd`.
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

Example output: `Format: handbook` or `Format: overview` or `Format: presentation`.

Then continue to Step 6.

## Step 6 — Render the HTML

Read these five files in parallel:

- `${CLAUDE_SKILL_DIR}/design/formats/${format}.html` (skeleton — `${format}` was set in Step 5b: `handbook`, `overview`, or `presentation`)
- `${CLAUDE_SKILL_DIR}/design/palette.css` (CSS variables, `:root`)
- `${CLAUDE_SKILL_DIR}/design/typography.css` (Inter @import, scale)
- `${CLAUDE_SKILL_DIR}/design/components.css` (component CSS — sidebar, hero, all 16 component families)
- `${CLAUDE_SKILL_DIR}/design/components.html` (markup allowlist)

Then assemble the output:

1. Replace the `<link rel="stylesheet" href="../palette.css">` and
   `<link rel="stylesheet" href="../typography.css">` lines in the skeleton's
   `<head>` with a single `<style>` block containing, IN THIS ORDER:
   a) The verbatim contents of `palette.css`.
   b) A blank line.
   c) The verbatim contents of `typography.css`.
   d) A blank line.
   e) The verbatim contents of `components.css`.

   Keep the skeleton's existing inline `<style>` block(s) (layout rules; for
   presentation, also the slide-deck type scale) as additional `<style>` block(s) right after — do not merge them with the inlined CSS.

2. Fill each slot comment in the body with content matching the approved arc:
   - `<!-- DOC TITLE -->` — the H1 text.
   - `<!-- LOGO SLOT -->` and `<!-- NAV ITEMS SLOT -->` — sidebar nav matching the arc's beats. Use the `.sb-*` markup pattern from the references.
   - `<!-- STICKY BAR SLOT -->` — optional; can be empty.
   - `<!-- HERO H1 SLOT -->`, `<!-- HERO SUBTITLE SLOT -->`, `<!-- HERO STATS SLOT -->` — H1, `.s-lead` subtitle, optional `.stats`.
   - `<!-- SECTION 1 EYEBROW/H2/BODY -->` (one per arc row) — eyebrow, h2, body built ONLY from classes in `components.html`.
   - `<!-- FLOATING PILL SLOT -->` — optional bottom-right nav pill.

   When `${format}` is `presentation`, the skeleton has slide-specific slots instead of section slots:
   - `<!-- SLIDE NAV ITEMS SLOT -->` — one `<a class="nav-a" href="#slide-N"><span class="nav-n">N</span></a>` per slide. Active state is set by the navigation script — do not hardcode `class="nav-a active"`.
   - `<!-- SLIDE 1 H1 SLOT -->` (one per arc row) — the slide's H1.
   - `<!-- SLIDE 1 BODY SLOT -->` (one per arc row) — body content from the components.html allowlist.
   - Replace the `BYLINE_LITERAL` token (in the first inline `<style>` block, inside `.slide::before`) with a short byline shown at the top-left of every slide. Default: the document title (the H1). If the user identified a presenter (e.g., "this is for X to present"), use `PRESENTER  ·  TITLE` separated by a wide bullet (` · ` with one space on each side, doubled for visual breathing). Keep it on one line.
   - Presentation is the only format where the audit allows JS. The skeleton ships one official navigation script at the bottom of `<body>` (keyboard navigation, click-anywhere-to-advance, active nav highlight, side-arrow show/hide at boundaries). Leave the script verbatim — do not modify, remove, or duplicate it. Inline event handlers (`onclick=`, `onload=`, etc.) remain banned in every format including presentation.

3. Use only classes from the design system (`design/components.html`,
   `design/components.css`, `design/typography.css`,
   `design/formats/*.html`). The audit in Step 7 harvests its allowlist
   from those four sources via the wildcard glob (D3-18); failing here
   means a guaranteed retry.

4. Verify before writing: zero `<link rel="stylesheet"` attributes, zero
   `on*=` event handlers, zero `javascript:` URLs. For `${format}` ≠ `presentation`,
   also zero `<script>` tags. For `${format}` == `presentation`, the output
   contains exactly ONE `<script>` block (the verbatim skeleton script) — leave
   it in place; the audit allows scripts only in presentation outputs.

5. Write the assembled HTML to the absolute path computed in Step 5 using
   the Write tool.

## Step 7 — Audit

Run the audit script via Bash:

```bash
bash "${CLAUDE_SKILL_DIR}/audit/run.sh" "<absolute-path-from-step-5>"
```

Capture exit code and stderr.

- Exit 0 → continue to Step 8.
- Non-zero → read the violations on stderr, regenerate the HTML addressing
  each violation, write again, re-run the audit. **Maximum 2 retry rounds.**
  If round 3 still fails: keep the file, surface the verbatim violation list
  to the user, then continue to Step 8 anyway. The file is never silently
  delivered with violations — failure is loud.

## Step 8 — Open and print path

1. Run `open "<absolute-path>"` via Bash. If `open` exits non-zero, ignore the
   error and continue — the path-print line is the fallback.
2. Print the absolute path on its own line. No prefix, no emoji, no banner,
   no "✓ Generated", no next-steps suggestion. The path is the LAST output.

Example final output (the `-<type>` suffix varies per Step 5):

```
/Users/santiago/Desktop/2026-04-27-deshtml-handbook.html
```

Stop. Your work is done.

## Constraints this file enforces

- This file is ≤200 lines (D2-01) and contains flow control only — no rubric content (Pitfall 14).
- Sub-files are read on demand at the step that needs them (Pitfall 15).
- Mode detection at turn 1 — never silently falls back (SKILL-03).
- The arc gate is mechanical (story-arc.md whitelist) — no fuzzy approval.
- The output is always self-contained — three CSS files inlined, zero external assets.
- The audit is the moat — failure is loud, not silent.
