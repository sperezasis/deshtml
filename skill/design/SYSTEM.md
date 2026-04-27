# Caseproof Documentation System — Skill Index

Phase 2's `SKILL.md` reads from this directory. This file is the table of contents.

All values, classes, and markup in `skill/design/` are verbatim extractions from `~/work/caseproof/DOCUMENTATION-SYSTEM.md` and the two reference implementations under `references/`. **Do not paraphrase. Do not invent. If something is missing, grep `references/`.**

## Tokens

| File | Contains | When SKILL.md loads it |
|------|----------|-------------------------|
| `palette.css` | All Caseproof colors as `:root` CSS variables, plus `color-scheme: light`. | At HTML-assembly time, after the arc is approved. Inlined into the output's `<style>` block. |
| `typography.css` | Inter `@import`, system-font fallback chain, type scale rules for `body`, `h1`, `h2`, `h3`, `.s-lead`, `.eye`, `.cl`, `.fl`, `.ct`, `.cd`, `.ic`, `.fn`. | Same as palette.css — inlined alongside it. |

## Components

| File | Contains | When SKILL.md loads it |
|------|----------|-------------------------|
| `components.html` | The closed allowlist of approved component classes (16 components, in source order from DOCUMENTATION-SYSTEM.md). One canonical example per component. | Read at HTML-assembly time to pick the right markup for each section. Phase 2's audit pass treats every class here as the source of truth — any class in generated output not present in this file is a violation. |

## Format Skeletons

| File | Contains | When SKILL.md loads it |
|------|----------|-------------------------|
| `formats/handbook.html` | Handbook 960px-sidebar skeleton with slot comments (HERO, SIDEBAR, STICKY BAR, SECTION 1..N, FLOATING PILL). | Loaded when format is Handbook (4+ sections). Skeleton is filled in, not regenerated. |
| `formats/overview.html` | Overview 1440px-linear skeleton with slot comments (HERO, SECTION 1..N). | Loaded when format is Overview (1-3 sections). |

Both skeletons declare `color-scheme: light` (via `palette.css`) AND `<meta name="color-scheme" content="light">` AND `<meta name="supported-color-schemes" content="light">`. This combination prevents iOS Safari, Android Chrome forced-dark-mode, and other auto-inversion behavior from breaking the design (DESIGN-07, PITFALLS Pitfall 7).

Both skeletons contain ZERO `<script>` tags and ZERO inline JS. Self-contained constraint.

## References (read-only ground truth)

| File | Contains | Use |
|------|----------|-----|
| `references/pm-system.reference.html` | Verbatim copy of the canonical Caseproof Handbook implementation. | Phase 2 greps this when a component is missing or unclear. **Never pasted from directly into output** — `components.html` and the format skeletons are the paste sources. |
| `references/bnp-overview.reference.html` | Verbatim copy of the canonical Caseproof Overview implementation. | Same role for Overview format. |

## Rules Phase 2 must respect

1. Hex literals only inside `palette.css`. Generated HTML uses `var(--token-name)` everywhere else (DESIGN-01).
2. Class names in generated output must appear in `components.html` (DESIGN-03).
3. Both format skeletons keep their meta tags + `color-scheme: light` (DESIGN-07).
4. No `<script>` tags in generated output (D-17).
5. Verbatim discipline (D-14): copy from this directory, do not paraphrase.
6. **Inline palette + typography at paste time.** The format skeletons (`formats/handbook.html`, `formats/overview.html`) currently load CSS via `<link rel="stylesheet" href="../palette.css">` and `<link rel="stylesheet" href="../typography.css">`. The end-product must be a single self-contained HTML file (PROJECT.md "Constraints" — no asset folders). Phase 2 MUST replace those two `<link>` tags with `<style>...</style>` blocks containing the verbatim contents of `palette.css` and `typography.css`. Phase 2's audit pass MUST grep the generated output for zero `<link rel="stylesheet"` occurrences (acceptance check).
