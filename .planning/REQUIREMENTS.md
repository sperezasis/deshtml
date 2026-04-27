# deshtml — v1 Requirements

**Project:** deshtml — installable Claude Code skill that turns ideas into beautifully designed, story-first HTML documents.
**Last updated:** 2026-04-27 after initialization
**Source:** `.planning/PROJECT.md` (scope), `.planning/research/SUMMARY.md` (technical implications)

---

## v1 Requirements

### Install (INSTALL)

- [x] **INSTALL-01
**: User can install deshtml by pasting a single shell command (curl-pipe-bash) into a terminal — no follow-up steps, no prompts, no sudo
- [x] **INSTALL-02
**: Installer drops the skill payload into `~/.claude/skills/deshtml/` and only that directory (user scope, not project scope)
- [x] **INSTALL-03
**: Installer is atomic — a dropped network connection mid-install never leaves a half-installed skill (stage to temp dir, move on success)
- [x] **INSTALL-04
**: Installer is idempotent — running the install command on an already-installed skill updates it in place without breaking anything
- [x] **INSTALL-05
**: Installer refuses to run as root and prints a friendly explanation
- [x] **INSTALL-06
**: User can uninstall deshtml by running a documented one-liner that removes `~/.claude/skills/deshtml/` and prints a confirmation
- [x] **INSTALL-07
**: After install, `/deshtml` is available in any Claude Code session for that user without restart or reconfiguration

### Skill invocation (SKILL)

- [x] **SKILL-01** (plan 02-02): User can invoke `/deshtml` with no arguments to start a from-scratch interview
- [ ] **SKILL-02**: User can invoke `/deshtml @path/to/draft.md` (or paste raw text in the prompt) and the skill uses the source as the document's raw material instead of interviewing
- [x] **SKILL-03** (plan 02-02): Skill detects mode (interview vs source) at turn 1 — never silently falls back from one mode to the other
- [x] **SKILL-04** (plan 02-02): Skill's first interactive question is the document type (5 options) and the answer branches the rest of the run
- [x] **SKILL-05** (plan 02-02): SKILL.md stays under 200 lines (flow-control only); per-type prompts and design assets load on demand via Claude reading their files

### Story arc gate (ARC)

- [x] **ARC-01** (plan 02-02): Skill produces a story arc as a table with columns: `#`, `Beat`, `Section`, `One sentence`, `Reader feels`
- [x] **ARC-02** (plan 02-02): Skill renders the "One sentence" column read top-to-bottom as a flowing paragraph immediately under the table so narrative gaps are visible at a glance
- [x] **ARC-03** (plan 02-02): Skill performs an automated self-review pass on the arc before showing it to the user (handbook-tone check, causality-chain check, "name the thing" title check)
- [x] **ARC-04** (plan 02-02): Skill blocks HTML generation until the user types `approve` (or equivalent explicit confirmation) — no implicit approval, no silent passthrough
- [x] **ARC-05** (plan 02-02): User can request changes to the arc; skill regenerates the table + paragraph and re-asks for approval; loops until approved

### Document types (DOC)

V1 ships tailored interviews and arc templates for five document types:

- [ ] **DOC-01**: Pitch — problem → solution → ask narrative, Overview format (1440px linear)
- [x] **DOC-02** (plan 02-02): Handbook / system overview — multi-section reference doc, Handbook format (960px sidebar)
- [ ] **DOC-03**: Technical brief — architecture / decision write-up for engineers, Handbook format
- [ ] **DOC-04**: Presentation / slide deck — single-page anchor-navigated slides, custom Presentation format (CSS scroll-snap, no JS)
- [ ] **DOC-05**: Meeting prep — briefing doc with context, goals, talking points, Overview format
- [ ] **DOC-06**: Each doc type has its own interview file (`skill/interview/<type>.md`) following an identical schema (audience → material → section conventions → tone notes → handoff to story-arc)
- [x] **DOC-07** (plan 02-02): Each doc type's interview asks no more than 5 questions before producing the arc

### Design system fidelity (DESIGN)

- [x] **DESIGN-01** (plan 01-02): Generated HTML uses only colors from the Caseproof Documentation System palette — no hex literals appear outside the `:root` CSS variable block
- [x] **DESIGN-02** (plan 01-02): Generated HTML uses only typography rules from the Caseproof Documentation System (Inter via Google Fonts, with `-apple-system, sans-serif` fallback)
- [x] **DESIGN-03** (plan 01-02): Generated HTML uses only components from a closed component library — no freelance markup
- [ ] **DESIGN-04**: Skill auto-selects format: Handbook (960px sidebar) for 4+ sections, Overview (1440px linear) for 1-3, Presentation for slide decks
- [x] **DESIGN-05** (plan 01-02): Design tokens (palette, typography, components, format skeletons) ship as verbatim CSS / HTML files in `skill/design/` that Claude pastes — never paraphrases — into output
- [x] **DESIGN-06
**: A post-generation audit pass rejects output containing hex literals outside the variable block, unknown CSS class names, or markup not in the component library
- [x] **DESIGN-07** (plan 01-02): Generated HTML declares `color-scheme: light` and includes the meta tag that prevents browser forced-dark-mode from inverting the palette

### Output behavior (OUTPUT)

