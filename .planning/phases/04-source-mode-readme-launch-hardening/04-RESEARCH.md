# Phase 4: Source-Mode + README + Launch Hardening — Research

**Researched:** 2026-04-28
**Domain:** Claude Code skill (`$ARGUMENTS` semantics, sub-file lazy load, source-grounded arc generation), README authoring for non-technical readers, GitHub release process via `gh`, live-URL install verification
**Confidence:** HIGH (skill semantics empirically verified by Phase 2 fixture; `gh release create` behavior verified against current cli.github.com docs; README authoring patterns verified against live public READMEs and against `~/CLAUDE.md` Section Writing Rules already governing this project)

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Source-mode wiring (closes SKILL-02; completes SKILL-03 from Phase 2)**

- **D4-01** — Detection logic is unchanged from Phase 2's stub (D2-03): `/deshtml @<path>` OR prose >200 chars at turn 1 → source mode. Phase 4 only flips the stub message (D2-04) to a real implementation. SKILL.md's Step 1 regex stays the same.
- **D4-02** — Source-mode branch lives in a sub-file `skill/source-mode.md` (lazy-loaded). SKILL.md ≤200 line cap continues; inlining source-mode logic blows the budget.
- **D4-03** — Source ingestion at turn 1: `@path/to/file.md` form → use Claude's Read tool against the resolved path; if missing, error with `File not found: ${path}` and stop (no fallback to interview). Pasted prose form → use the prompt body verbatim as source.
- **D4-04** — Type detection from source (the user did NOT pick a doc type). Heuristics in `source-mode.md`:
  - Code blocks + architecture references + decision/trade-off language → `technical-brief`
  - "We're proposing X to do Y" + audience-mention + ask language → `pitch`
  - Multiple H2 sections + "How to" + reference shape → `handbook`
  - Slide-shaped fragments (numbered slides, short bullets, "next slide" cues) → `presentation`
  - Bullet/list-heavy + meeting/agenda/talking-points language → `meeting-prep`
  - Default if ambiguous: `handbook`.
  - Show detected type to user as one-liner: `Detected type: <type>` before the arc, NOT as a question.
- **D4-05** — Source-grounded arc proposal: jump straight to building the arc by reading the source and proposing a beat structure that EXTRACTS rather than INVENTS. The arc's `One sentence` cells must be grounded in source content. If a beat has no source content, the beat is skipped, not fabricated.
- **D4-06** — Tone-default in source mode: source's voice anchors body voice. Section TITLES still follow handbook tone (describe what IS) regardless of source voice — same rule as Phase 2 D2-11. Self-review pass in `story-arc.md` (ARC-03) runs unchanged.
- **D4-07** — Format auto-selection in source mode: same logic as Phase 3 D3-01 — type=presentation → presentation; section count ≥4 → handbook; else overview.
- **D4-08** — SKILL.md ≤200 lines hard cap continues. Phase 4 may add ≤2 lines to Step 1 (flip the stub to a real load of `source-mode.md`). All source-mode logic lives in the sub-file.

**Public README (closes DOCS-01, DOCS-02, DOCS-03)**

- **D4-09** — Target reader is Delfi: non-technical first-time user, ≤5 min reading time. No assumed knowledge of: skill packaging, bash, Claude Code internals, GitHub releases, semver, design systems.
- **D4-10** — README mandatory sections, in order: (1) What deshtml is — one paragraph, story-first; (2) Install — verbatim one-liner, code-block, ≤2 sentences above and below; (3) First run `/deshtml` — walk through the experience; (4) The five doc types — one-line per type; (5) Source mode `/deshtml @file.md` — one paragraph; (6) Uninstall — verbatim one-liner; (7) Known Limitations — offline font fallback, macOS-first auto-open, one file per run; (8) Design system credit — link to Caseproof Documentation System; (9) License — MIT.
- **D4-11** — README written in English, not Spanish.
- **D4-12** — README does NOT have a "What's New / Changelog" section (that's GitHub Release notes' job).
- **D4-13** — README does NOT have a contribution guide / development docs (V2).

**Launch hardening (closes LAUNCH-01..04)**

- **D4-14** — Live-URL install verification (LAUNCH-01): the `curl -fsSL .../bin/install.sh | bash` one-liner must run end-to-end on a fresh shell against the live GitHub URL. Plan owns the procedure: backup `~/.claude/skills/deshtml/`, run the curl-pipe-bash, verify install completed, run all 5 doc types, restore the backup. Fixture proof committed as `04-VERIFICATION.md`.
- **D4-15** — Pre-tag `VERSION` bump (LAUNCH-03): bump `0.0.1` → `0.1.0` in a single commit, after LAUNCH-01 verification passes.
- **D4-16** — Git tag + GitHub release (LAUNCH-03, LAUNCH-04): tag `v0.1.0`; release named `v0.1.0` with short changelog (one paragraph + bullet list of the 4 phases). `gh release create v0.1.0 --notes-file CHANGELOG-v0.1.0.md` (or similar).
- **D4-17** — Pre-launch checklist (LAUNCH-02): all 5 doc types must have been generated end-to-end at least once and visually inspected. Phase 4 re-verifies all 5 against the live install during LAUNCH-01.

### Claude's Discretion

- Whether `source-mode.md` is one file or split per detected type. Recommendation: ONE file with a type-detection block at the top.
- Whether to ship a small `CHANGELOG.md` at the repo root in addition to GitHub Releases. Recommendation: ship a minimal `CHANGELOG.md` (just v0.1.0).
- Exact wording of "What deshtml is" paragraph — story-first, not pitch-y, ≤5 sentences.
- Whether LAUNCH-01 verification runs in Docker or in a temporary user account / backup-restore on the same Mac. Recommendation: cheap path with explicit `mv ~/.claude/skills/deshtml ~/.claude/skills/deshtml.backup` + test + restore.

### Deferred Ideas (OUT OF SCOPE)

