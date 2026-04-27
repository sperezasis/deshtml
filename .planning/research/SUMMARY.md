# Project Research Summary

**Project:** deshtml
**Domain:** Claude Code skill — installable, opinionated HTML document generator with story-first methodology gate
**Researched:** 2026-04-27
**Confidence:** HIGH

## Executive Summary

`deshtml` is a curl-pipe-bash installable Claude Code skill that turns ideas into self-contained HTML documents following the Caseproof Documentation System and the Story-First methodology. The stack is deliberately minimal — a `SKILL.md` prompt, reference HTML skeletons, embedded CSS fragments, and a POSIX bash installer — with no build toolchain and no runtime dependencies. Claude writes HTML directly by adapting reference skeletons, which is the only approach that faithfully reproduces the 20+ custom components in the design system. The recommended architecture separates distribution artifacts (installer scripts) from the skill payload (`skill/`), and keeps SKILL.md as lean flow-control that progressively loads per-type interview files and shared methodology assets only when needed.

The two most important structural decisions converge across all four research files: (1) the story-arc gate is a hard gate — no HTML is generated without explicit user approval of the arc table, and this is the product's moat; (2) per-type interview files must be separate files, not branches in a monolithic SKILL.md, because the mega-skill pattern is the most cited failure mode for Claude Code skills and would make every invocation token-heavy even for doc types not in use.

The primary risks are installer atomicity (partial install on dropped connection), design-token drift (LLMs hallucinate colors and class names without syntactic enforcement), and arc-gate degradation (users rubber-stamp the arc and blame the output). All three are preventable with specific, low-effort techniques: the `main()` wrapper + temp-dir staging pattern for the installer, verbatim CSS fragment files that Claude pastes rather than regenerates for design fidelity, and a forced `approve` string with the one-sentence column rendered as a flowing paragraph for the arc gate.

## Key Findings

### Recommended Stack

The stack is a Claude Code skill (`SKILL.md` with YAML frontmatter), a POSIX bash installer, embedded CSS and HTML skeleton files, and no other runtime. Claude writes HTML directly from reference skeletons — no markdown preprocessor, no templating engine, no JS framework. The existing `pm-system.html` (1,726 lines, single file) proves this produces design-system-faithful output without an intermediate layer. Google Fonts CDN via `@import` is the V1 font strategy with `-apple-system, sans-serif` as the graceful offline fallback. Self-hosting fonts as base64 is a V2 option if a real complaint arrives.

**Core technologies:**
- `SKILL.md` (Claude Code skill format, 2.1.88+): entry point and flow control — the only format with official slash-command invocation and `disable-model-invocation: true` support
- POSIX bash installer (`bin/install.sh`, Bash 3.2+): curl-pipe-bash one-liner with atomic staging, idempotent update, and root rejection
- Inline `<style>` + Google Fonts CDN: the production pattern already used by the Caseproof reference implementations; opens correctly via `file://`, email attachment, and AirDrop
- `skill/` directory as the install payload: `install.sh` copies only this directory into `~/.claude/skills/deshtml/`; no installer plumbing is exposed on user machines

### Expected Features

**Must have (table stakes):**
- One-line install (curl-pipe-bash) + global `/deshtml` command
- First question = document type (5 options, numbered, one-sentence descriptions for Delfi)
- Story arc gate: produces `#, Beat, Section, One sentence, Reader feels` table; requires explicit `approve` string before any HTML is generated; re-renders after every revision
- Self-review pass on the arc before presenting it to the user (handbook-tone enforcement, causality chain check, "name the thing" title check, "one sentence column reads as narrative" check)
- Source-material ingestion via `@file.md` or pasted text — mode detection at turn 1
- Format auto-selection: Handbook (960px, sidebar) for 4+ sections, Overview (1440px) for 1-3, Presentation as its own custom layout
- Single self-contained `.html` output in CWD, `YYYY-MM-DD-{slug}-{type}.html` naming, collision suffix on re-run
- Auto-open file at end + print absolute path
- Strict palette + typography via verbatim CSS fragment files; no hex literals outside the variable block
- Component-library-only HTML; no freelance markup; closed class list enforced in the prompt

