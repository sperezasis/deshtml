# Phase 3: Remaining Four Doc Types — Research

**Researched:** 2026-04-27
**Domain:** CSS scroll-snap presentation format, type-tailored interview design, format auto-selection in SKILL.md, audit harvester extension across multiple format skeletons.
**Confidence:** HIGH (scroll-snap browser support verified against caniuse + MDN current docs; schema-drift heuristics derived from the working `interview/handbook.md` and audit harvester semantics; slot vocabulary verified by reading `formats/handbook.html` + `formats/overview.html` directly) / MEDIUM (Presentation visual rubric — no Caseproof reference exists, recommendation is a derived pattern from public CSS-Tricks/CodePen examples).

---

## Summary

Phase 3 fans out from Phase 2's proven flow. The skill payload, the arc gate, the audit, and the design system are all locked. What's new: four interview files, one Presentation format skeleton, format auto-selection in SKILL.md, and a one-line widening of the audit harvester. The high-stakes piece is **Presentation** — every other change is mechanical and inherits Phase 2's tooling unchanged.

The most consequential research findings, with action items for the planner:

1. **Scroll-snap is broadly safe in 2026 — but the snap container belongs on `<body>`, not `<html>`, for Safari.** caniuse reports 96.23% global support for CSS Scroll Snap; `scroll-snap-stop` reached Baseline Widely Available in July 2022. The single most-cited Safari quirk is that `html { scroll-snap-type: y mandatory; }` does not work reliably on Safari — applying snap to a child container (the existing CSS-Tricks recipe is `body` or a dedicated `<main>`) is the safe pattern. `[CITED: caniuse.com/css-snappoints]` `[CITED: css-tricks.com/practical-css-scroll-snapping/ — "html doesn't work in Safari and body does"]` `[CITED: developer.mozilla.org/en-US/docs/Web/CSS/scroll-snap-stop — Baseline Widely available since July 2022]`

2. **The 30-min spike (D3-03) is the single risk gate.** With the snap container scoped to a child element (per finding 1) and `scroll-snap-stop: always` honored on every modern engine, the spike is most likely to **pass** rather than expose Safari fragility. The fallback design (D3-03's `:target`-only mode) is a pure CSS shrink — drop the snap rules, keep the anchor IDs and the floating nav. Documented fail criteria below.

3. **CSS-only slide counter requires a hard-coded total.** `counter-reset` + `counter-increment` produces "current N" trivially; producing "current / total" without JS requires the generator (Claude) to inject the total as a literal at render time — there is no pure-CSS "count my children" primitive. The pattern: render `--total: 5;` as a custom property on the snap container and read it via `content: counter(slide-num) " / " var(--total);` — but `var()` inside `content` is broadly supported, so the simpler form `content: counter(slide-num) " / 5";` (numeric literal substituted at generation time) is fine. `[CITED: developer.mozilla.org/en-US/docs/Web/CSS/counter-increment]`

4. **`formats/handbook.html` and `formats/overview.html` already share their slot vocabulary verbatim.** Both use the same comment names: `<!-- DOC TITLE -->`, `<!-- HERO H1 SLOT -->`, `<!-- HERO SUBTITLE SLOT (.s-lead) -->`, `<!-- SECTION N EYEBROW/H2/BODY SLOT -->`. Overview omits the sidebar slots; that's it. SKILL.md Step 6's slot-fill logic does NOT need format-aware branching for these two — read the variable file, fill whatever slots exist. **`presentation.html` should follow the same vocabulary** plus a small set of slide-specific slots (`<!-- SLIDE N H1 SLOT -->`, `<!-- SLIDE N BODY SLOT -->`, `<!-- SLIDE NAV SLOT -->`). `[VERIFIED: read both files in this session]`

5. **The audit harvester extends in one line.** `audit/run.sh` already loops over a fixed set of design-system files (components.html, components.css, typography.css, formats/handbook.html). Replacing the hard-coded `formats/handbook.html` with a glob over `formats/*.html` is mechanical. macOS bash 3.2 globs without `nullglob`, but the existing `[ ! -f "$f" ] && exit 2` guard handles the no-match case correctly. `[VERIFIED: read audit/run.sh:30-37 in this session]`

6. **Type-labeled clones are the biggest UX risk.** Pitch and meeting-prep both produce 3-section Overviews. If their interview questions and tone-defaults don't produce genuinely different content, the user reads them as the same document with different filenames. Mitigation lives in the interview-question wording (D3-12) and the visual gate (D3-22) — research confirms there is no mechanical check that catches this; the human verifier is the only signal. The Phase 3 planner must size plan 03-04 to read all four fixtures sequentially, not just side-by-side.

**Primary recommendation:** Run the spike (D3-03) **first**, as plan 03-01 Task 1, with concrete pass/fail criteria written down before the browser is opened. Build all four interview files from a single template that lifts handbook.md's structure verbatim and changes only the question wording and tone-defaults. Extend the harvester via the wildcard glob and add a `lint-interviews.sh` schema check (or fold it into `audit/run.sh` as a separate exit code) so schema drift surfaces at CI time, not at fixture time.

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

Verbatim from `03-CONTEXT.md`:

**Type → format mapping (D3-01, D3-02):**
```
if type == "presentation": format = "presentation"
elif arc.section_count >= 4:  format = "handbook"
else:                          format = "overview"
```
SKILL.md Step 5 prints `Format: <handbook|overview|presentation>` to the user before render. Not a question — visibility only. No `--format=` override knob in v1.

**Presentation format (D3-03 through D3-09):**
- D3-03 — 30-min spike before build: minimal HTML + 3 stub slides + `scroll-snap-type: y mandatory`, verify in Chrome + Safari. Plan 03-01 Task 1 owns it. Fallback: `:target`-only navigation if Safari snap broken.
- D3-04 — `<section class="slide" id="slide-N">` at `100vh`, `scroll-snap-align: start`. Parent `<main>` is `scroll-snap-type: y mandatory; overflow-y: scroll; height: 100vh;`.
- D3-05 — CSS-only slide counter via `counter-reset` on `<main>` + `counter-increment` on `.slide`, displayed via `::after { content: counter(slide-num) " / N"; }` on a fixed-position element.
- D3-06 — `id="slide-N"` sequential anchors. Floating nav with `#slide-N` links, same `nav-a` markup as the handbook sidebar.
- D3-07 — No transition animation in v1. Default scroll-snap behavior only.
- D3-08 — Presentation typography scales UP from Handbook: H1 80px, H2 56px, body 22px. Inline as a SECOND `<style>` block in `presentation.html`. Does NOT modify `typography.css`.
- D3-09 — Presentation has NO sidebar. Full-viewport slides. Skeleton omits `<aside>` entirely.

**Interview files (D3-10 through D3-13):**
- D3-10 — Schema identical to `handbook.md`: audience → material → sections → tone → handoff.
- D3-11 — ≤5 questions per file. Some types (pitch) may have 4.
- D3-12 — Type-tailored question order:
  - **Pitch:** audience, the ask, the problem, the solution, include/avoid.
  - **Technical brief:** audience, the decision, alternatives considered, trade-offs, include/avoid.
  - **Presentation:** audience, the takeaway, slide outline, tone, include/avoid.
  - **Meeting prep:** meeting purpose, audience, talking points, open questions/risks, include/avoid.
- D3-13 — Empty-answer behavior identical across all five files: accept, proceed with documented defaults, never validate, never retry.

**SKILL.md updates (D3-14 through D3-17):**
- D3-14 — Step 2's four stubs flip to real routes (load `interview/<type>.md`, then `story-arc.md`, then auto-select format).
- D3-15 — New Step 5b: select format per D3-01 logic, print `Format: ${format}` line.
- D3-16 — Step 6 skeleton routing: `Read ${CLAUDE_SKILL_DIR}/design/formats/${format}.html`. Slot-fill logic unchanged.
- D3-17 — SKILL.md hard cap is 200 lines. If implementation needs more, factor route bodies into `skill/routes/<type>.md` sub-files.

**Audit allowlist extension (D3-18, D3-19):**
- D3-18 — Harvester scans `$skill_dir/design/formats/*.html` automatically. Picks up any future format files.
- D3-19 — Presentation classes (`slide`, `slide-counter`, `slide-num`, `slide-nav`) get harvested automatically. No hand-maintained allowlist additions.

**Visual gate (D3-20 through D3-22):**
- D3-20 — Four canonical fixtures (one per doc type). Pitch + meeting-prep diff against `bnp-overview.html`. Technical brief diffs against `pm-system.html`. Presentation has no Caseproof reference — gate is "looks like a designed slide deck, palette + fonts match, scroll-snap works in Chrome and Safari."
- D3-21 — One human-verify checkpoint at end of plan 03-04. Side-by-side review.
- D3-22 — "None reads like a type-labeled clone" check. Read all four fixtures sequentially.

### Claude's Discretion

- Whether the spike (D3-03) lives in plan 03-01 Task 1 or as a separate Wave-0 plan.
- Exact wording of the four interview files' questions — D3-12 is the floor.
- Whether `presentation.html`'s slide-counter renders top-right, bottom-right, or centered.
- Whether the "Format: ${format}" line includes a `[auto-selected based on N sections]` annotation.
- Whether the four interview files share a header-comment template for schema lineage to `handbook.md` (DOC-06).

### Deferred Ideas (OUT OF SCOPE)

- Per-type audit rules (V2).
- Slide transitions / animations in Presentation (V2).
- Speaker notes for Presentation (V2).
- `/deshtml --format=<x>` override flag (V2).
- PDF export (V2/V3).
- A sixth doc type (locked out of v1 by PROJECT.md).
- Multi-deck Presentation (V2 at earliest).
</user_constraints>

---

## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| DOC-01 | Pitch — problem → solution → ask, Overview format | §"Interview file template" + §"Format auto-selection logic" (lands Overview by section count) |
| DOC-03 | Technical brief — architecture/decision write-up, Handbook format | §"Interview file template" + §"Format auto-selection logic" (lands Handbook by section count) |
| DOC-04 | Presentation — single-page anchor-navigated slides, custom Presentation format (CSS scroll-snap, no JS) | §"Presentation format — scroll-snap pattern" + §"CSS-only slide counter" |
| DOC-05 | Meeting prep — briefing doc, Overview format | §"Interview file template" + §"Format auto-selection logic" |
| DOC-06 | Each doc type has its own interview file following identical schema | §"Interview file template" + §"Schema-drift heuristic" |
| DESIGN-04 | Skill auto-selects format from arc + type | §"Format auto-selection logic" — pure section-count + type-match check |

---

## Project Constraints (from CLAUDE.md)

`/Users/sperezasis/CLAUDE.md` is the methodology source of truth, inherited unchanged from Phase 2. The Phase-3-relevant constraints:

| Directive | Phase 3 Enforcement |
|-----------|---------------------|
| Tone: handbook, not pitch — describe what IS. | Each interview file's tone-defaults reference CLAUDE.md verbatim. **Pitch is the exception** (sales tone is appropriate for a pitch's body) but **section TITLES still follow handbook tone** even in a pitch — every doc type's titles describe what IS. |
| Titles are structural facts or directives. | Self-review check (a) in `story-arc.md` already enforces this — runs unchanged for all five types. |
| Each section answers ONE question. | Inherited from `story-arc.md`. |
| Anyone in the world should understand it. | The interview question wording must be plain — Delfi must understand "the ask" without explanation. |
| RULE #1 — Responses must be short. | The four new interview files are ≤80 lines each (matching `handbook.md`'s 45-line precedent). |
| ALWAYS respond in English. | Interview file prose is in English. Output document language follows source per PROJECT.md. |

