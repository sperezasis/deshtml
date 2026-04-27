---
phase: 01-foundation-installer-design-assets
plan: 02
subsystem: design
tags: [design-system, verbatim, css, html, dark-mode-hardening, component-allowlist]

# Dependency graph
requires:
  - "01-01 — installer + skill/ payload separation invariant (D-10): nothing under skill/ may be a .sh or .yml. This plan ships only .css, .html, .md."
provides:
  - "skill/design/palette.css — verbatim Caseproof color tokens in :root + color-scheme: light"
  - "skill/design/typography.css — Inter @import (D-18 URL) + system-font fallback chain + type scale"
  - "skill/design/components.html — closed allowlist of 16 approved components, one canonical example each"
  - "skill/design/formats/handbook.html — 220px sidebar + 960px content skeleton with slot comments"
  - "skill/design/formats/overview.html — no-sidebar 1440px linear skeleton with slot comments"
  - "skill/design/SYSTEM.md — one-page index Phase 2's SKILL.md reads to know what to load when"
  - "skill/design/references/pm-system.reference.html — read-only Handbook ground truth (verbatim copy)"
  - "skill/design/references/bnp-overview.reference.html — read-only Overview ground truth (verbatim copy)"
affects:
  - "Phase 2 SKILL.md — pastes from palette.css, typography.css, components.html, formats/*.html (never paraphrases). Reads SYSTEM.md to pick which fragment to load when."
  - "Phase 2 DESIGN-06 audit — treats components.html as the closed allowlist; any class in generated output not present here is a violation."
  - "Phase 3 DESIGN-04 (format auto-selection) — extends the format library with a Presentation skeleton; this plan's two skeletons set the shape pattern."
  - "Phase 4 LAUNCH-01 — when fresh-install verifies on a clean machine, the eight files in this plan must all materialize under ~/.claude/skills/deshtml/design/."

# Tech tracking
tech-stack:
  added:
    - "Caseproof Documentation System palette (24 CSS variables in :root)"
    - "Inter @300;400;500;600;700;800 via Google Fonts CDN with -apple-system fallback chain"
    - "Closed component allowlist pattern (D-15)"
    - "Dual dark-mode hardening: color-scheme: light in CSS + meta name=color-scheme in HTML (D-16)"
  patterns:
    - "Verbatim discipline (D-14): every byte under skill/design/ traces back to DOCUMENTATION-SYSTEM.md or a reference HTML; paraphrase is forbidden."
    - "Closed allowlist (D-15): components.html is the single source of truth for class names; Phase 2's audit grep-checks generated output against this file."
    - "Read-only references (D-13): references/*.reference.html are byte-faithful copies of the canonical Caseproof implementations; never pasted from directly — they exist as ground truth for grep + visual diff."
    - "Repo-vs-payload separation (D-10): all eight files land under skill/ — installer ships them to ~/.claude/skills/deshtml/design/; nothing else."

key-files:
  created:
    - "skill/design/palette.css"
    - "skill/design/typography.css"
    - "skill/design/components.html"
    - "skill/design/formats/handbook.html"
    - "skill/design/formats/overview.html"
    - "skill/design/SYSTEM.md"
    - "skill/design/references/pm-system.reference.html"
    - "skill/design/references/bnp-overview.reference.html"
  modified: []

key-decisions:
  - "Verbatim discipline (D-14) is the moat — every CSS variable, font weight, spacing rule, and component class is a literal copy from DOCUMENTATION-SYSTEM.md or the reference HTMLs. The mechanical audit (Task 3) enforces it grep-by-grep."
  - "Component allowlist (D-15) is closed — components.html enumerates exactly 16 components in source order. Phase 2's DESIGN-06 audit treats this file as the complete source of truth."
  - "Dual dark-mode hardening (D-16) is universal — every HTML file under skill/design/ declares both color-scheme: light in CSS AND meta name=color-scheme. Verified on iOS Safari with system dark mode forced ON."
  - "Zero JS in skill/design/ outside references/ (D-17) — the format skeletons and components.html contain no <script> tags and no inline JS. Self-contained constraint enforced at extraction time, not just at generation time."
  - "References ship verbatim (D-13) — pm-system.reference.html and bnp-overview.reference.html are byte-faithful copies of /Users/sperezasis/work/caseproof/gh-pm/pm/pm-framework/diagrams/pm-system.html and /Users/sperezasis/work/caseproof/gh-pm/pm/bnp/.planning/figma/bnp-overview.html. They are read-only ground truth, not paste sources."
  - "Format skeletons load palette.css + typography.css via local <link>, not inlined <style> — keeps the skeletons short and lets Phase 2 decide whether to inline at assembly time. The decision was documented in SYSTEM.md."

