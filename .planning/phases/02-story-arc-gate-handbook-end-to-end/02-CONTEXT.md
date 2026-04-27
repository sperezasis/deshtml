# Phase 2: Story-Arc Gate + Handbook End-to-End - Context

**Gathered:** 2026-04-27
**Status:** Ready for planning
**Source:** Auto-mode discuss (recommended defaults applied silently). Decisions below derive from PROJECT.md, REQUIREMENTS.md, Phase 1 CONTEXT.md (D-rules), Phase 1 SUMMARY.md hand-off notes, and the research artifacts under `.planning/research/`.

<domain>
## Phase Boundary

Phase 2 ships the working `/deshtml` skill, end-to-end, for **one** document type — Handbook. By end of phase:

1. Pasting `/deshtml` (no args) into a Claude Code session launches a 5-question handbook interview.
2. Claude proposes a story arc (table + flowing paragraph), runs an automated self-review pass, and refuses to write HTML until the user types `approve` (or one of a small whitelist of equivalent phrases).
3. On approval, Claude writes a single self-contained `.html` file to the user's CWD, runs `open <file>`, and prints the absolute path.
4. A post-generation audit rejects any output containing hex literals outside `:root`, class names not in `components.html`, or markup outside the closed component library — confirmed by side-by-side compare with `pm-system.html`.

**Not in this phase (Phase 3 / Phase 4 own these):**
- The other four document types (pitch, technical brief, presentation, meeting prep). Phase 2 stubs the type-selection branch so users picking those see a "coming in Phase 3" message — never a silent fallback.
- Source mode (`/deshtml @file.md` or pasted-text mode). Phase 2 implements the **detection** at turn 1 (per SKILL-03: never silently fall back) and returns a "source mode coming in Phase 4" message; the actual source-grounded arc proposal is Phase 4's SKILL-02.
- The full README, launch hardening, `v0.1.0` tag — all Phase 4.

</domain>

<decisions>
## Implementation Decisions

All gray areas auto-resolved with the recommended defaults (per `--auto`). The planner has latitude inside the guardrails below.

### SKILL.md structure (closes SKILL-05)

- **D2-01 — Skill payload layout:** `skill/SKILL.md` is the single entrypoint and stays under 200 lines. It is **flow-control only**: mode detection → type branch → load `interview/handbook.md` → arc gate (loads `story-arc.md` on demand) → render (loads `design/*` on demand) → audit → write. Sub-files Phase 2 ships:
  - `skill/SKILL.md` — top-level flow (≤200 lines)
  - `skill/story-arc.md` — arc-table format spec, self-review checklist, approval-phrase whitelist, BAD→GOOD tone examples
  - `skill/interview/handbook.md` — the 5-question handbook interview
  - `skill/audit/rules.md` — DESIGN-06 audit rules (hex-literal regex, allowed-class regex, banned-tag list) — referenced by SKILL.md but lives in its own file so Phase 3 can extend it without touching SKILL.md
- **D2-02 — Lazy-loading discipline:** SKILL.md never inlines content from sub-files. It instructs Claude to read each sub-file at the appropriate step. This keeps SKILL.md token cost flat as more doc types are added in Phase 3.

### Mode detection at turn 1 (closes SKILL-01, SKILL-03; partially scaffolds SKILL-02)

- **D2-03 — Detection rules:** Turn-1 detection is mechanical, not heuristic.
  - If the prompt contains an `@<path>` reference → **source mode**.
  - Else if the prompt body (excluding any `@`-mentions) is >200 characters of prose → **source mode** (per PROJECT.md "pasted text").
  - Else → **interview mode**.
- **D2-04 — Source-mode stub:** Phase 2 detects source mode but does not implement it. Response when source mode triggers: a 2-line message — "Source mode is coming in Phase 4. For now, run `/deshtml` with no arguments to use the interview." — then exit. **Never silently fall back to interview** (SKILL-03 contract).
- **D2-05 — Interview branch:** First interactive question = document type. Phase 2 implements only the `handbook` branch; the other four types respond "`<type>` is coming in Phase 3 — try `handbook` for now." then exit. SKILL.md does not delete or hide the four options; the type list is complete from Phase 2.