---

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Type-branch routing | SKILL.md Step 2 | — | Pure flow control; load `interview/<type>.md` based on type. |
| Type-tailored interview content | `skill/interview/<type>.md` (× 4 new) | — | Lazy-loaded; SKILL.md never inlines. |
| Format auto-selection | SKILL.md Step 5b | — | Mechanical (`if type == "presentation" elif section_count >= 4 else`). No LLM judgment. |
| Format skeleton routing | SKILL.md Step 6 | `skill/design/formats/<format>.html` | Variable-load reads the file matching the chosen format. |
| Slot-fill logic | Claude (LLM, instructed by SKILL.md) | — | Same logic across all three formats since slot vocabularies are unified. |
| Scroll-snap behavior | `formats/presentation.html` (CSS only) | — | Browser scroll engine + CSS scroll-snap; zero JS. |
| Slide counter rendering | `formats/presentation.html` (CSS counters) | Claude (substitutes total at render time) | `counter-increment` is browser-side; the literal total must be injected per-output. |
| Anchor navigation between slides | `formats/presentation.html` (id + href) | — | Standard HTML anchor mechanism. |
| Audit harvester (multi-format) | `skill/audit/run.sh` | — | Wildcard glob over `formats/*.html`. |
| Schema-drift detection | New `lint-interviews.sh` (or `audit/run.sh --interviews` flag) | — | Catches Pitfall 19 at CI time. |

---

## Stack Confirmation

Phase 3 introduces zero new tooling dependencies. Everything Phase 2 established carries forward unchanged:

| Component | Inherited From | Version | Phase 3 Change |
|-----------|---------------|---------|----------------|
| SKILL.md frontmatter (`disable-model-invocation: true`, `allowed-tools: Read Write Bash(...)`) | Phase 2 | — | None |
| Lazy-load discipline (read sub-files on demand at the documented step) | Phase 2 | — | Extends to four new sub-files |
| `command grep` / `command sed` (bypass shell aliases) | Phase 2 | — | None |
| BSD bash 3.2 / BSD grep / BSD sed compatibility | Phase 2 | — | Confirms harvester wildcard works in 3.2 (no `globstar` needed) |
| Three-CSS-file inlining (palette → typography → components) | Phase 2 | — | Order unchanged for all three formats |
| `color-scheme: light` + `<meta name="color-scheme">` | Phase 1 | — | `presentation.html` MUST include both (Pitfall 7) |
| Inter via Google Fonts CDN with system-font fallback stack | Phase 1 | — | Presentation uses larger sizes but same font stack |

`[VERIFIED: read skill/SKILL.md, skill/audit/run.sh, skill/design/formats/handbook.html, skill/design/formats/overview.html in this session]`

---

## Architecture — Where the New Files Fit

```
skill/
├── SKILL.md                          (171 lines → ~190 lines after Phase 3 — modify Steps 2/5/6)
├── story-arc.md                      (Phase 2, NO CHANGE)
├── interview/
│   ├── handbook.md                   (Phase 2, NO CHANGE — schema reference)
│   ├── pitch.md                      (NEW — Phase 3)
│   ├── technical-brief.md            (NEW — Phase 3)
│   ├── presentation.md               (NEW — Phase 3)
│   └── meeting-prep.md               (NEW — Phase 3)
├── audit/
│   ├── run.sh                        (MODIFY — wildcard harvester, D3-18)
│   └── rules.md                      (Phase 2, NO CHANGE — rules unchanged)
└── design/
    ├── palette.css                   (Phase 1+2, NO CHANGE)
    ├── typography.css                (Phase 1+2, NO CHANGE)
    ├── components.css                (Phase 2, NO CHANGE)
    ├── components.html               (Phase 1, NO CHANGE)
    ├── SYSTEM.md                     (Phase 1, NO CHANGE)
    └── formats/
        ├── handbook.html             (Phase 1+2, NO CHANGE)
        ├── overview.html             (Phase 1, NO CHANGE)
        └── presentation.html         (NEW — Phase 3)
```

**Optional new file (planner discretion):**
- `skill/audit/lint-interviews.sh` — schema-drift gate. Alternative: fold into `audit/run.sh` as a `--interviews` mode. See §"Schema-drift heuristic" below.

**Diff summary for Phase 3:** 5 new files, 2 modified files. SKILL.md grows from 171 → ~185 lines (well under 200 cap). No code-review carryover from Phase 2 (per `02-CONTEXT.md` §"Code-review carryover from Phase 2").

---

## Implementation Patterns

### Pattern 1: Format auto-selection logic (D3-01, D3-15)

**What:** Mechanical decision tree run in SKILL.md Step 5b after the arc is approved.

**When to use:** Every Phase 3 invocation, regardless of type.

**Example (insert into SKILL.md as Step 5b):**

```markdown
## Step 5b — Select format

Based on the approved arc and the document type chosen in Step 2:

1. If type == `presentation` → format = `presentation`.
2. Else if the approved arc has 4 or more rows → format = `handbook`.
3. Else → format = `overview`.

Print exactly one line to the user (no other prose):

> Format: <format>

Then continue to Step 6.
```

**Why this design:**
- Predictable. The user can derive the format from the arc without reading SKILL.md.
- Testable. The fixture for each doc type can assert the auto-selected format.
- Reversible. If the user wants a different format, they edit the arc (add/remove sections) and re-approve. No `--format=` flag.

**Source:** D3-01 + D3-15. No external citation needed — pure logic per CONTEXT.md.

---

### Pattern 2: Skeleton routing in SKILL.md Step 6 (D3-16)

