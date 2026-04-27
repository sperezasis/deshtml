---
phase: 02-story-arc-gate-handbook-end-to-end
plan: 01
subsystem: design-assets
tags: [css, design-system, components, palette, verbatim-extraction, audit-prep]

# Dependency graph
requires:
  - phase: 01-foundation-installer-design-assets
    provides: skill/design/palette.css, skill/design/typography.css, skill/design/components.html, skill/design/references/pm-system.reference.html, skill/design/SYSTEM.md
provides:
  - skill/design/components.css (verbatim component CSS — sidebar, hero, sticky-bar, layout, section grid, 16 component families)
  - palette.css extension — sidebar sub-palette tokens (--sb-hover, --sb-group, --sb-nav, --sb-nav-hover) and darker accent tokens (--blue-d, --green-d, --red-d, --orange-d, --purple-d, --teal-d)
  - SYSTEM.md three-file inlining contract (palette → typography → components, in that order)
affects: [02-02-plan, 02-03-plan, 02-04-plan, phase-03-other-doc-types]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Three-file CSS inlining contract — output writer must inline palette.css, typography.css, components.css into a single <style> block, in that order"
    - "Closed token layer — every color literal in component CSS resolves via var(--token); no hex outside :root in any inlined block"
    - "Verbatim discipline (D-14) preserved at rule-shape and selector level even when color-literal tokenization is applied; selector text and rule order are byte-for-byte from source"

key-files:
  created:
    - "skill/design/components.css (694 lines, verbatim from pm-system.reference.html lines 7-697 minus three de-duplication deletions)"
  modified:
    - "skill/design/palette.css (extended with sidebar sub-palette and darker accent variants — Rule 2 deviation)"
    - "skill/design/SYSTEM.md (added components.css row to Tokens table; rewrote Rule 6 to mandate the three-file inlining contract)"

key-decisions:
  - "components.css is a verbatim extraction of pm-system.reference.html lines 7-697 with three de-duplication deletions (@import, :root, body) and sixteen color-literal tokenizations"
  - "Plan's stated single deviation (#3a3a3c → var(--g9)) was rejected: --g9 is too bright (#525256) against the #2C2C2E sidebar background; introduced --sb-hover token instead"
  - "Extended palette.css with sidebar sub-palette and darker accent tokens (Rule 2 deviation) because the audit (D2-19) regex would fail every generated handbook on the reference's stray hex literals; both groups are documented in upstream DOCUMENTATION-SYSTEM.md and were simply not split out as :root variables in Phase 1"
  - "Three-file inlining order is locked: palette → typography → components. Order is load-bearing (tokens must resolve before typography or components reference them; component overrides cascade after the type scale)"

patterns-established:
  - "Token-completion pattern: when verbatim source uses inline hex literals, the executor extends palette.css with documented tokens (from upstream DOCUMENTATION-SYSTEM.md) rather than approximating with closest-neighbor mapping. Preserves color fidelity AND audit gate."
  - "Header-comment hex-avoidance: file-level comments in inlined CSS files cannot reference hex literals (the audit's #[0-9a-fA-F]{3,8} regex matches anywhere in the file). Document conversions abstractly in the file header; full per-line mapping lives in SUMMARY.md."

requirements-completed: [DESIGN-06]

# Metrics
duration: ~1h
completed: 2026-04-27
---

# Phase 02 Plan 01: components.css Extraction Summary

**Verbatim component CSS now lives in `skill/design/components.css` (694 lines, zero hex literals, zero @import statements, sidebar + hero + sticky-bar + 16 component families intact) and palette.css is extended with the documented sidebar sub-palette + darker accent tokens so the three-file inlining contract is feasible.**

## Performance

- **Duration:** ~1h (initial planning + extraction + tokenization + verification)
- **Started:** 2026-04-27 (this session)
- **Completed:** 2026-04-27T22:18:20Z
- **Tasks:** 2
- **Files modified:** 3 (one created, two updated)

## Accomplishments

- `skill/design/components.css` exists with the full verbatim component CSS from `pm-system.reference.html` lines 7-697, minus three de-duplication deletions (`@import` line 8, `:root` lines 13-33, `body` lines 35-40) — those three rules are owned by `palette.css` (`:root`) and `typography.css` (`@import`, `body`).
- 16 color-literal usages converted to palette tokens. The conversions are mechanical (selector text and rule order are byte-for-byte preserved); only the right-hand side of color declarations changed.
- `skill/design/palette.css` extended with ten new tokens that the upstream design system already documents: `--blue-d`, `--green-d`, `--red-d`, `--orange-d`, `--purple-d`, `--teal-d` (tag text on tinted backgrounds) and `--sb-hover`, `--sb-group`, `--sb-nav`, `--sb-nav-hover` (sidebar sub-palette).
- `skill/design/SYSTEM.md` updated: third row added to Tokens table for `components.css`; Rule 6 rewritten to mandate the three-file inlining order palette → typography → components.
- Plan's automated verification gate passes: 694 lines (within 600-720), zero `@import`, zero `:root`, zero `body { ... }`, zero hex literals, all required selectors present (`.sidebar`, `.tag`, `.cmp`, `.hl`, `.flow`), file header contains required strings.
- SYSTEM.md's automated verification gate passes: components.css row present, references pm-system.reference.html, mentions all three CSS files in load order, all Phase-1 rows preserved.

