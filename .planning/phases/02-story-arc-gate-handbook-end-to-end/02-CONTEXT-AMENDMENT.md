# Phase 2 Context Amendment — D2-15 update

**Issued:** 2026-04-28
**By:** Phase 2 planner during plan-set authoring
**Source:** Triggered by 02-RESEARCH.md §"Open Questions → OQ-1" (component CSS gap)
**Scope:** Modifies one decision in `02-CONTEXT.md`. All other locked decisions (D2-01..D2-25 except D2-15) are unchanged.

---

## What changed

### D2-15 — File layout assembly (amended)

**Original D2-15 (in 02-CONTEXT.md):**
> SKILL.md instructs Claude to construct the output by:
> 1. Loading `skill/design/formats/handbook.html` as the skeleton.
> 2. **Inlining** the full content of `skill/design/palette.css` and `skill/design/typography.css` into a single `<style>` block in `<head>` — replacing whatever `<link>` references the skeleton uses for dev-time. **The published file MUST be self-contained** (OUTPUT-05). Closes Phase 1 code-review IN-01.
> 3. Filling each `<!-- HERO -->`, `<!-- SECTION -->`, etc. slot with content matching the approved arc, using only classes from `skill/design/components.html`.
> 4. Verifying no `<script>` tag was introduced (D-17 from Phase 1 still applies to all output).

**Amended D2-15 (effective 2026-04-28):**
> SKILL.md instructs Claude to construct the output by:
> 1. Loading `skill/design/formats/handbook.html` as the skeleton.
> 2. **Inlining** the full content of `skill/design/palette.css`, `skill/design/typography.css`, AND `skill/design/components.css` into a single `<style>` block in `<head>` — replacing whatever `<link>` references the skeleton uses for dev-time. The inlining order is **palette → typography → components** (load-bearing: palette defines `:root` tokens first; typography owns body/h1/h2/h3 second; components cascade last). **The published file MUST be self-contained** (OUTPUT-05). Closes Phase 1 code-review IN-01.
> 3. Filling each `<!-- HERO -->`, `<!-- SECTION -->`, etc. slot with content matching the approved arc, using only classes from `skill/design/components.html` (markup allowlist) AND the type-scale labels from `skill/design/typography.css`.
> 4. Verifying no `<script>` tag was introduced (D-17 from Phase 1 still applies to all output).

---

## Why

02-RESEARCH.md surfaced (HIGH-impact gap, OQ-1) that **`skill/design/components.css` does not exist**. Phase 1 shipped:

- `skill/design/palette.css` — `:root` color tokens.
- `skill/design/typography.css` — Inter @import + type scale (8 scale labels).
- `skill/design/components.html` — markup allowlist (75+ class names with one canonical example each).

But the **CSS rules** for those 75+ classes (`.tag`, `.ic`, `.tip`, `.hl`, `.cmp`, `.flow`, `.donut`, `.sidebar`, `.hero`, etc.) live ONLY inside `skill/design/references/pm-system.reference.html` — a 1,726-line read-only ground-truth reference, not a paste source.

D2-15 (original) said to inline two CSS files. That was sufficient for color tokens and typography but left every component class **unstyled**. Without component CSS, generated handbooks would have correct palette + correct font + correct hero scale, but `.sidebar` would render as a plain `<aside>`, `.tag` would render as a plain `<span>`, `.cmp` would render as a plain `<div>`, etc. Visual fidelity to `pm-system.html` (D2-23) would be impossible.

02-RESEARCH §"Open Questions → OQ-1" recommended **Option (a) — strong recommendation:** create `skill/design/components.css` as a Phase 2 task by extracting the relevant component CSS from `pm-system.reference.html`. This becomes a third inlining target. The audit class allowlist gains a third source.

This amendment makes that recommendation a locked decision.

---

## Downstream consequences (already reflected in plans)

### Plan 02-01 (Wave 1) — components.css extraction
Closes the gap. Extracts the `<style>` block from `skill/design/references/pm-system.reference.html` (lines 7-697) into `skill/design/components.css` with three de-duplication deletions (`@import`, `:root`, `body` — owned elsewhere) and one documented deviation (`#3a3a3c → var(--g9)` for the `.sb-div` divider). Updates `skill/design/SYSTEM.md` Rule 6 to mandate the three-file inlining contract.

### Plan 02-02 (Wave 1) — SKILL.md flow
Step 6 ("Render the handbook HTML") instructs Claude to read FIVE files (skeleton + three CSS files + components.html) and inline the three CSS files in palette → typography → components order.

### Plan 02-03 (Wave 1) — audit
Audit's class-allowlist harvest already covers `components.html` (markup) + `typography.css` (type-scale labels). It does NOT need to harvest from `components.css` — the markup allowlist in `components.html` is the source of truth for "what classes are allowed in output," and `components.css` provides the styling for those allowed classes. The audit's class allowlist remains a two-source harvest.

### Plan 02-04 (Wave 2) — visual gate
The fixture run validates the three-file inlining produced output that visually matches `pm-system.html`. If `components.css` is missing rules that `pm-system.html` had inline, the visual diff catches it.

---

## What was NOT changed

All other Phase 2 decisions (D2-01, D2-02, D2-03, D2-04, D2-05, D2-06, D2-07, D2-08, D2-09, D2-10, D2-11, D2-12, D2-13, D2-14, D2-16, D2-17, D2-18, D2-19, D2-20, D2-21, D2-22, D2-23, D2-24, D2-25) remain in force exactly as written in `02-CONTEXT.md`. The Deferred Ideas list is unchanged. Claude's Discretion items are unchanged.

The `01-CONTEXT.md` decisions (D-01..D-19 from Phase 1) are unchanged. D-14 (verbatim discipline) is what makes this amendment safe — components.css is a verbatim extraction from a verbatim Phase-1 reference; no design-system drift introduced.

---

## How downstream agents should treat this file

1. **Read `02-CONTEXT.md` first.** It is still the source of truth for D2-01..D2-25 minus D2-15.
2. **Read this amendment second** to learn the actual D2-15 (three CSS files, palette → typography → components order, audit allowlist still two-source).
3. **Treat the amended D2-15 as locked.** Do not revisit. Do not silently revert to the original two-CSS-file form.
4. If a future amendment is issued, it will be appended here as `## D2-XX update — <date>` so the chain is traceable.

---

*Amendment effective: 2026-04-28*
*Phase: 02-story-arc-gate-handbook-end-to-end*
