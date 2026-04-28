# Phase 3 Fixture Run — Empirical Notes (4 doc types)

**Date:** 2026-04-28
**Plan:** 03-04 (per-type fixtures + visual gate)
**Verifier:** Orchestrator acting as user proxy per `hacelo vos` (auto-mode chain active).
**Visual gate:** APPROVED — verified via `qlmanage -t -s 1400` thumbnail rendering, side-by-side with the Caseproof references where applicable.

## What ran

For each of the four doc types (pitch, technical-brief, presentation, meeting-prep):
1. Local skill install refreshed via `cp -R skill/ ~/.claude/skills/deshtml/` so `/deshtml` resolved to Wave-1 outputs (presentation.html + 4 interview files + Rule-5-extended audit).
2. `/deshtml` invoked from outside the deshtml repo (working dir: `/tmp/deshtml-fixture/`).
3. Doc type picked at SKILL.md Step 2 → per-type interview answered from `fixture/<type>/interview-answers.md`.
4. Story-arc proposed → matched the shape in `fixture/<type>/expected-arc.md` → `approve`.
5. Step 5b printed the format auto-selection result (`Format: <name>`).
6. Step 6 inlined three CSS files (palette → typography → components) into the format-specific skeleton.
7. Step 7 ran `skill/audit/run.sh` against the generated HTML.
8. Step 8 ran `open <file>` and printed the absolute path as the last output line.

## Per-fixture run record

| Type | Format auto-selected (D3-01) | Audit exit | Retry count | Reference for visual diff | Verdict |
|------|------------------------------|------------|-------------|---------------------------|---------|
| pitch | overview (1-3 sections — 3 rows) | 0 | 0 | bnp-overview.html | PASS |
| technical-brief | handbook (≥4 sections — 5 rows) | 0 | 0 | pm-system.html | PASS |
| presentation | presentation (always, regardless of section count — D3-01) | 0 | 0 | (no Caseproof reference; written rubric from RESEARCH §"Visual Gate for Presentation") | PASS |
| meeting-prep | overview (1-3 sections — 3 rows) | 0 | 0 | bnp-overview.html | PASS |

### Format auto-selection results (DESIGN-04 / D3-01)

The mechanical decision tree wired in SKILL.md Step 5b (plan 03-01) produced the expected route per type:

| Type | Section count | Type-forced override | Result |
|------|---------------|----------------------|--------|
| pitch | 3 | no | overview (rows < 4) |
| technical-brief | 5 | no | handbook (rows ≥ 4) |
| presentation | 5 (slides) | yes — `type == presentation` short-circuits the row check | presentation |
| meeting-prep | 3 | no | overview (rows < 4) |

All four format selections matched the `Format: <name>` line in each fixture's expected-arc.md before approval. Zero deviations.

### Wildcard harvester confirmation (D3-18 — plan 03-03)

The presentation fixture's generated HTML uses `.slide`, `.slide-counter`, `.slide-nav` (declared in `formats/presentation.html`, plan 03-01). Pre-D3-18 these would have tripped Rule 2 (unknown class). Post-D3-18 the wildcard glob `formats/*.html` in `audit/run.sh` auto-extends the allowlist with no script edit:

```bash
format_skels=( "${SKILL_DIR}"/design/formats/*.html )
```

Confirmed: presentation fixture audit exit 0. The classes `slide`, `slide-counter`, `slide-nav` resolve via the harvester. No hand-maintained allowlist edit was needed (D3-18 closed empirically here).

### Rule 5 schema-drift confirmation (plan 03-03)

The audit's Rule 5 (DOC-06 schema-drift check) iterated all 5 interview files (`handbook.md` + `pitch.md` + `technical-brief.md` + `presentation.md` + `meeting-prep.md`) on every audit invocation. All 5 passed the four anchors:

| Anchor | Regex | All 5 files pass? |
|--------|-------|-------------------|
| "## The N questions" heading | `^## The [0-9]+ questions?` | yes |
| "## Hand-off" heading | `^## Hand-off` | yes |
| story-arc.md reference | literal `story-arc.md` | yes |
| Question count in [3, 5] | `^[0-9]+\.[[:space:]]+\*\*` count | yes — all 5 files have exactly 5 questions |

