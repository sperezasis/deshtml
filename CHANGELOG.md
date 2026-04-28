# Changelog

All notable changes to deshtml are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project
follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

Nothing yet.

## [0.1.0] — 2026-04-28

First public release.

### Added

- **Installer (Phase 1).** Atomic, idempotent, no-sudo curl-pipe-bash
  one-liner that drops the skill into `~/.claude/skills/deshtml/` and
  refuses to run as root. Reads the pinned tag from the `VERSION` file
  and stages to a temp directory before swapping atomically.

- **Caseproof Documentation System assets (Phase 1).** Verbatim palette,
  typography, component library, and two layout skeletons (Handbook
  960px sidebar, Overview 1440px linear) shipped as design tokens that
  Claude pastes — never paraphrases — into output.

- **Story-arc gate + Handbook flow end-to-end (Phase 2).** `/deshtml`
  runs a 5-question interview, builds a 5-column story-arc table with
  a flowing-paragraph diagnostic, runs an automated self-review pass,
  and blocks HTML rendering until the user types `approve` (or one of
  the whitelist phrases). The post-generation audit rejects hex literals
  outside the variable block, unknown CSS class names, and markup not
  in the component library.

- **All five doc types (Phase 3).** Pitch, handbook, technical brief,
  presentation, and meeting prep each ship a tailored 5-question
  interview file. Format auto-selects from the approved arc: Handbook
  (4+ sections), Overview (1-3), Presentation (slide decks). Audit
  auto-grows for new format skeletons.

- **Source mode (Phase 4).** `/deshtml @path/to/draft.md` (or pasted
  prose >200 characters) is detected at turn 1, infers the document
  type from the source's shape, and proposes a story arc grounded in
  the source content. The same arc-approval gate runs.

- **Public README and launch hardening (Phase 4).** The repo README is
  written for a non-technical first-time reader (target: Delfi),
  explains the install one-liner, the five doc types, source mode,
  uninstall, the three known limitations (offline, macOS-first,
  one file per run), and credits the Caseproof Documentation System.
  The install one-liner has been verified end-to-end against the live
  public URL.

### Known limitations

- Inter font loads via Google Fonts; offline runs fall back to the
  system font.
- The skill auto-opens the file via `open` (macOS-only). On Linux,
  the file is written and the absolute path is printed; the browser
  does not auto-open.
- One file per run. Iterate via normal Claude conversation.

[Unreleased]: https://github.com/sperezasis/deshtml/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/sperezasis/deshtml/releases/tag/v0.1.0