**Should have (differentiators):**
- Two-pass arc quality: self-review before showing user, then forced-stop gate for user approval
- Handbook-tone rewrite pass — the most common AI failure mode for these docs
- Tailored arc templates per doc type (removes cold-start friction for Delfi)
- Source-mode shortcut: skip interview, go directly to arc proposal grounded in the source
- Image placeholder blocks (dashed-border gap divs) instead of auto-embedded data URIs
- `color-scheme: light` meta tag + CSS to block forced dark-mode inversion
- `scroll-margin-top` on all anchor targets to prevent sticky-nav occlusion

**Defer (v2+):**
- Configurable design tokens / alternate palettes
- Self-hosted base64-inlined fonts (offline/GDPR)
- Print stylesheet polish and PDF export workflow
- Additional sub-templates within existing doc types

**Explicit anti-features (never build in V1):**
- In-skill revision loop — use normal Claude conversation
- Multi-file output — single file is the entire distribution model
- Auto-publishing, telemetry, auth, user accounts
- Syntax highlighting, Mermaid diagrams, Reveal.js (all JS deps)
- Auto-update check on every run
- PDF export (browser print-to-PDF covers this without code)

### Architecture Approach

The architecture has four layers: Distribution (GitHub repo), Install (POSIX bash installer), Skill (the `skill/` payload in `~/.claude/skills/deshtml/`), and Output (single `.html` in user's CWD). Inside the skill layer, SKILL.md acts as lean flow-control only — it references four subsystems loaded progressively: `interview/<type>.md` (loaded after user picks type), `story-arc.md` (shared methodology gate, loaded after type interview), `design/` (CSS fragments + HTML skeletons, loaded only at render time after arc is approved). SKILL.md never inlines content from these files; it directs Claude to read them. This keeps every invocation token-efficient and makes adding a sixth doc type a single file drop.

**Major components:**
1. `install.sh` — atomic, idempotent, no-sudo POSIX bash installer; stages to temp dir, moves on success, wraps all logic in `main()` for truncation safety
2. `skill/SKILL.md` — flow control: detect input mode → branch by type → gate on arc → render; stays under 200 lines
3. `skill/interview/<type>.md` — one file per doc type (pitch, handbook, brief, deck, meeting); identical schema so SKILL.md treats them uniformly; ends by handing off to `story-arc.md`
4. `skill/story-arc.md` — shared methodology gate; arc-table format, approval requirement, Section Writing Rules enforcement; single source of truth for all 5 branches
5. `skill/design/` — embedded Caseproof Documentation System: `palette.css`, `typography.css`, `components.html`, `formats/handbook.html`, `formats/overview.html`; Claude pastes these verbatim, never regenerates them

### Critical Pitfalls

1. **Interactive prompts hang via `curl | bash`** — any `read` call reads from the pipe, not the keyboard, and freezes. Fix: no interactive prompts in the happy path; use `main()` wrapper; `read < /dev/tty` for unavoidable confirmations; provide `DESHTML_FORCE=1` env override.

2. **Partial install on dropped connection** — bash executes incrementally as bytes arrive; mid-script network drop leaves a half-installed skill. Fix: wrap all logic in `main()` called on the last line; stage to `mktemp -d`; atomic `cp -R` at the end; `set -euo pipefail` throughout.

3. **Design-system token drift** — LLMs hallucinate hex codes and class names when constraints are not syntactic. Fix: ship verbatim CSS variable block and class definitions as separate files Claude pastes; forbid hex literals outside the variable block; post-generation regex audit is a hard gate.

4. **Arc-gate rubber-stamping** — users skim and approve a flawed arc; structural problems surface only after 1,500 words are written. Fix: require explicit `approve` string; render "one sentence" column as a connected flowing paragraph under the table so narrative problems are visible at a glance.

5. **Mega-skill token bloat** — one SKILL.md with all 5 types branched inline grows past 500 lines and loads irrelevant context on every invocation. Fix: SKILL.md is flow-control only; each doc type is a separate file loaded on demand; design CSS is loaded only at render time.

## Implications for Roadmap

Build order converges across all four research files. The dependency graph is strict: design assets must exist before SKILL.md, SKILL.md must exist before the installer is meaningful, and one doc type must be proven end-to-end before four more are added.

### Phase 1: Installer Skeleton + Design Assets

**Rationale:** The installer is the user-facing contract; the design assets are the output-quality contract. Both must exist and be verifiable before any skill logic is written. Building installer plumbing after the skill is working is the anti-pattern ARCHITECTURE.md explicitly names.
**Delivers:** Working `install.sh` (atomic, idempotent, no-sudo); `uninstall.sh`; the complete `skill/design/` directory (SYSTEM.md, palette.css, typography.css, components.html, handbook.html skeleton, overview.html skeleton) extracted verbatim from the Caseproof reference implementations.
**Addresses:** Table-stakes install UX; design-fidelity baseline; pitfalls 1, 2, 3, 7, 8, 9.
**Avoids:** Building SKILL.md before the design assets it references exist.

### Phase 2: Story-Arc Gate + Handbook End-to-End

**Rationale:** The arc gate is the moat. Prove it on the densest doc type (Handbook: 4+ sections, sidebar, most components) before anything else. If it works on Handbook, the other four types are pattern applications. ARCHITECTURE.md explicitly recommends Handbook first.
**Delivers:** `skill/story-arc.md`; `skill/interview/handbook.md`; `skill/SKILL.md` (flow-control only, handbook branch only); complete end-to-end `/deshtml` run that produces a handbook matching `pm-system.html` side-by-side.
**Implements:** Lean SKILL.md, shared story-arc.md, verbatim CSS fragments, format skeletons.
**Avoids:** Pitfalls 3, 4, 10, 11, 13.

### Phase 3: Remaining Four Doc Types

**Rationale:** With handbook proven, the other four types are mechanical schema applications. Deck is the structural outlier (CSS-only scroll-snap slide layout) and should be built last within this phase.
**Delivers:** `skill/interview/pitch.md`, `brief.md`, `deck.md`, `meeting.md`; Presentation format skeleton (custom layout); updated SKILL.md with all five branches.
**Addresses:** All five type-specific features including tailored arc templates and type-specific anti-features.
**Avoids:** Pitfall 12 (over-questioning — ≤5 questions per type, validated with Delfi before shipping).

### Phase 4: Source-Mode + Quality Passes + README

**Rationale:** Source-mode and quality passes are differentiators that require the base flow to be stable first. README is last because the install command must be stable before it's documented for public consumption.
**Delivers:** Source-mode detection in SKILL.md; two-pass arc quality (self-review before presenting + forced-stop before generating); post-generation rules-check pass; README written for a non-technical first-time user.
**Addresses:** Pitfall 6 (ignored source material), pitfall 3 (outline-fill prose), pitfall 10 (rubber-stamped arc); FEATURES.md differentiators.

### Phase 5: V1 Hardening + Public Launch

**Rationale:** The "looks done but isn't" checklist from PITFALLS.md has 12 items that each catch a distinct class of shipping bug. Work through it before the install URL is shared publicly.
**Delivers:** Verified install one-liner (tested via `curl | bash` against the live URL); offline rendering test; dark-mode test on iOS Safari; collision-suffix on second run; `VERSION` file + `v0.1.0` git tag; GitHub release with changelog.
**Addresses:** Full "looks done but isn't" checklist; pitfall 1, 2, 7, 8, 11 verification.

### Phase Ordering Rationale

- Design assets before SKILL.md: SKILL.md references files that must exist before it can be tested. Inverting this means testing flow-control against placeholders.
- Arc gate before doc types: the gate is shared by all five types. A working gate on handbook means all subsequent types inherit a real gate.
- One type end-to-end before five: the interview files follow the same schema. Writing all five before testing one produces five broken implementations.
- Installer first and last: built in Phase 1 (skeleton), verified in Phase 5 (hardening) — maximum time for atomic-staging patterns to be exercised before the URL is public.
- Source-mode and quality passes in Phase 4: differentiators that require stable base flow before branching is layered on top.

### Research Flags

Needs iteration during planning:
- **Phase 2, self-review pass:** prompt-engineering for handbook-tone enforcement is the least-specified piece in the research; plan 2-3 rounds of iteration budget
- **Phase 3, Presentation type:** CSS-only scroll-snap slide layout; spike (30 min) to confirm `scroll-snap-type: y mandatory` works reliably in Chrome and Safari before writing the interview file
- **Phase 4, rules-check pass:** post-generation prose audit is cited in research but no working implementation to copy; expect iteration

Standard patterns — skip research-phase:
- **Phase 1:** installer pattern fully specified; design extraction is mechanical from existing reference files
- **Phase 5:** pure QA checklist execution

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | Verified against current Claude Code docs (2026-04-27); installer pattern cross-checked against three public skill repos; reference HTML confirmed against `pm-system.html` |
| Features | HIGH | Driven by PROJECT.md, DOCUMENTATION-SYSTEM.md, and GSD skill; only gap is Delfi's actual behavior (conservatively designed around) |
| Architecture | HIGH | Skill structure spec is authoritative; install pattern is conventional; one-level-deep reference rule is from Anthropic best practices |
| Pitfalls | HIGH | Curl-pipe-bash pitfalls sourced from real post-mortems; design-token drift from empirical LLM CSS research; name-collision from open Claude Code issues |

**Overall confidence:** HIGH

### Gaps to Address

- **Email-rendering expectation:** PROJECT.md says "opens correctly when emailed." STACK.md interprets this as "opened in a browser from email" not inline Gmail rendering (Gmail strips `<style>` entirely). Confirm with Santiago before Phase 5: if true inline rendering is required, V1 strategy changes substantially (fully inline per-tag CSS, web-safe fonts only). Recommendation: V1 targets browser-open-from-attachment only; document this in README Known Limitations.
- **Project vs user scope install:** PITFALLS.md notes project-scoped skills are now read-only (Claude Code issue #36155). User scope (`~/.claude/skills/`) is the right V1 target. Confirm that global-only install is acceptable for all three users.
- **Base64-inlined fonts decision:** Deferred to V2 per STACK.md. Document explicitly in README "Known Limitations" so offline/corporate-network degradation is a stated decision, not a surprise.
- **Delfi user testing:** Interview design assumptions (≤5 questions, plain-English phrasing, example arc shown first) are LOW confidence on her actual behavior. Validate with Delfi before Phase 3 ships; if she abandons mid-interview, the interview design is wrong.

## Sources

### Primary (HIGH confidence)
- `code.claude.com/docs/en/skills` — skill format, directory layout, naming rules, invocation control, 500-line guidance
- `platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices` — progressive disclosure, mega-skill anti-pattern, one-level-deep references
- `/Users/sperezasis/projects/code/deshtml/.planning/PROJECT.md` — requirements, scope, constraints, key decisions
- `/Users/sperezasis/CLAUDE.md` — Story-First methodology, Section Writing Rules
- `/Users/sperezasis/work/caseproof/DOCUMENTATION-SYSTEM.md` — palette, typography, components, layout, two formats
- `pm-system.html` (local Caseproof reference) — 1,726-line handbook; confirmed Google Fonts + inline `<style>` as working production pattern
- `hvpandya.com/llm-design-systems` — closed token layer, post-generation audit script pattern
- `arxiv.org/html/2402.14871v1` — LLM document generation, narrative-agent pattern, outline-fill failure mode

### Secondary (MEDIUM confidence)
- `oaustegard/claude-skills`, `alirezarezvani/claude-skills`, `s2005/claude-code-skill-template` — curl-pipe-bash convention and `~/.claude/skills/<name>/` path confirmed
- `linuxvox.com/blog/execute-bash-script-remotely-via-curl/` — `/dev/tty` solution for interactive prompts in piped scripts
- `dev.to/operous/how-to-build-a-trustworthy-curl-pipe-bash-workflow-4bb` — `main()` wrapper + atomic staging pattern
- Claude Code issues #33080, #14945, #36155 — skill name collision, project-scope read-only behavior

### Tertiary (informational)
- `emailonacid.com` — Gmail strips `<style>` and web fonts; background for email-rendering gap
- `xjavascript.com/blog/how-to-prevent-force-dark-mode-by-system/` — `color-scheme: light` + meta tag
- `gomakethings.com` — `scroll-margin-top` fix for sticky-nav anchor occlusion

---
*Research completed: 2026-04-27*
*Ready for roadmap: yes*
