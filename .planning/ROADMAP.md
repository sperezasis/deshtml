# Roadmap: deshtml

## Overview

deshtml ships in four phases that follow the strict dependency graph from research: design assets and the installer skeleton must exist before any skill logic, the story-arc gate must be proven on the densest doc type (Handbook) before the other four are added, and the install one-liner must be verified against the live public URL before it is shared. Phase 1 builds the foundation that everything else assumes. Phase 2 proves the moat — the story-arc gate plus a handbook generated end-to-end that matches `pm-system.html` side-by-side. Phase 3 replicates the proven pattern across the remaining four doc types. Phase 4 layers the source-mode shortcut and quality passes on top of a stable base, writes the README, and runs the launch hardening checklist before tagging `v0.1.0`.

## Phases

- [x] **Phase 1: Foundation — Installer + Design Assets** - Atomic curl-pipe-bash installer and verbatim Caseproof design fragments ready for Claude to paste
- [x] **Phase 2: Story-Arc Gate + Handbook End-to-End** - Mandatory arc-approval gate proven on a single handbook flow that matches the Caseproof reference
- [x] **Phase 3: Remaining Four Doc Types** - Pitch, technical brief, presentation, and meeting prep tailored to the same arc gate and design system
- [ ] **Phase 4: Source-Mode, README, and Launch Hardening** - Source-material shortcut, quality passes, public README, and verified `v0.1.0` release

## Phase Details

### Phase 1: Foundation — Installer + Design Assets
**Goal**: A user can install deshtml from a single shell command, and Claude has every verbatim design asset it needs to render Caseproof-faithful HTML once the skill logic exists.
**Depends on**: Nothing (first phase)
**Requirements**: INSTALL-01, INSTALL-02, INSTALL-03, INSTALL-04, INSTALL-05, INSTALL-06, INSTALL-07, DESIGN-01, DESIGN-02, DESIGN-03, DESIGN-05, DESIGN-07
**Success Criteria** (what must be TRUE):
  1. Pasting the documented one-liner into a fresh terminal installs deshtml into `~/.claude/skills/deshtml/` with no prompts, no sudo, and no follow-up steps
  2. Re-running the install command on an already-installed skill updates it in place; killing the network mid-install leaves the existing install untouched (atomic staging via temp dir + `main()` wrapper)
  3. The documented uninstall one-liner removes `~/.claude/skills/deshtml/` cleanly and prints a confirmation
  4. `skill/design/` contains the verbatim Caseproof palette CSS, typography CSS, component-library HTML, Handbook 960px skeleton, and Overview 1440px skeleton — opening either skeleton in a browser visually matches the Caseproof reference implementations
  5. Every design skeleton declares `color-scheme: light` plus the `<meta name="color-scheme">` tag and survives forced-dark-mode in iOS Safari
**Plans**: TBD
**UI hint**: yes

### Phase 2: Story-Arc Gate + Handbook End-to-End
**Goal**: A user can run `/deshtml`, answer a handbook interview, approve a story arc, and receive a self-contained `.html` file in their CWD that is visually indistinguishable from `pm-system.html`.
**Depends on**: Phase 1
**Requirements**: SKILL-01, SKILL-03, SKILL-04, SKILL-05, ARC-01, ARC-02, ARC-03, ARC-04, ARC-05, DOC-02, DOC-07, DESIGN-06, OUTPUT-01, OUTPUT-02, OUTPUT-03, OUTPUT-04, OUTPUT-05
**Success Criteria** (what must be TRUE):
  1. `/deshtml` (no args) launches an interview that asks document type as the first question and runs the handbook branch in five questions or fewer
  2. The skill produces an arc table with the canonical five columns plus the "one sentence" column rendered as a flowing paragraph, and refuses to generate HTML until the user types `approve` (or equivalent explicit confirmation)
  3. The user can request arc changes; the skill regenerates the table + paragraph and re-asks for approval, looping until approved
  4. After approval, the skill writes `YYYY-MM-DD-<slug>-handbook.html` to the user's CWD, runs `open <file>`, prints the absolute path, and the file opens correctly via `file://` with no JS errors and no broken layout
  5. A post-generation audit rejects any output containing hex literals outside the variable block, unknown CSS class names, or markup not in the component library — confirmed by side-by-side comparison with `pm-system.html`
  6. SKILL.md stays under 200 lines and loads `interview/handbook.md`, `story-arc.md`, and `design/*` only on demand