- [x] **OUTPUT-01** (plan 02-02): Skill writes a single self-contained `.html` file to the user's current working directory
- [x] **OUTPUT-02** (plan 02-02): Output filename follows `YYYY-MM-DD-<slug>-<type>.html`; on collision a numeric suffix is appended (`-2`, `-3`)
- [x] **OUTPUT-03** (plan 02-02): After writing, skill runs `open <file>` so the document opens in the user's default browser without further action
- [x] **OUTPUT-04** (plan 02-02): Skill prints the absolute path of the written file at the end of the run
- [x] **OUTPUT-05** (plan 02-02): Generated HTML opens correctly when double-clicked (file://) — no JS errors, no broken layout, no missing stylesheets (wired via three-CSS-file inlining; empirically verified by plan 02-04 fixture run)

### Documentation (DOCS)

- [ ] **DOCS-01**: Repo README explains: what deshtml is, the install one-liner, basic usage (`/deshtml`, `/deshtml @file.md`), the 5 supported doc types, the uninstall command, and a link to the Caseproof Documentation System
- [ ] **DOCS-02**: README has a "Known Limitations" section documenting offline behavior (system-font fallback) and the macOS-first auto-open behavior
- [ ] **DOCS-03**: README is written for a first-time, non-technical user (target reader: Delfi)

### Launch verification (LAUNCH)

- [ ] **LAUNCH-01**: Install one-liner has been verified end-to-end against the live public URL on a fresh machine before the URL is shared
- [ ] **LAUNCH-02**: All five doc types have been generated end-to-end at least once and visually inspected against the Caseproof reference implementations
- [ ] **LAUNCH-03**: Repo has a `VERSION` file and a `v0.1.0` git tag corresponding to the launch commit
- [ ] **LAUNCH-04**: GitHub release exists with a short changelog

---

## v2 Requirements (deferred — do not build in V1)

- Configurable design tokens / alternate palettes for non-Caseproof users
- Self-hosted base64-inlined fonts for true offline rendering
- Print stylesheet polish and one-click PDF export
- Sub-templates within doc types (e.g., "pitch — internal" vs "pitch — external")
- Linux / Windows auto-open behavior parity
- Inline-render-in-Gmail compatibility (would force tableized inline-style HTML; compromises design fidelity)

---

## Out of Scope

- **In-skill revision loop after HTML is generated** — edits go through normal Claude conversation. Reason: Claude Code already handles iterative editing well; building a revision UI inside the skill is duplicate effort.
- **Multi-file output / asset folders / sidebars-as-separate-files** — single self-contained `.html` only. Reason: portability is the entire distribution model.
- **Hosted version, web UI, non-Claude-Code distribution** — terminal install is the only delivery channel. Reason: scope discipline; the value is in the HTML, not in the delivery surface.
- **Authentication, telemetry, analytics, user accounts** — public repo, no tracking. Reason: trust + simplicity for a tool used by family and small team.
- **Auto-publishing the output** (GitHub Pages, hosting, sharing links) — user handles distribution. Reason: out of the value proposition; one more thing to maintain.
- **Project-scope skill install** (`.claude/skills/` inside a project dir) — user scope only. Reason: Claude Code currently treats project-scope skill files as read-only (issue #36155), which breaks the install / update flow.
- **Mermaid diagrams, syntax highlighting, Reveal.js, any external JS dep in output** — design system covers visual needs without JS. Reason: self-contained-file constraint and dark-mode/forced-color compatibility.
- **Auto-update check on every run** — user reruns the install one-liner when they want updates. Reason: avoids network calls inside Claude Code sessions.

---

## Traceability

| REQ-ID | Phase | Status |
|--------|-------|--------|
| INSTALL-01 | Phase 1 | Pending |
| INSTALL-02 | Phase 1 | Pending |
| INSTALL-03 | Phase 1 | Pending |
| INSTALL-04 | Phase 1 | Pending |
| INSTALL-05 | Phase 1 | Pending |
| INSTALL-06 | Phase 1 | Pending |
| INSTALL-07 | Phase 1 | Pending |
| SKILL-01 | Phase 2 | Complete (02-02) |
| SKILL-02 | Phase 4 | Pending |
| SKILL-03 | Phase 2 | Complete (02-02) |
| SKILL-04 | Phase 2 | Complete (02-02) |
| SKILL-05 | Phase 2 | Complete (02-02) |
| ARC-01 | Phase 2 | Complete (02-02) |
| ARC-02 | Phase 2 | Complete (02-02) |
| ARC-03 | Phase 2 | Complete (02-02) |
| ARC-04 | Phase 2 | Complete (02-02) |
| ARC-05 | Phase 2 | Complete (02-02) |
| DOC-01 | Phase 3 | Pending |
| DOC-02 | Phase 2 | Complete (02-02) |
| DOC-03 | Phase 3 | Pending |
| DOC-04 | Phase 3 | Pending |
| DOC-05 | Phase 3 | Pending |
| DOC-06 | Phase 3 | Pending |
| DOC-07 | Phase 2 | Complete (02-02) |
| DESIGN-01 | Phase 1 | Complete (01-02) |
| DESIGN-02 | Phase 1 | Complete (01-02) |
| DESIGN-03 | Phase 1 | Complete (01-02) |
| DESIGN-04 | Phase 3 | Pending |
| DESIGN-05 | Phase 1 | Complete (01-02) |
| DESIGN-06 | Phase 2 | Pending |
| DESIGN-07 | Phase 1 | Complete (01-02) |
| OUTPUT-01 | Phase 2 | Complete (02-02) |
| OUTPUT-02 | Phase 2 | Complete (02-02) |
| OUTPUT-03 | Phase 2 | Complete (02-02) |
| OUTPUT-04 | Phase 2 | Complete (02-02) |
| OUTPUT-05 | Phase 2 | Complete (02-02) |
| DOCS-01 | Phase 4 | Pending |
| DOCS-02 | Phase 4 | Pending |
| DOCS-03 | Phase 4 | Pending |
| LAUNCH-01 | Phase 4 | Pending |
| LAUNCH-02 | Phase 4 | Pending |
| LAUNCH-03 | Phase 4 | Pending |
| LAUNCH-04 | Phase 4 | Pending |

**Coverage:** 43/43 v1 requirements mapped (100%)

---
