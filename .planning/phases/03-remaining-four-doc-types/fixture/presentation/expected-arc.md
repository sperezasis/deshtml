# Fixture: presentation — expected arc shape

Presentation has NO Caseproof reference. The visual gate IS the written
rubric below (RESEARCH §"Visual Gate for Presentation (D3-21 rubric)").

## Expected number of rows = slide count

5 rows = 5 slides. Each arc row maps to one `<section class="slide">` in
the rendered output. Slide counter shows `1 / 5` … `5 / 5` per the
`TOTAL_SLIDES_LITERAL` substitution from plan 03-01.

## Expected format auto-selection (D3-01)

Step 5b should print exactly one line:

> Format: presentation

Because: type=presentation short-circuits at rule 1. Even if the arc had
1 row or 7 rows, format=presentation always.

## Expected flowing paragraph

> Phase 3 status: all five doc types ship end-to-end. The Phase 3 audit
> extension picks up new format skeletons via wildcard glob; Rule 5
> catches schema drift across interview files. Phase 4 wires the README,
> launch hardening, and source-mode shortcut. v0.1.0 is the next tag.

Acceptable variations: any phrasing that lands the 5-beat status arc.

## Expected slide titles (handbook tone — RESEARCH §Pattern 8 presentation row)

Self-review (story-arc.md): TITLES describe what IS. Body may run more
energetic (slides reward visual punch) but TITLES are still handbook —
the arc-gate self-review enforces this regardless of doc type.

## Visual gate rubric (RESEARCH §"Visual Gate for Presentation")

### Should look like:
- Each slide fills the viewport (100vh, no scrollbar within a slide).
- Slide background is `var(--white)` — pure light, no off-white.
- H1 uses Inter at ~80px, weight 800, tracking ~-3px. Visually larger than
  any handbook H1.
- H2 (if used) at ~56px, weight 800.
- Body text at ~22px, gray (`var(--g8)`), comfortable line-length.
- Slide counter visible bottom-right, shows "current / total" (e.g., `2 / 5`)
  in muted gray.
- Floating slide-nav present top-right, reuses `.nav-a` styling from
  sidebar (Pattern 5).
- Palette identical to Handbook/Overview. NO new colors.

### Must have:
- `<meta name="color-scheme" content="light">` and
  `<meta name="supported-color-schemes" content="light">` (Pitfall 7).
- All three CSS files inlined (palette → typography → components per D2-15).
- Inter `@import` present (typography.css inlined).
- Zero `<script>` tags. Zero `on*=` handlers. Zero `javascript:` URLs.
- All classes used appear in the audit allowlist (after wildcard harvest
  from plan 03-03).

### Must not have:
- Any sidebar (D3-09 — full-viewport, no sidebar).
- Any sticky bar.
- Any custom transition or animation CSS beyond browser default snap (D3-07).
- Hex literals outside `:root`.
- Slide content overflowing 100vh.

### Browser test matrix:
- **Chrome (latest stable on macOS)**: scroll wheel scrolls one slide at a time.
  Trackpad scroll snaps. Anchor click jumps cleanly.
- **Safari (latest stable on macOS)**: same three behaviors. PRIMARY VERIFICATION.
- **iOS Safari (Simulator OK)**: forced-dark-mode test stays light. Touch-swipe
  behavior acceptable.

### Acceptable diffs:
- Different content per slide (this fixture is "Phase 3 status update").
- Slight font tracking vs Caseproof references (Inter tracks differently
  at 80px than at 56px).

### Unacceptable:
- Wrong palette color.
- Custom font (Inter only).
- Non-allowlisted class.
- Snap fails on Chrome OR Safari (= spike from plan 03-01 was wrong, OR
  plan 03-01 shipped fallback but the fallback isn't documented in
  presentation.html's header — re-check the spike-outcome line).

## What the verifier looks for

Before `approve`:
1. Five columns.
2. 5 rows.
3. `Format: presentation`.
4. Each `One sentence` reads slide-shaped (one beat per slide).

Before opening:
1. Filename matches `YYYY-MM-DD-<slug>-presentation.html`.
2. Audit exit 0 (the wildcard harvester from plan 03-03 must accept
   `.slide`, `.slide-counter`, `.slide-nav`).

In Chrome:
1. Run the should-look-like checklist top-to-bottom.
2. Scroll wheel → snaps. Trackpad fast-scroll → snaps to last slide
   without skipping.
3. Click `<a href="#slide-3">` → jumps cleanly.

In Safari:
1. Same checklist. PRIMARY signal — if Safari is broken and Chrome
   works, the spike from plan 03-01 was a false PASS; revisit.

iOS Safari forced-dark-mode:
1. File stays light.