**Plans**: TBD
**UI hint**: yes

### Phase 3: Remaining Four Doc Types
**Goal**: All five v1 document types — pitch, handbook, technical brief, presentation, meeting prep — produce design-faithful output through the same arc gate, with the format auto-selected from the approved arc.
**Depends on**: Phase 2
**Requirements**: DOC-01, DOC-03, DOC-04, DOC-05, DOC-06, DESIGN-04
**Success Criteria** (what must be TRUE):
  1. Each of the five doc types has its own `skill/interview/<type>.md` file following an identical schema (audience → material → section conventions → tone notes → handoff to story-arc), each asking five questions or fewer
  2. Format auto-selects from the approved arc: Handbook (960px) for 4+ sections, Overview (1440px) for 1–3, Presentation (CSS scroll-snap) for slide decks
  3. The Presentation format renders as full-viewport slides with anchor navigation (`#slide-N`), a CSS-only slide counter, and `scroll-snap-type: y mandatory` working in Chrome and Safari
  4. Each doc type has been generated end-to-end at least once and visually inspected against the Caseproof references — none reads like a type-labeled clone of another
**Plans**: TBD
**UI hint**: yes

### Phase 4: Source-Mode, README, and Launch Hardening
**Goal**: deshtml accepts source material as input, a non-technical first-time reader can install and use it from the public README alone, and the install one-liner is verified end-to-end against the live URL before `v0.1.0` is tagged and released.
**Depends on**: Phase 3
**Requirements**: SKILL-02, DOCS-01, DOCS-02, DOCS-03, LAUNCH-01, LAUNCH-02, LAUNCH-03, LAUNCH-04
**Success Criteria** (what must be TRUE):
  1. `/deshtml @path/to/draft.md` (or pasted text >200 chars) is detected at turn 1 as source mode and the skill jumps straight to an arc proposal grounded in the source — never silently falls back to interview mode
  2. The repo README (written for Delfi as the target reader) explains what deshtml is, the install one-liner, basic usage, the five doc types, the uninstall command, the link to the Caseproof Documentation System, and a "Known Limitations" section covering offline font fallback and macOS-first auto-open
  3. The install one-liner from the README has been executed end-to-end via `curl … | bash` against the live public URL on a fresh machine and the resulting `/deshtml` produces all five doc types correctly
  4. The repo has a `VERSION` file pinned to `0.1.0`, a matching `v0.1.0` git tag, and a GitHub release with a short changelog
**Plans:** 3 plans
Plans:
- [ ] 04-01-PLAN.md — Source-mode wiring: skill/source-mode.md (NEW) + SKILL.md Step 1 flip (closes SKILL-02; ≤200 line cap preserved)
- [ ] 04-02-PLAN.md — Public README rewrite (Delfi-targeted, 9-section D4-10 structure) + CHANGELOG.md seed (closes DOCS-01..03)
- [ ] 04-03-PLAN.md — Launch hardening: pre-merge dry-run + VERSION bump + v0.1.0 tag + GitHub release + live LAUNCH-01 verification (closes LAUNCH-01..04)

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Foundation — Installer + Design Assets | 2/2 | Complete | 2026-04-27 |
| 2. Story-Arc Gate + Handbook End-to-End | 4/4 | Complete | 2026-04-28 |
| 3. Remaining Four Doc Types | 4/4 | Complete | 2026-04-28 |
| 4. Source-Mode, README, and Launch Hardening | 0/3 | Not started | - |

## Cross-Phase Dependencies

- **Phase 2 → Phase 1**: SKILL.md references `skill/design/*` and the install layout from Phase 1; cannot be built before those exist.
- **Phase 3 → Phase 2**: All four new interview files inherit the arc gate, the SKILL.md schema, and the post-generation audit proven in Phase 2. DESIGN-04 (format auto-selection) only becomes meaningful once Overview and Presentation are exercised.
- **Phase 4 → Phase 3**: README must list all five doc types and link a stable install one-liner; LAUNCH-02 requires all five types working end-to-end.
- **Phase 4 → Phase 1**: LAUNCH-01 verifies the Phase 1 installer against the live URL — this gate is intentionally re-tested at the end so atomic-staging patterns get maximum exposure before public release.