## Task Commits

1. **Task 1: Extract components.css verbatim from pm-system.reference.html** — `d7a85e4` (feat)
2. **Task 2: Update SYSTEM.md to document components.css and the three-file inlining contract** — `6d0c3f2` (docs)

## Files Created/Modified

- `skill/design/components.css` (created, 694 lines) — Verbatim component CSS from pm-system.reference.html. Sidebar, hero, sticky-bar, layout, section grid, and 16 component families (`.tag`, `.cmp`, `.hl`, `.flow`, `.donut`, `.dtree`, `.dstep`, `.tip`, `.ic`, `.fn`, `.role-card`, `.lane`, `.persona`, `.if-box`, `.show`, `.tb`, plus utilities). Every color is `var(--token)`.
- `skill/design/palette.css` (modified) — Extended with the sidebar sub-palette tokens and darker accent variants. Header note documents the Phase 2 extension and the rationale.
- `skill/design/SYSTEM.md` (modified) — Added `components.css` row to the Tokens table (third row, after `typography.css`). Replaced Rule 6 with the three-file inlining contract that mandates palette → typography → components order.

## Decisions Made

1. **Plan's `#3a3a3c → var(--g9)` mapping rejected.** The plan claimed only one stray hex literal in the reference, with `var(--g9)` (`#525256`) as the closest neighbor for `.sb-div`. In practice the reference contains seventeen hex usages outside `:root`, and `--g9` is meaningfully brighter than `#3a3a3c` against the `#2C2C2E` sidebar — the sidebar divider would visibly lift. Introduced a dedicated `--sb-hover` token instead.
2. **palette.css extended rather than rgba()-approximation or token re-mapping.** Both new groups (sidebar sub-palette, darker accent variants) are documented in `~/work/caseproof/DOCUMENTATION-SYSTEM.md` — they are part of the design system, just not yet extracted as variables in Phase 1. Adding them is a single-source-of-truth completion, not invention.
3. **Header-comment hex literals avoided.** The verify gate's `! grep -nE '#[0-9a-fA-F]{3,8}'` matches anywhere in the file, including comments. The detailed per-line mapping (`#3a3a3c → var(--sb-hover)`, etc.) lives in this SUMMARY rather than in components.css's header. components.css's header lists conversions abstractly ("sidebar grays → var(--sb-*)") so the audit grep is satisfied.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing Critical] Plan undercounted hex literals; palette.css extended with documented tokens**
- **Found during:** Task 1 (components.css extraction, Step 4 verify-zero-hex check)
- **Issue:** The plan stated only one hex literal (`#3a3a3c` on line 58) needed conversion. In reality `pm-system.reference.html` contains seventeen hex usages outside `:root`: `#3a3a3c` (lines 58, 72), `#636366` (lines 63, 75, 81), `#8e8e93` (line 69), `#c7c7cc` (line 72), `#3B7AE0`, `#4A9B6E`, `#C46B5A`, `#C49340`, `#7C5FCC`, `#3D8A79` (lines 245-251 + 310 — tag text + dstep.wild), and `#fff` (lines 547, 664, 665). Without conversion, the audit (D2-19) would fail every generated handbook because it greps `#[0-9a-fA-F]{3,8}` outside the stripped `:root` block.
- **Fix:** Extended `skill/design/palette.css` with two new token groups, both documented in upstream `~/work/caseproof/DOCUMENTATION-SYSTEM.md`:
  - **Sidebar sub-palette:** `--sb-hover: #3a3a3c`, `--sb-group: #636366`, `--sb-nav: #8e8e93`, `--sb-nav-hover: #c7c7cc`. Documented at DOCUMENTATION-SYSTEM.md line 78 ("Sidebar uses its own dark sub-palette").
  - **Darker accent variants:** `--blue-d: #3B7AE0`, `--green-d: #4A9B6E`, `--red-d: #C46B5A`, `--orange-d: #C49340`, `--purple-d: #7C5FCC`, `--teal-d: #3D8A79`. Documented at DOCUMENTATION-SYSTEM.md lines 61-71 ("Tags use darker versions of the accent for text").
  - Pure-white `#fff` shorthands converted to `var(--white)`.
- **Files modified:** `skill/design/palette.css` (extended), `skill/design/components.css` (every conversion uses `var(--token)`).
- **Verification:** `command grep -nE '#[0-9a-fA-F]{3,8}' skill/design/components.css` returns nothing; the plan's automated gate now passes.
- **Committed in:** `d7a85e4` (Task 1 commit — palette.css extension and components.css extraction were a single logical change).

**Per-line conversion table (full audit trail):**