**What:** Replace the hard-coded `formats/handbook.html` reference with a variable load.

**When to use:** Whenever Step 6 reads the format skeleton.

**Existing code (skill/SKILL.md:96, Phase 2):**
```markdown
- `${CLAUDE_SKILL_DIR}/design/formats/handbook.html` (skeleton)
```

**Phase 3 replacement:**
```markdown
- `${CLAUDE_SKILL_DIR}/design/formats/${format}.html` (skeleton — `${format}` was set in Step 5b)
```

**Slot-fill logic stays the same.** Both `handbook.html` and `overview.html` use the same slot-comment vocabulary. `presentation.html` introduces additional slide-specific slots — the planner adds them to the generation instructions in Step 6, but the **fill mechanism is unchanged** (find slot comment → replace with content).

`[VERIFIED: read skill/design/formats/handbook.html and overview.html in this session — they share `<!-- DOC TITLE -->`, `<!-- HERO H1 SLOT -->`, `<!-- HERO SUBTITLE SLOT (.s-lead) -->`, `<!-- SECTION N EYEBROW/H2/BODY -->` verbatim]`

---

### Pattern 3: Presentation format — scroll-snap pattern (D3-04, D3-09)

**What:** A `<main>` container scoped to the viewport with vertical mandatory scroll-snap; each `<section class="slide">` is `100vh` with `scroll-snap-align: start`.

**Verified canonical CSS (use this verbatim in `presentation.html`):**

```css
/* Snap container is <main>, NOT <html>. Safari fragility on html-as-snap-container is the
   single most-cited issue (CSS-Tricks: "html doesn't work in Safari and body does"). */
main.deck {
  scroll-snap-type: y mandatory;
  overflow-y: scroll;
  height: 100vh;
  margin: 0;
}

.slide {
  scroll-snap-align: start;
  scroll-snap-stop: always;  /* Forces stop at every slide even on fast scroll. Baseline since July 2022. */
  height: 100vh;
  width: 100%;
  display: flex;
  flex-direction: column;
  justify-content: center;
  padding: 80px 120px;
  box-sizing: border-box;
  scroll-margin-top: 0;  /* No sticky header in Presentation, so 0. */
}
```

**HTML shape:**

```html
<main class="deck">
  <section class="slide" id="slide-1"> ... </section>
  <section class="slide" id="slide-2"> ... </section>
  <!-- ... -->
</main>
```

**Why this exact form:**
- `<main>` is the snap container, not `<html>` or `<body>`. This sidesteps the well-known Safari quirk where `html { scroll-snap-type: ... }` does not behave correctly. `[CITED: css-tricks.com/practical-css-scroll-snapping/]`
- `scroll-snap-stop: always` is **Baseline Widely Available since July 2022** — safe to ship without a polyfill. `[CITED: developer.mozilla.org/en-US/docs/Web/CSS/scroll-snap-stop]`
- `display: flex` + `justify-content: center` centers the slide content vertically — slide content rarely fills 100vh, and centered content reads as "slide-shaped."
- `box-sizing: border-box` keeps padding from breaking the 100vh height (the "tall element" gotcha).

**Sources:**
- `[CITED: css-tricks.com/practical-css-scroll-snapping/ — vertical mandatory pattern, html-vs-body quirk]`
- `[CITED: caniuse.com/css-snappoints — 96.23% global support for CSS Scroll Snap]`
- `[CITED: developer.mozilla.org/en-US/docs/Web/CSS/scroll-snap-stop — Baseline Widely Available since July 2022]`
- `[CITED: css-tricks.com/css-scroll-snap-slide-deck/ — slide-deck pattern]`

---

### Pattern 4: CSS-only slide counter (D3-05)

**What:** Display "current / total" on every slide without JavaScript.

**The trick:** `counter-increment` produces "current" trivially. "Total" must be injected by the generator at render time — there is no pure-CSS primitive that counts children.

**Pattern (use in `presentation.html`):**

```css
main.deck {
  /* Counter set up on the snap container so each slide increments it. */
  counter-reset: slide-num;
}

.slide {
  counter-increment: slide-num;
  position: relative;
}

/* Counter pill: fixed bottom-right of every slide. */
.slide-counter {
  position: absolute;
  bottom: 24px;
  right: 32px;
  font-size: 14px;
  font-weight: 700;
  color: var(--g6);
  letter-spacing: 1.2px;
}

.slide-counter::before {
  content: counter(slide-num) " / TOTAL_SLIDES_LITERAL";
}
```

**At render time:** Claude substitutes the literal `TOTAL_SLIDES_LITERAL` string with the actual slide count from the approved arc. So a 5-slide deck ships with `content: counter(slide-num) " / 5";`.

**HTML inside each `.slide`:**
```html
<div class="slide-counter"></div>
```

**Alternative considered:** Using a CSS custom property (`--total: 5;` on `<main>`, then `content: counter(slide-num) " / " var(--total);`). `var()` inside `content` is widely supported, but the literal-substitution form is simpler, has zero browser-quirk surface, and is what the audit harvester naturally accepts. Recommend the literal form.

