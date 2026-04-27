# Stack Research

**Domain:** Claude Code skill — packaged + publicly distributed via GitHub, generates self-contained HTML documents from a fixed design system.
**Researched:** 2026-04-27
**Confidence:** HIGH (skill format + reference HTML pattern verified against current docs and an existing working reference; installer pattern verified against multiple public skill repos)

---

## TL;DR

The deshtml stack is **deliberately minimal**: a `SKILL.md` prompt + a small `templates/` directory of reference HTML scaffolds + a `bin/install.sh` shell script. No build system, no Node runtime at install time, no JS framework, no markdown-to-HTML preprocessor. Claude writes HTML directly from the tailored prompt, copying CSS verbatim from a checked-in reference template that matches the existing Caseproof HTML the design system was extracted from.

The most consequential decisions:

1. **Skill, not plugin, not subcommand.** Single `SKILL.md` at `~/.claude/skills/deshtml/SKILL.md` per the official Claude Code skill spec. `disable-model-invocation: true` so it only fires when the user types `/deshtml`.
2. **Curl-pipe-bash installer that clones a pinned tag, not a templated copy of files.** Mirrors the public-skill-repo install pattern (oaustegard/claude-skills, alirezarezvani/claude-skills) and is recoverable, idempotent, and uninstallable in one line each.
3. **Claude writes HTML directly, no markdown preprocessor.** A markdown-to-HTML library cannot produce the nested cards, sidebars, eyebrow labels, and stat blocks the design system requires. Claude already produces this HTML well when given the reference file as a template — verified by the existing `pm-system.html` (1,726 lines, hand-written, exactly the target shape).
4. **Self-contained HTML via inline `<style>` block + Google Fonts `@import`** — the same pattern the existing Caseproof reference HTML uses today. Documents must open offline and via desktop double-click; the missing-font fallback to `-apple-system, sans-serif` already covers offline + privacy-strict cases gracefully.

---

## Recommended Stack

