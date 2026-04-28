# Phase 3: Remaining Four Doc Types - Context

**Gathered:** 2026-04-28
**Status:** Ready for planning
**Source:** Auto-mode discuss (recommended defaults applied silently). Decisions derive from PROJECT.md, REQUIREMENTS.md (DOC-01/03/04/05/06, DESIGN-04), Phase 2's CONTEXT.md and SUMMARY artifacts, and ROADMAP.md §"Phase 3".

<domain>
## Phase Boundary

Phase 3 extends `/deshtml` from one working doc type to all five. The handbook flow Phase 2 shipped is the template — Phase 3 replicates the pattern across pitch, technical brief, presentation, and meeting prep. The arc gate, the audit, the design-system contract, the output writer — all locked in Phase 2 — apply unchanged. What's new in Phase 3:

1. **Four interview files** — `skill/interview/{pitch,technical-brief,presentation,meeting-prep}.md`, each following the DOC-06 schema (audience → material → sections → tone → handoff), each ≤5 questions (DOC-07).
2. **Presentation format skeleton** — `skill/design/formats/presentation.html`, CSS scroll-snap full-viewport slides with `#slide-N` anchor navigation and a CSS-only slide counter. No JS.
3. **Format auto-selection** — SKILL.md picks format from the approved arc + chosen type: Presentation type → Presentation format always; else section count ≥4 → Handbook (960px); else Overview (1440px).
4. **SKILL.md type-branch flip** — the four "coming in Phase 3" stubs Phase 2 left in place become real routes into the corresponding interview file.
5. **Audit allowlist extension** — the harvester picks up classes from all three format skeletons (currently only `handbook.html` is harvested).

**Not in this phase (Phase 4 owns):**
- Source mode (`/deshtml @file.md` or pasted-text mode). Phase 2 stubbed detection; Phase 4 implements the source-grounded arc proposal (SKILL-02).
- Public README, "Known Limitations" section, Delfi-targeted docs (DOCS-01/02/03).
- Live-URL `curl … | bash` end-to-end verification (LAUNCH-01), `v0.1.0` tag, GitHub release (LAUNCH-03/04).

</domain>

<decisions>
## Implementation Decisions

All gray areas auto-resolved with the recommended defaults (per `--auto`). Planner has latitude inside the guardrails below.

### Type → format mapping (closes DESIGN-04)

- **D3-01 — Format auto-selection logic, lives in SKILL.md Step 5 (between approval and render):**
  ```
  if type == "presentation": format = "presentation"
  elif arc.section_count >= 4:  format = "handbook"
  else:                          format = "overview"
  ```
  Type=presentation always wins regardless of section count — slide decks are inherently a different rendering shape, not a "longer Overview." For the other four types, section count is the discriminator. This produces the expected mappings from REQUIREMENTS.md DOC-01..05 organically:
  - Pitch (problem → solution → ask, typically 1-3 beats) → Overview ✓
  - Handbook (multi-section reference, typically 4+ beats) → Handbook ✓
  - Technical brief (architecture write-up, typically 4+ beats) → Handbook ✓
  - Presentation → Presentation always ✓
  - Meeting prep (briefing, typically 1-3 beats) → Overview ✓

- **D3-02 — Format-selection result is exposed to the user before render:** SKILL.md Step 5 prints a single line: `Format: <handbook|overview|presentation>`. Not a question — just visibility. If the user objects, they can edit the arc (add/remove sections) and re-approve to flip the format. No separate "force this format" override knob in v1.

### Presentation format (closes DOC-04, partially DESIGN-04)

