# Phase 1: Foundation — Installer + Design Assets - Context

**Gathered:** 2026-04-27
**Status:** Ready for planning

<domain>
## Phase Boundary

Two deliverables, no others:

1. **Installer** — Atomic, idempotent, no-sudo curl-pipe-bash one-liner that drops the `skill/` payload into `~/.claude/skills/deshtml/`. A documented uninstall one-liner that removes that directory cleanly.
2. **Design assets** — Verbatim Caseproof Documentation System fragments under `skill/design/` (palette CSS, typography CSS, component library, Handbook + Overview format skeletons) ready for Phase 2's SKILL.md to paste without paraphrase.

**Not in this phase:** any skill logic (SKILL.md, interview files, story-arc gate, output rendering). Those land in Phase 2+.

</domain>

<decisions>
## Implementation Decisions

All decisions in this phase were made at user discretion ("you decide all") with research recommendations applied. The planner has the latitude to refine specifics within these guardrails.

### Installer

- **D-01 — One-liner URL:** Stable URL pointing at `main` branch of the public repo. Concretely: `curl -fsSL https://raw.githubusercontent.com/sperezasis/deshtml/main/bin/install.sh | bash`. The README shows this exact line above the fold.
- **D-02 — Version-pinning strategy:** `install.sh` (fetched from `main`) reads the `VERSION` file (also from `main`), then `git clone --depth 1 --branch "v${VERSION}"` into a temp dir. **Rationale:** stable URL across all releases; latest tag always wins on rerun; release flow is "bump VERSION + push tag" without rewriting `install.sh`. The `VERSION` file lands in this phase even though `LAUNCH-03` (pinning it to `0.1.0`) is owned by Phase 4 — Phase 1 ships an initial value (e.g. `0.0.1` pre-launch) so the script has something real to read.
- **D-03 — Re-run / idempotency UX:** Silent overwrite. No `read`, no `/dev/tty`, no `DESHTML_FORCE` env var. Rationale: PROJECT.md mandates "no prompts, no follow-up steps"; under `curl | bash` `read` is fragile; rerun semantics = "reinstall the pinned version atomically." Existing install is only removed *after* the new clone succeeds.
- **D-04 — Atomic staging:** All install logic wrapped in `main() { ... }; main "$@"` invoked on the very last line of the script (truncation safety). Stage to `mktemp -d`, `trap 'rm -rf "$TMP"' EXIT`, atomic move/copy at the end. `set -euo pipefail` throughout.
- **D-05 — Root refusal:** Refuse to run when `EUID=0`. Print one line: "Do not run as root — deshtml installs into your home directory." Exit 1.
- **D-06 — Update path = rerun:** Updating is the same one-liner. The script detects `~/.claude/skills/deshtml/` and replaces it atomically with the freshly cloned tag. No separate "update" command.
- **D-07 — Uninstall:** Documented one-liner removes `~/.claude/skills/deshtml/` and prints a confirmation. Implementation: ship `bin/uninstall.sh` in the repo (so the README can link it) AND document the equivalent inline `rm -rf` form for users who prefer that.
- **D-08 — Linting gate:** `shellcheck bin/install.sh bin/uninstall.sh` must pass cleanly. Wired into a GitHub Action (`.github/workflows/shellcheck.yml`) so a future PR cannot regress.
- **D-09 — Bash version target:** Bash 3.2+ (macOS default). No Bash 4 features (associative arrays, `mapfile`, `${var,,}`).
- **D-10 — Repo-vs-payload separation:** `bin/`, `.github/`, `README.md`, `LICENSE`, `VERSION`, `CHANGELOG.md` live at the repo root. Only the contents of `skill/` are copied into `~/.claude/skills/deshtml/`. Installer plumbing never lands on user machines.

### Design assets (skill/design/)

- **D-11 — File layout:** Multi-file split, per research recommendation. The directory contains:
  - `skill/design/palette.css` — `:root` variables only (the Caseproof color palette, full set).
  - `skill/design/typography.css` — type scale, weights, Inter import, `-apple-system, sans-serif` fallback chain.
  - `skill/design/components.html` — closed component library: every approved class name with one canonical example block per component (see D-15).
  - `skill/design/formats/handbook.html` — Handbook 960px-sidebar skeleton.
  - `skill/design/formats/overview.html` — Overview 1440px linear skeleton.
  - `skill/design/SYSTEM.md` — short index file: lists each fragment, what it contains, when Phase 2's SKILL.md should reference it. ≤1 page.