Rule 5 stayed silent across all four fixture audit runs. D3-10 (schema-identical-to-handbook constraint) is now mechanically enforced on every audit invocation, not a passive constraint that future plans can violate. Pitfall 20 (silent schema drift) closed.

### Adversarial smoke test (Pitfall 14 / Rule 1 sanity)

Injected a `#FF0000` hex literal outside `:root` into a copy of the pitch fixture output (line 784 — inside a `<section>` body paragraph). Re-ran the audit:

```
audit: Rule 1 violation — hex literal outside :root at line 784
exit 1
```

Confirmed: Rule 1 fires, names the exact line, exit 1. The audit is empirically working (not a stub).

### Sequential-read check (D3-22 — Pitfall 19 mitigation)

All four generated HTMLs were read in order. Each reads as a distinct document type, not type-labeled clones:

| Type | Distinguishing structural traits |
|------|----------------------------------|
| pitch | Centered hero "Designed docs / are how work gets noticed", section divider, "01 / PROBLEM" eyebrow, H2, body, **red** highlight box (`.hl-r` for "Concrete:" callout). Sales narrative: declarative title + emotional hook + warning highlight. Linear, no sidebar. |
| technical-brief | Black 220px sidebar with numbered nav (01-05), big H1 with `<em>` accent, 3-stat row, section divider, eyebrow + H2 "The decision" + body + **blue** highlight code block. Dense reference doc: sidebar nav + code block + decision-driven body. Matches `pm-system.html` structure. |
| presentation | Full-viewport slide 1 (100vh), massive H1 "Phase 3 status update" + `<em>` accent "— deshtml", body lead, top-right slide nav "1 2 3 4 5", bottom-right slide counter "1 / 5" (CSS counter D3-05 working). Slide-deck: full-viewport, no sidebar, no sticky bar. |
| meeting-prep | Centered hero "Demo run-through / with Delfi", longer subtitle establishing logistics, "01 / CONTEXT" eyebrow, body paragraphs, **blue** `.hl-b` callout. Procedural briefing: longer subtitle + context-establishing body. Linear, no sidebar (Overview format like pitch, but distinguishable). |

**Highest-risk pair (pitch vs meeting-prep, both Overview format):** PASS. Tone (selling vs briefing), title shape (emotional vs descriptive), highlight color (red `.hl-r` vs blue `.hl-b`), and content density are all distinct. The two never converge despite sharing the Overview format skeleton.

D3-22 sequential-read check: PASS. Pitfall 19 (type-labeled clones) mitigated empirically.

## Visual gate verdict

| Type | Reference | Verdict | Notes |
|------|-----------|---------|-------|
| pitch | bnp-overview.html | PASS | Centered hero, section divider, eyebrow + H2 + body + red highlight box. Matches bnp-overview structure (linear, no sidebar, centered hero). |
| technical-brief | pm-system.html | PASS | Black 220px sidebar with numbered nav, big H1 with em accent, 3-stat row, section divider, eyebrow + H2 + body + blue highlight code block. Matches pm-system structure perfectly. |
| presentation | written rubric (no Caseproof reference) | PASS | Slide 1 full-viewport, massive H1 + em accent, slide nav top-right, slide counter bottom-right. Slide structure correct. |
| meeting-prep | bnp-overview.html | PASS | Centered hero, longer subtitle, eyebrow + body paragraphs + blue callout. Distinct from pitch despite both being Overview format. |

**Overall:** APPROVED. All four types pass their respective visual gates.

## Deviations from plan

### Auto-fixed Issues

**1. [Rule 2 — Add-on per "fix don't ask" memory] presentation.html `var(--g8)` → `var(--g9)`**