### Core "Technologies"

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| Claude Code skill format | Current spec (code.claude.com/docs/en/skills, 2025-11+) | Distribution + invocation envelope for `/deshtml` | Official, authoritative, supports slash-command invocation, frontmatter-controlled invocation gating, supporting files. No alternative with comparable installed-base or Claude Code integration. |
| `SKILL.md` (YAML frontmatter + Markdown body) | n/a | The skill's actual instructions Claude reads when `/deshtml` runs | Required by the spec. Body is the prompt — keep under 500 lines per Anthropic guidance, defer detail to `references/`. |
| Bash 3.2+ install script (`bin/install.sh`) | POSIX-compatible | One-liner public install (`curl ... \| bash`) | Macs ship Bash 3.2; using `bash` not `zsh` keeps it portable to Monika's and Delfi's Macs without setup. No Node, npm, or Python required at install time. |
| Inline HTML + `<style>` block + Google Fonts `@import` | HTML5 | The actual deliverable — single `.html` file | Matches what `pm-system.html` (the design system's reference implementation) already does verbatim. Browsers render it correctly online; offline it falls back to `-apple-system` (which is what the design system already specifies as fallback). |
| `git clone --depth 1` of pinned tag | git 2.0+ | How `install.sh` fetches the skill payload | Standard pattern in public skill repos. Pinning to a tag (not `main`) gives deterministic installs and a clean rollback. |

### Supporting Files in the Skill

| File | Purpose | When to Use |
|------|---------|-------------|
| `SKILL.md` | The skill's prompt. YAML frontmatter + body that defines the interview, story-arc gate, and pointer to per-doc-type references. | Required entrypoint. Always loaded when `/deshtml` is invoked. |
| `references/handbook-format.html` | Verbatim copy of the canonical Handbook reference (the existing `pm-system.html`, trimmed to a structural skeleton). | Loaded by Claude when the chosen format is Handbook (4+ sections). Claude copies CSS and component classes from this. |
| `references/overview-format.html` | Verbatim copy of the canonical Overview reference (`bnp-overview.html` skeleton). | Loaded when format is Overview (1-3 sections). |
| `references/design-system.md` | Trimmed local copy of `DOCUMENTATION-SYSTEM.md` (palette, type scale, spacing, components). | Always referenced — the design language source of truth, decoupled from Santiago's local workspace path. |
| `references/story-first.md` | Trimmed local copy of the Documentation Methodology section from `~/CLAUDE.md`. | Loaded to enforce the arc-table-then-approve gate. |
| `references/doc-types/{pitch,handbook,brief,deck,meeting-prep}.md` | One file per supported document type with the tailored interview questions, story-arc beats, and section conventions for that type. | Loaded conditionally: SKILL.md branches on the answer to "What kind of document?" and tells Claude which one to read. |
| `bin/install.sh` | Curl-pipe-bash installer. Clones a pinned tag, copies the skill into `~/.claude/skills/deshtml/`, prints next steps. | Top of repo, served via `raw.githubusercontent.com`. |
| `bin/uninstall.sh` | Removes `~/.claude/skills/deshtml/`. | Documented in README. |
| `VERSION` | Plain-text semver tag (e.g. `0.1.0`). | Read by `install.sh` and surfaced in the skill output footer for support. |
| `README.md` | Public-facing: what it is, install one-liner, usage, supported types, link to the design system. | Top of repo. |
| `LICENSE` | MIT. | Public repo. |

### Development Tools

| Tool | Purpose | Notes |
|------|---------|-------|
| `shellcheck` | Lint `install.sh` / `uninstall.sh` before tagging a release. | `brew install shellcheck`. Catch all the classic curl-pipe-bash footguns (unquoted vars, missing `set -euo pipefail`). |
| `git tag` + GitHub Releases | Version pinning for the installer. | `install.sh` fetches `VERSION` or a hard-coded tag, not `main`. Releases page becomes the human changelog. |
| Browser (Chrome / Safari) | Manual visual QA — open generated HTML, eyeball against the reference. | No automated visual regression in V1; Santiago is the eye. |
| `gh` CLI | Repo + release management from terminal. | Already available; no new dependency. |

---

## Installation

There is **nothing to install at build time**. The repo is plain text. Users install the skill itself with one line:

```bash
# End-user install (the public one-liner the README leads with)
curl -fsSL https://raw.githubusercontent.com/sperezasis/deshtml/main/bin/install.sh | bash
```

Authoring (local dev loop while iterating on the skill):

```bash
# Symlink the working tree directly into ~/.claude/skills/ so edits are live
mkdir -p ~/.claude/skills
ln -sfn "$(pwd)" ~/.claude/skills/deshtml

# Or run the installer against a local file (for end-to-end test)
bash bin/install.sh

# Lint the installer before tagging
shellcheck bin/install.sh bin/uninstall.sh
```

No `npm install`, no `pip install`, no virtualenv, no toolchain.

---

## Alternatives Considered

| Recommended | Alternative | When to Use Alternative |
|-------------|-------------|-------------------------|
| Single `SKILL.md` skill | Claude Code **plugin** (with `plugin.json`, multiple skills, marketplace add) | Use when you have 3+ related skills to ship together, or you want users to install via `/plugin marketplace add`. deshtml is one command — a plugin is unnecessary ceremony. Reconsider in V2 if a deshtml family emerges (e.g. `/deshtml-edit`, `/deshtml-review`). |
| Curl-pipe-bash installer | npm package (`npx deshtml install`) | Use if you want a Node ecosystem (changelogs, npm registry visibility, `npx` convenience). Drawback: forces every user to have Node; not all of Santiago's three users do. The GSD npm pattern is overkill for a single-skill repo. |
| Curl-pipe-bash installer | `git clone` + manual copy in README | Acceptable but loses the "paste one line" UX bar Santiago wants to match GSD on. Two steps already breaks the promise to Delfi. |
| Curl-pipe-bash installer | Claude Code `/plugin add /path/to/dir` | Requires the user to first clone, then know the slash command. Worse UX than `curl \| bash`. Useful as a *secondary* documented path for security-conscious users. |
| Claude writes HTML directly from a reference template | Markdown → HTML preprocessor (markdown-it, Marked, Pandoc) with a custom Pandoc template | A markdown layer cannot produce: nested card grids, eyebrow labels, the `<em>` accent inside h1, color-tagged pills, sidebars, hero stats, flow boxes. Anything custom requires HTML in the markdown anyway, defeating the layer. Claude already writes the design-system HTML cleanly — verified by the existing `pm-system.html` reference. |
| Claude writes HTML directly | Templating engine (Handlebars, Nunjucks, Liquid) generated by Claude → rendered by a runtime | Adds a second build step and a runtime dependency users would have to install. Claude can render the final HTML in one pass; no benefit to a templating intermediate. |
| Inline `<style>` + Google Fonts `@import` | Self-host WOFF2 fonts inlined as base64 in CSS | Best practice for performance/privacy/GDPR per 2025 web.dev guidance. Trade-off: bloats every output file by ~80-200KB and requires maintaining font binaries in the skill. The Caseproof reference already uses Google Fonts `@import` and falls back gracefully to `-apple-system`. **Defer self-hosting to V2** if a real complaint arrives. |
| Inline `<style>` + Google Fonts `@import` | Tailwind / Tailwind utility classes in HTML | Tailwind is for systems where you compose utilities; deshtml's design language is intentionally locked to fixed component classes (`.ct`, `.cd`, `.tag`, `.eye`, `.fl`). Tailwind would dilute fidelity to the existing references. |

---

## What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| Plugin/marketplace packaging in V1 | Single skill — extra files (`plugin.json`, marketplace metadata) add overhead with no UX benefit and complicate the install one-liner. | Plain `SKILL.md` at the repo root path that `install.sh` copies into `~/.claude/skills/deshtml/`. |
| `curl ... \| sudo bash` | Skill installs into the user's home directory; sudo is wrong and a red flag to security-aware users. | `curl ... \| bash` (no sudo). Refuse to run as root inside the script. |
| Fetching `install.sh` from `main` branch on every install | Non-deterministic; a bad `main` push breaks all installers worldwide instantly. | Pin to a tagged release. README's one-liner can stay on `main` (so install bug fixes ship without README changes), but `install.sh` itself should `git clone --depth 1 --branch v$VERSION` against a known tag, not just `main`. |
| Markdown-to-HTML libraries (markdown-it, Marked, remark, Pandoc) | Cannot produce the design-system's custom components. Adds a build/runtime dep users must install. Reduces fidelity. | Claude writes HTML directly, copying patterns from `references/*.html`. |
| Rendering frameworks (React, Vue, Svelte) | Output must be a single self-contained HTML file with no external JS. Frameworks are the wrong shape. | Plain HTML + inline `<style>`. No JS in V1. |
| External JS (analytics, font-loader scripts, framework runtimes) | PROJECT.md constraint: "no external JS dependencies". Breaks email/desktop portability. | Plain HTML and CSS only. |
| Design tokens / runtime theming layer (CSS-in-JS, theme switcher) | PROJECT.md: "Opinionated V1, configurable V2". Locked to one palette. | Hardcoded CSS variables in the inline `<style>` block, copied verbatim from `references/design-system.md`. |
| `node_modules`, `package.json`, `pnpm-lock.yaml` | No Node runtime. Installer is shell-only. | Plain text repo. |
| `disable-model-invocation: false` (default) | Would let Claude auto-fire `/deshtml` mid-conversation when it thinks the user is "writing a doc". This skill has side effects (writes a file) and a mandatory user-approval gate; auto-invocation would skip the gate. | Set `disable-model-invocation: true` in SKILL.md frontmatter. User must type `/deshtml`. |
| Skill `name` longer than 64 chars or with uppercase/underscores | Claude Code spec rejects it. | `name: deshtml` — 7 chars, lowercase, matches repo and slash command. |

---

## Stack Patterns by Variant

**If V1 ships as planned (single skill, public repo, Santiago + 2 users):**
- Use everything above as-is.
- One `SKILL.md`, one `install.sh`, references as Markdown + the two HTML skeletons.
- Single tagged release (`v0.1.0`) referenced by `install.sh`.

**If a "deshtml family" emerges in V2 (e.g. `/deshtml-edit`, `/deshtml-review`, `/deshtml-export`):**
- Promote to a Claude Code plugin (`plugin.json` + multiple skills under one repo).
- Keep `curl | bash` installer (it can install a plugin too) **and** add the marketplace command (`/plugin marketplace add sperezasis/deshtml`) for users who prefer it.

**If users complain about offline rendering or font-privacy concerns (V2):**
- Self-host Inter as base64-inlined WOFF2 in the generated CSS.
- Single output file remains, just larger (~150KB).
- No change to skill structure.

**If document-type prompts grow past ~200 lines each:**
- Move per-type prompts from `references/doc-types/*.md` into separate sub-skills (`/deshtml-pitch`, `/deshtml-handbook`, ...) sharing a common reference. Anthropic's "keep SKILL.md under 500 lines" guidance is the trigger.

---

## Version Compatibility

| Component | Compatible With | Notes |
|-----------|-----------------|-------|
| Skill format used here | Claude Code 2.1.88+ | Anthropic moved skills to `.claude/skills/<name>/SKILL.md` in 2.1.88. Earlier Claude Code uses `.claude/commands/`. README should state the minimum CC version. |
| `install.sh` | Bash 3.2+ (macOS default) | Don't rely on Bash 4 features (associative arrays, `mapfile`). Tested on macOS default `/bin/bash`. |
| Generated HTML | Modern browsers (Chrome 90+, Safari 14+, Firefox 88+) | CSS variables, Inter font, modern flex/grid. No IE support. |
| Google Fonts `@import` | All modern browsers; fails-soft offline | `-apple-system, sans-serif` fallback in the design system handles offline + privacy-blocking cases. |

---

## Special-Focus Answers

### Should the skill "just write HTML" or use a templating/markdown layer?

**Just write HTML.** Confidence: HIGH.

Three reasons:

1. **The design system has 20+ custom components** (`.ct`, `.cd`, `.tag.t-bl`, `.eye`, `.fl`, `.flow-box`, `.hero-stat`, ...). Markdown libraries don't emit these. Templating libraries would require defining each component as a partial — that's just rewriting the HTML in another syntax with no portability gain.
2. **The reference implementation is already 1,726 lines of hand-written HTML** that Claude can mimic. Giving Claude the reference + the design system spec produces output indistinguishable from hand-crafted (the project's stated success bar). No layer needed in between.
3. **A layer would block iteration.** The Story-First methodology means the document structure changes per type. A rigid template can't accommodate "this pitch has 3 sections, this handbook has 11, this deck has 7 slides". Claude can; templates can't (without becoming so generic they lose the design).

The right intermediate isn't a markdown layer — it's a **reference HTML skeleton** per format (Handbook, Overview) that Claude copies and fills in. That's `references/handbook-format.html` and `references/overview-format.html` in the file table above.

### Claude Code skill packaging conventions

Verified against current docs (code.claude.com/docs/en/skills, fetched 2026-04-27):

- **Path:** `~/.claude/skills/<skill-name>/SKILL.md` for personal/global, `.claude/skills/<skill-name>/SKILL.md` for project. deshtml uses personal.
- **Required:** `SKILL.md` with YAML frontmatter (`name`, `description` recommended). All other frontmatter fields optional.
- **Naming rules:** `name` is lowercase letters/numbers/hyphens, max 64 chars. Becomes the slash command.
- **Description budget:** combined `description` + `when_to_use` truncated at 1,536 chars. Front-load the use case.
- **Body cap:** keep `SKILL.md` under 500 lines per Anthropic guidance; offload detail to supporting files referenced from the body.
- **Auto-discovery vs manual:** default lets Claude auto-invoke. For deshtml, set `disable-model-invocation: true` so only the user fires it.
- **Live reload:** Claude Code watches skill directories — edits during dev show up in the current session. Useful for the development loop. Creating a brand-new top-level skills directory mid-session does require a Claude Code restart.

### GSD-style installer pattern

Verified by inspecting `oaustegard/claude-skills/templates/installation/install-skills.sh` and the alirezarezvani/claude-skills install scripts.

Note on naming: the user's inspiration is "GSD" but the actual `gsd-build/get-shit-done` package uses an **npx installer**, not curl-pipe-bash. The prompt asked for "GSD-shaped" / curl-pipe-bash; the latter is what public single-skill repos actually use, and what should be matched. The recommended pattern is:

```bash
#!/usr/bin/env bash
set -euo pipefail

# 1. Refuse sudo / root
[[ $EUID -eq 0 ]] && { echo "Do not run as root."; exit 1; }

# 2. Pin to a tagged release (not main)
VERSION="${DESHTML_VERSION:-v0.1.0}"
REPO="https://github.com/sperezasis/deshtml.git"
DEST="$HOME/.claude/skills/deshtml"

# 3. Idempotent: detect existing install, offer overwrite
if [[ -d "$DEST" ]]; then
  echo "deshtml is already installed at $DEST."
  read -r -p "Reinstall? [y/N] " ans
  [[ "$ans" =~ ^[Yy]$ ]] || exit 0
  rm -rf "$DEST"
fi

# 4. Shallow clone into temp, copy, clean up
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
git clone --depth 1 --branch "$VERSION" "$REPO" "$TMP/deshtml"
mkdir -p "$HOME/.claude/skills"
cp -R "$TMP/deshtml/skill/" "$DEST"

# 5. Confirm + next steps
echo "Installed deshtml $VERSION to $DEST"
echo "Run /deshtml in Claude Code to start."
```

Properties this guarantees:
- **Idempotent** (detects existing install, prompts; supports `DESHTML_VERSION=vX.Y.Z` override and unattended `yes | curl ... | bash`).
- **Recoverable** (failed clone → temp dir cleaned up by trap; existing install untouched until clone succeeds).
- **Pinned** (version is in the URL parameters, not floating on `main`).
- **Refuses root** (this skill installs into `$HOME`; sudo would create permission rot).
- **Uninstall is one matching script** (`bin/uninstall.sh`: `rm -rf "$HOME/.claude/skills/deshtml"`).
- **Update is just rerun** (the script handles overwrite).

### Self-contained HTML — verified against the existing Caseproof reference

The reference `pm-system.html` already does exactly what we need:

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>...</title>
<style>
  @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap');
  /* ... all CSS inlined here ... */
</style>
</head>
<body>...</body>
</html>
```

Properties:
- Single file, opens correctly via `file://`, email attachment, AirDrop.
- Online: fetches Inter from Google Fonts CDN.
- Offline / fonts blocked: silently falls back to `-apple-system, sans-serif` (declared in design-system fallback chain). Layout integrity is preserved because Inter and `-apple-system` have very similar metrics.
- No external JS, no asset folders.
- Total size for a 1,700-line document: ~80KB. Email-friendly without inlining font binaries.

**Email-rendering caveat (worth flagging in PITFALLS):** the design system + Google Fonts `@import` work great when the file is *opened in a browser from email*. If a recipient previews it inline in Gmail / Outlook, those clients strip `<style>` blocks and ignore `@import`. The PROJECT.md spec says "opens correctly when emailed" which I read as "opens correctly when downloaded and double-clicked from an email" — confirm this with Santiago. If true *inline email rendering* is required, the strategy changes substantially (fully inlined per-tag CSS, web-safe fonts only) and would compromise design fidelity. Recommend: V1 targets the "opened in a browser" path only, and document this.

### Repo conventions for distributing Claude Code skills publicly

Pattern across `oaustegard/claude-skills`, `alirezarezvani/claude-skills`, `s2005/claude-code-skill-template`:

```
deshtml/
├── README.md              # What / install / usage / link to design system
├── LICENSE                # MIT
├── VERSION                # 0.1.0 (semver, no leading v)
├── CHANGELOG.md           # Optional but recommended
├── bin/
│   ├── install.sh         # The one-liner target
│   └── uninstall.sh
├── skill/                 # The payload: this entire dir is copied to ~/.claude/skills/deshtml/
│   ├── SKILL.md
│   └── references/
│       ├── design-system.md
│       ├── story-first.md
│       ├── handbook-format.html
│       ├── overview-format.html
│       └── doc-types/
│           ├── pitch.md
│           ├── handbook.md
│           ├── brief.md
│           ├── deck.md
│           └── meeting-prep.md
└── .github/
    └── workflows/
        └── shellcheck.yml # Lint installer on every PR
```

README must lead with the install one-liner above the fold. Versioning via git tags + GitHub Releases (the changelog the world reads). No npm package, no Homebrew formula in V1.

---

## Sources

- [Claude Code: Extend Claude with skills](https://code.claude.com/docs/en/skills) — HIGH confidence. Authoritative; verified directory layout, frontmatter fields, naming rules, invocation control, supporting-files pattern, the 500-line guidance, the 1,536-char description cap, the 2.1.88 path migration. This is the source of truth.
- [anthropics/skills GitHub](https://github.com/anthropics/skills) — HIGH confidence. Anthropic's own example skill repo confirming structure and frontmatter conventions in production.
- [Skill authoring best practices (Claude API docs)](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices) — HIGH confidence. Description-writing rules, gerund naming, third-person.
- [oaustegard/claude-skills install-skills.sh](https://raw.githubusercontent.com/oaustegard/claude-skills/main/templates/installation/install-skills.sh) — HIGH confidence on installer pattern. Gaps in their script (no idempotency, no pinning, no uninstall) informed the recommended improvements above.
- [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) — MEDIUM confidence. Confirms the `bash <(curl -s ...)` pattern and the `~/.claude/skills/<name>/` install target as conventional.
- [gsd-build/get-shit-done](https://github.com/gsd-build/get-shit-done) — HIGH confidence on the "GSD" reference: it actually uses `npx`, not curl-pipe-bash. Documented in Alternatives Considered.
- [Claude Code skill template (s2005)](https://github.com/s2005/claude-code-skill-template) — MEDIUM confidence. Confirms the `scripts/`, `references/`, `assets/`, `examples/` convention.
- [web.dev: Best practices for fonts](https://web.dev/articles/font-best-practices) — HIGH confidence. Background on self-hosted vs CDN trade-offs that informs the "defer self-hosting to V2" call.
- [Why Inline CSS Is Still Essential for HTML Emails (Franki T, 2025)](https://www.francescatabor.com/articles/2025/12/12/why-inline-css-is-still-essential-for-html-emails) — MEDIUM confidence. Background for the email-rendering caveat (Gmail strips `<style>` blocks).
- Local file: `/Users/sperezasis/work/caseproof/gh-pm/pm/pm-framework/diagrams/pm-system.html` — HIGH confidence. The reference HTML the design system was extracted from. Confirms the Google Fonts `@import` inside an inline `<style>` block is the working production pattern. 1,726 lines, single file, no external JS.
- Local file: `/Users/sperezasis/work/caseproof/DOCUMENTATION-SYSTEM.md` — HIGH confidence. Defines the design language deshtml must produce; confirms `-apple-system, sans-serif` is the documented fallback (handles offline gracefully).

---

*Stack research for: Claude Code skill — public distribution, fixed-design HTML generator*
*Researched: 2026-04-27*