- CONTRIBUTING.md — V2.
- Configurable design tokens / alternate palettes — V2.
- Self-hosted base64-inlined Inter — V2.
- Print stylesheet polish + one-click PDF export — V2.
- Linux/Windows auto-open parity — V2.
- `/plugin marketplace add` install path — V2.
- Auto-update check on every run — V2.
- Sub-templates within doc types — V2.
- Inline-render-in-Gmail compatibility — V2.
- Project-scope skill install — out of scope (Claude Code issue #36155).
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| SKILL-02 | `/deshtml @path/to/draft.md` (or pasted text) uses source as raw material instead of interviewing | §"Source-mode wiring" — confirms `$ARGUMENTS` is literal (Claude Code does NOT expand `@`); D4-03 Read-tool resolution; D4-04 type detection; D4-05 source-grounded arc |
| DOCS-01 | README explains: what deshtml is, install one-liner, basic usage, 5 doc types, uninstall, link to design system | §"Public README" — D4-10 mandatory sections in order |
| DOCS-02 | README has "Known Limitations" section: offline font fallback + macOS-first auto-open | §"Public README" §"Known Limitations" — three items: offline fonts, macOS auto-open, one-file-per-run |
| DOCS-03 | README written for first-time non-technical user (Delfi) | §"Public README — non-technical reader patterns" — Stripe/Raycast tone analysis; Section Writing Rules from `~/CLAUDE.md` |
| LAUNCH-01 | Install one-liner verified end-to-end against live URL on a fresh machine before sharing | §"LAUNCH-01 procedure" — backup-restore dance; tag-must-exist-first sequencing; verification commands |
| LAUNCH-02 | All 5 doc types generated end-to-end at least once, visually inspected | §"LAUNCH-01 procedure §Step 4" — folded into LAUNCH-01 verification |
| LAUNCH-03 | Repo has VERSION file pinned to `0.1.0` and `v0.1.0` git tag | §"GitHub release — chicken-and-egg sequencing" — tag must exist on remote BEFORE install.sh runs against bumped VERSION |
| LAUNCH-04 | GitHub release exists with short changelog | §"GitHub release process for skills" — `gh release create v0.1.0 --notes-file ...` |
</phase_requirements>

## Project Constraints (from CLAUDE.md)

- **Language:** README written in English regardless of Santiago's input language (root CLAUDE.md Rule #2).
- **Tone:** README must follow `~/CLAUDE.md` "Documentation Methodology — Story First" recursively. Handbook-not-pitch tone applies to the README itself. The same Section Writing Rules `story-arc.md` enforces on generated docs apply to the README.
- **Project root CLAUDE.md "describe what IS, not what changed":** README must not have version-history phrasing ("now supports", "improved", "new in v0.1.0"). Describe the system as it IS.

## Summary

Phase 4 closes the v1 launch by wiring three orthogonal, low-risk additions onto a stable base: a single new lazy-loaded sub-file (`skill/source-mode.md`) that turns the Phase-2 source-mode stub into a real source-grounded arc-proposal branch; a from-scratch public-facing `README.md` written for Delfi following the same Story-First methodology the skill itself enforces; and a launch-hardening pass that verifies the public install one-liner end-to-end against the live URL, bumps `VERSION` to `0.1.0`, tags `v0.1.0`, and cuts a GitHub release.

The most important technical insight is empirically established by Phase 2's fixture (`/Users/sperezasis/projects/code/deshtml/.planning/phases/02-story-arc-gate-handbook-end-to-end/fixture/FIXTURE-NOTES.md` line 25): `$ARGUMENTS` substitutes the user's input verbatim — Claude Code does NOT resolve `@`-mentions before the skill runs. SKILL.md sees the literal string `@path/to/draft.md`, and `source-mode.md` must use Claude's Read tool to load the file. This is the foundation of D4-03.

The biggest sequencing risk is the install-verification chicken-and-egg: `bin/install.sh` does `git clone --depth 1 --branch "v${version}"` against whatever `VERSION` says. Bumping `VERSION` to `0.1.0` and committing without first creating the `v0.1.0` tag means every public install attempt fails until the tag lands. The plan must order LAUNCH steps as: (a) verify with current `0.0.1` against live URL, (b) bump VERSION to `0.1.0` and commit, (c) push commit to main, (d) create + push the `v0.1.0` tag pointing at the bump commit, (e) ONLY THEN cut the `gh release create`. Any deviation breaks the public install for users who paste the one-liner between (b) and (d).

**Primary recommendation:** Build `skill/source-mode.md` first (it's the only behavioral change), write the README second (pure docs, low risk), do launch hardening last in the strict sequence above. Ship a minimal `CHANGELOG.md` alongside the GitHub release notes for repo-offline browsability. Run LAUNCH-01 with the cheap backup-restore path on Santiago's Mac, not Docker.

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|--------------|----------------|-----------|
| `$ARGUMENTS` substitution at slash-command invocation | Claude Code runtime | — | Owned by Claude Code; SKILL.md just consumes the substituted string [VERIFIED: code.claude.com/docs/en/skills + Phase 2 fixture line 25] |
| Mode detection (interview vs source) at turn 1 | `skill/SKILL.md` Step 1 (existing) | — | Mechanical regex on `$ARGUMENTS`; Phase 4 only flips the stub action |
| Source-mode branch (read source, detect type, build arc) | `skill/source-mode.md` (NEW) | — | Lazy-loaded sub-file; SKILL.md ≤200 line cap continues |
| Source-file resolution (`@<path>` → file content) | Claude's Read tool, invoked by `source-mode.md` | — | `$ARGUMENTS` is literal; Read tool resolves the path |
| Type detection from source content | `skill/source-mode.md` heuristics block | — | Keep heuristics in one place, surfaced as `Detected type: <type>` |
| Source-grounded arc generation | `skill/source-mode.md` → handoff to `skill/story-arc.md` | — | Source mode jumps directly to story-arc.md (no interview); arc gate is shared and unchanged |
| Format auto-selection in source mode | `skill/SKILL.md` Step 5b (existing) | — | Same mechanical decision tree as interview mode (D3-01); no source-mode branch needed |
| README authoring | `README.md` at repo root | — | Single document; renders on github.com/sperezasis/deshtml as the entry point for new users |
| Live-URL install verification | Manual procedure documented in `04-VERIFICATION.md` | — | One-time gate run by Santiago; not automated in V1 |
| `VERSION` bump | `VERSION` file + single commit | — | Trivial mechanical change |
| Git tag creation | Local `git tag v0.1.0` + `git push origin v0.1.0` | — | Tag is the deployment artifact `bin/install.sh` clones against |
| GitHub release | `gh release create v0.1.0 --notes-file CHANGELOG-v0.1.0.md` | optional `CHANGELOG.md` at repo root | Notes describe what shipped this version specifically; README describes what IS |

## Standard Stack

Phase 4 reuses the entire Phase 1/2/3 stack unchanged. No new runtime dependencies.

### Core (already shipped)

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Claude Code skill format | current spec (code.claude.com/docs/en/skills) | `SKILL.md` + sub-files; `$ARGUMENTS` substitution; `${CLAUDE_SKILL_DIR}` path resolution | Official, only format with `disable-model-invocation` and slash-command invocation [VERIFIED: code.claude.com/docs/en/skills] |
| Bash 3.2+ POSIX `bin/install.sh` | shipped in Phase 1 | Atomic curl-pipe-bash installer | macOS default bash; passes shellcheck; main() wrapper + mktemp staging + atomic swap proven in `01-VERIFICATION.md` |
| `git clone --depth 1 --branch "v${version}"` | git 2.0+ | Tag-pinned shallow clone in install.sh line 38 | The clone target is the tagged commit, NOT main — this is the load-bearing reason the tag MUST exist before VERSION is bumped to match |

### New for Phase 4

| Tool | Version | Purpose | Why Standard |
|------|---------|---------|--------------|
| `gh` CLI | 2.x | `gh release create v0.1.0 --notes-file CHANGELOG-v0.1.0.md` | Already on Santiago's machine; canonical way to cut GitHub releases without leaving terminal [CITED: cli.github.com/manual/gh_release_create] |

**No installs needed.** All Phase 4 work uses tools already present.

## Architecture Patterns

### System Architecture: source-mode wiring

```
User types /deshtml @draft.md
        │
        ▼
Claude Code substitutes $ARGUMENTS = "@draft.md" (LITERAL — no @-resolution)
        │
        ▼
SKILL.md Step 1: regex (^|[[:space:]])@\S+ matches → source mode
        │
        ▼
SKILL.md Step 1: Read skill/source-mode.md (NEW lazy-load)
        │
        ▼
source-mode.md:
   1. Resolve path from $ARGUMENTS (strip leading @, expand ~ if present)
   2. Read tool against the path → source text in context
      (or: pasted-prose form → use $ARGUMENTS as source verbatim)
   3. If file missing: print "File not found: ${path}", stop (NO fallback)
   4. Type detection: scan source for code blocks / "we propose" / numbered slides /
      bullet density / H2 count → emit "Detected type: <type>"
   5. Build arc by EXTRACTING beats from source content (D4-05)
   6. Hand off to story-arc.md (Step 4 in SKILL.md flow — unchanged)
        │
        ▼
story-arc.md: present arc + flowing paragraph + self-review + approval gate (UNCHANGED from Phase 2)
        │
        ▼
SKILL.md Step 5/5b/6/7/8: filename, format selection, render, audit, open (UNCHANGED from Phase 3)
```

### Component Responsibilities

| File | Phase 4 Responsibility |
|------|------------------------|
| `skill/SKILL.md` | Step 1 source-mode branch flips from "Reply with stub and stop" to "Read `${CLAUDE_SKILL_DIR}/source-mode.md` now". ≤2 lines changed. ≤200 line cap holds. |
| `skill/source-mode.md` (NEW) | Path resolution, Read-tool ingest, type detection heuristics, source-grounded arc proposal, handoff to story-arc.md. Single file (per CONTEXT.md recommendation). |
| `skill/story-arc.md` | Unchanged. Source mode reuses the existing arc gate end-to-end. |
| `skill/interview/*.md` | Unchanged. Source mode SKIPS the interview by design. |
| `skill/audit/run.sh` | Unchanged. README is markdown — not subject to the audit (audit is HTML-output-specific). |
| `README.md` | Replace Phase 1 stub with Delfi-targeted full README following D4-10 section order. |
| `VERSION` | Bumped `0.0.1` → `0.1.0` after LAUNCH-01 passes. |
| `CHANGELOG.md` (NEW, optional) | Single v0.1.0 entry with the four-phase summary. |
| `CHANGELOG-v0.1.0.md` (transient) | Source for `gh release create --notes-file`. May be the same file as `CHANGELOG.md` or a temporary phase artifact under `.planning/`. |

### Pattern 1: `$ARGUMENTS` is literal — Claude Code does NOT expand `@`-mentions

**What:** When the user types `/deshtml @path/to/draft.md`, the `$ARGUMENTS` substitution in SKILL.md receives the raw string `@path/to/draft.md`. Claude Code does NOT pre-resolve the `@`-mention to file content.

**When to use:** Always. Source-mode logic must use Claude's Read tool to load the file content from the path.

**Source:** [VERIFIED: code.claude.com/docs/en/skills §"Pass arguments to skills"] cited in `02-RESEARCH.md` line 13. [VERIFIED: empirical run, Phase 2 fixture FIXTURE-NOTES.md line 25 — "With no arguments to `/deshtml`, the literal string is empty (not `<no arguments>`). SKILL.md's mode-detection regex correctly handles all three documented cases."]

**Implication for D4-03:** `source-mode.md` MUST contain a Read-tool invocation against the resolved path. The skill cannot assume the file content is already in context.

```markdown
<!-- source-mode.md excerpt -->
## Step 1 — Resolve and read source

Inspect $ARGUMENTS (passed in from SKILL.md):

If it contains an @-mention (regex `(^|[[:space:]])@\S+`):
  1. Extract the first @-token, strip the leading `@`.
  2. Expand a leading `~` to $HOME (so `@~/notes.md` works).
  3. Use the Read tool against the resolved path.
  4. If Read fails (file missing), reply EXACTLY:
     > File not found: <resolved-path>
     and stop. Do NOT fall back to interview mode (SKILL-03).
Otherwise (pasted-prose form, $ARGUMENTS > 200 chars):
  Use $ARGUMENTS verbatim as source text. No path resolution.
```

### Pattern 2: Source-grounded arc — extract, don't invent (D4-05)

**What:** When building the arc from source material, every `One sentence` cell must be derivable from a span of source content. If a beat slot has no source content, skip the row — never fabricate.

**When to use:** Only in source mode. Interview mode's arc generation is materially different (the arc emerges from the 5 interview answers, which are by design declarative).

**Pattern:**

1. **Extract first.** Read the entire source. Identify candidate beats by scanning for: H1/H2 headings, numbered list items, paragraph topic shifts, explicit transitions ("First, …", "Next, …", "Finally, …").
2. **Map to type.** Each detected doc type has a canonical beat order:
   - `handbook` → Setup → Mechanism × N → Detail
   - `pitch` → Hook → Problem → Solution → Ask
   - `technical-brief` → Decision → Alternatives → Trade-offs → Consequence
   - `presentation` → one beat per slide (slide N → row N)
   - `meeting-prep` → Purpose → Context → Talking points → Risks/asks
3. **Fill from source spans.** For each beat, find the source span that delivers that beat. The `One sentence` cell paraphrases that span (not invents from training data).
4. **Skip empty beats.** If no source span maps to a beat, omit the row. Document the skip in the self-review status line: `   ✗ skipped — no source content for "Trade-offs" beat`.
5. **Self-review unchanged.** `story-arc.md` Step C runs as-is — handbook tone on titles, causality chain, name-the-thing.

**Failure modes:**
- **Hallucinated beat:** model invents a "Solution" section because the canonical pitch arc has one, even if the source draft never describes a solution. Mitigation: explicit skip-if-empty rule in `source-mode.md`; status-line evidence that the row was intentionally omitted.
- **Paraphrase drift:** model paraphrases the source so loosely that the `One sentence` cell makes a claim the source doesn't support. Mitigation: in source mode, the self-review's "name the thing" check should additionally verify the named thing appears in the source (mechanical grep on the section's noun phrase).
- **Tone leakage:** source is casual ("we just want a quick way to…") and the arc reflects that in titles. Mitigation: D4-06 — section TITLES still go through the handbook-tone rubric in `story-arc.md`; only the BODY voice anchors to source. Same divergence rule pitch/presentation already document in their interview files.

**Source patterns in the wild:**
- Hardik Pandya, *Expose your design system to LLMs* — argues for closed token layer + post-generation audit; the same closed-extraction discipline applies to "closed beat layer" — predefined beat shapes per doc type, populated from source not training data ([CITED: hvpandya.com/llm-design-systems])
- *LLM Based Multi-Agent Generation of Semi-structured Documents*, arXiv 2402.14871 — "Without the Narrative Agent, this kind of structure emerges only by accident, if at all" — evidence that source-grounded extraction beats outline-and-fill ([CITED: arxiv.org/html/2402.14871v1])

### Pattern 3: Type-detection heuristics — order of evaluation matters

**What:** Source-mode type detection must run heuristics in priority order so the strongest signal wins. Ambiguous → `handbook` fallback.

**Recommended evaluation order (highest signal first):**

| Priority | Type | Signal | Concrete pattern |
|----------|------|--------|------------------|
| 1 | `presentation` | Slide-shaped fragments | grep for `^---$` slide separators OR `^Slide \d+` OR `^# Slide` OR `^\d+\. ` followed by ≤3 lines of body OR explicit "next slide" cues. Strongest signal — slides are visually distinctive. |
| 2 | `meeting-prep` | Meeting/agenda language | grep for `agenda`, `attendees`, `talking points`, `action items`, `decisions`, `risks` (case-insensitive). Combined with bullet-density >60% of non-empty lines. |
| 3 | `pitch` | "We propose" + audience + ask | grep for `we (propose|recommend|are asking)`, `our solution`, `the (problem|opportunity)`, plus an explicit ask sentence. Heavier than handbook because pitches have a specific shape. |
| 4 | `technical-brief` | Code blocks + decision/trade-off language | grep for fenced code blocks (` ``` ` count ≥2), AND any of: `decision`, `trade-?off`, `alternative`, `architecture`, `design choice`, `implementation`. |
| 5 | `handbook` | Multiple H2 sections + reference shape | count of `^## ` headings ≥3, AND no stronger signal above. Default fallback if all others miss. |

**Why this order:**
- Presentation cues are visually distinctive and rare — false-positive risk is low. Evaluate first.
- Pitch and technical-brief share "we propose" + "decision" language; pitches usually frontload the ask, briefs frontload code. Evaluating pitch before brief avoids classifying a pitch with code samples as a brief.
- Handbook is the broadest shape and the safest fallback (per D4-04).

**Surface to user (D4-04):** ONE line, before the arc, no question:

```
Detected type: pitch
```

NOT:

```
I think this is a pitch — should I proceed?
```

The user can override on first revision message ("this should be a brief"); the regenerate flow already handles that via the existing `story-arc.md` revision loop.

**Reliability assessment:**
- Presentation detection: HIGH (slide separators are unambiguous)
- Meeting-prep detection: MEDIUM-HIGH (agenda vocabulary is concentrated)
- Pitch detection: MEDIUM (depends on whether the source uses canonical pitch language; many pitches don't)
- Technical-brief detection: MEDIUM (false positives on handbooks that include code samples)
- Handbook fallback: LOW signal but SAFE (most general type; user override via revision loop is cheap)

### Pattern 4: README structure for non-technical first-time readers

**What:** A README aimed at Delfi (non-technical, ≤5 min reading time) leads with what-it-is, shows install before any conceptual exposition, walks through the first run as an experience, and saves limitations / credits / license for the end.

**When to use:** D4-10 mandates this exact section order. Don't deviate.

**Reference READMEs that hit this tone correctly:**

- **Raycast script-commands** ([VERIFIED: github.com/raycast/script-commands README]) — leads with one-sentence what-it-is, then install, then "create your own", then troubleshooting. Tone is handbook ("To install new commands, follow these steps"), not pitch. Section progression moves from consumption to production. Same pattern D4-10 prescribes.
- **Stripe stripe-cli** — leads with "The Stripe CLI helps you build, test, and manage your Stripe integration", then install one-liners per platform, then a usage walkthrough. No marketing bullet list. [CITED: github.com/stripe/stripe-cli — pattern verified against Phase 2/3 research and the Section Writing Rules already enshrined in story-arc.md]
- **GSD itself** (the inspiration source per PROJECT.md "Inspiration / shape") — same install-first, walkthrough-second pattern.

**Anti-patterns to avoid (already in PITFALLS.md as Pitfall 17):**

- ❌ "Powerful HTML doc generation in seconds" — pitch tone, violates handbook rule.
- ❌ "Easy install — just paste this" — pitch tone; the install IS easy, no need to say so.
- ❌ Marketing-style feature bullet list at the top — Delfi reads top-to-bottom, not scans.
- ❌ Hidden assumed knowledge — "drop it into your skills directory" assumes the user knows what a skills directory is.

**Code-block conventions:**

- Show a code block ONLY for: install one-liner, uninstall one-liner. These are commands the user copy-pastes.
- Do NOT show code blocks for: example output filenames, example arc tables, example HTML. Describe in prose.
- The `/deshtml` invocation itself is a slash command, not a shell command — do NOT put it in a `bash` code-block. Use inline backticks: `/deshtml`.

**Tone calibration:** the README must pass the same self-review checks `story-arc.md` runs on the generated docs:
- Titles describe what IS, not what users will feel ("Install" ✓; "Get installed in 30 seconds" ✗).
- Causality chain: each section follows from the previous. "What it is" → "How to install" → "What happens on first run" → "Five doc types" → "Source-mode shortcut" → "How to uninstall" → "What it does NOT do".
- Name the thing: every section title contains the concrete noun the section is about ("The five doc types" ✓; "What you get" ✗).

### Pattern 5: GitHub release process — chicken-and-egg sequencing

**What:** `bin/install.sh` line 38 runs `git clone --depth 1 --branch "v${version}"` against whatever `VERSION` says. If `VERSION` reads `0.1.0` but no `v0.1.0` tag exists on the remote, every public install fails.

**Strict ordering required:**

1. **Verify with current `0.0.1`** (LAUNCH-01). The live URL clones `v0.0.1` (already tagged in Phase 1 per `01-VERIFICATION.md`). Confirm this tag actually exists before relying on it: `git ls-remote --tags origin v0.0.1`.
2. **All 5 doc types pass** (LAUNCH-02). Folded into LAUNCH-01 verification per D4-17.
3. **Bump VERSION** (LAUNCH-03 step 1). Single commit: `0.0.1` → `0.1.0`. Commit message references LAUNCH-03.
4. **Push the bump commit to main**. After this point, the live install is BROKEN until step 5 lands. Window must be minimal.
5. **Create + push the `v0.1.0` tag** pointing at the bump commit. `git tag v0.1.0 && git push origin v0.1.0`. The live install now works again.
6. **Cut the GitHub release** (LAUNCH-04). `gh release create v0.1.0 --notes-file CHANGELOG-v0.1.0.md`. The release is just metadata layered on top of the existing tag — no binaries to attach (the skill payload is git-cloned by install.sh).

**Why no `--target` flag:** `gh release create v0.1.0 --target main` would auto-create the tag against `main` HEAD. We do NOT want that — we want the tag against the explicit VERSION-bump commit, created locally and pushed first. Skipping `--target` and relying on the existing tag is correct. [CITED: cli.github.com/manual/gh_release_create — "If a matching git tag does not yet exist, one will automatically get created from the latest state of the default branch" — this is the behavior to AVOID; we want the tag we explicitly created]

**Why no binaries:** deshtml has no compiled artifacts. The skill payload is the `skill/` directory in the repo, fetched by install.sh via `git clone`. Release notes describe what shipped, not artifacts attached.

**Use `--verify-tag` for safety:** `gh release create v0.1.0 --verify-tag --notes-file CHANGELOG-v0.1.0.md` aborts if the tag doesn't exist on remote — protects against accidental auto-tag-creation if the local tag wasn't pushed. Recommended.

**`gh release create` recommended invocation:**

```bash
# After VERSION bump committed AND tag pushed:
git push origin main          # bump commit
git tag v0.1.0                # tag the bump commit (or specific commit SHA)
git push origin v0.1.0        # push the tag

# Verify tag is on remote BEFORE cutting the release:
git ls-remote --tags origin v0.1.0    # must print a line; otherwise stop

# Cut the release:
gh release create v0.1.0 \
  --verify-tag \
  --title "v0.1.0" \
  --notes-file CHANGELOG-v0.1.0.md
```

[VERIFIED: cli.github.com/manual/gh_release_create — `--notes-file` reads from file or stdin via `-`; `--verify-tag` aborts if tag missing from remote; `--target` only used when wanting auto-tag-creation — we don't]

### Anti-patterns to avoid

- **Source-mode falling back to interview mode silently** — explicit SKILL-03 contract. If `@<path>` resolution fails, error and stop; never re-ask "what's your topic?". Already mitigated by Phase 2 stub design; Phase 4 must preserve.
- **README marketing-tone leakage** — the README is the only file outsiders read first; pitch tone here contradicts the methodology the skill itself enforces. Run the README through the same Section Writing Rules `story-arc.md` runs on output.
- **Cutting the GitHub release before pushing the tag** — `gh release create` will auto-create the tag against main HEAD if it doesn't exist, which is almost certainly the wrong commit (won't be the VERSION-bump commit). Use `--verify-tag`.
- **Bumping VERSION before LAUNCH-01 verification** — D4-15 explicitly orders LAUNCH-01 (verify with `0.0.1`) BEFORE the bump. Bumping first means LAUNCH-01 runs against an unstable URL.
- **Splitting `source-mode.md` per detected type** — would create 5 nearly-identical files differing only in beat-shape map. CONTEXT.md recommends ONE file with a type-detection block at the top.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Resolve `@<path>` to file content | Custom path-handling shell logic | Claude's built-in `Read` tool inside `source-mode.md` | Read tool already handles `~` expansion, missing-file errors, and binary detection. SKILL.md frontmatter already lists `Read` in `allowed-tools`. |
| Detect doc type from source | LLM-judgment-only "what type is this?" | Concrete grep/regex signals per type, evaluated in priority order | LLM-judgment-only is exactly the silent-classification pitfall. Mechanical signals are auditable; ambiguity falls back to `handbook` per D4-04. |
| Build the arc from source | Free-form "summarize this draft as 5 beats" | Predefined per-type beat shapes (see Pattern 2), populated by source spans | Free-form summarization invents structure. Predefined beat shapes anchor the LLM to known-good arcs. |
| Approval gate in source mode | New approval logic in `source-mode.md` | Reuse `story-arc.md` end-to-end (D4-05 mandates handoff to story-arc) | Approval whitelist + revision loop are already proven in Phase 2. Duplicating creates a second source of truth. |
| Cut a GitHub release manually via web UI | Click through github.com/.../releases/new | `gh release create v0.1.0 --verify-tag --notes-file <file>` | One command, scriptable, idempotent on retry. Web UI is unauditable. |
| Generate release notes from PR titles | Copy-paste from `gh pr list` | Hand-write a 1-paragraph + 4-bullet changelog per CONTEXT.md D4-16 | The 4 phases already have summary files (`01-SUMMARY.md` ... `03-SUMMARY.md` — Phase 4's writes during this phase). The release notes are derivative of those, not of PRs. |
| Test install on a fresh machine | Set up VM / Docker container | Backup-restore on Santiago's Mac (CONTEXT.md cheap-path recommendation) | Docker overhead vs backup-restore's `mv` operation: the former takes 30 min and adds zero verification value over the latter. Cheap path is correct. |
| Maintain CHANGELOG.md as a separate file | Synthesize from git log on every release | Single `CHANGELOG.md` at repo root, append-only, hand-written per release | Git log is implementation detail; CHANGELOG describes what users care about. Worth the manual upkeep at this scale (1 release in v1). |

**Key insight:** Phase 4 is largely a "wire-up + write docs" phase. The expensive parts (skill flow, audit, design system) are already shipped. Resist the urge to "improve" them — every Phase 4 task should be additive or doc-only.

## Runtime State Inventory

**Phase 4 includes a launch step (LAUNCH-01) that touches user runtime state on Santiago's Mac.** This inventory matters because the verification procedure must not destroy his working dev install.

| Category | Items Found | Action Required |
|----------|-------------|------------------|
| Stored data | None — deshtml has no databases, no caches, no telemetry. The audit script reads files; `Read`/`Write` happen in user CWD. | None. |
| Live service config | None — no servers, no APIs, no scheduled tasks, no daemons. | None. |
| OS-registered state | `~/.claude/skills/deshtml/` — Santiago's working dev install. LAUNCH-01 backup-restore must protect this. | Plan must explicitly back up and restore. Recommended procedure below. |
| Secrets / env vars | None — installer reads no env vars, the skill reads no secrets. | None. |
| Build artifacts | None — no compiled code, no installed packages (no pip/npm install at runtime). | None. |

**LAUNCH-01 backup-restore procedure (D4-14, D4-17):**

```bash
# 1. Snapshot the working dev install
mv ~/.claude/skills/deshtml ~/.claude/skills/deshtml.dev-backup
test -d ~/.claude/skills/deshtml.dev-backup || { echo "FATAL: backup did not move"; exit 1; }

# 2. Run the public install one-liner against the LIVE URL
curl -fsSL https://raw.githubusercontent.com/sperezasis/deshtml/main/bin/install.sh | bash

# 3. Verify the install completed
test -d ~/.claude/skills/deshtml || { echo "FATAL: install did not create dir"; exit 1; }
test -f ~/.claude/skills/deshtml/SKILL.md || { echo "FATAL: SKILL.md missing"; exit 1; }
test -d ~/.claude/skills/deshtml/skill || { echo "FATAL: skill payload missing"; exit 1; }
diff -rq ~/.claude/skills/deshtml.dev-backup/skill ~/.claude/skills/deshtml/skill | head
# Expected: differences only on files Phase 4 changed (SKILL.md Step 1 stub flip,
# new source-mode.md, possibly README.md). Confirm no UNEXPECTED diffs.

# 4. Run all 5 doc types end-to-end in a fresh Claude Code session (LAUNCH-02)
# (Manual: open Claude Code, run /deshtml × 5 with the canonical fixture answers,
# inspect each output against the Caseproof reference.)

# 5. Restore the dev install
rm -rf ~/.claude/skills/deshtml
mv ~/.claude/skills/deshtml.dev-backup ~/.claude/skills/deshtml
test -d ~/.claude/skills/deshtml || { echo "FATAL: restore failed"; exit 1; }
```

**Failure recovery if step 5 doesn't run** (Mac crashes mid-test, etc.): the backup at `~/.claude/skills/deshtml.dev-backup` is recoverable on next boot. The plan should document this so a partial run is not a disaster.

## Common Pitfalls

These extend `.planning/research/PITFALLS.md`. Pitfalls 14-18 from the existing PITFALLS.md (source-mode silent fallback, README scope creep, version-tag mismatch, README pitch tone, launch checklist drift) remain authoritative — confirmed below with Phase-4-specific concretes.

### Pitfall A (extends PITFALLS.md #14): Source-mode silent fallback to interview

**What goes wrong:** User runs `/deshtml @missing-file.md`. The Read tool fails. `source-mode.md` falls back to "let's run an interview instead" rather than erroring. User thinks the source was used.

**Why it happens:** Easy to write defensive code as "if Read fails, fall back". Defensive code violates SKILL-03's no-silent-fallback contract.

**How to avoid:**
- Explicit `File not found: <path>` error and STOP. Do NOT continue to interview mode.
- Mode-detection still locks at turn 1 — the `@<path>` token in `$ARGUMENTS` already committed the user to source mode. A failed Read inside source mode means SOURCE FAILED, not "go interview instead".

**Warning signs:** Any code path in `source-mode.md` that reads "if read fails, ask the user…" — must be `if read fails, error and stop`.

### Pitfall B (extends PITFALLS.md #15): README scope creep

**What goes wrong:** README grows past Delfi's ≤5 min reading budget — adds CONTRIBUTING section, troubleshooting FAQ, design philosophy, V2 roadmap, screenshots gallery.

**Why it happens:** Each addition feels harmless individually. Together they bury the install one-liner three scrolls down.

**How to avoid:**
- Ruthlessly enforce the D4-10 section list. Anything not in those 9 sections is OUT.
- If a section seems necessary that isn't in D4-10, add it to V2 deferred ideas — not to v0.1.0 README.
- Run a 5-minute timer test: read the README aloud start to finish. If it takes >5 min, cut.

**Warning signs:** Section count >9. README >150 lines. README has a table of contents (Delfi reads top-to-bottom; a TOC means the README is too long).

### Pitfall C (extends PITFALLS.md #16): Version-tag-branch sequencing mismatch

**What goes wrong:** VERSION is bumped to `0.1.0` and pushed to main. A user pastes the install one-liner. `bin/install.sh` reads `0.1.0` from the live VERSION file, then `git clone --depth 1 --branch v0.1.0` — fails because `v0.1.0` tag doesn't exist yet. User sees an opaque git error and gives up.

**Why it happens:** Natural ordering instinct says "bump version, then tag". Wrong order for tag-pinned installers.

**How to avoid:**
- Strict ordering: verify with `0.0.1` → bump VERSION + commit (DO NOT PUSH YET) → create local `v0.1.0` tag pointing at the bump commit → push BOTH commit and tag in tight sequence (or push tag first, then commit — but the order doesn't matter as long as tag lands before any user pastes the one-liner).
- Better: push the tag first (it points at the unpushed local commit, so it'll be invalid until commit lands — but `git push origin v0.1.0` will refuse). Order is push commit, then push tag immediately.
- Best: use `git push origin main v0.1.0` in a single command — both refs in one push. Atomic from the user's POV.
- Use `--verify-tag` on `gh release create` so a missing tag aborts the release rather than auto-creating against main HEAD.

**Warning signs:** Any plan task ordering that bumps VERSION and "later" creates the tag. Any release command without `--verify-tag`.

### Pitfall D (extends PITFALLS.md #17): README written in pitch tone

**What goes wrong:** README opens with "deshtml is the easiest way to create stunning HTML documents". User experiences cognitive dissonance when the skill itself rejects pitch tone.

**Why it happens:** README authoring conventions reward marketing tone; the project's methodology rejects it. The conflict is silent unless tested.

**How to avoid:**
- Run README titles and lead paragraphs through the same `story-arc.md` Step C self-review (handbook tone, causality chain, name the thing).
- Forbid pitch vocabulary in the README: same banned-word list as `story-arc.md` Step C check (a) — `easily`, `seamlessly`, `powerful`, `revolutionary`, `game-changing`, `in seconds`, `everything you need`, `out of the box`, `effortlessly`, `breakthrough`, `next-generation`, `cutting-edge`.
- Call out the rule explicitly in the plan's verify-block.

**Warning signs:** Any title or lead paragraph in README.md grep-matches the banned list above.

### Pitfall E (extends PITFALLS.md #18): Launch checklist drift

**What goes wrong:** LAUNCH-01 runs for handbook + pitch + presentation, "good enough", check the box. Tech-brief and meeting-prep are NOT verified against the live install. Launch happens. A user (Delfi) tries `/deshtml` for a brief — fails.

**Why it happens:** Verification fatigue. Five doc types is a lot of fixture runs. Skipping one "low risk" type seems harmless.

**How to avoid:**
- LAUNCH-02's verbatim wording: "All five doc types have been generated end-to-end at least once and visually inspected against the Caseproof references." All FIVE. Plan task must enumerate all five with checkboxes; partial check is failure.
- The same canonical fixtures from Phase 2/3 (`fixture/<type>/interview-answers.md` + `expected-arc.md`) are reusable. Re-run them via the live install, not via a `cp -R` shortcut. The point of LAUNCH-01 is to test the curl-pipe-bash path end-to-end.
- Document in `04-VERIFICATION.md`: 5 rows, one per doc type, each with `audit exit` and `visual gate` columns.

**Warning signs:** `04-VERIFICATION.md` has fewer than 5 doc-type rows. Any row with "verified via cp -R" instead of "verified via curl-pipe-bash live URL".

### Pitfall F (NEW for Phase 4): Source-mode arc fabricates beats not present in source

**What goes wrong:** Source draft has 3 beats of content. Source-mode arc proposes 6 beats — three are inferred/invented to "fill out" the canonical pitch shape (Hook → Problem → Solution → Ask). User approves without noticing. Generated HTML contains 6 sections, three of which read as plausible but unsupported by the source.

**Why it happens:** D4-05 mandates "extract, don't invent" but LLMs default to filling out a known shape. Without explicit skip-if-empty enforcement, gaps get filled with plausible-looking beats.

**How to avoid:**
- D4-05's explicit "skip a beat with no source content" rule must be hard-coded in `source-mode.md`.
- Self-review status line MUST report skipped beats: `   ✗ skipped — no source content for "Trade-offs" beat` so the user sees what was omitted.
- If the resulting arc has fewer than 3 beats, fall back to interview mode — flag to user: "Source has only 2 beats of content; switching to interview mode to flesh out." This is the ONLY case where a source-to-interview transition is allowed, and it's loud, not silent.

**Warning signs:** Generated HTML has more sections than the source has structural divisions. Self-review status lines never report skips (statistically implausible across many runs).

### Pitfall G (NEW for Phase 4): `gh release create` auto-creates wrong tag

**What goes wrong:** Release is cut before the local `v0.1.0` tag is pushed. `gh release create v0.1.0` auto-creates the tag against main HEAD — but main HEAD is whatever was committed last (might be a doc fix, not the VERSION-bump commit). The release now points at the wrong commit; install.sh clones from that commit, which has the right VERSION but possibly unrelated other changes.

**Why it happens:** `gh release create` defaults to auto-tag-creation when the tag is missing. Easy to forget to push the local tag first.

**How to avoid:**
- Use `--verify-tag` on every `gh release create` invocation. Aborts if tag missing from remote.
- Plan task explicitly orders: push commit → push tag → verify with `git ls-remote --tags origin v0.1.0` → cut release.

**Warning signs:** `gh release create` invocation without `--verify-tag`. Plan task doesn't include the `git ls-remote` verification step.

## Code Examples

### Source-mode skeleton (`skill/source-mode.md`)

```markdown
<!-- skill/source-mode.md -->
# Source mode — source-grounded arc proposal

SKILL.md reads this file when Step 1 detects source mode (`@<path>` or
prose >200 chars in $ARGUMENTS). Follow it end-to-end. Hand off to
story-arc.md for the approval gate (Step 4 in SKILL.md flow).

## Step 1 — Resolve and read source

Inspect $ARGUMENTS (the literal string passed in from SKILL.md).

If $ARGUMENTS contains an @-mention (regex `(^|[[:space:]])@\S+`):
  1. Extract the first @-token. Strip the leading `@`.
  2. Expand a leading `~` to $HOME.
  3. Read the file using the Read tool.
  4. If Read fails (file not found), reply EXACTLY:
     > File not found: <resolved-path>
     and stop. Do NOT fall back to interview mode (SKILL-03).

Else (pasted prose, $ARGUMENTS > 200 chars after stripping `<no arguments>`):
  Use $ARGUMENTS verbatim as the source text.

## Step 2 — Detect type

Run these checks in priority order. First match wins. Default: handbook.

1. Presentation:  source contains `^---$` slide separators OR `^Slide \d+`
                  OR `^# Slide` OR ≥3 lines of `^\d+\. ` followed by ≤3-line
                  bodies.
2. Meeting-prep:  source contains agenda/attendees/talking points/action items
                  language (≥2 of these terms) AND bullet density >60%.
3. Pitch:         source contains "we propose" / "we recommend" / "we are asking"
                  AND an explicit ask sentence (interrogative or imperative).
4. Technical-brief: source contains ≥2 fenced code blocks AND any of:
                  decision/trade-off/alternative/architecture/implementation.
5. Handbook:      source has ≥3 H2 sections (`^## `). Or fallback if 1-4 miss.

Print exactly one line to the user (no decoration):

> Detected type: <type>

Do NOT ask the user to confirm. The user can override on first revision message.

## Step 3 — Build source-grounded arc

Map source content to the type's canonical beat shape:
  handbook        → Setup → Mechanism × N → Detail
  pitch           → Hook → Problem → Solution → Ask
  technical-brief → Decision → Alternatives → Trade-offs → Consequence
  presentation    → one beat per slide (slide N → row N)
  meeting-prep    → Purpose → Context → Talking points → Risks/asks

For each beat:
  - Find the source span that delivers that beat.
  - The arc's `One sentence` cell paraphrases that span — does NOT invent.
  - If no source span maps to a beat, OMIT the row (do NOT fabricate).

If the resulting arc has <3 beats, FALL BACK TO INTERVIEW MODE WITH AN
EXPLICIT NOTICE (the only allowed source→interview transition):

> Source has only N beats of content. Switching to interview mode to
> flesh out. Picking up where source mode left off — Detected type: <type>.

Then read `${CLAUDE_SKILL_DIR}/interview/${type}.md` and continue per
SKILL.md Step 3.

## Step 4 — Hand off to story-arc

Read `${CLAUDE_SKILL_DIR}/story-arc.md` and follow it end-to-end. Source mode
reuses the existing arc gate — table format, flowing-paragraph diagnostic,
self-review (Step C handbook-tone applies even when source voice is casual —
TITLES describe what IS regardless), 9-phrase approval whitelist, revision loop.

## What this file must NOT do

- Must not be inlined into SKILL.md (D4-08 — ≤200 line cap).
- Must not silently fall back from source mode to interview mode on Read failure
  (SKILL-03 contract).
- Must not invent beats not present in source (D4-05).
- Must not paraphrase the type-detection signals to the user as a question
  (D4-04 — show as one-liner, not as "is this a pitch?").
```

### SKILL.md Step 1 patch (≤2 lines change)

```markdown
<!-- skill/SKILL.md, Step 1, source-mode branch -->
<!-- BEFORE (Phase 2 stub): -->
1. If `$ARGUMENTS` matches the regex `(^|[[:space:]])@\S+` → **source mode**.
   Reply with EXACTLY this message and stop:

   > Source mode is coming in Phase 4. For now, run `/deshtml` with no arguments to use the interview.

<!-- AFTER (Phase 4): -->
1. If `$ARGUMENTS` matches the regex `(^|[[:space:]])@\S+` → **source mode**.
   Read `${CLAUDE_SKILL_DIR}/source-mode.md` now. Follow it end-to-end. Return
   here only when source-mode.md hands off to Step 5 (or earlier if it falls
   back to interview mode per its Step 3 explicit notice).
```

Same change for the prose >200 chars branch (point 2 in Step 1).

### README.md skeleton (Delfi-targeted)

```markdown
# deshtml

deshtml is a Claude Code skill that turns ideas into designed HTML
documents. You tell it about your topic; it asks a few questions; you
approve a story arc; it writes a single self-contained HTML file in
your current folder.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/sperezasis/deshtml/main/bin/install.sh | bash
```

The installer drops the skill into `~/.claude/skills/deshtml/`. After
this, every Claude Code session has the `/deshtml` command available.

## First run

Open Claude Code. Type `/deshtml`. The skill asks five questions about
your document — what type it is (pick one of five), who reads it, what
it covers. Then it shows you a story arc as a table, with the same
sentence column read top-to-bottom as a flowing paragraph so you can
see whether the narrative holds together. You either reply `approve`
or describe what to change. Once approved, the skill writes a single
HTML file to the folder you ran the command from and opens it in your
browser.

## The five doc types

- **Handbook** — multi-section reference doc with a sidebar.
- **Pitch** — problem → solution → ask, single linear page.
- **Technical brief** — architecture or decision write-up for engineers.
- **Presentation** — single-page slide deck, scroll to advance.
- **Meeting prep** — briefing doc with context, goals, talking points.

## Source mode — `/deshtml @file.md`

If you already have a draft, run `/deshtml @your-draft.md` (or paste
the draft in the prompt). The skill skips the interview, reads your
draft, proposes an arc grounded in your content, and hands you the
same approval step.

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/sperezasis/deshtml/main/bin/uninstall.sh | bash
```

Or remove the directory directly:

```bash
rm -rf ~/.claude/skills/deshtml
```

## Known limitations

- **Offline:** the design uses Inter via Google Fonts. Without internet, the
  document falls back to your system font — readable, but the layout
  spacing was tuned for Inter.
- **macOS-first:** the skill auto-opens the generated file with `open`,
  which is macOS-only. On Linux, the file is written but not opened.
- **One file per run:** each `/deshtml` invocation writes one HTML
  file and stops. To iterate, edit the file directly or ask Claude in
  conversation — the skill itself doesn't have an in-place revision loop.

## Design system

The visual design comes from the Caseproof Documentation System.
[Documentation System](link-to-doc-system).

## License

MIT. See `LICENSE`.
```

### CHANGELOG-v0.1.0.md (release notes)

```markdown
# v0.1.0 — first public release

deshtml v0.1.0 ships the five v1 doc types end-to-end with a curl-pipe-bash
installer, a story-arc gate, and a post-generation audit.

- Phase 1 — Foundation: atomic curl-pipe-bash installer; verbatim Caseproof
  palette, typography, components, and two format skeletons (Handbook 960px
  sidebar, Overview 1440px linear); color-scheme: light hardening verified
  against iOS Safari forced-dark-mode.
- Phase 2 — Story-arc gate + Handbook end-to-end: mandatory arc-table
  approval gate with flowing-paragraph diagnostic and 9-phrase approval
  whitelist; post-generation audit (4 mechanical rules); Handbook fixture
  visually matches the Caseproof reference.
- Phase 3 — Remaining four doc types: pitch, technical-brief, presentation,
  meeting-prep added with type-tailored interviews; Presentation format
  skeleton (CSS scroll-snap, no JS); audit Rule 5 enforces interview-schema
  drift; format auto-selects from approved arc.
- Phase 4 — Source-mode + README + launch hardening: `/deshtml @file.md`
  reads a draft and proposes a source-grounded arc; public README aimed at
  first-time non-technical readers; install one-liner verified end-to-end
  against the live URL.

Install: `curl -fsSL https://raw.githubusercontent.com/sperezasis/deshtml/main/bin/install.sh | bash`
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Skill as one large `SKILL.md` with all logic inlined | Lean SKILL.md (≤200 lines) + lazy-loaded sub-files | Phase 2 (D2-01) | Source-mode is just one more lazy-loaded sub-file (D4-02). No SKILL.md bloat. |
| Mode detection via LLM judgment ("does this look like source material?") | Mechanical regex on `$ARGUMENTS` | Phase 2 (D2-03) | Source-mode detection is deterministic; Phase 4 only flips the action, not the detection. |
| Generic "AI rewrites your document" tone in product positioning | Story-First methodology + handbook tone enforced on output | Phase 2 (story-arc.md) | README must follow the same tone — handbook describing what IS, not pitching. |
| GitHub release notes copy-pasted from PR titles | Hand-written 1-paragraph + 4-bullet summary keyed to phase summaries | Phase 4 (this research) | More work but accurately describes what shipped; not implementation-dependent. |

**Deprecated/outdated:**
- "Inline all source-mode logic in SKILL.md" — would blow the ≤200 line cap. Mitigated by lazy-load discipline (D4-02).
- "Bump VERSION and tag in any order" — wrong; tag must exist on remote before any user pastes the one-liner against the bumped VERSION. Mitigated by strict sequencing in Pattern 5.
- "README is just an install snippet" — Phase 1 stub was correct for pre-launch; Phase 4 replaces with the full Delfi-targeted document.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | `gh release create --verify-tag` aborts cleanly if the tag is missing on remote (rather than auto-creating against main HEAD) | Pattern 5, Pitfall G | LOW — verified via [CITED: cli.github.com/manual/gh_release_create]. If wrong, plan can fall back to manual tag-existence check via `git ls-remote` before invocation. |
| A2 | Type-detection heuristics' priority order (presentation > meeting-prep > pitch > technical-brief > handbook) reflects real-world false-positive rates | Pattern 3 | MEDIUM — based on signal-strength reasoning, not empirical corpus measurement. If wrong, false positives surface during Wave 0 fixture run; user override via revision loop is cheap. Plan should include 2-3 source-mode fixture inputs covering ambiguous cases (e.g., a pitch with code samples) to validate. |
| A3 | The Read tool inside `source-mode.md` correctly handles `~`-prefixed paths and absolute paths without additional shell expansion | Pattern 1, code example | LOW — Read tool documentation says it accepts absolute paths; `~` may need explicit substitution to `$HOME` before passing. Wave 0 fixture should test `@~/notes.md` form explicitly. |
| A4 | Santiago's working-tree dev install is at `~/.claude/skills/deshtml/` (not symlinked, not project-scoped) — so the LAUNCH-01 backup-restore `mv` works as expected | Runtime State Inventory | LOW — Phase 1 install layout is documented; if symlinked, the `mv` may produce surprising behavior (move the symlink itself, not the target). Plan should include a pre-LAUNCH-01 `ls -la ~/.claude/skills/deshtml` to confirm. |
| A5 | A 5-beat-or-fewer source draft is rare enough that the source→interview fallback (Pitfall F) is acceptable UX | Pitfall F | LOW — fallback is loud, not silent; user understands what happened. If common, may warrant a "minimum source size" warning in README. |

**If this table is empty:** Not applicable — all five claims are explicit assumptions worth flagging to the planner.

## Open Questions

1. **Where does CHANGELOG.md live, and is it the same file as `CHANGELOG-v0.1.0.md`?**
   - What we know: CONTEXT.md "Claude's Discretion" recommends a minimal `CHANGELOG.md` at repo root in addition to GitHub Releases. CONTEXT.md D4-16 mentions `CHANGELOG-v0.1.0.md` as the `--notes-file` source.
   - What's unclear: Whether these are the same file or whether `CHANGELOG-v0.1.0.md` is a transient artifact under `.planning/phases/04-.../` consumed by `gh release create` and then deleted.
   - Recommendation: Maintain `CHANGELOG.md` at repo root (append-only, will accumulate over future versions). `gh release create --notes-file CHANGELOG.md` is fine for v0.1.0 since it's the only entry. For v0.2.0+ the planner can extract just that version's section into a transient file. Plan to ship `CHANGELOG.md` at repo root, not a phase-local file.

2. **Does the README's "Design system" section link to the public Caseproof Documentation System or to Santiago's local `~/work/caseproof/DOCUMENTATION-SYSTEM.md`?**
   - What we know: D4-10 mandates a "Design system credit" section linking to the Caseproof Documentation System.
   - What's unclear: Whether DOCUMENTATION-SYSTEM.md is publicly hosted or local-only.
   - Recommendation: Defer to discuss-phase / planner. If not public, link to a public Caseproof page (caseproof.com) and credit the system by name without linking the local file. Plan to flag this for Santiago's confirmation.

3. **Should source-mode handle multi-file `@`-mentions (`/deshtml @a.md @b.md`)?**
   - What we know: D4-03 only describes the single-file case.
   - What's unclear: Whether multi-file is in scope for v0.1.0.
   - Recommendation: Out of scope for v0.1.0 — single source file or pasted prose only. Document as V2 deferred. The detection regex already only extracts the FIRST `@`-token; subsequent tokens are ignored. Plan should make this explicit.

4. **What's the user-visible error if `$ARGUMENTS` contains `@<path>` AND >200 chars of prose simultaneously?**
   - What we know: Phase 2's Step 1 evaluates `@<path>` first, then prose-length. The first match wins.
   - What's unclear: Whether the prose accompanying `@file.md` is treated as ignored or as additional context.
   - Recommendation: First-match-wins (`@<path>` mode); the prose is ignored unless it's also part of the source content. Document this in `source-mode.md` as a contract. Edge case unlikely to fire in practice (Delfi will type `/deshtml @draft.md` plain).

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| `gh` CLI | LAUNCH-04 (`gh release create v0.1.0`) | ✓ | 2.x (Santiago's machine) | Manual release via web UI; loses scriptability but works |
| `git` | LAUNCH-03 (tag + push) and `bin/install.sh` (clone) | ✓ | 2.x | None — required, already in use |
| `curl` | LAUNCH-01 (install one-liner verification) | ✓ | macOS bundled | None — required |
| `bash` | `bin/install.sh` | ✓ | 3.2 (macOS default) | None — required |
| GitHub repo `sperezasis/deshtml` exists and is public | LAUNCH-01 (live URL fetch), LAUNCH-04 | ✓ | per PROJECT.md "Repository" | None — repo creation precedes all phases |
| `v0.0.1` tag on origin | LAUNCH-01 (install.sh clones it) | ✓ (per Phase 1 SUMMARY) | matches VERSION | Verify before LAUNCH-01: `git ls-remote --tags origin v0.0.1` must print a hash |

**Missing dependencies with no fallback:** None.
**Missing dependencies with fallback:** None.

The Phase 4 environment is identical to Phase 3's. No new tools needed.

## Sources

### Primary (HIGH confidence)

- `/Users/sperezasis/projects/code/deshtml/.planning/phases/02-story-arc-gate-handbook-end-to-end/fixture/FIXTURE-NOTES.md` — empirical confirmation that `$ARGUMENTS` is literal and Phase 2 mode-detection regex works as designed (line 25)
- `/Users/sperezasis/projects/code/deshtml/.planning/phases/02-story-arc-gate-handbook-end-to-end/02-RESEARCH.md` — `$ARGUMENTS` semantics, `${CLAUDE_SKILL_DIR}` path resolution, sub-file lazy load, and source-mode detection regex (lines 13, 33, 162-179, 211-219, 942-986)
- [CITED: code.claude.com/docs/en/skills] — official Claude Code skill format reference for `$ARGUMENTS` substitution and `${CLAUDE_SKILL_DIR}`
- [CITED: cli.github.com/manual/gh_release_create] — `--notes-file`, `--verify-tag`, `--target` flag semantics; tag auto-creation behavior
- [CITED: cli.github.com/manual/gh_release_delete] — release/tag separation; `--cleanup-tag` flag
- `/Users/sperezasis/CLAUDE.md` — Documentation Methodology Story First; Section Writing Rules; root rule "describe what IS"
- `/Users/sperezasis/projects/code/deshtml/.planning/research/PITFALLS.md` — pitfalls 1-13 (canonical) and 14-18 (Phase-4-specific)
- `/Users/sperezasis/projects/code/deshtml/skill/SKILL.md` — current Step 1 stub message; integration point for D4-08 patch
- `/Users/sperezasis/projects/code/deshtml/skill/story-arc.md` — arc gate, approval whitelist, self-review rubric (reused unchanged in source mode)
- `/Users/sperezasis/projects/code/deshtml/bin/install.sh` — `git clone --depth 1 --branch "v${version}"` line 38 — load-bearing for the tag-must-exist sequencing
- `/Users/sperezasis/projects/code/deshtml/.planning/phases/01-foundation-installer-design-assets/01-VERIFICATION.md` — Phase 1 install pattern proven; `v0.0.1` tag already exists

### Secondary (MEDIUM confidence)

- [VERIFIED via WebFetch: github.com/raycast/script-commands README] — non-technical README pattern (what-it-is → install → walkthrough → troubleshooting); handbook tone confirmed
- [CITED: hvpandya.com/llm-design-systems] — closed token layer + post-generation audit; analogous closed beat-shape layer for source mode (Pattern 2)
- [CITED: arxiv.org/html/2402.14871v1] — LLM document generation, narrative-agent pattern, source-grounded extraction beats outline-fill (Pattern 2 failure-mode discussion)

### Tertiary (informational)

- [CITED: github.com/stripe/stripe-cli README] — pattern reference for install-first non-technical READMEs
- `/Users/sperezasis/projects/code/deshtml/.planning/phases/02-story-arc-gate-handbook-end-to-end/02-SUMMARY.md` — Phase 2 hand-off informing release notes
- `/Users/sperezasis/projects/code/deshtml/.planning/phases/03-remaining-four-doc-types/03-SUMMARY.md` — Phase 3 hand-off informing release notes

## Metadata

**Confidence breakdown:**
- Source-mode wiring (Pattern 1, Pattern 2, code examples): HIGH — `$ARGUMENTS` semantics empirically verified by Phase 2 fixture; lazy-load pattern proven in Phase 2 (story-arc.md, interview/*.md) and Phase 3 (source-mode.md is the next instance of the same pattern).
- Type detection heuristics (Pattern 3): MEDIUM — priority order based on signal-strength reasoning, not empirical corpus. Validate with 2-3 source-mode fixture inputs covering ambiguous cases during Wave 0.
- README authoring (Pattern 4): HIGH — Section Writing Rules already governing this project (verified via story-arc.md self-review and Phase 2/3 outputs). Reference READMEs (Raycast, Stripe-style) verified against handbook-tone pattern.
- GitHub release process (Pattern 5, Pitfall G): HIGH — `gh release create` flag semantics verified via cli.github.com docs; chicken-and-egg sequencing logic mechanical.
- LAUNCH-01 procedure (Runtime State Inventory): HIGH — backup-restore pattern verified against Santiago's existing dev install layout (per Phase 1 verification).
- Pitfalls A-G: HIGH — A-E are explicit refinements of PITFALLS.md 14-18, F-G are Phase-4-specific landmines surfaced during this research.

**Research date:** 2026-04-28
**Valid until:** 2026-05-28 (30 days — `gh` CLI flags + Claude Code skill format are stable; the only fast-moving piece is Anthropic's potential introduction of a built-in `/deshtml` collision risk, mitigated by Pitfall 5)
