# deshtml

## What This Is

`deshtml` is an installable Claude Code skill that turns ideas into beautifully designed, self-contained HTML documents. The user runs `/deshtml` (from scratch or against a draft), answers a short structured interview, approves a story arc, and receives a single-file HTML document that follows the Caseproof Documentation System.

It exists because Santiago presents, ships, and explains nearly every project as a designed HTML document, and wants Delfi (personal) and Monika (work) to produce the same caliber of output without learning the design system or the story-first methodology by hand.

## Core Value

**A non-author runs one command and gets a beautifully designed, story-first HTML document that looks like Santiago made it.**

If the visual design and narrative arc are wrong, nothing else matters. Speed, options, and configurability are secondary to producing output that is indistinguishable from a hand-crafted Caseproof document.

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] Public GitHub repo at `github.com/sperezasis/deshtml` with a one-liner install command (curl-pipe-bash style, GSD-shaped)
- [ ] Installer drops the skill into `~/.claude/skills/deshtml/` so `/deshtml` is available globally
- [ ] `/deshtml` (no args) launches a from-scratch interview
- [ ] `/deshtml @file.md` (or pasted text) uses the source as raw material instead of interviewing
- [ ] First interview question is document type, branching the prompt for the rest of the run
- [ ] V1 supports five document types with tailored prompts: pitch, handbook / system overview, technical brief, presentation / slide deck, meeting prep
- [ ] Skill enforces the Story-First methodology: produces a story arc table (`#, Beat, Section, One sentence, Reader feels`) and gates on user approval before writing HTML
- [ ] Generated HTML strictly follows the Caseproof Documentation System (palette, typography, components, Handbook-960px or Overview-1440px format selected by content size)
- [ ] Output is a single self-contained HTML file written to the current working directory, then auto-opened in the default browser via `open <file>`
- [ ] Iteration after generation happens via normal Claude conversation (no in-skill revision loop)
- [ ] README explains: what it is, install command, usage, supported document types, link to Caseproof Documentation System
- [ ] Uninstall command documented

### Out of Scope

- Configurable design tokens / alternate palettes — V1 is opinionated; locked to Caseproof Documentation System. Revisit in V2 once usage exposes real needs.
- Multi-file output, sidebars-as-separate-files, asset folders — single self-contained `.html` file only.
- Re-running the skill against generated HTML for structured revisions — edits go through normal chat.
- Hosted version, web UI, or non-Claude-Code distribution — terminal install is the only delivery channel.
- Authentication, telemetry, or analytics — public repo, no tracking, no accounts.
- Auto-publishing the output (GitHub Pages, hosting, sharing links) — user handles where the HTML goes after generation.
- Non-English / non-Spanish UX surfaces — input language is whatever the user types; output language follows source.

## Context

- **Audience:** Santiago, Delfi (personal), Monika (work, Caseproof teammate). Public install allowed but those four people drive the design.
- **Design source of truth:** `~/work/caseproof/DOCUMENTATION-SYSTEM.md` (642 lines: palette, typography, component library, layout, two formats — Handbook 960px sidebar / Overview 1440px linear).
- **Methodology source of truth:** `~/CLAUDE.md` "Documentation Methodology — Story First" section (define narrative arc → table of beats → approve → write).
- **Reference implementations** named in DOCUMENTATION-SYSTEM.md: `gh-pm/ongoing/pm/pm-framework/diagrams/pm-system.html` (Handbook) and `gh-pm/ongoing/pm/bnp/.planning/figma/bnp-overview.html` (Overview).
- **Inspiration / shape:** GSD (Get Shit Done) — same install pattern, same story-first methodology baked into a skill, same single-command UX.
- **Repository:** `https://github.com/sperezasis/deshtml` (public, already created by user).

## Constraints

- **Distribution:** Claude Code skill format only — must live under `~/.claude/skills/deshtml/` after install, callable as `/deshtml`.
- **Install UX:** must match GSD's bar — single shell command pasted into a terminal, no follow-up steps required.
- **Design fidelity:** output HTML must visually match the Caseproof reference implementations. No alternate styling, no "lite" mode.
- **Self-contained output:** the generated `.html` opens correctly when double-clicked or shared as a file. Inline CSS; web fonts via Google Fonts CDN are acceptable (degrades to system fonts offline — documented as a known limitation, not blocked); no external JS dependencies, no asset folders.
- **No backend / no infra:** the skill is pure prompt + templates. No API keys, no servers, nothing for users to configure beyond the install.
- **Input language:** Spanish or English; the skill replies in English (per Santiago's standing rule). Output document language follows the source material.

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Opinionated V1, configurable V2 | Lock the design system so output is consistent across users; configurability is a feature for later, not a V1 risk | — Pending |
| Single self-contained HTML file | Maximum portability (double-click, share, drop in any folder) — matches how Santiago distributes docs today | — Pending |
| Auto-open with `open <file>` after generation | Zero-friction preview, no local server needed; mac-first UX for V1 | — Pending |
| Branch prompt by document type upfront | Pitch, handbook, brief, deck, and meeting prep have genuinely different story arcs and section conventions; one generic prompt would dilute all of them | — Pending |
| One-shot generation, edit via chat | Avoids building a revision UI inside the skill; Claude Code already handles iterative editing well | — Pending |
| GSD-style install (one-liner, public repo) | Proven UX, zero auth friction, mirrors a model Santiago and his audience already understand | — Pending |
| Story-First methodology gate is mandatory | The methodology is the moat — skipping the arc-approval step would let users generate pretty but incoherent docs | — Pending |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-04-27 after initialization*
