# Phase 4: Source-Mode, README, and Launch Hardening - Context

**Gathered:** 2026-04-28
**Status:** Ready for planning
**Source:** Auto-mode discuss (recommended defaults applied silently). Decisions derive from PROJECT.md, REQUIREMENTS.md (SKILL-02, DOCS-01..03, LAUNCH-01..04), Phase 1/2/3 hand-off artifacts, and ROADMAP.md §"Phase 4".

<domain>
## Phase Boundary

Phase 4 is the launch phase. It closes three threads:

1. **Source-mode shortcut** — `/deshtml @path/to/draft.md` (or pasted text >200 chars) is detected at turn 1 and routes straight to a story-arc proposal grounded in the source material, **without running the type interview**. Phase 2 stubbed the detection (D2-04); Phase 4 wires the actual source-grounded arc proposal.

2. **Public README** — written for Delfi as the target reader (DOCS-03). Explains what deshtml is, the install one-liner, basic usage, the five doc types, the uninstall command, the link to the Caseproof Documentation System, and a "Known Limitations" section covering offline-font fallback (system font) and macOS-first auto-open behavior.

3. **Launch hardening** — verify the public install one-liner end-to-end against the live URL on a fresh machine; pin `VERSION` to `0.1.0`; tag `v0.1.0`; cut a GitHub release with a short changelog.

**Not in this phase:**
- Any new doc types (the 5-type cap from PROJECT.md is locked).
- Any V2 ideas (configurable design tokens, self-hosted fonts, print stylesheet, PDF export, etc. — see Deferred section).
- Hosted version, web UI, or non-Claude-Code distribution.

</domain>

<decisions>
## Implementation Decisions

All gray areas auto-resolved with recommended defaults (per `--auto`). Planner has latitude inside the guardrails below.

### Source-mode wiring (closes SKILL-02; completes SKILL-03 from Phase 2)

- **D4-01 — Detection logic is unchanged from Phase 2's stub (D2-03):** `/deshtml @<path>` OR prose >200 chars at turn 1 → source mode. Phase 4 only flips the stub message (D2-04) to a real implementation. SKILL.md's Step 1 regex stays the same.
- **D4-02 — Source-mode branch lives in a sub-file `skill/source-mode.md` (lazy-loaded):** SKILL.md grew to ~198 lines in Phase 3 (≤200 cap). Inlining source-mode logic blows the budget. Mirror the discipline from Phase 2 (`story-arc.md`, `interview/handbook.md`) and Phase 3 (`interview/<type>.md`, `audit/run.sh`): one new sub-file, lazy-loaded by SKILL.md Step 1 when source mode triggers, then handing off to `story-arc.md` for the gate.
- **D4-03 — Source ingestion at turn 1:** SKILL.md Step 1 (when source mode triggers) reads `skill/source-mode.md` and the source material:
  - **`@path/to/file.md` form:** Use Claude's Read tool against the resolved path. Validate the file exists; if missing, error with "File not found: ${path}" and stop. No fallback to interview mode (SKILL-03 contract).
  - **Pasted prose form:** Use the prompt body verbatim as source. No path resolution.
- **D4-04 — Type detection from source (NEW):** the user did NOT pick a doc type in source mode (they bypassed the interview). The skill must infer it. Heuristics in `source-mode.md`:
  - Code blocks + architecture references + decision/trade-off language → `technical-brief`
  - "We're proposing X to do Y" + audience-mention + ask language → `pitch`
  - Multiple H2 sections + "How to" + reference shape → `handbook`
  - Slide-shaped fragments (numbered slides, short bullets, "next slide" cues) → `presentation`
  - Bullet/list-heavy + meeting/agenda/talking-points language → `meeting-prep`
  - **Default if ambiguous:** `handbook` (the most general type, safe fallback).
  - The skill SHOWS the detected type to the user as a one-line: `Detected type: <type>` before the arc, NOT as a question. If wrong, the user can include "this should be a pitch" in their first revision message.
