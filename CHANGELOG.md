# Changelog

All notable changes to deshtml are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project
follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

Nothing yet.

## [0.4.4] — 2026-04-30

### Fixed

- **Installer no longer leaves slash-command-shadowing dirs on mid-flight kill.** v0.4.3 and earlier staged the new payload at `${DEST}.installing.XXXXXX` and the previous install at `${DEST}.old.$$` during the atomic swap. Both names share the `deshtml.` prefix, so if the script was killed in the swap window (SIGKILL, crash, OOM), the surviving directory was registered by Claude Code as a sibling slash command (e.g. `/deshtml.old.12345`) and shadowed `/deshtml` via prefix-match — typing `/deshtml` would route to the leftover backup instead of the real skill. v0.4.4 stages and backs up at `.deshtml_install_stage.XXXXXX` and `.deshtml_install_backup.$$` (leading dot, no `deshtml.` prefix), keeping the same parent directory so `mv` stays atomic. The installer also best-effort-cleans any orphaned `deshtml.old.*` / `deshtml.installing.*` siblings from older killed installs.

## [0.4.3] — 2026-04-29

### Changed

- **Update notice moved out of SessionStart and into `/deshtml`.** v0.4.0–v0.4.2 tried to surface the notice via a SessionStart hook (additionalContext / `/dev/tty`); both were either invisible to the user or visually invasive (the v0.4.2 banner overlapped Claude Code's welcome banner and disrupted layout). The notice now lives as Step 0 of `SKILL.md` — it appears as the first line of `/deshtml` output when a newer version is available, silent otherwise. Same automation, no terminal disruption.
- **`skill/check-update.js` ships with the skill payload.** Reads the cached `latest` if fresh (<6h); otherwise fetches upstream `VERSION` with a 2s timeout. Falls silent on any error.

### Removed

- **SessionStart hook (`bin/deshtml-check-update.js`, `bin/deshtml-register-hook.js`).** Both are gone. The installer's hook-installation step is removed.
- **Legacy cleanup.** `bin/install.sh` and `bin/uninstall.sh` now actively remove leftover files from v0.4.0–v0.4.2 installs: the two hook scripts in `~/.claude/hooks/` and the SessionStart entry in `~/.claude/settings.json` (atomic JSON edit). Re-running the installer cleans up automatically.

## [0.4.2] — 2026-04-29

### Fixed

- **SessionStart hook now writes the banner to `/dev/tty` directly.** v0.4.1 used `hookSpecificOutput.additionalContext` which is only delivered to Claude (the model), not rendered as a visible UI element — the user never saw the notice. Hooks in Claude Code 2.x have stdio captured (plain stdout/stderr never reach the terminal), and the statusline channel is reserved for `statusLine` config (already taken by GSD on this machine). The reliable mechanism is `/dev/tty`: when a hook child process inherits a controlling terminal from its parent, opening `/dev/tty` resolves to the user's terminal and bypasses the captured pipes. The `additionalContext` JSON is still emitted so Claude knows about the update and can mention it on demand.
- **Debug log added.** The hook now appends a one-line entry per invocation to `~/.cache/deshtml/last-run.log` (timestamp + state). Lets users verify the hook is firing and whether `/dev/tty` is reachable in their Claude Code build (`tty=ok` vs `tty=fail`).

## [0.4.1] — 2026-04-29

### Fixed

- **SessionStart hook output now visible.** Claude Code 2.x suppresses plain stdout from `SessionStart` hooks — the v0.4.0 hook printed the update notice but it never reached the user. Switched to the official user-visible mechanism: `hookSpecificOutput.additionalContext` JSON form. Claude Code injects the message as a system context entry at session start, surfacing the notice in the conversation.

## [0.4.0] — 2026-04-29

### Added

- **SessionStart update-check hook.** New scripts `bin/deshtml-check-update.js` (the hook itself) and `bin/deshtml-register-hook.js` (idempotent register / unregister of the hook in `~/.claude/settings.json`). The hook fetches the upstream `VERSION` from GitHub, compares against the locally-installed `~/.claude/skills/deshtml/.version`, and prints a one-line notice on the next Claude Code session start when a newer version is available. Cached for 6 hours to avoid hammering GitHub. Fails silently on network errors / missing files / parse errors — the skill continues to work even if the hook fails.
- **`bin/install.sh` extended (steps 6-8).** After the atomic skill swap, the installer (1) writes `~/.claude/skills/deshtml/.version` so the hook has something to compare against, (2) copies both hook scripts into `~/.claude/hooks/`, and (3) registers the hook in `~/.claude/settings.json` via the Node helper. Hook installation is best-effort: if Node.js is unavailable, the install completes with a one-line notice and the user gets a manual-install hint. The skill itself works either way.
- **`bin/uninstall.sh` extended.** Now calls the register helper to unregister the hook before deleting it, removes both hook scripts from `~/.claude/hooks/`, and clears the `~/.cache/deshtml/` cache.

### Why minor bump (0.3.0 → 0.4.0)

Additive — new auto-update notification capability. Existing installs upgrade transparently the next time `bin/install.sh` runs (the new step 7 is idempotent, so re-running the installer simply registers the hook). No breaking changes; users without Node.js get a graceful fallback.

## [0.3.0] — 2026-04-29

### Added

- **Context mode (`skill/context-mode.md`).** When `/deshtml` is invoked in a session that already discussed the document being created, the skill now drafts the interview answers from the prior conversation and asks the user to confirm with one prompt — instead of running the full 5-question interview from scratch. New SKILL.md Step 1.5 detects the mode by counting context signals (doc-type mention, audience mention, source content provided, structure / tone discussed); 2+ signals trigger context mode. The user can accept the draft, edit specific fields, or restart from a fresh interview. Thin drafts (<3 fields, or no detectable doc type) are surfaced loudly and route back to the standard interview — no silent fallback (preserves the SKILL-03 contract).
- **`AskUserQuestion` tool.** Added to `allowed-tools` in `SKILL.md`. The five interview files and `context-mode.md` now use multiple-choice prompts (with sensible default options + auto-"Other" for free-text override) instead of text-only prompts. Open-content questions (audience prose, material, takeaway, decision, trade-offs) still use plain text — those are the user's content, not a Claude-proposable default. Closed-shape questions (audience type, sections, tone, inclusions, alternatives) now render as terminal-side option pickers — same UX as GSD's question prompts.

### Changed

- **`SKILL.md` Step 2 (doc type) now uses `AskUserQuestion`** with four canonical options (Handbook / Pitch / Presentation / Technical brief) plus the auto-"Other" channel for "meeting prep" via free-text. The five-options-listed-as-prose prompt is gone.
- **Filename suffix is now correct per doc type.** Pre-0.3.0 SKILL.md hardcoded `-handbook.html` for every format due to a doc bug; the audit's content-based presentation detection (added in 0.2.0) compensated. Step 5 now uses `<date>-<slug>-<type>.html` properly (`-presentation.html`, `-pitch.html`, etc.).

### Why this version is a minor bump (0.2.0 → 0.3.0)

New flow capability (context mode) — additive, no breaking changes. Existing `/deshtml` invocations in fresh sessions still go straight to Step 2 because Step 1.5 finds <2 signals and falls through. The interactive prompt format change is purely UX — same questions, less typing.

## [0.2.0] — 2026-04-29

### Changed

- **Presentation format rebuilt.** The slide skeleton (`skill/design/formats/presentation.html`) was rewritten end-to-end based on lessons from a real production deck. The old layout used `justify-content: center`, which caused per-slide title drift because content heights vary across slides. The new layout uses `justify-content: flex-start` + `padding-top: 140px` to anchor the title (eyebrow + h1 + lead) at a consistent slide-internal y, then auto-margins on the first body child (`*:nth-child(4) { margin-top: auto }`) and last child (`*:last-child { margin-bottom: auto }`) to center the body content (cards/flow/hl) in the remaining space. Result: same-template same-Y title across every slide, balanced body, no landing-page emptiness.
- **Per-slide counter removed; active nav highlight added.** The bottom-right `N / 6` counter was unreliable when scroll-snap engaged imperfectly on anchor clicks (the previous slide's counter bled into the top of the next slide's viewport, showing `4 / 6` on slide 5). Replaced by an `.active` highlight on the slide-nav anchor link itself (current slide's number turns blue with a tinted background). The counter element is hidden via `display: none` and the navigation script toggles `.active` on scroll.
- **Byline at top-left of every slide.** A new `BYLINE_LITERAL` token in `.slide::before` renders a short line at the top-left ("Presenter  ·  Title", or just "Title" by default). Visible immediately when a slide is snapped — replaces the previous bottom-positioned byline that bled into the next slide's top during imperfect snaps.
- **Scroll-snap bleed eliminated.** Three fixes shipped together: (1) `scroll-margin: 0` on `.slide` overrides the global `section { scroll-margin-top: 90px }` from `components.css` that was offsetting snap targets; (2) `scroll-behavior: smooth` was REMOVED from `main.deck` because it was racing with `scroll-snap-type: y mandatory` and stopping mid-scroll; (3) `html, body { overflow: hidden; height: 100vh }` locks all scrolling to `main.deck` so anchor clicks scroll the snap container directly.

### Added

- **Side navigation buttons (`#nav-prev`, `#nav-next`).** Centered circular buttons on the left and right edges of the viewport. The script hides `#nav-prev` on the first slide and `#nav-next` on the last slide.
- **Click-anywhere-to-advance.** Clicking on the body of a slide advances to the next slide. The handler ignores clicks on the slide-nav, on the prev button, and on any `<a>` or `<button>` element inside the slide content (so interactive components don't double-fire).
- **Keyboard navigation.** `→`, `↓`, `Space`, `PageDown` advance; `←`, `↑`, `PageUp` go back. The handler calls `preventDefault()` so spacebar doesn't double-scroll.
- **`<script>` tag is allowed in presentation outputs only.** Audit Rule 3 was relaxed for files matching `*-presentation*.html` (including collision-renamed `*-presentation-2.html`, etc.). All other formats (handbook, pitch, technical brief, meeting prep) remain script-free. Inline event handlers (`on*=`), `javascript:` URLs, and `<iframe>`/`<object>`/`<embed>` tags remain banned in every format.

### Why this version is a minor bump (0.1.3 → 0.2.0)

A new format capability shipped: presentations now include navigation JS that the previous version explicitly forbade. The audit's banned-tag pattern is now format-aware. Existing handbooks and pitches generated by older versions still pass the new audit unchanged; they just don't gain the new JS capability. No API or filename changes — `/deshtml` is invoked the same way.

## [0.1.3] — 2026-04-28

### Removed

- **Internal Caseproof reference HTMLs (`skill/design/references/*.reference.html`).** Two 113 KB files (`pm-system.reference.html`, `bnp-overview.reference.html`) shipped in the public skill payload as Phase 1 verbatim ground-truth for design extraction. They were never read at runtime and exposed internal Caseproof team / product content to anyone running the installer. Removed from the payload; SYSTEM.md and components.css comments updated to no longer reference them.

### Changed

- **README rewritten** to be more useful for first-time readers: hero screenshot of a generated handbook, a "Why this exists" section explaining the problem the skill solves, a "What story-first means" section explaining the methodology that gates HTML generation, and a small grid of example screenshots (pitch + presentation). All examples are now generic — no Caseproof / internal-team content in the public README.
- **`docs/examples/`** added with three runnable example HTML files generated by the skill itself: `handbook-onboarding.html`, `pitch-ai-support.html`, `presentation-q3-roadmap.html`. Each opens correctly via `file://` and demonstrates a different format (handbook sidebar, overview linear, presentation scroll-snap).

## [0.1.2] — 2026-04-28

### Fixed

- **Installer still printed `tmp: unbound variable` after the v0.1.1 fix.** v0.1.1 only patched the first `EXIT` trap, but `bin/install.sh` replaces it later with a stage+backup-aware multiline trap that referenced `$tmp`, `$stage`, `$backup`. Same `set -u` issue at fire-time. The second trap now also captures values at set-time (double-quoted) so all four references resolve before `main()` returns. Verified end-to-end: install completes silently with no spurious warnings.

## [0.1.1] — 2026-04-28

### Fixed

- **Installer prints `tmp: unbound variable` after success.** The `EXIT` trap referenced a `local` variable from `main()`; under `set -u` the trap fired after `main` returned and `$tmp` was out of scope, producing a cosmetic warning. The install itself succeeded, but the noise was alarming. The trap now captures the temp-dir path at set-time (double-quoted) so it survives `main` returning. Discovered during the LAUNCH-01 live-URL verification of v0.1.0.

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
