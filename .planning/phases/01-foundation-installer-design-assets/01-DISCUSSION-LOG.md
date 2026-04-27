# Phase 1: Foundation — Installer + Design Assets - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-04-27
**Phase:** 01-foundation-installer-design-assets
**Areas presented:** Install pin strategy, Re-run UX, Design asset layout, Component closure
**User interaction style:** "you decide all. its really not that complicated" — Claude's discretion applied across all four areas using research recommendations.

---

## Gray-Area Selection

| Option | Description | Selected |
|--------|-------------|----------|
| Install pin strategy | How `install.sh` resolves which VERSION to install — hardcoded, read from VERSION on main, or GitHub API | (deferred to Claude) |
| Re-run UX | curl\|bash on existing install: silent overwrite, /dev/tty prompt, or `DESHTML_FORCE=1` | (deferred to Claude) |
| Design asset layout | Multi-file split vs consolidated CSS + skeletons vs two full HTML skeletons only | (deferred to Claude) |
| Component closure | Enumerated allowlist, regex audit, or both | (deferred to Claude) |

**User's choice:** "you decide all. its really not that complicated."
**Notes:** Santiago waived discussion and delegated all four areas to Claude's judgment. Decisions in CONTEXT.md follow research recommendations from `.planning/research/STACK.md` and `.planning/research/SUMMARY.md`, hardened against PROJECT.md constraints (no prompts, no follow-up steps, atomic + idempotent).

---

## Claude's Discretion — Decisions Made on User's Behalf

### Install pin strategy
- **Decision:** `install.sh` (fetched from `main`) reads `VERSION` from `main`, then `git clone --depth 1 --branch v${VERSION}`.
- **Considered:** (a) hardcoded version in `install.sh` — rejected: requires editing the script every release. (b) GitHub API for latest release — rejected: extra network call, harder to reason about offline.
- **Why this:** Stable URL across releases; latest tag wins on rerun; release flow is "bump VERSION + push tag."

### Re-run / idempotency UX
- **Decision:** Silent overwrite. No `read`, no `/dev/tty`, no `DESHTML_FORCE` env var.
- **Considered:** (a) `read < /dev/tty` confirmation — rejected: PROJECT.md mandates "no prompts," `read` under `curl|bash` is fragile. (b) `DESHTML_FORCE=1` env var — rejected: extra step for users; explicit intent already conveyed by rerunning the command.
- **Why this:** PROJECT.md constraint: "no prompts, no follow-up steps." Rerun = atomic reinstall of the pinned version. Existing install removed only after new clone succeeds.

### Design asset layout
- **Decision:** Multi-file split — `palette.css`, `typography.css`, `components.html`, `formats/handbook.html`, `formats/overview.html`, plus `SYSTEM.md` index. Verbatim reference originals preserved separately under `references/`.
- **Considered:** (a) single consolidated `system.css` + format skeletons — rejected: forces Claude to extract the right slice every paste. (b) two full HTML skeletons only — rejected: no clean way for Phase 2's audit to find palette/component boundaries.
- **Why this:** Matches research recommendation in SUMMARY.md; Phase 2 SKILL.md can load each fragment by name, reducing token weight per paste.

### Component closure
- **Decision:** Enumerated allowlist in `components.html` (Phase 1 deliverable) + regex audit in Phase 2 (DESIGN-06).
- **Considered:** (a) enumeration only — rejected: doesn't catch hex literal drift outside `palette.css`. (b) regex audit only — rejected: doesn't catch unknown class names invented by Claude.
- **Why this:** Defence in depth; each catch closes a different drift pattern. Phase 1 owns the enumeration; Phase 2 owns the audit code.

---

## Deferred Ideas

Captured in `01-CONTEXT.md` `<deferred>` section. Notable items:

- Self-hosted base64 fonts (V2)
- Print stylesheet (V2)
- Configurable palette (V2)
- `/plugin marketplace add` install path (V2)
- Auto-update on every run (out of scope)