**Counter placement (Claude's Discretion per CONTEXT.md):** The Caseproof Documentation System has no slide-counter precedent. Three reasonable placements:

| Placement | When it makes sense |
|-----------|---------------------|
| **Bottom-right** (recommended) | Most common slide-deck convention (Keynote default, Reveal.js default). Unobtrusive, expected. |
| Top-right | Higher visibility, less common. Risk of clashing with slide title. |
| Centered footer | Used by some minimal decks (Pip Decks). Less common; reads as decorative. |

Recommend **bottom-right** as the default.

**Sources:**
- `[CITED: developer.mozilla.org/en-US/docs/Web/CSS/counter-increment — counter mechanism]`
- `[CITED: codersblock.com/blog/fun-times-with-css-counters/ — counter patterns]`
- `[CITED: css-tricks.com/almanac/properties/c/counter-increment/ — examples]`

---

### Pattern 5: Anchor navigation between slides (D3-06)

**What:** A floating nav element with `<a href="#slide-N">` links. Browser handles the scroll on click.

**Pattern:**

```html
<nav class="slide-nav">
  <a class="nav-a" href="#slide-1">1</a>
  <a class="nav-a" href="#slide-2">2</a>
  <!-- ... -->
</nav>
```

```css
.slide-nav {
  position: fixed;
  top: 24px;
  right: 32px;
  display: flex;
  gap: 8px;
  z-index: 10;
}

/* .nav-a is reused verbatim from the handbook sidebar — see components.css.
   No new class needed. */
```

**Why reuse `.nav-a`:** Phase 2's audit harvests `.nav-a` from `components.css` already. Reusing it means zero allowlist additions and visual consistency across Handbook and Presentation.

**Browser behavior:** Clicking `#slide-3` triggers a scroll to that ID. Combined with `scroll-snap-type: y mandatory`, the browser snaps cleanly to the target. **No JavaScript required.**

**Pitfall 9 mitigation:** Presentation has no sticky header (D3-09 — no sidebar, no sticky bar), so `scroll-margin-top` can be `0`. Different from Handbook's 80px. Don't copy Handbook's `scroll-padding-top: 80px`.

`[VERIFIED: read .nav-a presence in components.css via the sample selector grep in this session]`

---

### Pattern 6: Presentation typography scaling (D3-08)

**What:** Slide-visibility-sized type, inlined in `presentation.html`, NOT modifying `typography.css`.

**Pattern:**

```html
<!-- presentation.html — second <style> block, after the inlined three CSS files. -->
<style>
  /* Slide-deck type scale. Rides on Inter @import from typography.css. */
  .slide h1 {
    font-size: 80px;
    font-weight: 800;
    letter-spacing: -3px;
    line-height: 1.05;
  }
  .slide h2 {
    font-size: 56px;
    font-weight: 800;
    letter-spacing: -2px;
    line-height: 1.1;
  }
  .slide p,
  .slide li {
    font-size: 22px;
    font-weight: 400;
    line-height: 1.5;
    color: var(--g8);
  }
</style>
```

**Why inline, not in `typography.css`:**
- `typography.css` is the **document** type scale (handbook + overview body text). Mixing slide sizes pollutes the contract.
- Audit harvester reads `typography.css` for the document-text class allowlist. Slide-specific sizes don't belong there.
- Phase 3 ships only one new format. If V2 adds more (e.g., a poster format), each gets its own inlined scale.

**`letter-spacing` calibration:** Inter at 80px tracks visibly looser than at 56px. The `-3px` value mirrors the H1 calibration in `pm-system.html` proportionally (-2.5px at 56px → -3px at 80px). Empirical adjustment may be needed during the spike — flag as a known calibration knob.

`[ASSUMED]` That the visual rubric for Presentation will accept this scaling. No Caseproof reference exists; the verifier (D3-21) is the only signal.

---

### Pattern 7: Audit harvester wildcard (D3-18)

**What:** Replace the hard-coded `formats/handbook.html` reference in `audit/run.sh` with a glob over `formats/*.html`.

**Existing code (`skill/audit/run.sh:30-37`):**
```bash
handbook_skel="${SKILL_DIR}/design/formats/handbook.html"

for f in "$components_html" "$components_css" "$typography_css" "$handbook_skel"; do
  if [ ! -f "$f" ]; then
    echo "audit: missing $f" >&2
    exit 2
  fi
done
```

**Phase 3 replacement:**
```bash
# Harvest classes from every format skeleton — handbook, overview, presentation,
# and any future formats added under design/formats/.
format_skels=( "${SKILL_DIR}"/design/formats/*.html )

# Verify required design-system files exist; format skeletons are checked
# inline below since the glob may match zero files on a misconfigured install.
for f in "$components_html" "$components_css" "$typography_css"; do
  if [ ! -f "$f" ]; then
    echo "audit: missing $f" >&2
    exit 2
  fi
done

# Empty-glob guard. In bash 3.2 (macOS default), an unmatched glob expands to
# the literal pattern, NOT an empty list. Without this guard, the harvester
# would try to read a file named "*.html" and fail noisily. shopt -s nullglob
# is bash 4 only — unavailable on macOS — so we test each entry.
if [ ! -e "${format_skels[0]}" ]; then
  echo "audit: no format skeletons found in ${SKILL_DIR}/design/formats/" >&2
  exit 2
fi
```

**Then in the harvest loop (around line 100):**
```bash
{
  command grep -oE 'class="[^"]+"' "$components_html"
  for skel in "${format_skels[@]}"; do
    command grep -oE 'class="[^"]+"' "$skel"
  done
  for css in "$typography_css" "$components_css"; do
    # ... existing extraction logic, unchanged ...
  done
} \
  | command sed -E 's/class="//; s/"$//' \
  ...
```

**Why this exact form:**

1. **bash 3.2 / BSD compatibility (Phase 2 D2-22 carry-over).** macOS bash is locked at 3.2.57. `shopt -s nullglob` is a bash 4 feature — unavailable. The recommended workaround is the existence test on the first array element. `[VERIFIED: ran `bash --version` in prior Phase 2 research; existing audit/run.sh:12 uses `set -euo pipefail` and bash 3.2 idioms]`

2. **Whitelist vs. wildcard.** D3-18 mandates `formats/*.html` (wildcard). This auto-extends to future formats without script edits — D3-19 explicitly says no hand-maintained allowlist additions. The trade-off: any random `.html` file dropped into `formats/` would be harvested. Mitigation: `formats/` already has only the three skeletons; if a planner introduces a stray file (e.g., `formats/example-output.html`), the harvest would inflate the allowlist. Counter-mitigation: add a comment in `formats/` documenting that **only format skeletons** belong there.

3. **Empty-glob handling.** Without the guard, an unmatched glob in bash 3.2 expands to the literal pattern (`design/formats/*.html`). The first array element check (`-e "${format_skels[0]}"`) cleanly distinguishes "no files match" from "files match." This is the canonical bash 3.2 idiom for nullglob without `shopt`.

`[VERIFIED: read skill/audit/run.sh:30-37 + 100-130 in this session — the harvester pattern is well-defined and extensible with a one-line change]`

---

### Pattern 8: Interview file template (D3-10, D3-12)

**What:** All four new interview files share the schema and structure of `handbook.md`. Only question wording, defaults, and tone notes differ.

**Recommended template (planner uses this as the starting point for all four files):**

```markdown
# <Type> interview

SKILL.md reads this file when the user picks `<type>` as the document type.
Ask the questions one at a time, in order. Wait for each answer before asking
the next. Empty answers are accepted — proceed with sensible defaults. Do
not enforce length, do not retry, do not validate. The arc-gate is where
quality is enforced, not the interview.

The schema follows DOC-06's mandate (audience → material → section conventions
→ tone notes → handoff to story-arc) — same shape as `handbook.md`.

## The <N> questions

1. **<Question 1>.** <wording per D3-12>.
   (Default if blank: "<documented default>")

2. **<Question 2>.** ...

   <... up to 5 questions max ...>

## Hand-off

After question <N> (or earlier if the user says "go ahead, propose"), do NOT
write HTML. Read `${CLAUDE_SKILL_DIR}/story-arc.md` and follow it end-to-end.
The story-arc gate decides when HTML is allowed.

## What this interview must NOT do

- Do not validate answers. Empty answers proceed with the documented defaults.
- Do not loop on a question. One ask, one answer, move on.
- Do not re-ask the document type. SKILL.md handled that.
- Do not paraphrase the questions. The wording is the contract.
- Do not mention any other doc type elsewhere.
```

**Tone-defaults wording per type (verbatim from CLAUDE.md, except where pitch diverges):**

| Type | Tone default if blank |
|------|----------------------|
| handbook | `"Handbook, not pitch. Describe what IS." — verbatim from CLAUDE.md.` |
| pitch | `"Direct and confident. Selling is OK in the body, but section TITLES still describe what IS — never pitch in titles." (titles inherit handbook tone; body diverges)` |
| technical-brief | `"Handbook, not pitch. Describe what IS." — verbatim from CLAUDE.md. (Same as handbook — engineers read for facts, not enthusiasm.)` |
| presentation | `"Handbook tone in titles. Body may run more energetic — slides reward visual punch — but never pitch-y. Use direct nouns, short clauses."` |
| meeting-prep | `"Handbook, not pitch. Describe what IS." — verbatim from CLAUDE.md. (Briefings deliver facts; selling is wrong here.)` |

Three of five use the verbatim CLAUDE.md tone default. Pitch and Presentation diverge slightly — but **only in the body**, not in titles. The story-arc self-review pass (Phase 2 D2-11) catches title-tone drift regardless of which type generated the arc.

**Anti-pattern to avoid:** Copying handbook.md and changing only the H1 (e.g., `# Pitch interview` and otherwise identical questions). The whole point of type-tailored interviews is that the questions surface different material. See §"Pitfall 19 — Type-labeled clones."

---

### Pattern 9: Schema-drift heuristic (Pitfall 20 mitigation)

**What:** A mechanical check that fails CI if any interview file violates the DOC-06 schema.

**Recommended checks (the planner picks one of three implementations):**

1. **`grep`-based, in audit/run.sh.** Add a new rule (Rule 5):
   ```bash
   # Rule 5 — interview schema check
   for interview in "${SKILL_DIR}"/interview/*.md; do
     # Must have `## The N questions` heading.
     command grep -qE '^## The [0-9]+ questions?' "$interview" || violations=$((violations+1))
     # Must have `## Hand-off` heading.
     command grep -qE '^## Hand-off' "$interview" || violations=$((violations+1))
     # Must reference story-arc.md in hand-off.
     command grep -q 'story-arc.md' "$interview" || violations=$((violations+1))
     # Question count cap (DOC-07).
     q_count="$(command grep -cE '^[0-9]+\.[[:space:]]+\*\*' "$interview")"
     if [ "$q_count" -gt 5 ]; then violations=$((violations+1)); fi
     if [ "$q_count" -lt 3 ]; then violations=$((violations+1)); fi
   done
   ```

2. **Standalone `audit/lint-interviews.sh`.** Same logic, separate file. Pros: single-purpose script reads cleaner. Cons: SKILL.md doesn't invoke it (it's a CI-time check, not a per-output check).

3. **GitHub Actions step in `.github/workflows/shellcheck.yml`.** Uses the same grep checks but in a CI YAML step. Pros: zero per-output cost. Cons: doesn't run on the contributor's local machine before commit.

**Recommendation: Option 1.** Folds into the existing audit pattern, runs on every output, fast (4 greps × 5 files = ~20ms), and surfaces drift loudly. The check verifies STRUCTURE, not CONTENT — it can't catch "the questions are dull" but it does catch "you forgot the `## Hand-off` section in `pitch.md`."

**Why a check is worth building:** Schema drift is silent — one interview file slowly diverges from the schema as plans iterate. The fixture-time human verifier doesn't see schema, only output. By the time a 6th doc type is proposed in V2 and finds the schema isn't actually enforced, the drift is across all five files.

`[ASSUMED]` That this check belongs in V1 rather than V2. CONTEXT.md doesn't explicitly mandate it — D3-10 just says "schema is identical to handbook.md." Worth flagging to the planner: a passive constraint (D3-10) without an active check is a constraint the next plan can violate. Discretion: planner decides whether to ship the check in Phase 3 or defer to V2.

---

## Component Responsibilities

| File | Responsibility |
|------|----------------|
| `skill/SKILL.md` | Flow control. Phase 3 modifies Step 2 (route stubs), adds Step 5b (format selection), modifies Step 6 (skeleton routing). |
| `skill/interview/handbook.md` | Schema reference. NO CHANGE in Phase 3. |
| `skill/interview/pitch.md` (NEW) | Pitch-tailored questions. ≤4 questions per D3-12. |
| `skill/interview/technical-brief.md` (NEW) | Tech-brief-tailored questions. ≤5 questions. |
| `skill/interview/presentation.md` (NEW) | Presentation-tailored questions. ≤5 questions. Forces format = presentation regardless of section count. |
| `skill/interview/meeting-prep.md` (NEW) | Meeting-prep-tailored questions. ≤5 questions. |
| `skill/story-arc.md` | Universal arc gate. NO CHANGE. Used by all 5 doc types. |
| `skill/audit/run.sh` | Mechanical audit. Modify only the harvester glob (one-line change per Pattern 7). Optionally add Rule 5 (Pattern 9). |
| `skill/audit/rules.md` | Human-readable rule reference. Update if Rule 5 is added. |
| `skill/design/formats/presentation.html` (NEW) | Slide-deck skeleton with scroll-snap, slide counter, anchor nav, NO sidebar. |

---

## Visual Gate for Presentation (D3-21 rubric)

**Problem:** Presentation has no Caseproof reference HTML to diff against. The visual gate must rely on a written rubric.

**Recommended rubric (planner copies into plan 03-04 as the verifier checklist):**

### Should look like:
- [ ] Each slide fills the viewport (100vh, no scrollbar within a slide).
- [ ] Slide background is `var(--white)` — pure light, no off-white.
- [ ] H1 uses Inter at ~80px, weight 800, tracking ~-3px. Visually larger than any handbook H1.
- [ ] H2 (if used) at ~56px, weight 800. Distinct from H1, not just slightly smaller.
- [ ] Body text at ~22px, gray (`var(--g8)`), comfortable reading line-length.
- [ ] Slide counter visible (bottom-right by default), shows "current / total" in muted gray.
- [ ] Floating slide-nav present (top-right by default), reuses `.nav-a` styling from the sidebar.
- [ ] Palette is identical to Handbook/Overview — same blues, grays, accents. **No new colors.**

### Must have:
- [ ] `<meta name="color-scheme" content="light">` and `<meta name="supported-color-schemes" content="light">` (Pitfall 7 — forced dark mode).
- [ ] `color-scheme: light` declared in `:root` (palette.css inherits it).
- [ ] All three CSS files inlined (palette → typography → components) per Phase 2 D2-15.
- [ ] Inter `@import` present (typography.css inlines it).
- [ ] System-font fallback stack on body (Pitfall 8 — Google Fonts blocked).
- [ ] Zero `<script>` tags. Zero `on*=` handlers. Zero `javascript:` URLs.
- [ ] All classes used appear in the audit allowlist after harvester extension.

### Must not have:
- [ ] Any sidebar (D3-09 — Presentation is full-viewport, no sidebar).
- [ ] Any sticky bar (no `position: sticky` elements).
- [ ] Any custom transition or animation CSS beyond the browser's default snap behavior (D3-07).
- [ ] Hex literals outside `:root` (Pitfall 4 — design-token drift).
- [ ] Slide content that overflows the 100vh container (the "tall element" gotcha — would break mandatory snap).

### Browser test matrix:
- [ ] Chrome (latest stable on macOS): scroll wheel scrolls one slide at a time. Trackpad scroll snaps. Anchor click jumps cleanly.
- [ ] Safari (latest stable on macOS): same three behaviors. **This is the spike's primary verification target.**
- [ ] iOS Safari (latest, real device or simulator): forced-dark-mode test still passes (Pitfall 7). Touch-swipe behavior is acceptable (snap may feel different on touch — that's expected).

### Acceptable diffs:
- [ ] Different content per slide (the fixture is "Phase 3 status update" per D3-20; content is content).
- [ ] Slight font tracking differences vs Caseproof references (Presentation uses larger sizes; Inter tracks differently at 80px than at 56px).

### Unacceptable:
- [ ] Any wrong palette color (every accent must be from `palette.css`).
- [ ] Any custom font (Inter only, with fallback).
- [ ] Any non-allowlisted class (audit must pass after harvester extension).
- [ ] Snap fails on Chrome or Safari (= spike failed = fall back to `:target`-only navigation per D3-03).

**Sources for rubric calibration:**
- `[CITED: css-tricks.com/css-scroll-snap-slide-deck/ — public scroll-snap slide-deck pattern]`
- `[CITED: codepen.io/lideo/pen/gOawqaW — 100vh sections with scroll snap]`
- `[VERIFIED: skill/design/formats/handbook.html — for shared header/CSS-inlining contract]`

---

## Spike Build Sheet (D3-03 — Plan 03-01 Task 1)

**Time budget:** 30 minutes. Hard timeout — if 30 min elapses without conclusive Chrome+Safari pass, fall back to `:target`-only mode and document the limitation.

**Inputs needed:** Nothing — pure CSS/HTML, no skill state, no design system inlining (use raw colors for the spike, design tokens come later).

**Build:**

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="color-scheme" content="light">
  <title>Scroll-snap spike</title>
  <style>
    body { margin: 0; font-family: system-ui, sans-serif; }
    main.deck {
      scroll-snap-type: y mandatory;
      overflow-y: scroll;
      height: 100vh;
      margin: 0;
    }
    .slide {
      scroll-snap-align: start;
      scroll-snap-stop: always;
      height: 100vh;
      width: 100%;
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      box-sizing: border-box;
      font-size: 80px;
      font-weight: 800;
    }
    .slide:nth-child(1) { background: #F0F5FE; }
    .slide:nth-child(2) { background: #F0FAF0; }
    .slide:nth-child(3) { background: #FFF5E6; }
    .slide-nav { position: fixed; top: 24px; right: 32px; display: flex; gap: 8px; z-index: 10; }
    .slide-nav a { padding: 4px 10px; border: 1px solid #888; text-decoration: none; color: #333; }
  </style>
</head>
<body>

<nav class="slide-nav">
  <a href="#slide-1">1</a>
  <a href="#slide-2">2</a>
  <a href="#slide-3">3</a>
</nav>

<main class="deck">
  <section class="slide" id="slide-1">Slide 1</section>
  <section class="slide" id="slide-2">Slide 2</section>
  <section class="slide" id="slide-3">Slide 3</section>
</main>

</body>
</html>
```

**Test sequence (≤30 min):**

| Step | Browser | Action | Expected | Pass criteria |
|------|---------|--------|----------|---------------|
| 1 | Chrome (latest macOS) | Open file via `file://` | First slide fills viewport, blue bg | Visual match |
| 2 | Chrome | Scroll wheel down once | Snaps to slide 2 (green), no half-state | No partial scroll lingering |
| 3 | Chrome | Trackpad fast-scroll all the way down | Lands on slide 3, NOT skipped past | `scroll-snap-stop: always` confirmed |
| 4 | Chrome | Click `<a href="#slide-2">` in nav | Jumps to slide 2 cleanly, no overshoot | Anchor + snap composes |
| 5 | Safari (latest macOS) | Repeat steps 1-4 | Same behavior | **PRIMARY VERIFICATION** |
| 6 | Safari | Resize window to ~600px height, scroll | Slides resize to new viewport, snap still works | Responsive viewport handling |
| 7 | Safari | Open DevTools, throttle CPU 4x, fast-scroll | Snap still fires, may be jittery but completes | iOS-Safari proxy (no jitter on macOS Safari ≈ no jitter on iOS) |

**Pass:** All 7 steps work in both browsers.
**Fail:** Any of: snap doesn't fire (free-scroll behavior), anchor click overshoots and bounces back, slide content overflows when viewport shrinks, Safari behavior visibly differs from Chrome on a non-resize step.

**On fail — fallback design (`:target`-only navigation):**

Drop these properties from the CSS:
- `scroll-snap-type: y mandatory` (on `main.deck`)
- `scroll-snap-align: start`, `scroll-snap-stop: always` (on `.slide`)

Keep `id="slide-N"` and the floating nav. Behavior degrades to: clicking a nav link scrolls to the target (browser default for fragment navigation). The user can free-scroll between slides. **This is acceptable for v1** — slide-deck UX still works, just without the "click-and-snap" precision. Document as a known limitation in the README (Phase 4).

**Trade-off summary (snap vs `:target`-only):**

| Property | scroll-snap (full) | `:target`-only fallback |
|----------|-------------------|------------------------|
| Slide-at-a-time scrolling | Yes | No (continuous) |
| Anchor nav | Yes | Yes |
| Browser support | Modern only (Baseline since 2022) | Universal (HTML 1.0) |
| Safari fragility | Possible (mitigated by main-not-html) | Zero |
| User confusion (free-scroll) | None | Possible — user mid-scrolls between slides |

`[ASSUMED]` That the spike will pass on Chrome and Safari macOS in 2026. caniuse + MDN both report broad support and Phase 3 is the first time the team builds it; if the spike fails, the fallback is documented and acceptable.

---

## Pitfalls Specific to Phase 3

These extend the existing pitfall registry (`.planning/research/PITFALLS.md` Pitfalls 1-13 + Phase 2's 14-18). Phase 3 introduces three new pitfalls + refines two existing ones.

### Pitfall 19 (Phase 3 specific): Type-labeled clones

**What goes wrong:**
The four new doc types produce documents that look distinguishable on a per-slot basis but read like the same document with different filenames. Pitch and meeting-prep both ship 3-section Overviews — if their interview-question wording isn't tailored, both ask "who's the audience? what are the talking points? anything to avoid?" and the user gets two near-identical outputs.

**Why it happens:**
Copy-paste implementation. The four new interview files start as `cp interview/handbook.md interview/pitch.md` (or equivalent), the planner intends to revise the questions, the revision is mechanical (reword a few sentences), the underlying *material that gets gathered* is the same. Output reads as the same.

**How to avoid:**
- Author each interview file from D3-12's question order, NOT from `handbook.md`. The schema is shared; the questions are not.
- Each interview asks for **type-distinctive material**. Pitch asks "the ask" and "the problem" — handbook does not. Tech brief asks "alternatives considered" and "trade-offs" — pitch does not. Meeting prep asks "open questions / risks" — handbook and pitch do not.
- Plan 03-04's visual gate (D3-22) is the only mechanical signal — read all four fixtures sequentially, not side-by-side. If two read the same, the interviews are too similar.

**Warning signs:**
- Interview files diff smaller than 20% of their question content.
- Visual gate reviewer can't tell pitch.html and meeting-prep.html apart at the headline level.
- Tone defaults across the four files reference the same CLAUDE.md tone with no per-type adjustment.

---

### Pitfall 20 (Phase 3 specific): Schema drift across the five interview files

**What goes wrong:**
A future plan adds a sixth doc type (or modifies an existing one) and the interview file uses a slightly different schema — `audience → tone → material → sections → handoff` instead of `audience → material → sections → tone → handoff`. The arc-gate still works because it doesn't care about interview file shape. But the user UX diverges: handbook asks tone before sections, pitch asks tone after, the experience feels inconsistent.

Worse: a future change to the schema (DOC-06) is supposed to apply to all files, but only `handbook.md` is updated because it's the "reference." The other four silently fall behind.

**Why it happens:**
D3-10 says "schema is identical to handbook.md" but provides no mechanical check. Plans drift because the constraint is passive, not active.

**How to avoid:**
- Add a schema-drift check to the audit (Pattern 9 above). Mechanical, ~20ms per output.
- Reference handbook.md as the schema source of truth in every interview file's header comment (D3-12 Claude's-discretion item — recommend doing it).
- When DOC-06 changes (V2), update ALL FIVE interview files atomically in one commit — don't update handbook.md and treat the others as "follow-up work."

**Warning signs:**
- An interview file lacks the `## Hand-off` section.
- Question count outside 3-5 range.
- An interview file omits the "What this interview must NOT do" section.
- New doc type proposed and the schema check doesn't run on it.

---

### Pitfall 21 (Phase 3 specific): Format auto-selection picks the wrong shape

**What goes wrong:**
User runs `/deshtml`, picks `pitch`, the interview elicits a 4-section narrative (problem → context → solution → ask). Auto-selection lands Handbook (≥4 sections). But pitch is supposed to be Overview per REQUIREMENTS.md DOC-01. User gets a 960px-sidebar handbook instead of a 1440px-linear pitch. **Or**: user picks `technical brief`, interview produces 3 sections (decision → alternatives → trade-offs). Auto-selection lands Overview. But tech brief is supposed to be Handbook per DOC-03.

**Why it happens:**
D3-01 makes section count the discriminator, not type. The mapping in CONTEXT.md (pitch typically 1-3 → Overview; tech brief typically 4+ → Handbook) is a **typical-case observation**, not an enforced rule. Edge cases produce surprises.

**How to avoid:**
- D3-02's `Format: <name>` print line is the user's only signal. The line MUST be visible (not buried in prose) so the user can react before render.
- If the user objects to the auto-selected format, the only path is: edit the arc (add or remove sections) and re-approve. SKILL.md does NOT add a `--format=` override flag in v1.
- Document this trade-off in the README (Phase 4): "Format follows from your arc. To change format, change the arc."

**Warning signs:**
- Visual-gate fixture for pitch ships as Handbook (would mean the canonical pitch had 4+ sections — likely too long).
- Visual-gate fixture for technical brief ships as Overview (would mean the canonical tech brief had 1-3 sections — likely too thin).
- User feedback (Phase 4 launch) "I picked pitch but it gave me a sidebar."

**Mitigation if the trade-off bites users:**
V2 ships a `/deshtml --format=<name>` override (CONTEXT.md "Deferred Ideas" already lists this).

---

### Pitfall 11 refinement (extends existing Pitfall 11): Output written to wrong directory or overwrites existing files

**Phase 3 angle:** With four new doc types, the slug-collision surface widens. A user runs `/deshtml`, picks `pitch`, writes `2026-04-29-bnp-deshtml-pitch.html`. Same day, picks `technical-brief` against the same content, writes `2026-04-29-bnp-deshtml-technical-brief.html`. The TYPE suffix prevents collision across types — good.

**But** if the user re-runs `/deshtml` for the same type on the same day (revising, regenerating), the suffix-on-collision logic from Phase 2 (`-2`, `-3`) handles it. **Verify**: the SKILL.md Step 5 collision check (already in place) runs identically per type. No Phase 3 change needed.

**Confirmed:** Phase 2's collision logic is type-agnostic (`while test -f "$target"; do target="...-${suffix}.html"`). Phase 3 inherits unchanged. `[VERIFIED: read SKILL.md:73-89]`

---

### Pitfall 9 refinement (extends existing Pitfall 9): Anchor links hide content behind sticky header

**Phase 3 angle:** Presentation has NO sidebar and NO sticky bar (D3-09). So `scroll-margin-top` should be `0` (or simply not set). **Do not copy Handbook's `scroll-padding-top: 80px`** into `presentation.html`.

If the planner accidentally inherits Handbook's pattern (`html { scroll-padding-top: 80px; }`), every slide's anchor jump would land 80px below the slide's top edge — a visible gap on every nav click.

**Mitigation:** `presentation.html`'s inline `<style>` explicitly sets `html { scroll-padding-top: 0; }` (matching `overview.html`'s approach) or simply omits the rule entirely.

`[VERIFIED: read overview.html:14 — uses `scroll-padding-top: 0` explicitly]`

---

## Test Strategy for Visual Gate

**Plan 03-04 owns this.** Recommend the following structure for the visual-gate plan:

### Wave 0: Spike (D3-03, plan 03-01 Task 1)
- 30-min scroll-snap spike per the §"Spike Build Sheet" above.
- Output: a record (commit message + brief comment in `presentation.html`) of "Snap works in Chrome+Safari" or "Snap fails, fallback engaged."

### Wave 1: Per-type fixtures (D3-20)
Generate one canonical fixture per doc type. Each fixture follows Phase 2's pattern (interview-answers.md + expected-arc.md + FIXTURE-NOTES.md):

| Fixture | Subject | Expected format | Reference for diff |
|---------|---------|-----------------|--------------------|
| `pitch.html` | "Pitching deshtml to a small-team CTO" — audience: technical, ask: "let me build this for our team," 3 sections | Overview | `bnp-overview.html` (palette, typography, hero shape match) |
| `technical-brief.html` | "Why we chose curl-pipe-bash for distribution" — audience: Caseproof engineers, decision: pipe-bash over packaged installer, 5-6 sections | Handbook | `pm-system.html` (sidebar, layout, type scale match) |
| `presentation.html` | "Phase 3 status update" — audience: Caseproof team, 5 slides | Presentation | NONE — use the §"Visual Gate for Presentation" rubric |
| `meeting-prep.html` | "Demo run-through with Delfi" — audience: Delfi, 3 sections (context, demo flow, anticipated questions) | Overview | `bnp-overview.html` |

### Wave 2: Sequential read (D3-22)
Reader opens all four fixtures in one session, reads them in order. Acceptance: each reads as a distinct document, not a type-labeled clone of another. This is the Pitfall 19 gate.

### Wave 3: Audit + browser matrix (D3-21)
- Run `bash skill/audit/run.sh <fixture.html>` on each — exit 0 expected.
- Open each fixture in Chrome + Safari (macOS). Visual diff vs the reference (where applicable).
- Open Presentation fixture on iOS Safari (forced dark mode on) — confirm light-only rendering.

**No nyquist_validation infrastructure needed.** `.planning/config.json` confirms `workflow.nyquist_validation: false` — no test framework, no per-task pytest. The visual gate is the test.

`[VERIFIED: read .planning/config.json — workflow.nyquist_validation: false]`

---

## Code Examples

### Verified Pattern: `presentation.html` skeleton (full)

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="color-scheme" content="light">
  <meta name="supported-color-schemes" content="light">
  <title><!-- DOC TITLE --></title>
  <link rel="stylesheet" href="../palette.css">
  <link rel="stylesheet" href="../typography.css">
  <style>
    /* Presentation layout — full-viewport vertical slide deck.
       NO sidebar, NO sticky bar. Snap container scoped to <main>, not <html>,
       to avoid Safari's html-as-snap-container fragility. */
    html { scroll-padding-top: 0; }
    body { background: var(--white); margin: 0; }

    main.deck {
      scroll-snap-type: y mandatory;
      overflow-y: scroll;
      height: 100vh;
      margin: 0;
      counter-reset: slide-num;
    }

    .slide {
      scroll-snap-align: start;
      scroll-snap-stop: always;
      height: 100vh;
      width: 100%;
      display: flex;
      flex-direction: column;
      justify-content: center;
      padding: 80px 120px;
      box-sizing: border-box;
      counter-increment: slide-num;
      position: relative;
    }

    .slide-counter {
      position: absolute;
      bottom: 24px;
      right: 32px;
      font-size: 14px;
      font-weight: 700;
      color: var(--g6);
      letter-spacing: 1.2px;
    }
    .slide-counter::before {
      /* TOTAL_SLIDES_LITERAL is replaced by Claude at render time with the literal slide count. */
      content: counter(slide-num) " / TOTAL_SLIDES_LITERAL";
    }

    .slide-nav {
      position: fixed;
      top: 24px;
      right: 32px;
      display: flex;
      gap: 8px;
      z-index: 10;
    }
  </style>
  <style>
    /* Slide-deck type scale. Rides on Inter @import from typography.css.
       Larger than the document scale because slides are read at distance. */
    .slide h1 {
      font-size: 80px;
      font-weight: 800;
      letter-spacing: -3px;
      line-height: 1.05;
    }
    .slide h2 {
      font-size: 56px;
      font-weight: 800;
      letter-spacing: -2px;
      line-height: 1.1;
    }
    .slide p,
    .slide li {
      font-size: 22px;
      font-weight: 400;
      line-height: 1.5;
      color: var(--g8);
    }
  </style>
</head>
<body>

<!-- SLIDE NAV: floating top-right anchor links to each slide. Reuses .nav-a from components.css. -->
<nav class="slide-nav">
  <!-- SLIDE NAV ITEMS SLOT -->
</nav>

<main class="deck">

  <!-- SLIDE 1..N: each section is a full-viewport slide with optional .slide-counter pill. -->
  <section class="slide" id="slide-1">
    <!-- SLIDE 1 H1 SLOT -->
    <!-- SLIDE 1 BODY SLOT (components from components.html allowlist) -->
    <div class="slide-counter"></div>
  </section>

</main>

</body>
</html>
```

`[CITED: skill/design/formats/handbook.html and overview.html for shared header/CSS-link contract]`
`[CITED: css-tricks.com/practical-css-scroll-snapping/ for the scroll-container-on-main pattern]`
`[CITED: developer.mozilla.org/en-US/docs/Web/CSS/scroll-snap-stop for Baseline support]`

---

### Verified Pattern: SKILL.md Step 2 type-branch (full Phase 3 form)

Replaces lines 36-54 of the existing SKILL.md (Step 2). The structural change is the four stub flips and the implicit auto-selection downstream:

```markdown
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
normalized type from Step 2). Follow it end-to-end. Return here only after the
user has answered the questions (or stopped early per that file's instructions).

Do NOT read `story-arc.md` yet (Pitfall 15).
```

`[VERIFIED: replicates the existing Step 2 structure from SKILL.md:36-54 with the four stubs flipped]`

---

### Verified Pattern: SKILL.md Step 5b (NEW)

Inserted between existing Step 5 (filename + collision) and existing Step 6 (render). Approximately 12 new lines:

```markdown
## Step 5b — Select format

Determine which format skeleton Step 6 will use. The decision is mechanical:

1. If the document type from Step 2 == `presentation` → format = `presentation`.
2. Else if the approved arc has 4 or more rows → format = `handbook`.
3. Else → format = `overview`.

Print exactly one line to the user (no other prose, no decoration):

> Format: <format>

Example output: `Format: handbook` or `Format: overview` or `Format: presentation`.

Then continue to Step 6.
```

`[Source: D3-15 verbatim]`

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `scroll-snap-stop` requires polyfill | Baseline Widely Available | July 2022 | Phase 3 can ship `scroll-snap-stop: always` without a fallback |
| `html { scroll-snap-type: ... }` works everywhere | `<main>` (or another scoped container) is the safe Safari pattern | Always — Safari fragility predates baseline | Phase 3 scopes the snap container to `<main>`, not `<html>` |
| Reveal.js / Slidev / Spectacle for slide decks | Native CSS scroll-snap (no JS) | scroll-snap baseline 2018-2022 | Phase 3 ships zero JS — D-17 + PROJECT.md self-contained constraint enforced |
| Manual class allowlist file | Live harvest from design system at audit time | Phase 2 (D2-19) | Phase 3 inherits — no allowlist edits when adding `presentation.html` |

**Deprecated/outdated (do not use):**
- `-webkit-scroll-snap-points-y` and the legacy `scroll-snap-points-y` syntax — superseded by the modern `scroll-snap-type` / `scroll-snap-align` / `scroll-snap-stop` triad. caniuse confirms the legacy syntax is "dropped." `[CITED: caniuse.com/css-snappoints]`

---

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | The 30-min scroll-snap spike will pass on Chrome + Safari macOS in 2026 | §"Spike Build Sheet" | LOW. Fallback to `:target`-only is documented and acceptable per D3-03. caniuse + MDN both report broad support. |
| A2 | Presentation typography scale (H1 80px, H2 56px, body 22px) will pass the visual gate | §"Pattern 6 — Presentation typography" | MEDIUM. No Caseproof reference for Presentation. Verifier may want different sizes. Mitigation: easy to adjust during plan 03-04. |
| A3 | The schema-drift check (Pattern 9) belongs in V1 rather than V2 | §"Pattern 9 — Schema-drift heuristic" | LOW. Adding the check is ~20 lines of bash. CONTEXT.md doesn't mandate it but doesn't forbid it. Planner discretion. |
| A4 | `formats/overview.html` and `formats/handbook.html` share slot vocabulary | §Summary finding 4 + §"Pattern 2" | NONE — VERIFIED by reading both files in this session. |
| A5 | Pitch's tone-default should diverge from handbook's (sales tone in body OK) | §"Pattern 8 — Interview file template" | LOW. CLAUDE.md is unambiguous about title tone (always handbook); body tone for pitch is a soft Claude's-discretion call. Visual gate verifies. |
| A6 | macOS bash 3.2 + the wildcard glob in `audit/run.sh` works without `shopt -s nullglob` | §"Pattern 7 — Audit harvester wildcard" | LOW. The first-element-existence check is a canonical bash 3.2 idiom. Phase 2 already targets bash 3.2 successfully. |
| A7 | Reusing `.nav-a` from `components.css` for the slide-nav is visually appropriate | §"Pattern 5 — Anchor navigation" | LOW. `.nav-a` is already used in handbook.html sidebar. Reusing maintains visual consistency and avoids new allowlist additions. |
| A8 | The literal-substitution form for the slide counter (`" / 5"`) is preferable to the `var(--total)` form | §"Pattern 4 — CSS-only slide counter" | LOW. Either works. Literal form has zero browser-quirk surface and is what the audit harvester naturally accepts. |

**If this table seems large:** Most assumptions are LOW-risk and reversible. Only A1 (spike pass) and A2 (typography scale) carry meaningful risk, and both have explicit mitigations (A1 → fallback design; A2 → adjust during fixture).

---

## Open Questions

1. **Should `audit/run.sh` ship with the schema-drift check (Pattern 9) in Phase 3, or defer to V2?**
   - What we know: D3-10 mandates schema identity; D3-11 caps questions ≤5. Both are passive constraints today.
   - What's unclear: Whether the planner has budget for a 5th audit rule + corresponding rules.md update.
   - Recommendation: Ship in Phase 3 if plan 03-03 (audit extension) has any spare time. Otherwise defer to V2 and add a TODO comment in `audit/run.sh`. Do NOT skip without a TODO.

2. **Does the slide counter belong on every slide, or only as a fixed element (one DOM node)?**
   - What we know: D3-05 says "displayed via `::after { content: ... }` on a fixed-position element" — singular.
   - What's unclear: Per-slide pseudo-element vs single fixed element. CONTEXT.md leans single fixed.
   - Recommendation: Use ONE `<div class="slide-counter">` per slide (simpler — `position: absolute` inside the slide), but render it via `::before` on the singular `.slide-counter` div. The counter property `slide-num` increments per `.slide`, so each slide's `.slide-counter::before` shows the correct number. This is what Pattern 4 above codifies.

3. **What's the Presentation fixture's H1?**
   - What we know: D3-20 names the fixture subject as "Phase 3 status update."
   - What's unclear: Whether "Phase 3 status update" is the literal H1 (i.e., presentation.html slide 1 reads "Phase 3 status update" in 80px Inter) or a meta-description.
   - Recommendation: Plan 03-04 owns this. Recommend the H1 be the literal subject, so the fixture is self-documenting.

4. **Should the four interview files share a header-comment template or just inherit handbook.md's structure?**
   - What we know: D3-12 Claude's-discretion item flagged this.
   - What's unclear: Header comment vs. inline schema lineage.
   - Recommendation: Inline the schema lineage in each interview file's opening prose (the existing handbook.md says "The schema follows DOC-06's mandate (audience → material → sections → tone → handoff to story-arc) so plan 03's other interviews can mirror this shape." — flip "plan 03" to "the other four interviews" and keep). Single source of truth, no separate header.

---

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| bash 3.2 (BSD) | `audit/run.sh` harvester wildcard | ✓ | 3.2.57 (macOS default) | — |
| `command grep`, `command sed`, `awk` | Existing audit + new harvester glob | ✓ | BSD versions | — |
| Chrome (latest stable, macOS) | Spike + visual gate | ✓ (assumed dev box) | — | Test on Edge as fallback |
| Safari (latest stable, macOS) | Spike + visual gate (PRIMARY) | ✓ (assumed macOS) | — | None — Safari is the gate |
| iOS Safari (forced-dark-mode test) | Pitfall 7 verification | ✓ via Simulator | — | Real device if Simulator broken |
| `qlmanage` (visual diff thumbnails — Phase 2 pattern) | Plan 03-04 visual gate | ✓ | macOS built-in | Manual screenshot |

**No new external dependencies introduced by Phase 3.** All tooling is already on the dev machine per Phase 2.

`[VERIFIED: macOS 25.3.0 (Darwin) per env block; bash 3.2 + BSD utilities are macOS defaults]`

---

## Sources

### Primary (HIGH confidence)
- `[CITED: caniuse.com/css-snappoints]` — 96.23% global support for CSS Scroll Snap; legacy syntax dropped. https://caniuse.com/css-snappoints
- `[CITED: developer.mozilla.org/en-US/docs/Web/CSS/scroll-snap-stop]` — Baseline Widely Available since July 2022. https://developer.mozilla.org/en-US/docs/Web/CSS/scroll-snap-stop
- `[CITED: developer.mozilla.org/en-US/docs/Web/CSS/counter-increment]` — counter mechanism + content interpolation. https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/counter-increment
- `[CITED: developer.mozilla.org/en-US/docs/Web/CSS/Guides/Scroll_snap]` — official scroll-snap guide.
- `[VERIFIED: read skill/SKILL.md, skill/audit/run.sh, skill/design/formats/handbook.html, skill/design/formats/overview.html, skill/interview/handbook.md, skill/story-arc.md, .planning/config.json in this session]`

### Secondary (MEDIUM confidence)
- `[CITED: css-tricks.com/practical-css-scroll-snapping/]` — vertical mandatory pattern, html-vs-body Safari quirk. https://css-tricks.com/practical-css-scroll-snapping/
- `[CITED: css-tricks.com/css-scroll-snap-slide-deck/]` — public scroll-snap slide-deck reference. https://css-tricks.com/css-scroll-snap-slide-deck/
- `[CITED: codepen.io/lideo/pen/gOawqaW]` — 100vh sections with scroll snap.
- `[CITED: codepen.io/Chokcoco/pen/YzPPvBV]` — CSS Scroll Snap Points Full Height demo.
- `[CITED: codersblock.com/blog/fun-times-with-css-counters/]` — CSS counter patterns.
- `[CITED: webkit.org/blog/17818/announcing-interop-2026/]` — scroll-snap interop work in 2026.

### Tertiary (LOW confidence — flagged for validation)
- `[CITED: github.com/elementor/elementor/issues/29788]` — Safari scroll-snap fixed-bg quirk. Mitigation: don't use fixed backgrounds in slides (we don't).
- `[CITED: bugs.webkit.org/show_bug.cgi?id=173887]` — historical iOS Safari snap jitter under layout. Largely resolved post-2022; revalidate during the spike.
- `[CITED: discussions.apple.com/thread/256138682]` — Safari iOS 26 viewport bug (recent). Validate during iOS Safari forced-dark-mode test.

### Project-internal references (HIGH confidence — read directly)
- `/Users/sperezasis/projects/code/deshtml/.planning/PROJECT.md`
- `/Users/sperezasis/projects/code/deshtml/.planning/REQUIREMENTS.md`
- `/Users/sperezasis/projects/code/deshtml/.planning/ROADMAP.md`
- `/Users/sperezasis/projects/code/deshtml/.planning/research/PITFALLS.md`
- `/Users/sperezasis/projects/code/deshtml/.planning/phases/03-remaining-four-doc-types/03-CONTEXT.md`
- `/Users/sperezasis/projects/code/deshtml/.planning/phases/02-story-arc-gate-handbook-end-to-end/02-CONTEXT.md`
- `/Users/sperezasis/projects/code/deshtml/.planning/phases/02-story-arc-gate-handbook-end-to-end/02-SUMMARY.md`
- `/Users/sperezasis/projects/code/deshtml/.planning/phases/02-story-arc-gate-handbook-end-to-end/02-RESEARCH.md`
- `/Users/sperezasis/projects/code/deshtml/skill/SKILL.md`
- `/Users/sperezasis/projects/code/deshtml/skill/story-arc.md`
- `/Users/sperezasis/projects/code/deshtml/skill/interview/handbook.md`
- `/Users/sperezasis/projects/code/deshtml/skill/audit/run.sh`
- `/Users/sperezasis/projects/code/deshtml/skill/design/formats/handbook.html`
- `/Users/sperezasis/projects/code/deshtml/skill/design/formats/overview.html`
- `/Users/sperezasis/projects/code/deshtml/skill/design/components.html`
- `/Users/sperezasis/CLAUDE.md` §"Documentation Methodology — Story First"

---

## Metadata

**Confidence breakdown:**
- Stack confirmation (inheriting Phase 2): HIGH — verified via direct file reads
- Architecture (where new files fit): HIGH — slot vocabulary verified across handbook.html + overview.html
- Scroll-snap pattern (D3-03/04/05/06/07): HIGH — verified via caniuse, MDN, multiple CSS-Tricks references
- Presentation typography scale (D3-08): MEDIUM — derived recommendation, no Caseproof precedent
- Visual rubric for Presentation (D3-21): MEDIUM — written rubric vs. the side-by-side reference Handbook+Overview enjoy
- Audit harvester wildcard (D3-18): HIGH — bash 3.2 idiom verified against existing run.sh
- Schema-drift heuristic (Pattern 9): MEDIUM — derived recommendation, not mandated by CONTEXT.md
- Pitfalls 19/20/21: HIGH — derived from explicit CONTEXT.md decisions and Phase 2 patterns

**Research date:** 2026-04-27
**Valid until:** 2026-05-27 (30 days — scroll-snap support is stable; Safari iOS 26 viewport advisories may shift sooner)

---
*Phase: 03-remaining-four-doc-types*
*Researched: 2026-04-27 by gsd-phase-researcher*