### Handbook interview (closes DOC-02 partial, DOC-07 for handbook)

- **D2-06 — Interview file shape:** `skill/interview/handbook.md` follows the schema PROJECT.md will lock for all five types in Phase 3: `audience → material → section conventions → tone notes → handoff to story-arc`. ≤5 questions before the arc is proposed (DOC-07).
- **D2-07 — Handbook-specific questions (recommended order, planner may refine wording):**
  1. Who is the reader? (single-line free text)
  2. What is the document about? (1-3 sentences)
  3. What sections do you imagine? (free list, or "let Claude propose" — both accepted)
  4. Tone notes? (free text — defaults to "handbook, not pitch" per CLAUDE.md if blank)
  5. Anything to definitely include / definitely avoid? (free text, optional)
- **D2-08 — No interview validation theater:** No required-field enforcement, no length checks, no retry-the-question loops. Empty answer = Claude proceeds with sensible defaults; the arc-gate is where quality is enforced, not the interview.

### Story-arc gate (closes ARC-01..05)

- **D2-09 — Arc table format:** Literal markdown table with exactly these column headers: `#`, `Beat`, `Section`, `One sentence`, `Reader feels`. No extra columns, no renamed columns. Column widths/order locked.
- **D2-10 — Flowing paragraph (ARC-02):** Immediately under the arc table, render a heading `## Read the One Sentence column top-to-bottom` followed by the `One sentence` cells joined into one paragraph in row order. This is the narrative-gap diagnostic — it must read as a coherent story or the arc is wrong.
- **D2-11 — Self-review pass (ARC-03):** Before showing the arc to the user, Claude executes the three checks defined in `~/CLAUDE.md` "Section Writing Rules":
  1. **Handbook-tone check** — every section title is a structural fact or directive, not a sales/pitch line.
  2. **Causality-chain check** — each section's lead question follows from the previous section's answer.
  3. **"Name the thing" check** — every title contains a concrete noun naming what the section is about (no abstract nouns like "shape," "approach," "way").
  Self-review is rendered as a one-line status under each section ("✓ tone, ✓ chain, ✓ named" or "✗ tone — title 'Projects have shape' is vague, suggest 'Every project has a structure'"). Failures auto-fix in-place before display, but the fix is shown so the user sees what changed.
- **D2-12 — Approval phrase whitelist:** `approve` is the canonical answer. Also accepted (case-insensitive, exact-match-after-trim): `approved`, `looks good`, `lgtm`, `ship it`, `go`, `proceed`, `aprobado`, `dale`. Anything else = NOT approved → arc-revision loop. **No fuzzy / semantic match** — the moat depends on the gate being mechanical.
- **D2-13 — Revision loop (ARC-05):** Any non-approval response is treated as a revision request. Claude regenerates the table + paragraph + self-review and re-asks for approval. No iteration cap — user kills the conversation when satisfied or frustrated.
- **D2-14 — Tone-examples reference:** `skill/story-arc.md` includes 8-10 BAD→GOOD pairs copied verbatim from `~/CLAUDE.md` "Section Writing Rules" so the self-review has a concrete rubric to compare against, not just abstract rules.

### Output writer (closes OUTPUT-01..05, DOC-02 fully)

- **D2-15 — File layout assembly:** SKILL.md instructs Claude to construct the output by:
  1. Loading `skill/design/formats/handbook.html` as the skeleton.
  2. **Inlining** the full content of `skill/design/palette.css` and `skill/design/typography.css` into a single `<style>` block in `<head>` — replacing whatever `<link>` references the skeleton uses for dev-time. **The published file MUST be self-contained** (OUTPUT-05). Closes Phase 1 code-review IN-01.
  3. Filling each `<!-- HERO -->`, `<!-- SECTION -->`, etc. slot with content matching the approved arc, using only classes from `skill/design/components.html`.
  4. Verifying no `<script>` tag was introduced (D-17 from Phase 1 still applies to all output).