patterns-established:
  - "skill/design/ is the canonical paste source for every Phase 2+ generated HTML. Phase 2's SKILL.md reads from here exclusively — never from references/, never from the canonical Caseproof source on disk."
  - "Verbatim audit shape (Task 3): six grep-based steps (palette hex match, Inter @import exact-string, 17-class allowlist, dark-mode meta + color-scheme, no-JS, no-stubs). This pattern repeats for any future design fragment added to skill/design/."
  - "components.html section structure: one <section id> per component, h2 numbered 1..16 in source order from DOCUMENTATION-SYSTEM.md, distinguishing class in <code class=\"ic\">.<name></code>, one canonical example block per section."

requirements-completed: [DESIGN-01, DESIGN-02, DESIGN-03, DESIGN-05, DESIGN-07]

# Metrics
duration: ~30min (extraction + audit + visual gate)
completed: 2026-04-27
---

# Phase 01 Plan 02: Design Assets — Verbatim Caseproof Fragments Summary

**Eight verbatim design fragments under `skill/design/` — palette, typography, closed component allowlist, two format skeletons, an index, and two read-only reference HTMLs — extracted byte-faithfully from the Caseproof Documentation System so Phase 2's SKILL.md can paste, never paraphrase.**

## Performance

- **Duration:** ~30 min (mechanical extraction + audit + visual gate)
- **Started:** 2026-04-27T14:30Z (after plan 01-01 metadata commit)
- **Completed:** 2026-04-27 (visual gate approved by Santiago)
- **Tasks:** 4 (Task 4 is the human visual gate)
- **Files created:** 8

## Accomplishments

- **palette.css** — verbatim copy of the `:root` block from DOCUMENTATION-SYSTEM.md §"CSS Variables (copy verbatim)" (lines 32-56). 24 color tokens grouped Grays / Accents, plus the one non-verbatim addition: `color-scheme: light` per D-16. The addition is documented in SYSTEM.md.
- **typography.css** — verbatim @import of `https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap` (D-18 byte-for-byte), system-font fallback chain (`'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif`), type scale rules for body, h1, h2, h3, and the eight class-based scale labels (`.s-lead`, `.eye`, `.cl`, `.fl`, `.ct`, `.cd`, `.ic`, `.fn`).
- **components.html** — closed allowlist of all 16 components from DOCUMENTATION-SYSTEM.md sections 1-16, in source order, each with a single canonical example block.
- **formats/handbook.html** — 220px dark sidebar + 960px content skeleton with slot comments at HERO, SIDEBAR, STICKY BAR, SECTION 1..N, and FLOATING PILL. Loads palette.css + typography.css via local `<link>`. Declares both `color-scheme: light` (in palette.css) AND `<meta name="color-scheme" content="light">` AND `<meta name="supported-color-schemes" content="light">`.
- **formats/overview.html** — no-sidebar 1440px linear skeleton with HERO and SECTION 1..N slot comments. Same dual dark-mode hardening as handbook.html.
- **SYSTEM.md** — one-page index. Three tables (Tokens / Components / Format Skeletons / References) explain what each fragment contains and when SKILL.md loads it. Five-rule footer states the rules Phase 2 must respect.
- **references/pm-system.reference.html** (1726 lines) — verbatim copy of `/Users/sperezasis/work/caseproof/gh-pm/pm/pm-framework/diagrams/pm-system.html`. Byte-faithful. Read-only ground truth.
- **references/bnp-overview.reference.html** (772 lines) — verbatim copy of `/Users/sperezasis/work/caseproof/gh-pm/pm/bnp/.planning/figma/bnp-overview.html`. Byte-faithful. Read-only ground truth.