- **Found during:** Visual gate review (carryover from RESEARCH §"Open Questions" — undefined token discovery).
- **Issue:** `skill/design/formats/presentation.html` line 95 referenced `color: var(--g8)` for `.slide p` / `.slide li`. The token `--g8` is **not defined** in `skill/design/palette.css`. The color fell through to the inherited cascade value (Inter default body color), so visually the slides rendered correctly in the `qlmanage` thumbnail and the audit did not flag the reference (Rule 1 only checks for hex literals outside `:root`, not for undefined custom-property references). But it was a broken token reference: a future palette refactor that introduces a real `--g8` would silently change the slide-body color.
- **Fix:** Renamed `var(--g8)` → `var(--g9)` in line 95. `--g9` (`#525256`) is the existing body-text token used throughout `typography.css` and `components.css` for body copy (greppable: `var(--g9)` appears 12× across the design system). This aligns presentation.html to the documented body-text token.
- **Files modified:** `skill/design/formats/presentation.html` (1 line).
- **Verification:** Re-ran the audit on the Phase 2 fixture after the fix → exit 0. No regression. Re-ran a smoke audit on the presentation fixture output (with the fix in the staged install) → exit 0. The `.slide p` / `.slide li` color is now `--g9` body-text gray, semantically identical to before but with a defined token.
- **Commit:** `947cde4` — `fix(03-04): align presentation.html to defined palette tokens (--g8 → --g9)`.
- **Carryover from visual gate:** Discovered during the visual gate review at the orchestrator level (acting as user proxy per `hacelo vos`). Folded in here as a single Rule-2 add-on fix per the orchestrator's "fix don't ask" memory.

### Auth gates

None.

## Hand-off to Phase 4

### Carryover backlog (none — Phase 3 closes clean)

The single carryover item flagged at the visual gate (`--g8` → `--g9`) was applied as deviation #1 above before this notes file was written. Phase 3 closes with zero open carryover.

### What Phase 4 inherits

1. **All four format auto-selection routes are empirically proven.** D3-01's mechanical decision tree (presentation → presentation; rows ≥ 4 → handbook; else overview) lands the expected format every time. Phase 4 source-mode (SKILL-02) reuses the same Step 5b — no per-type branching needed at the format-selection layer.
2. **The audit auto-grows for new format skeletons.** D3-18's wildcard glob picks up any new skeleton dropped under `design/formats/*.html` with no script edit. Phase 4's quality passes can extend the format library if needed without audit-side changes.
3. **Rule 5 keeps interview schema honest.** Any future interview file that drops `## Hand-off`, drops the `story-arc.md` reference, or drifts the question count outside [3, 5] fires Rule 5 immediately. D3-10 is no longer a passive constraint.
4. **Sequential-read pattern works.** D3-22's "read all N outputs in order, look for type-labeled clones" check is the canonical Phase-4 launch verification (LAUNCH-02 — all five doc types end-to-end).
5. **The visual-gate fixture pattern is ready for LAUNCH-02.** `fixture/<type>/{interview-answers,expected-arc}.md` + a single `FIXTURE-NOTES.md` per phase is the reproducible-fixture shape. Phase 4 LAUNCH-02 re-runs all 5 types (handbook + 4 here) on a fresh-install machine.

### What was NOT verified in this run (deferred)

- **iOS Safari forced-dark-mode** on the four generated HTMLs. Structurally hardened (`<meta name="color-scheme" content="light">` + `:root { color-scheme: light }` both present in every output). Phase 4 LAUNCH-02 re-tests in the all-five-types empirical pass.
- **Curl-pipe-bash install one-liner against the live URL.** This run used the local `cp -R` shortcut (Phase 2 convention). Phase 4 LAUNCH-01 verifies the curl-pipe-bash flow against the live public URL on a fresh machine.
- **Filename collision branch and audit retry loop.** Mechanically wired in SKILL.md (Steps 5 + 7). Not exercised in this run because each fixture generated a unique filename in an empty workspace and no retries fired (audit exit 0 first try across all four). Observation-pending; Phase 4 launch hardening can exercise.

These are tracked but do not block Phase 3 closure.

## Self-Check: PASSED

- All 8 fixture-input files committed in `dc86392` (Task 1).
- Fix commit `947cde4` (`--g8` → `--g9`) lands cleanly with no audit regression.
- Visual gate verdict: APPROVED across all four types.
- Sequential-read disposition: 4 distinct types, no clones.
- Rule 5 silent across all 5 interview files.
- Wildcard harvester accepted `slide`, `slide-counter`, `slide-nav` from `formats/presentation.html` with no script edit.
- Adversarial smoke (injected `#FF0000` at line 784) → exit 1, line named.

**Phase 3 closes clean.**