| Source line | Source rule | Source value | Replacement |
|------------|-------------|--------------|-------------|
| 58 | `.sb-div { background: ... }` | `#3a3a3c` | `var(--sb-hover)` |
| 63 | `.sb-group { color: ... }` | `#636366` | `var(--sb-group)` |
| 69 | `.nav-a { color: ... }` | `#8e8e93` | `var(--sb-nav)` |
| 72 | `.nav-a:hover { background: ... }` | `#3a3a3c` | `var(--sb-hover)` |
| 72 | `.nav-a:hover { color: ... }` | `#c7c7cc` | `var(--sb-nav-hover)` |
| 75 | `.nav-n { color: ... }` | `#636366` | `var(--sb-group)` |
| 81 | `.sb-foot { color: ... }` | `#636366` | `var(--sb-group)` |
| 245 | `.t-bl { color: ... }` | `#3B7AE0` | `var(--blue-d)` |
| 246 | `.t-gl { color: ... }` | `#4A9B6E` | `var(--green-d)` |
| 247 | `.t-rl { color: ... }` | `#C46B5A` | `var(--red-d)` |
| 248 | `.t-ol { color: ... }` | `#C49340` | `var(--orange-d)` |
| 249 | `.t-pl { color: ... }` | `#7C5FCC` | `var(--purple-d)` |
| 251 | `.t-tl { color: ... }` | `#3D8A79` | `var(--teal-d)` |
| 310 | `.dstep.wild .dnum { color: ... }` | `#C49340` | `var(--orange-d)` |
| 547 | `.pill-tab.active { color: ... }` | `#fff` | `var(--white)` |
| 664 | `.sbar-step:hover .sbar-name { color: ... }` | `#fff` | `var(--white)` |
| 665 | `.sbar-step.active .sbar-name { color: ... }` | `#fff` | `var(--white)` |

---

**Total deviations:** 1 auto-fixed (1 missing critical, with 17 conversion sites under that single deviation).

**Impact on plan:** The fix preserves verbatim discipline (selector text and rule order are byte-for-byte from source); only color literals are tokenized, and the new tokens are taken from documented upstream design-system content rather than invented. The plan's stated `#3a3a3c → var(--g9)` mapping was rejected because it was visually wrong (sidebar divider would visibly lift on the dark column). No scope creep — extending palette.css to cover all source hex literals is the minimum change that satisfies the plan's verify gate without compromising visual fidelity.

## Issues Encountered

- The plan's verify-gate grep `! command grep -nE '#[0-9a-fA-F]{3,8}'` matches anywhere in the file, including comment text. An initial detailed conversion table in components.css's header tripped the gate. Resolved by moving the per-line table to this SUMMARY.md and keeping the file header descriptive only ("sidebar grays → var(--sb-*)"). Pattern flagged for future plans that inline CSS files.
- The plan also instructed to retain `var(--g9)` somewhere in components.css to satisfy `command grep -q 'var(--g9)' skill/design/components.css`. The verbatim source already uses `var(--g9)` 6+ times (e.g., line 162 `section p { color: var(--g9); }`), so this was satisfied without explicit action.

## User Setup Required

None — no external service configuration required.

## Next Phase Readiness

**Plan 02-02 (SKILL.md flow) can now proceed.** Step 6 ("Render the handbook HTML") will read FIVE files: skeleton + palette.css + typography.css + components.css + components.html. It inlines the three CSS files into one `<style>` block in palette → typography → components order, then uses `components.html` as the markup allowlist.

**Plan 02-03 (audit) is unaffected.** D2-15 amendment §"Plan 02-03" confirms the audit's class-allowlist harvest is still a two-source harvest (markup from `components.html` + type-scale labels from `typography.css`). `components.css` is purely styling; the audit does not need to harvest classes from it.

**Plan 02-04 (visual gate) becomes feasible.** The fixture handbook generated end-to-end will include the verbatim component CSS, so the side-by-side compare with `pm-system.html` is a meaningful test rather than a guaranteed-fail.

**Open follow-up for any future plan that re-extracts from `pm-system.reference.html`:** The conversion table above is the full hex-to-token mapping. If the upstream reference is updated, re-extraction must apply these same conversions (or extend palette.css further if new hex literals appear).

## Self-Check: PASSED

Verification of all claimed artifacts:

- `skill/design/components.css` — FOUND (694 lines, all gates pass).
- `skill/design/palette.css` — FOUND (extended; ten new tokens defined).
- `skill/design/SYSTEM.md` — FOUND (Tokens table has 3 rows including components.css; Rule 6 mentions palette → typography → components).
- Commit `d7a85e4` — FOUND (`feat(02-01): extract components.css from pm-system.reference.html`).
- Commit `6d0c3f2` — FOUND (`docs(02-01): document components.css and three-file inlining contract in SYSTEM.md`).
- Plan automated gate (Task 1): zero @import, zero :root, zero body block, zero hex, sidebar+tag+cmp+hl+flow present, var(--g9) present, header strings present — ALL PASS.
- Plan automated gate (Task 2): components.css row present, three-file order documented, all Phase-1 rows preserved — ALL PASS.

---
*Phase: 02-story-arc-gate-handbook-end-to-end*
*Completed: 2026-04-27*