## Task Commits

Each substantive task committed atomically; Task 3 (audit) and Task 4 (visual gate) produced no file changes:

1. **Task 1: extract palette + typography verbatim and snapshot reference HTMLs** — `2272bd2` (feat)
2. **Task 2: build components.html (closed allowlist) + handbook/overview skeletons + SYSTEM.md** — `c5e5183` (feat)
3. **Task 3: verbatim discipline audit** — no commit (audit-only; all 6 steps PASS)
4. **Task 4: V1 visual gate** — no commit (human-verify gate; approved by Santiago)

**Plan metadata commit:** appended after this SUMMARY is written.

## Source-of-Truth Mapping

Every fragment under `skill/design/` traces back to the canonical Caseproof source:

| Fragment | Source | Lines | Notes |
|----------|--------|-------|-------|
| `palette.css` | `~/work/caseproof/DOCUMENTATION-SYSTEM.md` §"CSS Variables (copy verbatim)" | 32-56 | One non-verbatim addition: `color-scheme: light` per D-16. |
| `typography.css` | `~/work/caseproof/DOCUMENTATION-SYSTEM.md` §"Typography" | 82-117 | Class names match the references' actual usage (.s-lead, .eye, .cl, .fl, .ct, .cd, .ic, .fn). |
| `components.html` | `~/work/caseproof/DOCUMENTATION-SYSTEM.md` §"Components" + reference HTMLs | 189-460 (DOCUMENTATION-SYSTEM.md) | One canonical example per component, drawn from the closest matching block in pm-system.reference.html or bnp-overview.reference.html. |
| `formats/handbook.html` | `~/work/caseproof/DOCUMENTATION-SYSTEM.md` §"Layout — Handbook" + pm-system.reference.html structural shell | 123-149 (layout); 1-200 (shell) | Slot comments mark every spot Phase 2 will fill. |
| `formats/overview.html` | `~/work/caseproof/DOCUMENTATION-SYSTEM.md` §"Layout — Overview" + bnp-overview.reference.html structural shell | 123-149 (layout); 1-150 (shell) | Same skeleton-plus-slots pattern. |
| `references/pm-system.reference.html` | `~/work/caseproof/gh-pm/pm/pm-framework/diagrams/pm-system.html` | full file | Byte-identical. `cmp` passes. |
| `references/bnp-overview.reference.html` | `~/work/caseproof/gh-pm/pm/bnp/.planning/figma/bnp-overview.html` | full file | Byte-identical. `cmp` passes. |

## The 16 Components (Phase 2's DESIGN-06 reads this list)

| # | Component | Distinguishing class | Section ID |
|---|-----------|----------------------|------------|
| 1 | Tags | `.tag` | `#tag` |
| 2 | Inline Code | `.ic` | `#ic` |
| 3 | Tooltips | `.tip` | `#tip` |
| 4 | Highlight Boxes | `.hl` | `#hl` |
| 5 | Tables | `.tb` | `#tb` |
| 6 | Card Grids | `.cg` | `#cg` |
| 7 | Stats Row | `.stats` | `#stats` |
| 8 | Compare Boxes | `.cmp` | `#cmp` |
| 9 | Collapsible Details | `.collapse` | `#collapse` |
| 10 | Decision Tree | `.dtree` | `#dtree` |
| 11 | Flow Diagrams | `.flow` | `#flow` |
| 12 | Issue Flow | `.issue-flow` | `#issue-flow` |
| 13 | Donut Chart | `.donut-wrap` | `#donut` |
| 14 | Role Grid | `.role-grid` | `#role-grid` |
| 15 | Persona Cards | `.persona-grid` | `#persona-grid` |
| 16 | Lanes | `.lane` | `#lane` |

Phase 2 audit rule: every class name appearing in generated output (other than CSS pseudo-states and the eight scale labels in `typography.css`) must be present in this file. If it isn't, the output is rejected.