- **D-12 — Skeleton fidelity:** Format skeletons are **trimmed** to a structural shell — `<head>` (with Google Fonts `@import`, `color-scheme: light` rules, the meta tag), the inline `<style>` reference (or link to `palette.css` + `typography.css` content concatenated at build time — planner's call), and a body skeleton with HTML comments marking where each component slot goes (e.g. `<!-- HERO -->`, `<!-- SIDEBAR NAV -->`, `<!-- SECTION GRID -->`). Goal: small enough to read in one screen, faithful enough that Phase 2 can copy it and fill the slots.
- **D-13 — Reference originals preserved:** Verbatim copies of the source files live separately (suggested: `skill/design/references/pm-system.reference.html` and `bnp-overview.reference.html`) so Claude can grep / re-extract during Phase 2 planning if a component is missing from `components.html`. These references are part of the skill payload but are NOT the files Claude pastes from in Phase 2 — they are read-only ground truth.
- **D-14 — Verbatim discipline:** Every CSS value, font weight, spacing rule, color, and component class in the fragments is a literal copy from `~/work/caseproof/DOCUMENTATION-SYSTEM.md` and the two reference HTML files. **No paraphrasing, no interpretive renaming, no "improvements."** Phase 1 is mechanical extraction.
- **D-15 — Component library closure:** `components.html` is an **enumerated allowlist** — every supported class is listed once with a canonical example. Phase 2's audit pass (DESIGN-06) gets this list as its source of truth + a regex audit on top (hex literals outside `palette.css`, unknown class names not present in `components.html`). Phase 1 owns the list; Phase 2 owns the audit code.
- **D-16 — Color-scheme + dark-mode hardening:** Both Handbook and Overview skeletons declare `color-scheme: light` in CSS AND include `<meta name="color-scheme" content="light">` in `<head>`. This satisfies DESIGN-07 and survives forced-dark-mode in iOS Safari. Verified by manual test in iOS Safari before phase closes.
- **D-17 — No external JS:** Skeletons contain zero `<script>` tags. No CDN-loaded JS, no inline JS. Self-contained constraint enforced from Phase 1.
- **D-18 — Font strategy:** Google Fonts CDN via `@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap')`. Fallback chain `Inter, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif`. V2 may self-host; V1 does not.

### Verification

- **D-19 — Phase 1 visual gate:** Open `formats/handbook.html` and `formats/overview.html` directly in Chrome and Safari (`file://`). Place them side by side with `pm-system.html` and `bnp-overview.html`. **Visual diff must be zero** at the skeleton level (palette, typography, spacing, hero, sidebar shape, section grid). Acceptable diff: missing real content where slot comments are. Unacceptable: any wrong color, any wrong font weight, any wrong spacing.

### Claude's Discretion

The user explicitly said "you decide all" for this phase. Within the decisions above, the planner and executor have latitude on:

- Exact installer error messages and their tone
- `shellcheck` configuration nuance (which optional checks to enable)
- Whether `palette.css` and `typography.css` get inlined into format skeletons at extraction time or at Phase-2 paste time (either is fine; pick the simpler one)
- Internal sort order / grouping inside `components.html`
- Whether `SYSTEM.md` is a flat index or grouped by surface (palette / type / components / formats) — pick what reads cleaner in 60 seconds
- Exact filename of the `VERSION` file's initial value (something pre-`0.1.0` — `0.0.1` is fine, `0.0.0` is fine)
- Whether `bin/uninstall.sh` actually ships in V1 or just lives as a documented one-liner — both satisfy `INSTALL-06`; default to shipping the script for parity with `install.sh`

### Folded Todos

None — todo backlog was empty at phase start.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Design source of truth (verbatim extraction targets)
- `/Users/sperezasis/work/caseproof/DOCUMENTATION-SYSTEM.md` — Palette, typography, component library, layout rules, Handbook (960px sidebar) vs Overview (1440px linear) format spec. Single source of truth for everything `skill/design/` ships.
- `/Users/sperezasis/work/caseproof/gh-pm/pm/pm-framework/diagrams/pm-system.html` — Reference Handbook implementation (1,726 lines, single self-contained HTML). The exact visual target the Handbook skeleton must reproduce. **Note:** PROJECT.md and research/SUMMARY.md cite this at `gh-pm/ongoing/pm/...` — that path is wrong; the actual file lives at `gh-pm/pm/...`.
- `/Users/sperezasis/work/caseproof/gh-pm/pm/bnp/.planning/figma/bnp-overview.html` — Reference Overview implementation. The visual target for the Overview skeleton. Same path correction as above.

### Methodology (used by Phase 2 onward, not Phase 1, but planner should know it exists)
- `/Users/sperezasis/CLAUDE.md` §"Documentation Methodology — Story First" — Story-first arc requirement, table format, Section Writing Rules. Phase 2's story-arc gate consumes this.

### Project context
- `.planning/PROJECT.md` — Vision, scope, constraints, key decisions.
- `.planning/REQUIREMENTS.md` — INSTALL-01..07 and DESIGN-01,02,03,05,07 are the requirements this phase closes.
- `.planning/ROADMAP.md` §"Phase 1" — Goal statement, success criteria, dependency graph.

### Research artifacts (consult during planning, no need to copy into plan)
- `.planning/research/STACK.md` — Installer pattern (`main()` wrapper, atomic staging, root refusal); skill packaging conventions (`name`, `disable-model-invocation`, payload layout); curl-pipe-bash gotchas. **Required reading for the planner.**
- `.planning/research/PITFALLS.md` — Pitfalls 1, 2, 3, 7, 8, 9 are this phase's concern (interactive prompts under pipes, partial install on dropped connection, design-token drift, color-scheme handling, name-collision, repo-layout drift).
- `.planning/research/ARCHITECTURE.md` — Skill payload layout (`skill/` directory as the install target, four subsystems Phase 2 will load progressively).
- `.planning/research/FEATURES.md` — Must-have features for V1; Phase 1 closes the install + design-fidelity baseline.
- `.planning/research/SUMMARY.md` — Consolidated build-order rationale; explains why Phase 1 ships installer + design assets together.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets

- **None inside the deshtml repo.** This is the first build phase; the repo currently contains only `.planning/` artifacts and a `CLAUDE.md` stub.
- **External (extraction sources):** `pm-system.html`, `bnp-overview.html`, `DOCUMENTATION-SYSTEM.md` — all under `~/work/caseproof/`. These are read-only sources for verbatim extraction; they are not modified, not symlinked, not git-submoduled.

### Established Patterns

- **Installer pattern (from research):** `main()` wrapper + `set -euo pipefail` + temp-dir staging + atomic move + `trap` cleanup is the canonical curl-pipe-bash shape. See `research/STACK.md` §"GSD-style installer pattern" for the verified skeleton — the planner should treat that snippet as the starting point, not as something to redesign.
- **Skill packaging (from Anthropic docs cited in research):** `~/.claude/skills/<name>/SKILL.md` with YAML frontmatter; `name` is lowercase letters/numbers/hyphens, max 64 chars; `disable-model-invocation: true` for user-only-fired skills; supporting files referenced one level deep from `SKILL.md`. Phase 1 ships only `skill/design/` files — `SKILL.md` itself is Phase 2's responsibility, but Phase 1's directory layout must already match the path Phase 2 expects.

### Integration Points

- **Phase 2 → Phase 1:** Phase 2's `skill/SKILL.md` will reference `skill/design/palette.css`, `typography.css`, `components.html`, `formats/handbook.html`. Their paths and names must be stable by end of Phase 1.
- **Phase 4 → Phase 1:** `LAUNCH-01` (verified install one-liner) replays this phase's installer end-to-end on a fresh machine. The atomic-staging contract written here is what's being verified there.
- **External dependency:** Google Fonts CDN (`fonts.googleapis.com`). Offline behavior is graceful fallback to `-apple-system`, documented in Phase 4 README under "Known Limitations." Phase 1 ships the `@import` line; Phase 4 documents the limitation.

</code_context>

<specifics>
## Specific Ideas

- **GSD-shaped install UX is the bar.** One line, paste, done. If install needs explanation, it's wrong.
- **The reference HTML is the visual contract.** "Indistinguishable from `pm-system.html` side-by-side" is the success bar for the Handbook skeleton. Same for `bnp-overview.html` and the Overview skeleton.
- **Verbatim, not interpretive.** This phase is not a redesign opportunity. Extract literally from existing files. If something looks wrong in the source, that's a separate issue logged for the design system, not a Phase 1 fix.

</specifics>

<deferred>
## Deferred Ideas

- **Self-hosted base64-inlined Inter** — V2 only, gated on a real complaint. Phase 1 ships the Google Fonts `@import` line; offline degradation is a documented known limitation handled by Phase 4 README.
- **Print stylesheet** — V2.
- **Configurable design tokens / alternate palettes** — V2; locked to Caseproof system in V1.
- **Project-scope skill install** (`.claude/skills/` inside a project dir) — explicitly out of scope (Claude Code issue #36155 makes project-scope skills read-only).
- **`/plugin marketplace add` install path** — out of scope for V1; revisit in V2 if a deshtml family emerges.
- **Auto-update check on every run** — out of scope; user reruns the install one-liner when they want updates.

### Reviewed Todos (not folded)

None — todo backlog was empty at phase start.

</deferred>

---

*Phase: 01-foundation-installer-design-assets*
*Context gathered: 2026-04-27*
