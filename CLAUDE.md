## Project

deshtml — Claude Code skill that generates story-first, self-contained HTML documents from a fixed design system. Distributed publicly via curl-pipe-bash installer from this GitHub repo.

---

## Layout

- `skill/` — payload deployed to `~/.claude/skills/deshtml/` by the installer. SKILL.md is the entrypoint; `interview/*.md` hold the five doc-type questionnaires; `source-mode.md` and `context-mode.md` own the two non-interview entrypoints; `story-arc.md` is the rendering gate; `design/` holds palette/typography/components and the three format skeletons (handbook, overview, presentation); `audit/` holds `run.sh` and `rules.md`; `check-update.js` is the SKILL.md Step 0 update checker.
- `bin/` — `install.sh` (atomic, idempotent) and `uninstall.sh`. Both clean up legacy v0.4.0–v0.4.2 hook artifacts on every run.
- `docs/` — example HTML outputs and screenshots for the README.
- `CHANGELOG.md` — Keep-a-Changelog format. Versions follow semver.
- `VERSION` — single-line semver. `bin/install.sh` fetches `https://raw.githubusercontent.com/sperezasis/deshtml/main/VERSION` to know which tag to clone.

---

## Versions and recent direction

- **v0.4.3 (current)** — update notice runs as `/deshtml` Step 0 (no SessionStart hook). Cleans up legacy hook artifacts in `~/.claude/hooks/` and `~/.claude/settings.json`.
- **v0.4.0–v0.4.2** — three iterations on auto-update notice via SessionStart hook. Plain stdout was suppressed (0.4.0); `additionalContext` only reaches the model not the user (0.4.1); `/dev/tty` write was visible but visually invasive (0.4.2). Resolved by moving the notice into the skill itself in 0.4.3.
- **v0.3.0** — context mode (drafts answers from prior conversation, one-prompt confirm) + `AskUserQuestion`-driven interview pickers (multi-choice presets instead of plain text).
- **v0.2.0** — presentation format rebuilt: title anchored at consistent Y, body auto-centered in remaining space, byline at top-left, side-nav arrows, click-anywhere-to-advance, keyboard nav. Audit Rule 3 relaxed to allow `<script>` only in presentation outputs (content-based detection).
- **v0.1.x** — initial public release + cleanup of internal references.

---

## Audit moats (`skill/audit/run.sh`)

1. No hex literals outside `:root`.
2. Class allowlist harvested live from `components.html`, typography.css, components.css, and every `formats/*.html` skeleton.
3. Banned tags (`<iframe>`, `<object>`, `<embed>`) always banned. `<script>` allowed only in presentation outputs (detected by content: `<main class="deck">` + `<section class="slide">`). Inline event handlers and `javascript:` URLs always banned.
4. No leftover `<link rel="stylesheet">`.
5. Interview schema check on every `interview/*.md`: `## The N questions` heading, `## Hand-off` heading, `story-arc.md` reference, question count in [3, 5].

The audit is mechanical, not heuristic. Every rule is grep + set difference.

---

## Working conventions

- `SKILL.md` is ≤200 lines (D2-01) and contains flow control only — sub-files own their content. Pitfall 14: never inline rubric content into SKILL.md.
- Mode detection at turn 1 (source / context / interview) — never silently falls back. Pitfall 15: don't read sub-files speculatively.
- Story arc gate is mechanical (exact-match against the whitelist in `story-arc.md`). Pitfall 10: do not loosen to fuzzy match.
- Generated HTML is always self-contained — palette + typography + components.css inlined; zero external assets.
- Re-running the installer is idempotent. Same with the audit. Both are safe to invoke repeatedly.