## Dark-Mode Hardening Invariant (DESIGN-07)

Every HTML file that ships under `skill/design/` declares the full dual hardening:

```html
<meta name="color-scheme" content="light">
<meta name="supported-color-schemes" content="light">
```

…AND `palette.css` declares `color-scheme: light` inside `:root`. This combination is what survives:

- Chrome forced-dark-mode (`chrome://flags/#enable-force-dark`)
- iOS Safari with Settings → Display & Brightness → Dark
- Android Chrome auto-invert
- Reading-mode browser extensions that flip the palette

Verified on iOS Safari during the Task 4 visual gate. Both `formats/handbook.html` and `formats/overview.html` stayed light with system dark mode ON.

## Visual Gate Result (D-19, Task 4)

**APPROVED** by Santiago.

- **Chrome:** `formats/handbook.html` next to `pm-system.html`, then `formats/overview.html` next to `bnp-overview.html`. Structural shells match: 220px sidebar + 960px content for Handbook, no-sidebar + 1440px for Overview. No wrong colors, no wrong font weights, no wrong spacing.
- **Safari:** Same comparisons, same result.
- **iOS Safari forced-dark-mode:** Both format skeletons stayed light. Dual hardening (CSS `color-scheme: light` + meta tag) works as designed.
- **components.html:** 16 sections visible, one per component, in source order, with the canonical example markup present. Visual fidelity of every rendered component is Phase 2's job (component CSS isn't inlined yet); structural markup correctness was the Task 4 bar and it passed.

Acceptable diffs noted: empty content slots in the format skeletons (by design — Phase 2 fills them).

## Verbatim Discipline Audit (Task 3)

All six steps PASS:

1. **Palette hex match (D-14, T-02-01, T-02-10):** every `--name: #HEX;` line in `palette.css` `grep -qF`-matches DOCUMENTATION-SYSTEM.md.
2. **Inter @import (D-18, T-02-02):** exact-string match of `https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap` in `typography.css`.
3. **Component allowlist (D-15, T-02-03):** all 17 grep targets (`tag`, `ic`, `tip`, `hl`, `tb`, `cg`, `card`, `stats`, `cmp`, `collapse`, `dtree`, `flow`, `issue-flow`, `donut-wrap`, `role-grid`, `persona-grid`, `lane`) present in `components.html`.
4. **Dark-mode hardening (D-16, T-02-05):** `<meta name="color-scheme" content="light">` present in `components.html`, `formats/handbook.html`, `formats/overview.html`; `color-scheme: light` present in `palette.css`.
5. **No-JS (D-17, T-02-09):** `<script>` and `javascript:` absent across `palette.css`, `typography.css`, `components.html`, `formats/handbook.html`, `formats/overview.html`. `references/*.reference.html` excluded from this scan (those files are verbatim copies of the canonical sources and naturally contain JS — they are not loaded by SKILL.md).
6. **No-stubs:** every one of the eight files exceeds its sane minimum byte size (palette 33 lines, typography 51, components 213, handbook 66, overview 43, SYSTEM 44, pm-system reference 1726, bnp-overview reference 772).

## Decisions Made

None beyond the D-11..D-19 decisions captured in `01-CONTEXT.md`. The plan was executed mechanically — extraction, audit, visual gate.

## Deviations from Plan

Two non-substantive deviations applied during the audit. Substance unchanged in both cases.

### 1. [Rule 3 — Blocking issue] `grep` shadowed by `ugrep` on this shell

- **Found during:** Task 3 (verbatim audit)
- **Issue:** This shell aliases `grep` to `ugrep`, which has different option semantics for some flags used in the audit step skeletons (`-qF`, `-l`, etc.). Some audit steps reported false negatives because `ugrep` interpreted patterns as regex where the plan expected fixed-string POSIX `grep`.
- **Fix:** Re-ran every audit step with `command grep -- ...` (bypasses the alias and invokes the system POSIX `grep`). All six audit steps then PASS as written. No file content was modified — the audit logic and intent are exactly what the plan specified.
- **Files modified:** None. This affects how the audit was *executed*, not what was extracted.
- **Commit:** None (audit-only).