- **D3-03 — Spike before build:** ROADMAP flagged a 30-minute spike on `scroll-snap-type: y mandatory` in Chrome + Safari. Plan 03-01 owns the spike as Task 1 (≤30 min): build a minimal HTML with 3 stub slides + scroll-snap, open in both browsers, verify snap fires reliably. Document any browser-specific gotchas in `presentation.html` comments. **If Safari snap is broken,** fall back to JS-free `:target` pseudo-class navigation (anchor-only, no snap) and document the degradation.
- **D3-04 — Slide structure:** Each `<section class="slide" id="slide-N">` is `100vh` tall with `scroll-snap-align: start`. Slides flow vertically; the parent `<main>` is `scroll-snap-type: y mandatory; overflow-y: scroll; height: 100vh;`.
- **D3-05 — Slide counter (CSS-only):** Use `counter-reset` on `<main>` and `counter-increment` on each `.slide`, displayed via `::after { content: counter(slide-num) " / " counter(total); }` on a fixed-position element. No JS, no manual `data-slide-N` attribution.
- **D3-06 — Anchor navigation:** Each slide carries `id="slide-1"`, `id="slide-2"`, etc. Sequential, integer-based. A floating nav (analogous to the handbook's floating pill) lists `#slide-1, #slide-2, ...` as anchor links. Same `nav-a` markup as the handbook sidebar — no new components.
- **D3-07 — No transition animation in v1:** scroll-snap default behavior is fine; no custom `scroll-behavior: smooth` or transition CSS. Keeps the Presentation skeleton small and the audit allowlist tight. V2 may add transitions.
- **D3-08 — Presentation typography sizing:** scale UP from the Handbook scale for slide visibility — H1 80px, H2 56px, body 22px. These ride on the existing Inter @import; no new fonts. Inline as part of `presentation.html`'s layout `<style>` (the second `<style>` block, after the inlined three CSS files), not as additions to typography.css — that file remains the doc-text scale, not the slide scale.
- **D3-09 — Presentation does NOT have a sidebar:** the 220px sidebar is Handbook-only. Presentation slides are full-viewport. The skeleton's `<aside>` slot is omitted entirely.

### Interview files (closes DOC-06, DOC-07 fully)

- **D3-10 — Schema is identical to handbook.md:** every interview file follows audience → material → sections → tone → handoff, in that order. The QUESTIONS may differ per type, but the schema does not. This is what DOC-06 enforces.
- **D3-11 — Question-count cap:** each file asks ≤5 questions (DOC-07). Some types may ask 4 (pitch is short by nature); none ask more than 5.
- **D3-12 — Type-tailored questions (recommended order, planner may refine):**

  **Pitch (`pitch.md`)** — problem → solution → ask narrative, Overview format expected:
    1. Audience (who hears the pitch?)
    2. The ask (what specific outcome do you want from this audience?)
    3. The problem (1-2 sentences — what's broken without your solution?)
    4. Your solution (1-2 sentences — what you're offering, in plain terms)
    5. Anything to definitely include / avoid?

  **Technical brief (`technical-brief.md`)** — architecture/decision write-up, Handbook format expected:
    1. Audience (which engineers, what context do they have?)
    2. The decision (what was decided, in one sentence?)
    3. Alternatives considered (free list — at least 2)
    4. Trade-offs that drove the choice (free text)
    5. Anything to definitely include / avoid?

  **Presentation (`presentation.md`)** — slide deck, Presentation format always:
    1. Audience (who's watching this deck?)
    2. The takeaway (one sentence the audience leaves with)
    3. Slide outline (free list, or "let Claude propose")
    4. Tone (default: handbook, not pitch — but slide tone often runs more energetic; let user override)
    5. Anything to definitely include / avoid?

  **Meeting prep (`meeting-prep.md`)** — briefing doc, Overview format expected:
    1. Meeting purpose (one sentence — what is this meeting deciding?)
    2. Audience (who's in the room?)
    3. Talking points (free list — what you need to cover)
    4. Open questions / risks (free text)
    5. Anything to definitely include / avoid?

- **D3-13 — Empty-answer behavior is identical across all five files:** accept the empty answer, proceed with documented defaults, never validate, never retry. Quality enforcement is the arc gate, not the interview. (Same as handbook.md — D2-08 from Phase 2 carries forward.)

### SKILL.md updates (extends D2-01..D2-05 from Phase 2)

- **D3-14 — Type-branch routes:** Step 2's four stubs become real routes:
  - `pitch` → load `interview/pitch.md`, then `story-arc.md`, then format auto-select
  - `technical brief` → load `interview/technical-brief.md`, then `story-arc.md`, then auto-select
  - `presentation` → load `interview/presentation.md`, then `story-arc.md`, then format=presentation
  - `meeting prep` → load `interview/meeting-prep.md`, then `story-arc.md`, then auto-select
- **D3-15 — Step 5 format selection:** insert a new sub-step between filename computation and skeleton load:
  ```
  Step 5b — Select format
  if type == "presentation": format = "presentation"
  elif arc has 4+ rows:       format = "handbook"
  else:                        format = "overview"
  Print: "Format: ${format}"
  ```
- **D3-16 — Step 6 skeleton routing:** replace the hard-coded `formats/handbook.html` reference with a variable load:
  ```
  Read ${CLAUDE_SKILL_DIR}/design/formats/${format}.html
  ```
  Slot-fill logic remains the same. Each skeleton's slot comments are the contract.
- **D3-17 — SKILL.md size budget:** with 4 new routes + format selection + skeleton routing, the file may grow past 200 lines. **Hard cap is 200 lines.** If the implementation needs more, factor route bodies into a sub-file (e.g., `skill/routes/<type>.md`) loaded on demand. Phase 2 set the precedent (story-arc.md, interview/handbook.md, audit/run.sh are all sub-files).

### Audit allowlist extension

- **D3-18 — Harvester picks up all three format skeletons:** the audit script in Phase 2 currently harvests classes from `formats/handbook.html`. Extend to harvest from all three (`handbook.html`, `overview.html`, `presentation.html`). The simplest implementation: `for skel in $skill_dir/design/formats/*.html; do ...` — automatically picks up any future format files Phase 3+ adds.
- **D3-19 — Presentation-specific classes:** `presentation.html` introduces (per the spike output): `slide`, `slide-counter`, `slide-num`, possibly `slide-nav`. These get harvested automatically per D3-18. No hand-maintained allowlist additions needed.

### Visual gate (closes ROADMAP Phase 3 success #4)

- **D3-20 — Four fixture runs, one checkpoint:** Plan 03-04 generates one canonical fixture per doc type:
  - **Pitch fixture** — pitching deshtml to a small-team CTO (audience: technical, ask: "let me build this for our team," 3-section narrative). Visual diff vs `bnp-overview.html` (Overview).
  - **Technical brief fixture** — "Why we chose curl-pipe-bash for distribution" (audience: Caseproof engineers, decision: pipe-bash over a packaged installer, 5-6 sections). Visual diff vs `pm-system.html` (Handbook).
  - **Presentation fixture** — "Phase 3 status update" (audience: Caseproof team, 5 slides). No external Caseproof reference exists for Presentation — visual gate is "looks like a designed slide deck, palette + fonts match the system, scroll-snap works in Chrome and Safari."
  - **Meeting prep fixture** — "Demo run-through with Delfi" (audience: Delfi, 3 sections: context, demo flow, anticipated questions). Visual diff vs `bnp-overview.html`.
- **D3-21 — One human-verify checkpoint at the end of plan 03-04:** verifier opens all four fixture HTMLs side-by-side with their respective Caseproof references (where applicable), confirms format auto-selection picked the right shape per type, and runs the audit on each.
- **D3-22 — "None reads like a type-labeled clone" check:** the four fixtures are read sequentially. The reader should be able to tell which is which by tone, structure, and content density — not just by reading the H1. If two fixtures feel interchangeable, that's a content/interview-question issue, surfaced as a fix.

### Claude's Discretion

The planner has latitude on:

- Whether the spike (D3-03) lives in plan 03-01 as Task 1 or as a separate Wave-0 plan. Either is fine; planner should pick what flows cleaner.
- Exact wording of the four interview files' questions — the plan-level guidance in D3-12 is the floor, not the ceiling.
- Whether `formats/presentation.html`'s slide-counter is rendered top-right, bottom-right, or centered — pick what looks closest to a generic slide-deck convention.
- Whether the "Format: ${format}" line in SKILL.md Step 5b is plain text or has a subtle `[auto-selected based on N sections]` annotation — pick what reads cleaner.
- Whether the four interview files share a header-comment template noting their schema lineage to `handbook.md` (DOC-06) or simply state it inline in each file.

### Folded Todos

None — todo backlog is empty.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Methodology source of truth (Phase 3 inherits Phase 2's methodology)
- `/Users/sperezasis/CLAUDE.md` §"Documentation Methodology — Story First" — Story-First arc requirement, Section Writing Rules. Same source of truth Phase 2 used for `story-arc.md` BAD→GOOD pairs.

### Design source of truth
- `/Users/sperezasis/work/caseproof/DOCUMENTATION-SYSTEM.md` — palette, typography, components, layout. Phase 1 extracted; Phase 3 inherits unchanged.
- `/Users/sperezasis/work/caseproof/gh-pm/pm/pm-framework/diagrams/pm-system.html` — Handbook reference (used by handbook + technical-brief fixtures).
- `/Users/sperezasis/work/caseproof/gh-pm/pm/bnp/.planning/figma/bnp-overview.html` — Overview reference (used by pitch + meeting-prep fixtures).

### Phase 2 hand-off (consumed by Phase 3 unchanged)
- `skill/SKILL.md` — Phase 3 modifies Step 2 (type-branch routes), adds Step 5b (format selection), modifies Step 6 (skeleton routing). The 8-step structure is preserved.
- `skill/story-arc.md` — used by all five doc types. NO changes in Phase 3. Universal arc gate.
- `skill/interview/handbook.md` — schema reference for the four new interview files (DOC-06). Phase 3 reads this as the template, not modifies it.
- `skill/audit/run.sh` — extends harvester (D3-18) to scan all format skeletons. Audit logic itself unchanged.
- `skill/design/{palette.css, typography.css, components.css, components.html}` — used unchanged by all five doc types.
- `skill/design/formats/{handbook.html, overview.html}` — Phase 1 already shipped both. Phase 3 adds `presentation.html`.
- `.planning/phases/02-story-arc-gate-handbook-end-to-end/02-SUMMARY.md` — Phase 2's wrap-up, including audit-fix carryover details.

### Project context
- `.planning/PROJECT.md` — Vision, scope, constraints, key decisions. PROJECT.md row 6 enumerates the 5 doc types Phase 3 closes.
- `.planning/REQUIREMENTS.md` — DOC-01 (pitch), DOC-03 (tech brief), DOC-04 (presentation), DOC-05 (meeting prep), DOC-06 (uniform schema), DESIGN-04 (auto format selection) are the 6 requirements this phase closes.
- `.planning/ROADMAP.md` §"Phase 3" — Goal, 4 success criteria, dependencies on Phase 2.

### Research artifacts (consult during planning)
- `.planning/research/STACK.md` — confirmed: skill packaging supports per-type sub-files at any depth from SKILL.md. No new constraints introduced by Phase 3.
- `.planning/research/PITFALLS.md` — Pitfalls 11-13 are this phase's concern: Presentation scroll-snap browser inconsistencies (Pitfall 11), interview-file schema drift across types (Pitfall 12), format-selection logic creep into story-arc.md (Pitfall 13).
- `.planning/research/ARCHITECTURE.md` — Skill payload subsystems Phase 3 instantiates (`interview/<type>.md` × 4, `formats/presentation.html`).
- `.planning/research/SUMMARY.md` — Build-order rationale; explains why Phase 3 fans out from Phase 2's proven flow rather than rebuilding.

### Code-review carryover from Phase 2
- `.planning/phases/02-story-arc-gate-handbook-end-to-end/02-REVIEW.md` + `02-REVIEW-FIX.md` — All 9 findings fixed in Phase 2. No carryover into Phase 3.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets

- **Phase 2's entire skill payload is reused verbatim by Phase 3.** No paraphrase, no fork-and-edit. The four new interview files mirror `handbook.md`'s shape; SKILL.md's Step 2 stubs flip from "coming in Phase 3" to real routes; everything else is unchanged.
- **`formats/overview.html`** (shipped in Phase 1) is reused by pitch + meeting-prep with zero modification. The skeleton is already DESIGN-07-compliant (`color-scheme: light` + meta tag) and uses the same component allowlist.
- **`audit/run.sh`** auto-extends to new format skeletons via the wildcard harvest pattern (D3-18). No per-doc-type audit rules.

### Established Patterns

- **Lazy-load discipline (D2-02 from Phase 2)** applies recursively. SKILL.md does not inline interview content. Each interview file is read on demand at Step 3 after the type is known.
- **Verbatim discipline (D-14 from Phase 1, D2-14 from Phase 2)** applies to interview defaults: where `handbook.md` quotes `"Handbook, not pitch. Describe what IS." — verbatim from CLAUDE.md`, the four new interview files use the same verbatim CLAUDE.md quotes for their tone defaults. Pitch may diverge (sales tone is appropriate for a pitch's body, but the SECTION TITLES still follow handbook tone — every doc type's section titles describe what IS, regardless of body voice).
- **Mechanical gate over heuristic gate (D-12, D2-12 from prior phases)** — D3-01's format selection is a pure section-count + type-match check, not an LLM judgment call. Predictable and testable.

### Integration Points

- **Phase 3 → Phase 2:** SKILL.md is the integration point. Phase 3 modifies Steps 2, 5, and 6; the rest of Phase 2's SKILL.md flow remains untouched. Pre-merge regression: any Phase-2 fixture (handbook) must still produce identical output after the Step 2/5/6 changes.
- **Phase 3 → Phase 1:** `formats/overview.html` (shipped in Phase 1) is loaded for the first time by pitch + meeting-prep flows. If `overview.html`'s slot comments differ from `handbook.html`'s, Phase 3's slot-fill logic in SKILL.md Step 6 needs to handle both. Recommended: each format skeleton documents its own slot list at the top in HTML comments.
- **Phase 3 → Phase 4:** All four new interview files become input to Phase 4's source-mode shortcut (SKILL-02). When source mode is activated, the user's source material grounds the arc proposal — but the type-tailored interview is BYPASSED. Phase 4 routes source-mode → arc directly. Phase 3 should design the interviews to be skippable cleanly: each interview file's tone-defaults section becomes a tone INSTRUCTION when the source-mode-equivalent runs.
- **Phase 3 → no-skill-extension is locked:** the four doc types in PROJECT.md row 6 are the V1 set. Phase 3 does NOT add a sixth type, even if a "report" or "newsletter" feels natural. Out-of-scope per PROJECT.md.

</code_context>

<specifics>
## Specific Ideas

- **The "type-labeled clone" failure mode is the biggest risk.** If pitch and meeting-prep both produce 3-section Overviews with similar tone, the user reads them as the same thing in different fonts. Mitigation: each interview file's tone-defaults plus question wording must produce genuinely different content. Plan 03-04's visual gate explicitly checks this (D3-22).
- **Presentation is the squishiest piece — the 30-min spike is non-negotiable.** scroll-snap-type behavior diverges between Chrome and Safari historically (Safari has had snap fragility on flex containers, on iOS bounces, etc.). The spike (D3-03) is the gate; if Safari support is broken, the fallback is `:target`-only navigation without snap, documented as a Phase 3 limitation.
- **SKILL.md's 200-line cap is the constraint that disciplines the design.** If Step 2's type-branch grows long with route bodies, the right move is to pull each route into a sub-file, not to wave the cap. Same discipline as Phase 2's lazy-load pattern.
- **Format auto-selection is the most user-visible new behavior.** The single-line "Format: <name>" output (D3-02) is what a returning user sees that wasn't there before. If the format pick is wrong, the user can fix the arc instead of asking for a new flag — that's the design.

</specifics>

<deferred>
## Deferred Ideas

- **Per-type audit rules** — V2 only. The current audit is universal; if pitch turns out to need a different `<script>` exception (it doesn't, but if), a per-type rule fork lives in V2.
- **Slide transitions / animations in Presentation** — V2. v1 ships scroll-snap default behavior only.
- **Speaker notes for Presentation** — V2. Adds an `<aside class="notes">` per slide that prints but doesn't render. Non-trivial scope.
- **`/deshtml --format=<x>` override flag** — V2. v1 derives format from arc + type; if a user wants a different format they edit the arc.
- **PDF export** — V2 / V3. Out of v1.
- **A sixth doc type** (report, newsletter, FAQ, etc.) — locked out of v1 by PROJECT.md.
- **Multi-deck Presentation** (linked decks, table of contents across decks) — V2 at earliest.

### Reviewed Todos (not folded)

None — todo backlog is empty.

</deferred>

---

*Phase: 03-remaining-four-doc-types*
*Context gathered: 2026-04-28 via auto-mode discuss (recommended defaults applied silently)*