- **D4-05 — Source-grounded arc proposal:** instead of running the interview's 5 questions, source mode jumps straight to building the arc by reading the source material and proposing a beat structure that EXTRACTS rather than INVENTS. The arc's `One sentence` cells must be grounded in source content (not Claude's invention). If a beat has no source content, that beat is skipped, not fabricated.
- **D4-06 — Tone-default behavior in source mode:** the source's voice anchors the body voice (a casual draft → casual body; a formal spec → formal body). Section TITLES still follow handbook tone (describe what IS) regardless of source voice — same rule as Phase 2 D2-11. The self-review pass in `story-arc.md` (Phase 2 ARC-03) runs unchanged.
- **D4-07 — Format auto-selection in source mode:** same logic as Phase 3 D3-01 — type=presentation → presentation; section count ≥4 → handbook; else overview.
- **D4-08 — SKILL.md ≤200 lines hard cap continues:** Phase 4 may add ≤2 lines to SKILL.md Step 1 (flip the stub to a real load of `source-mode.md`). All source-mode logic lives in the sub-file.

### Public README (closes DOCS-01, DOCS-02, DOCS-03)

- **D4-09 — Target reader is Delfi (DOCS-03):** non-technical first-time user. Reading time ≤5 min. No assumed knowledge of: skill packaging, bash, Claude Code internals, GitHub releases, semver, design systems. README explains terms when introduced (e.g., "a *skill* is a Claude Code add-on that gives Claude a specific job to do").
- **D4-10 — README structure (mandatory sections, in order):**
  1. **What deshtml is** — one paragraph, story-first ("you tell deshtml about your topic; it gives you back a designed HTML doc").
  2. **Install** — the verbatim one-liner. Code-block. No prose around it. Two sentences max above and below.
  3. **First run — `/deshtml`** — what to expect: the 5 questions, the arc, the approval gate, the file opening in a browser. Walk through the experience as one paragraph + numbered list.
  4. **The five doc types** — one-line description per type. Show which format each lands in. No code samples, no comparison tables.
  5. **Source mode — `/deshtml @file.md`** — when to use it, what to expect (skips the interview). One paragraph.
  6. **Uninstall** — the verbatim one-liner. Code-block.
  7. **Known Limitations** — explicit subsection per DOCS-02:
     - Offline behavior: web fonts (Inter via Google Fonts) fall back to system font without internet
     - macOS-first: `open <file>` is macOS-only; on Linux the file is written but not auto-opened
     - One file per run: the skill writes one HTML and stops; iteration goes through normal Claude conversation
  8. **Design system credit** — link to Caseproof Documentation System (the source of the palette/typography/component library deshtml inlines).
  9. **License** — MIT (link to LICENSE).
- **D4-11 — README written in English, not Spanish (per CLAUDE.md root rule):** Santiago's Workspace root rule: written content in English. The README ships in English. Spanish input still works for the skill itself (PROJECT.md "Constraints" section).
- **D4-12 — README does NOT have a "What's New / Changelog" section:** that's the GitHub Release notes' job. The README describes what IS, not version history (matches the handbook-tone rule from CLAUDE.md).
- **D4-13 — README does NOT have a contribution guide / development docs:** v1 is opinionated and closed-ish. A future "CONTRIBUTING.md" can land in V2. Phase 4 README is for users, not contributors.

### Launch hardening (closes LAUNCH-01..04)

- **D4-14 — Live-URL install verification (LAUNCH-01):** the `curl -fsSL https://raw.githubusercontent.com/sperezasis/deshtml/main/bin/install.sh | bash` one-liner must run end-to-end on a fresh shell against the live GitHub URL. Plan owns the procedure: backup `~/.claude/skills/deshtml/`, run the curl-pipe-bash, verify install completed, run all 5 doc types end-to-end, restore the backup. Fixture proof committed to the phase as `04-VERIFICATION.md`.
- **D4-15 — Pre-tag `VERSION` bump (LAUNCH-03):** `VERSION` currently reads `0.0.1` (Phase 1). Bump to `0.1.0` in a single commit, after LAUNCH-01 verification passes (so the install verification ran against pre-launch `0.0.1` — which is what's deployed to public users until the tag).
- **D4-16 — Git tag + GitHub release (LAUNCH-03, LAUNCH-04):**
  - Tag `v0.1.0` against the commit that bumps VERSION.
  - GitHub release named `v0.1.0` with a short changelog (one paragraph + bullet list of the 4 phases) generated from the merged PR titles. Use `gh release create v0.1.0 --notes-file CHANGELOG-v0.1.0.md` or similar.
  - Release notes do NOT duplicate the README. They describe what landed in this version specifically.
- **D4-17 — Pre-launch checklist (LAUNCH-02):** all 5 doc types must have been generated end-to-end at least once and visually inspected against Caseproof references. Phases 2 + 3 covered handbook + 4 others. Phase 4 re-verifies all 5 against the live install (during LAUNCH-01).

### Claude's Discretion

The planner has latitude on:

- Whether `source-mode.md` is one file or split per detected type (e.g., `source-mode-pitch.md`, etc.). Recommendation: ONE file with a type-detection block at the top — fewer files to maintain.
- Whether to ship a small `CHANGELOG.md` at the repo root in addition to GitHub Releases. Recommendation: ship a minimal `CHANGELOG.md` (just the v0.1.0 entry) — small file, cheap, useful for users browsing the repo offline.
- Exact wording of the README's "What deshtml is" paragraph — the constraint is story-first, not pitch-y, ≤5 sentences.
- Whether the LAUNCH-01 verification runs in a Docker container (clean env) or in a temporary user account on the same Mac (cheap path). Recommend the cheap path with explicit `mv ~/.claude/skills/deshtml ~/.claude/skills/deshtml.backup` + test + `mv ~/.claude/skills/deshtml.backup ~/.claude/skills/deshtml`.

### Folded Todos

None — todo backlog is empty.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Methodology source of truth
- `/Users/sperezasis/CLAUDE.md` §"Documentation Methodology — Story First" — README itself follows the methodology. Section Writing Rules apply.

### Design source of truth (Phase 1 already extracted)
- `/Users/sperezasis/work/caseproof/DOCUMENTATION-SYSTEM.md` — link target for the README's "Design system credit" section.

### Phase 1/2/3 hand-off (consumed unchanged in Phase 4)
- `bin/install.sh`, `bin/uninstall.sh`, `VERSION`, `LICENSE`, `README.md` (current state — the Phase-1 README is a stub; Phase 4 replaces it with the real Delfi-targeted README).
- `skill/SKILL.md` — Phase 4 modifies Step 1 (flip source-mode stub to real load) only. ≤200 line cap continues.
- `skill/source-mode.md` — NEW in Phase 4. The source-grounded arc proposal logic.
- `skill/story-arc.md`, `skill/interview/*.md`, `skill/audit/run.sh` — unchanged.
- `skill/design/*` — unchanged.
- `.planning/phases/{01,02,03}/*-SUMMARY.md` — Phase summaries inform the GitHub release notes.

### Project context
- `.planning/PROJECT.md` — Vision, scope. The four-phase plan ends with Phase 4.
- `.planning/REQUIREMENTS.md` — SKILL-02, DOCS-01, DOCS-02, DOCS-03, LAUNCH-01, LAUNCH-02, LAUNCH-03, LAUNCH-04 — the 8 requirements this phase closes.
- `.planning/ROADMAP.md` §"Phase 4" — Goal, 4 success criteria.

### Research artifacts
- `.planning/research/SUMMARY.md` — flagged Phase 4 launch hardening's "rules-check pass" risk (post-generation prose audit). Phase 2's audit (DESIGN-06) already covers visual fidelity; Phase 4's "audit" here is README-quality / launch-checklist quality, not generated-output quality.
- `.planning/research/PITFALLS.md` — pitfalls 14-18 are this phase's concern: source-mode silent fallback, README scope creep, version-tag/branch-tag mismatch, README writing in pitch tone, launch checklist drift.

### Phase 2/3 review carryover (none blocking)
- `.planning/phases/02-story-arc-gate-handbook-end-to-end/02-REVIEW-FIX.md` — all 9 findings fixed. No carryover.
- `.planning/phases/03-remaining-four-doc-types/03-REVIEW.md` INFO-01 — V2 carryover (Rule 5 grep scope), explicitly deferred. Phase 4 may re-evaluate but is not required to fix.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets

- **Phase 2/3 entire skill payload reused unchanged in Phase 4.** Source-mode is purely additive: one new sub-file (`source-mode.md`) + a 1-2 line flip in SKILL.md Step 1.
- **Phase 1's `bin/install.sh`** is the one-liner LAUNCH-01 verifies. It already has the contracts (atomic, idempotent, root-refusal, shellcheck-CI) needed for a public-facing release.
- **The current `README.md`** (Phase 1 stub) is the file Phase 4 replaces. It has the install snippet only; Phase 4 expands to the full Delfi-targeted document.

### Established Patterns

- **Lazy-load discipline (D2-02 + D3-17)** — applies to source-mode.md.
- **Verbatim discipline (D-14)** — applies to README quotes (e.g., the install one-liner is byte-for-byte identical to what `bin/install.sh` ships).
- **Mechanical gates over heuristic gates (D-12, D2-12, D3-01)** — D4-04's type-detection heuristics are LLM-judgment-light: they look for concrete content patterns (code blocks, "we propose," numbered slides), with `handbook` as the safe fallback. Not a regex-only mechanical gate, but a clear decision tree.

### Integration Points

- **Phase 4 → Phase 2:** SKILL.md Step 1 source-mode stub becomes a real branch. The detection regex doesn't change. Phase 2's behavioral contract (SKILL-03: never silently fall back) holds in Phase 4.
- **Phase 4 → Phase 1:** the `curl … | bash` one-liner from Phase 1's README is what LAUNCH-01 verifies end-to-end.
- **Phase 4 → public users:** the README is the first thing a new user reads on github.com/sperezasis/deshtml. Tone is everything. Pitch-tone in the README would undercut the methodology the skill itself enforces.

</code_context>

<specifics>
## Specific Ideas

- **The README is the only file outsiders read first.** A pitch-tone README contradicts the handbook-tone moat. CLAUDE.md root rule "describe what IS" applies recursively.
- **LAUNCH-01 is a destructive-feeling test (overwrites local install).** The plan must include the backup-restore dance explicitly so the user (Santiago) running the verification doesn't lose his working dev install.
- **The release notes are the one place where some marketing-tone is acceptable** — they describe what shipped this version, which is by definition a "what's new" story. Even there, lead with handbook-tone fact ("v0.1.0 ships the five doc types end-to-end") not "v0.1.0 brings powerful design to your team."
- **Source-mode is the most user-facing new feature in Phase 4.** Most v0.1.0 users will read the README and try interview mode first. Source mode is the "and there's also a power-user shortcut" — documented but not lead-positioned.

</specifics>

<deferred>
## Deferred Ideas

- **CONTRIBUTING.md** — V2.
- **Configurable design tokens / alternate palettes** — V2 (locked out of v1 by PROJECT.md).
- **Self-hosted base64-inlined Inter** — V2 (per Phase 1 D-18 deferred decision).
- **Print stylesheet polish + one-click PDF export** — V2.
- **Linux/Windows auto-open parity** — V2 (v1 is macOS-first per OUTPUT-03 + DOCS-02 known limitation).
- **`/plugin marketplace add` install path** — V2.
- **Auto-update check on every run** — V2.
- **Sub-templates within doc types** (e.g., "pitch — internal" vs "pitch — external") — V2.
- **Inline-render-in-Gmail compatibility** (would force tableized inline-style HTML; compromises design fidelity) — V2.
- **Project-scope skill install** — out of scope (Claude Code issue #36155 makes project-scope skills read-only).

### Reviewed Todos (not folded)

None — todo backlog is empty.

</deferred>

---

*Phase: 04-source-mode-readme-launch-hardening*
*Context gathered: 2026-04-28 via auto-mode discuss (recommended defaults applied silently)*