- **D2-16 — Filename pattern:** `YYYY-MM-DD-<slug>-handbook.html` written to `pwd`. Slug = kebab-case of the first 4-5 words of the document title (the H1 in the approved arc). On collision, append `-2`, `-3` (per OUTPUT-02). Date is local-time today.
- **D2-17 — Auto-open:** After write, run `open "<absolute-path>"` (macOS-only behavior — documented as a known limitation in Phase 4's README). Print the absolute path on the next line so the user always sees where the file went.
- **D2-18 — Print path last:** Final terminal output is exactly the absolute path on its own line, after `open`. No celebration emoji, no decorative banner. The path is the last thing the user reads. Matches RULE #1 from `~/CLAUDE.md` (terse output).

### Post-generation audit (closes DESIGN-06)

- **D2-19 — Audit rules file:** `skill/audit/rules.md` contains:
  1. **Hex-literal rule:** any `#[0-9a-fA-F]{3,8}` token outside the `:root { ... }` block in `<style>` is a violation. Regex-checkable via `grep`.
  2. **Class allowlist:** every `class="..."` attribute value must match against the union of class names harvested from `skill/design/components.html`. Generated at audit time by parsing `components.html` (no separate hand-maintained list — single source of truth). Unknown classes = violation.
  3. **Tag denylist:** `<script>`, `<iframe>`, `<object>`, `<embed>`, inline `on*=` event handlers, `javascript:` URLs. Any presence = violation (D-17 enforcement).
- **D2-20 — Audit invocation:** SKILL.md runs the audit via Claude's Bash tool **after** the file is written but **before** `open`. Audit script lives at `skill/audit/run.sh` (Phase 2 owns it; Phase 3 may extend it for new doc types). Runs `bash skill/audit/run.sh <output.html>`. Exit 0 = pass; non-zero = list of violations on stderr.
- **D2-21 — Audit failure handling:** On failure, Claude reads the violation list, regenerates the output (loop), and re-runs the audit. **Max 2 retry rounds.** If round 3 still fails, the file is written anyway, the violations are surfaced to the user verbatim with the path, and the user decides next steps. The file is never silently delivered with violations — failure is loud.
- **D2-22 — Audit dev mode:** `skill/audit/run.sh` accepts a `--explain` flag that prints why each violation was flagged with file/line context. Useful when the planner / executor is iterating on the audit rules themselves; not invoked by SKILL.md in normal use.

### Visual contract verification (closes Phase 2 ROADMAP success #2)

- **D2-23 — Reference target:** A handbook generated from a known-good interview must be visually indistinguishable from `pm-system.html` at the structural-shell level (palette, typography, hero shape, sidebar, section grid). Acceptable diff: different content. **Unacceptable:** any wrong color, any wrong font, any wrong spacing, any extra/missing component.
- **D2-24 — Test fixture:** Phase 2's verification plan generates one canonical handbook end-to-end (recommended subject: deshtml itself — interview answers about deshtml, arc about deshtml, output is `YYYY-MM-DD-deshtml-handbook.html`). This output becomes the visual diff target for the human verification step.
- **D2-25 — Browser matrix:** Chrome + Safari side-by-side with `pm-system.html`. iOS Safari forced-dark-mode test on the generated handbook (DESIGN-07 still applies to all output, not just the skeletons from Phase 1).

### Claude's Discretion

The planner has latitude on:

- Whether `interview/handbook.md` is a flat numbered list or a YAML-front-mattered prose file — pick what reads cleaner.
- Exact wording of Phase-2 stub messages for source mode and the four future doc types — keep them ≤2 sentences.
- Whether `audit/rules.md` is markdown prose or a JSON config consumed by `audit/run.sh` — bash-readable is fine either way.
- Whether the audit script is bash or a small Python script — bash is preferred for parity with `bin/install.sh` (no new dependency), but Python is acceptable if the regex work gets ugly. macOS ships Python 3.
- Whether the self-review pass writes its result inline in the arc table (extra cell?) or as a status line below each row — pick what is less visually noisy in a Claude Code terminal.
- Approval-phrase whitelist may grow if the user asks during phase execution — D2-12 is the floor, not the ceiling.

### Folded Todos

None — todo backlog is empty.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Methodology source of truth (Phase 2's primary input)
- `/Users/sperezasis/CLAUDE.md` §"Documentation Methodology — Story First" — Story-First arc requirement, table format, Section Writing Rules (handbook tone, causality chain, name-the-thing), 8-10 BAD→GOOD pairs to copy into `skill/story-arc.md`.

### Design source of truth (consumed by output writer + audit)
- `/Users/sperezasis/work/caseproof/DOCUMENTATION-SYSTEM.md` — Layout rules (Handbook 960px sidebar), tone guidance, component library reference. Already extracted to `skill/design/` in Phase 1; this is the upstream source of truth if anything looks wrong in the extracted fragments.
- `/Users/sperezasis/work/caseproof/gh-pm/pm/pm-framework/diagrams/pm-system.html` — Reference Handbook implementation. **The visual diff target for D2-23.** Phase 1 also shipped a verbatim copy at `skill/design/references/pm-system.reference.html`.

### Phase 1 hand-off (consumed verbatim by Phase 2 output writer)
- `skill/design/palette.css` — `:root` color variables. Inlined into every output `<style>` block.
- `skill/design/typography.css` — Inter @import + type scale. Inlined into every output.
- `skill/design/components.html` — Closed component allowlist. **Single source of truth for the audit class-allowlist.**
- `skill/design/formats/handbook.html` — 960px sidebar skeleton. Output template for handbook type.
- `skill/design/SYSTEM.md` — Index of which fragment to load when. SKILL.md follows this map.
- `.planning/phases/01-foundation-installer-design-assets/01-02-SUMMARY.md` — Phase 1's hand-off notes; flags D-12 deferral (CSS inlining strategy) which Phase 2 closes via D2-15 above.

### Project context
- `.planning/PROJECT.md` — Vision, scope, constraints, key decisions.
- `.planning/REQUIREMENTS.md` — SKILL-01/03/04/05, ARC-01..05, DOC-02, DOC-07, DESIGN-06, OUTPUT-01..05 are the 17 requirements this phase closes.
- `.planning/ROADMAP.md` §"Phase 2" — Goal statement, six success criteria, dependency on Phase 1.

### Research artifacts (consult during planning)
- `.planning/research/STACK.md` — Skill packaging conventions, lazy-load discipline, SKILL.md size budget.
- `.planning/research/ARCHITECTURE.md` — Skill payload subsystems Phase 2 instantiates progressively.
- `.planning/research/PITFALLS.md` — Pitfalls 4, 5, 6, 10 are this phase's concern (silent mode-fallback, fuzzy approval matching, audit-as-decoration, prompt drift in self-review).
- `.planning/research/FEATURES.md` — Must-have feature list for V1; Phase 2 closes the working-skill baseline.
- `.planning/research/SUMMARY.md` — Build-order rationale; explains why arc-gate and handbook-end-to-end are bundled in one phase.

### Code-review carryover from Phase 1
- `.planning/phases/01-foundation-installer-design-assets/01-REVIEW.md` — Finding **IN-01** flagged that the format skeletons use `<link rel=stylesheet>` and Phase 2 must inline before publishing. Closed by **D2-15** above. No other Phase-1 carryover affects Phase 2.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets

- **All Phase 1 output is consumed verbatim by Phase 2.** No paraphrase, no re-extract. `skill/design/*` is the contract.
- `bin/install.sh` from Phase 1 is unchanged by this phase — Phase 2 ships purely new files under `skill/`.
- The repo's `.github/workflows/shellcheck.yml` already gates `bin/*.sh`. Phase 2 may extend this workflow if `skill/audit/run.sh` is bash.

### Established Patterns

- **Verbatim discipline (D-14 from Phase 1)** — applies recursively. `skill/story-arc.md` quotes `~/CLAUDE.md` BAD→GOOD pairs verbatim, not paraphrased. `skill/interview/handbook.md` may rephrase questions but must preserve the methodology's intent. `skill/audit/rules.md` describes Phase 1's component allowlist by reference (`components.html`), not by re-listing it.
- **Single-source-of-truth pattern** — every artifact has exactly one authoritative location. Components: `skill/design/components.html`. Palette: `skill/design/palette.css`. Tone rubric: `~/CLAUDE.md`. The audit script must read these directly, never duplicate them.
- **Mechanical gates over heuristic gates (D-12 carry-over)** — approval-phrase whitelist (D2-12), audit-via-regex (D2-19) — gates are mechanical so they can be enforced without LLM judgement at the boundary.

### Integration Points

- **Phase 2 → Phase 1:** SKILL.md hard-references `skill/design/*` paths. If Phase 1 paths change, Phase 2 breaks — but they are locked by D-11.
- **Phase 2 → Phase 3:** `skill/interview/handbook.md` defines a schema that Phase 3's four other interview files must follow (audience → material → sections → tone → handoff). `skill/audit/run.sh` must remain extensible for Phase 3's `presentation` format (CSS scroll-snap rules are different from Handbook/Overview). `skill/SKILL.md` must already enumerate all 5 doc types in the type-branch (per D2-05) so Phase 3 only flips the stubs to real interviews.
- **Phase 2 → Phase 4:** Source-mode detection (D2-03) is implemented in Phase 2; Phase 4 only swaps the stub message (D2-04) for a real source-grounded arc proposal. The detection logic itself does not change between Phase 2 and Phase 4.

</code_context>

<specifics>
## Specific Ideas

- **Self-review must show its work.** When a section title fails the "name the thing" check, the user should see the BAD title alongside the auto-fixed GOOD title. This builds trust in the gate — opaque auto-fixes feel like the skill is hiding errors.
- **The arc paragraph is the diagnostic.** Reading the joined `One sentence` column top-to-bottom is how narrative gaps surface. If that paragraph reads as a coherent story, the arc is right; if it doesn't, no amount of section polish saves it. The skill must teach this to the user via the heading wording, not bury it under the table.
- **The audit is the moat, not the interview.** Generated HTML can pass the eye test and still fail the audit (one stray hex literal, one freelance class). The user might never notice, but the next person who runs `/deshtml` will inherit the drift. The audit is the only thing that holds the line over time.
- **Phase 2 is the smallest possible end-to-end skill that proves the moat.** One doc type, one format, one full pipeline. Phase 3 only adds breadth on top — if Phase 2 ships with a sketchy arc gate or a soft audit, Phase 3 amplifies the rot.

</specifics>

<deferred>
## Deferred Ideas

- **Multi-language tone rubric** — `~/CLAUDE.md` is English-only. If the user generates a Spanish handbook (PROJECT.md allows this — output language follows source), the self-review pass falls back to structural checks only (causality, name-the-thing) and skips tone since it has no Spanish rubric. V2 ships a Spanish tone-pair set.
- **Audit auto-fix mode** — V2 may have the audit attempt automatic class/hex remediation. V1 only flags violations and regenerates the whole output, max 2 rounds.
- **Arc-gate undo** — once the user approves and the file is written, there is no "undo and revise the arc." User reruns `/deshtml`. V2 may add a `/deshtml --revise <file.html>` shortcut.
- **Token-budget alarms in self-review** — counting how close SKILL.md + sub-files are to the 200-line cap or the per-file context budget is V2.
- **Audit configuration via project file** — V2 may let users override the audit rules per project (e.g., add a custom class allowlist). V1 is opinionated; rules are baked into `skill/audit/rules.md`.
- **CSS scroll-snap presentation format** — Phase 3, not Phase 2. Flagged in roadmap as needing a 30-min spike before implementation.

### Reviewed Todos (not folded)

None — todo backlog is empty.

</deferred>

---

*Phase: 02-story-arc-gate-handbook-end-to-end*
*Context gathered: 2026-04-27 via auto-mode discuss (recommended defaults applied silently)*