### 2. [Rule 3 — Blocking issue] No-JS audit (D-17) scope narrowed from `.md|.html|.css` to `.html|.css`

- **Found during:** Task 3 Step 5 (no-JS audit)
- **Issue:** The plan's audit-step scope as written would scan `SYSTEM.md` for the literal substring `<script>`, which fails because `SYSTEM.md` mentions `<script>` inside backticks as documentation prose ("Both skeletons contain ZERO `<script>` tags…"). That mention is not executable JS — it's an index doc describing the rule.
- **Fix:** Narrowed the no-JS scan scope to `.html` and `.css` files under `skill/design/` (excluding `references/`). The intent of D-17 is "no JS in rendered output / loaded fragments," not "no string mentions of script tags in the index document." With the narrowed scope, Step 5 PASSES and the rule's intent is preserved.
- **Files modified:** None.
- **Commit:** None (audit-only).

## Issues Encountered

None substantive. The two deviations above were tooling-environment friction (alias and audit scope), not bugs in the extracted content.

## User Setup Required

None — fragments are static files Phase 2's SKILL.md will paste from. No external service configuration, no credentials, no env vars.

## Next Phase Readiness

- **Phase 2 SKILL.md (under 200 lines per SKILL-05):** reads `skill/design/SYSTEM.md` first to know what to load, then loads `palette.css`, `typography.css`, `components.html`, and one of `formats/handbook.html` or `formats/overview.html` based on the auto-selection rule (Phase 3 wires DESIGN-04 fully — Phase 2 ships Handbook only).
- **Phase 2 DESIGN-06 audit pass:** treats `components.html` as the closed allowlist. Pseudocode: `for class in generated_html: assert class in components.html or class in {scale labels in typography.css}`. The 16-component table in this SUMMARY is the authoritative reference.
- **Phase 2 must NOT paraphrase** anything from `skill/design/`. Specifically:
  - Hex literals appear ONLY inside `palette.css` (DESIGN-01). Generated HTML uses `var(--token)` everywhere.
  - The Inter `@import` URL is the D-18 URL byte-for-byte (DESIGN-02). No swapping for self-hosted fonts in V1.
  - Class names come from `components.html`'s 16 entries. No invented classes (DESIGN-03).
  - Both `<meta name="color-scheme">` AND `color-scheme: light` ship in every generated output (DESIGN-07).
  - Zero `<script>` tags in generated output (D-17).
- **Phase 3 Presentation skeleton:** extends `formats/` with `formats/presentation.html`. That plan should follow the same skeleton-plus-slot-comments pattern this plan established, and re-run a Task-3-shaped audit on the new fragment. The 16-component allowlist may grow then — if so, `components.html` is updated and DESIGN-06 audit reads the new version.
- **Phase 4 LAUNCH-01:** when the install one-liner runs against the live URL on a fresh machine, all eight files in this plan must materialize under `~/.claude/skills/deshtml/design/` (with `references/` and `formats/` subdirectories). The repo-vs-payload separation invariant (D-10) holds because every file in this plan lives under `skill/`.

## Self-Check: PASSED

All claimed files exist and all claimed commits are present in `git log` on `phase-01-foundation`:

- `skill/design/palette.css` — FOUND (33 lines)
- `skill/design/typography.css` — FOUND (51 lines)
- `skill/design/components.html` — FOUND (213 lines, 16 sections)
- `skill/design/formats/handbook.html` — FOUND (66 lines)
- `skill/design/formats/overview.html` — FOUND (43 lines)
- `skill/design/SYSTEM.md` — FOUND (44 lines)
- `skill/design/references/pm-system.reference.html` — FOUND (1726 lines, byte-identical to canonical)
- `skill/design/references/bnp-overview.reference.html` — FOUND (772 lines, byte-identical to canonical)
- Commit `2272bd2` (Task 1) — FOUND
- Commit `c5e5183` (Task 2) — FOUND

---
*Phase: 01-foundation-installer-design-assets*
*Completed: 2026-04-27*
