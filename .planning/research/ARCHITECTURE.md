# Architecture Research

**Domain:** Claude Code skill (installable via curl-pipe-bash) that produces self-contained HTML documents from a structured interview, gated by a story-arc approval step.
**Researched:** 2026-04-27
**Confidence:** HIGH (skill structure, install pattern, design embedding) / MEDIUM (uninstall + non-Mac handling — convention-driven, not enforced by Claude Code)

---

## Standard Architecture

### System Overview

```
┌──────────────────────────────────────────────────────────────────────┐
│                      DISTRIBUTION LAYER (GitHub)                      │
│  github.com/sperezasis/deshtml (public, main branch = release)        │
│   • README.md   • install.sh   • uninstall.sh   • skill/   • LICENSE  │
└───────────────────────────────┬──────────────────────────────────────┘
                                │  curl -fsSL .../install.sh | bash
                                ▼
┌──────────────────────────────────────────────────────────────────────┐
│                     INSTALL LAYER (user's machine)                    │
│  install.sh:                                                          │
│    1. Detect/create  ~/.claude/skills/                                │
│    2. If ~/.claude/skills/deshtml exists → update (git pull)          │
│       Else → git clone (or tarball download) into temp, then move     │
│    3. Symlink or copy `skill/` contents to ~/.claude/skills/deshtml/  │
│    4. Print success + "restart Claude Code, run /deshtml"             │
└───────────────────────────────┬──────────────────────────────────────┘
                                │
                                ▼
┌──────────────────────────────────────────────────────────────────────┐
│              SKILL LAYER (~/.claude/skills/deshtml/)                  │
│                                                                       │
│  ┌────────────────────────────────────────────────────────────────┐  │
│  │ SKILL.md  (entry point, <500 lines, loaded by /deshtml)        │  │
│  │   • Frontmatter: name, description, allowed-tools              │  │
│  │   • Phase 0: detect input mode (--auto vs interview vs @file)  │  │
│  │   • Phase 1: ask document type → branch                        │  │
│  │   • Phase 2: load matching interview/<type>.md                 │  │
│  │   • Phase 3: load story-arc.md, build table, gate on approval  │  │
│  │   • Phase 4: load design/SYSTEM.md + format/<fmt>.html         │  │
│  │   • Phase 5: write single .html to cwd                         │  │
│  └────────────────────────────────────────────────────────────────┘  │
│                                                                       │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────────────┐  │
│  │ interview/     │  │ story-arc.md   │  │ design/                │  │
│  │  pitch.md      │  │ (shared gate)  │  │  SYSTEM.md (canon)     │  │
│  │  handbook.md   │  │                │  │  palette.css           │  │
│  │  brief.md      │  │                │  │  typography.css        │  │
│  │  deck.md       │  │                │  │  components.html       │  │
│  │  meeting.md    │  │                │  │  formats/handbook.html │  │
│  └────────────────┘  └────────────────┘  │  formats/overview.html │  │
│                                           └────────────────────────┘  │
└───────────────────────────────┬──────────────────────────────────────┘
                                │  /deshtml (or /deshtml @file.md)
                                ▼
┌──────────────────────────────────────────────────────────────────────┐
│                    OUTPUT LAYER (user's cwd)                          │
│   ./<slug>.html  (single self-contained file, inline CSS, Inter via  │
│                   Google Fonts CDN, no external assets)               │
└──────────────────────────────────────────────────────────────────────┘
```

### Component Responsibilities

| Component | Responsibility | Implementation |
|-----------|----------------|----------------|
| `install.sh` | Idempotent install; detect existing install → update; print restart instructions | POSIX bash, `set -euo pipefail`, no sudo, no global writes outside `~/.claude/skills/deshtml/` |
| `uninstall.sh` | Remove `~/.claude/skills/deshtml/` after confirmation | POSIX bash; reads `--yes` flag for non-interactive |
| `skill/SKILL.md` | Entry point Claude loads when `/deshtml` is invoked. Owns the **flow control**: input detection → type branch → arc gate → render | Markdown + YAML frontmatter; ≤ 500 lines; references other files via relative paths |
| `skill/interview/<type>.md` | Type-specific question scripts and section conventions for each of the 5 doc types | One file per doc type. Each file follows identical schema (questions → section map → tone notes) so SKILL.md treats them uniformly |
| `skill/story-arc.md` | Shared methodology: how to build the `#, Beat, Section, One sentence, Reader feels` table, how to gate on approval, how to enforce headline-only readability | Single source of truth — referenced by SKILL.md after the type branch |
| `skill/design/SYSTEM.md` | Embedded copy of Caseproof Documentation System (palette, typography, components, layout). Self-contained — no read of user's `~/work/caseproof/` at runtime | Copied verbatim from canonical source at build/release time |
| `skill/design/formats/handbook.html` | Reference HTML skeleton for Handbook (sidebar, 960px) format. Claude reads + adapts | Full working HTML with placeholders Claude fills |
| `skill/design/formats/overview.html` | Reference HTML skeleton for Overview (1440px linear) format | Same as above |
| `skill/design/components.html` | Library of every component snippet (cards, tags, tables, hl boxes, etc.) ready to paste | One section per component, matching SYSTEM.md's component library |
| `README.md` | What deshtml is, install one-liner, usage, supported types, link to canonical design system | Caseproof Documentation System styling not required for the README — it's GitHub markdown |

---

## Recommended Project Structure

```
deshtml/                          # repo root
├── README.md                     # what + install + usage
├── LICENSE                       # MIT (public repo, low friction)
├── install.sh                    # curl-pipe-bash entry point
├── uninstall.sh                  # documented uninstall path
├── VERSION                       # semver, bumped per release
├── .planning/                    # GSD planning artifacts (not shipped)
│
└── skill/                        # ← everything in here is what gets
    │                             #    copied to ~/.claude/skills/deshtml/
    ├── SKILL.md                  # entry point + flow control
    │
    ├── interview/                # one file per doc type
    │   ├── pitch.md
    │   ├── handbook.md
    │   ├── brief.md
    │   ├── deck.md
    │   └── meeting.md
    │
    ├── story-arc.md              # shared methodology gate
    │
    └── design/                   # embedded design system
        ├── SYSTEM.md             # canonical spec (copy of Caseproof DS)
        ├── palette.css           # CSS variables block, ready to inline
        ├── typography.css        # type scale + Inter @import
        ├── components.html       # every component snippet, copy-paste ready
        └── formats/
            ├── handbook.html     # Handbook skeleton (sidebar, 960px)
            └── overview.html     # Overview skeleton (1440px linear)
```

### Structure Rationale

- **Repo root vs `skill/` split:** Distribution artifacts (README, install scripts, LICENSE, VERSION) live at root. Everything Claude actually loads lives under `skill/`. `install.sh` copies *only* `skill/*` into `~/.claude/skills/deshtml/`, so users never see installer plumbing in their skill directory.
- **`interview/` as flat per-type files:** SKILL.md routes to one file based on the answer to "what type?". Adding a 6th type later = drop a 6th file + add a route line in SKILL.md. No deep nesting.
- **`story-arc.md` at skill root, not inside `interview/`:** It's shared by all 5 branches. Putting it alongside SKILL.md signals "this is methodology, not type-specific".
- **`design/` self-contained with split files:** SKILL.md doesn't need to load all of SYSTEM.md every run. It loads `palette.css` + `typography.css` + the matching `formats/<fmt>.html` only — cheap, focused. `SYSTEM.md` exists as the canonical spec for when Claude needs to verify a rule (one-level-deep reference per Anthropic best practices).
- **No `scripts/` directory:** This skill is pure prompt + templates. No executable code, no Python, no API calls. Adding a `scripts/` dir would suggest otherwise.
- **`.planning/` excluded from `skill/`:** GSD planning artifacts ship with the repo (visible on GitHub for transparency) but never get installed onto user machines.

---

## Architectural Patterns

### Pattern 1: Single-Entry Skill with Flow-Control SKILL.md

**What:** SKILL.md is the only file Claude loads automatically when `/deshtml` fires. It contains short, declarative flow control that *references* other files but doesn't duplicate their content. Claude reads supplementary files via the Read tool only when the flow says to.

**When to use:** Any skill with a branching workflow where each branch needs distinct context but not all of it at once. This is the Anthropic-recommended progressive-disclosure pattern.

**Trade-offs:**
- (+) Token-efficient — only the active branch's content enters context
- (+) Easy to add a 6th doc type — one file + one route line
- (−) Requires discipline: SKILL.md must stay under ~500 lines and must *reference*, not inline, branch content
- (−) Requires that all `interview/*.md` files follow the same schema, otherwise SKILL.md can't treat them uniformly

**Example (SKILL.md flow-control sketch):**

```markdown
## Flow

1. **Detect input mode**
   - If `@file` provided → treat as raw material, skip generic questions
   - Else → run full interview

2. **Ask document type** (always — even with @file)
   - Options: pitch | handbook | brief | deck | meeting

3. **Load type-specific interview**
   - Read `interview/<type>.md` and follow it

4. **Build the story arc** (mandatory gate)
   - Read `story-arc.md`
   - Produce the `#, Beat, Section, One sentence, Reader feels` table
   - **STOP. Do not proceed until user approves the arc.**

5. **Render HTML**
   - Read `design/palette.css`, `design/typography.css`, `design/components.html`
   - Pick format: Handbook if 4+ sections, else Overview
   - Read `design/formats/<format>.html`
   - Inline everything; write `<slug>.html` to cwd
   - Confirm path and stop
```

### Pattern 2: Shared-Methodology File for DRY Branches

**What:** The 5 doc-type branches each have unique question scripts and section conventions, but they all share the same story-first methodology (define arc → table → approve → write). Pull that shared logic into a single `story-arc.md` that every branch flows through.

**When to use:** Whenever multiple workflow branches converge on the same gate, ritual, or quality check.

**Trade-offs:**
- (+) One place to update the methodology — fix it once, all 5 branches benefit
- (+) Branch files stay focused on what's actually different (question content, section conventions)
- (−) Two-file lookup per run (interview + story-arc) instead of one — negligible cost given progressive disclosure

**Example structure:**

```
interview/pitch.md    →  asks pitch questions, produces raw material
interview/handbook.md →  asks handbook questions, produces raw material
                              ↓ all 5 converge here ↓
story-arc.md          →  shared: build arc table, gate on approval
                              ↓
SKILL.md              →  proceeds to render only after gate passes
```

Each `interview/<type>.md` ends with the same final line:

```markdown
**Next:** Read `story-arc.md` and follow it to build the arc table.
```

### Pattern 3: Design Tokens as Loadable CSS Snippets

**What:** Don't embed design tokens (palette, type scale) as prose in SKILL.md. Ship them as actual CSS files Claude inlines verbatim into the output HTML. The narrative spec (what each color *means*) lives in `design/SYSTEM.md`.

**When to use:** When the skill produces visual output and consistency matters more than flexibility. (V1 explicitly opinionated — no alternate palettes — so this is the right fit.)

**Trade-offs:**
- (+) Zero risk of Claude paraphrasing CSS values incorrectly — it's a copy-paste
- (+) `palette.css` and `typography.css` can be linted/validated as real CSS
- (+) Updating a token = edit one CSS file, every future doc inherits the change
- (−) Slightly more files than a "shove everything in SKILL.md" approach
- (−) Requires SKILL.md to explicitly say "inline these files verbatim into a `<style>` tag"

**Example (`design/palette.css` excerpt — copied verbatim from SYSTEM.md):**

```css
:root {
  --black: #2C2C2E;
  --g9: #525256;
  --g6: #98989D;
  /* ... full palette ... */
  --blue: #6BA4F8;
  --blue-l: #F0F5FE;
}
```

SKILL.md says: *"Read `design/palette.css` and inline its contents inside a `<style>` tag at the top of the output."*

### Pattern 4: Format Skeletons as Working HTML

**What:** Provide `formats/handbook.html` and `formats/overview.html` as fully-working HTML skeletons (with the layout, sidebar/no-sidebar, responsive padding, etc. already correct) that Claude *adapts* by replacing placeholder content. Don't make Claude regenerate the layout from a description.

**When to use:** When visual output must match a reference implementation pixel-for-pixel and there's no value in re-deriving structure.

**Trade-offs:**
- (+) Layout consistency is guaranteed — Claude can't accidentally break the sidebar or the max-width
- (+) Reference matches the canonical implementations (`pm-system.html`, `bnp-overview.html`)
- (−) Skeletons must be kept in sync if the canonical reference evolves

**Example flow:**

```
User answered: 6 sections → Claude picks Handbook format
  ↓
Read design/formats/handbook.html (skeleton with placeholder content)
  ↓
Inline palette.css + typography.css into the skeleton's <style> block
  ↓
Replace skeleton sections with arc-driven content using components.html snippets
  ↓
Write to cwd
```

---

## Data Flow

### Invocation Flow (single `/deshtml` run)

```
User: /deshtml @rough-notes.md
  │
  ▼
Claude Code loads ~/.claude/skills/deshtml/SKILL.md  (only file auto-loaded)
  │
  ▼
SKILL.md flow:
  ├─ Detect: @file present → use as raw material
  ├─ Ask: "What type? pitch | handbook | brief | deck | meeting"
  │     User: "handbook"
  │
  ├─ Read: interview/handbook.md
  │     Run handbook-specific questions (audience, depth, sections,
  │     reference docs, format inclination)
  │
  ├─ Read: story-arc.md
  │     Produce arc table:
  │       | # | Beat | Section | One sentence | Reader feels |
  │     Present to user. STOP.
  │
  │     User: "Beat 3 should come before Beat 2. Otherwise approved."
  │     Claude: revise table, re-present, wait again.
  │     User: "Approved."
  │
  ├─ Decide format: 6 sections → Handbook
  │
  ├─ Read in parallel:
  │     design/palette.css
  │     design/typography.css
  │     design/components.html
  │     design/formats/handbook.html
  │
  ├─ Compose output:
  │     - Inline palette.css + typography.css inside <style>
  │     - Use handbook.html skeleton
  │     - Build each section from arc + raw material + components
  │     - Apply Caseproof section-writing rules from SYSTEM.md
  │       (handbook tone, structural-fact titles, causality chain)
  │
  └─ Write: ./<slug>.html
        Confirm path. End.
  │
  ▼
User opens <slug>.html in browser → matches Caseproof reference look
```

### Install Flow

```
User pastes:
  curl -fsSL https://raw.githubusercontent.com/sperezasis/deshtml/main/install.sh | bash
  │
  ▼
install.sh:
  ├─ set -euo pipefail
  ├─ Detect platform (uname). Warn if not Darwin/Linux but don't block.
  ├─ Compute INSTALL_DIR = ${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}
  ├─ mkdir -p "$INSTALL_DIR"
  │
  ├─ If "$INSTALL_DIR/deshtml" exists:
  │     Print "Existing install detected. Updating..."
  │     cd "$INSTALL_DIR/deshtml" && git pull --ff-only
  │     (or: download tarball, replace contents, preserve nothing user-edited)
  │
  ├─ Else:
  │     git clone --depth 1 https://github.com/sperezasis/deshtml.git /tmp/deshtml-install
  │     cp -R /tmp/deshtml-install/skill/* "$INSTALL_DIR/deshtml/"
  │     rm -rf /tmp/deshtml-install
  │
  ├─ Print success message:
  │     "✓ deshtml installed at $INSTALL_DIR/deshtml"
  │     "  Restart Claude Code, then run /deshtml"
  │     "  Uninstall: curl -fsSL .../uninstall.sh | bash"
  │
  └─ Exit 0
```

### Uninstall Flow

```
User: curl -fsSL .../uninstall.sh | bash
  │
  ▼
uninstall.sh:
  ├─ TARGET="$HOME/.claude/skills/deshtml"
  ├─ If not exists → print "Not installed." exit 0
  ├─ If --yes flag → skip confirmation
  │  Else → prompt "Remove $TARGET? [y/N]"
  ├─ rm -rf "$TARGET"
  └─ Print "✓ Removed."
```

---

## Build Order (Suggested Implementation Sequence)

The dependency graph drives the order. Each item below depends on the previous being usable:

| # | Component | Why this order | Verification |
|---|-----------|----------------|--------------|
| 1 | **`design/` directory (SYSTEM.md + palette.css + typography.css + components.html + formats/handbook.html + formats/overview.html)** | Output quality is the entire point. Without these, nothing else matters. Build them first by hand-extracting from the canonical Caseproof reference implementations (`pm-system.html`, `bnp-overview.html`). | Open the two reference HTMLs side-by-side with `formats/*.html` — they should match structurally. Inline `palette.css` + `typography.css` into each format skeleton and confirm visual fidelity in a browser. |
| 2 | **`story-arc.md`** | The methodology gate is the second-most important asset (the moat). Write it before the type-specific interviews because the interviews need to know what they're feeding into. | Hand-run the methodology against an existing Santiago doc — does the arc table reproducible match what would actually be written? |
| 3 | **`interview/handbook.md`** (first type only) | Pick *one* type to fully wire end-to-end before doing the other four. Handbook is the right first pick: it's the densest, exercises the most components, and Santiago has the most reference material for it. | Run the full flow manually (read SKILL.md → interview/handbook.md → story-arc.md → render) against a real handbook need. Output should be indistinguishable from `pm-system.html`. |
| 4 | **`SKILL.md`** (flow control) | Only writeable after #1–#3 exist, because SKILL.md *references* them. Keep ≤ 500 lines, branch on type, gate on arc. | Invoke `/deshtml` from scratch, end-to-end, on a fresh test directory. Then invoke `/deshtml @file.md` and confirm the @file shortcut works. |
| 5 | **Remaining 4 interview files (pitch, brief, deck, meeting)** | Now that the pattern is proven on handbook, replicate it. Use `interview/handbook.md` as the schema template. | One smoke-test run per type. Confirm each produces a doc whose section conventions match the type. |
| 6 | **`install.sh`** | Only meaningful once `skill/` is complete. Don't waste cycles building install plumbing for a skill that doesn't work yet. | Test on a fresh machine (or temp `CLAUDE_SKILLS_DIR=/tmp/test`). Verify both first-install and update-existing paths. |
| 7 | **`uninstall.sh`** | Trivially small once `install.sh` is done. | One run. |
| 8 | **`README.md`** | Last because the install command is now stable, the doc-type list is final, and you can link to the actual published repo paths. | Read it as a stranger — can you install and use deshtml without asking Santiago anything? |
| 9 | **`VERSION` + first git tag** | Mark the release. Use semver (`0.1.0` for first usable cut). | `git tag v0.1.0 && git push --tags`. |

**Critical sequencing rule:** Don't build SKILL.md before the design assets exist, and don't build interview/ files before story-arc.md exists. Each layer assumes the layer below is real.

---

## Strategy: Keeping the 5 Doc-Type Branches DRY

This is the biggest internal-architecture risk. Concrete tactics:

1. **One shared schema for all `interview/<type>.md` files.** Every file follows the same structure:
   - `## Audience questions` (who reads this, what do they care about)
   - `## Material questions` (what raw content exists, what's missing)
   - `## Section conventions` (what sections this doc type typically has)
   - `## Tone notes` (handbook vs pitch tone, etc.)
   - `## Next: hand off to story-arc.md`

   This means SKILL.md can route to any of them without special cases.

2. **All shared methodology lives in `story-arc.md`, not duplicated.** The arc-table format, the headline-only readability rule, the causality-chain rule, the section-writing rules — all live in one file. Branch files contain *only* what's actually different per type.

3. **Design system lives in `design/`, not in any interview file.** No interview file should contain CSS, color values, or component HTML. They describe *content shape*; design renders content.

4. **SKILL.md never inlines content from referenced files.** It says "read `interview/handbook.md` and follow it" — never "here's a summary of what handbook.md says". Otherwise the two drift.

5. **Single source of truth for shared rules.** The Caseproof section-writing rules (handbook tone, name the thing, structural-fact titles, causality chain) live in `design/SYSTEM.md` only. Both `story-arc.md` and the interview files reference SYSTEM.md when they need to invoke those rules — they don't restate them.

6. **One-level-deep references from SKILL.md.** Per Anthropic skill best practices: SKILL.md → interview/<type>.md, SKILL.md → story-arc.md, SKILL.md → design/*. Never SKILL.md → interview/handbook.md → some-other-file. This keeps Claude from doing partial reads on chained references.

---

## Anti-Patterns

### Anti-Pattern 1: Putting design tokens in SKILL.md prose

**What people do:** Embed the palette, type scale, and component snippets as markdown inside SKILL.md. ("The primary text color is `#2C2C2E`. Use it for…")
**Why it's wrong:** (a) Bloats SKILL.md past the 500-line limit, (b) every `/deshtml` run pays the token cost even when not rendering, (c) Claude can paraphrase or transcribe wrong, (d) updating the palette requires editing prose instead of CSS.
**Do this instead:** Ship `design/palette.css` and `design/typography.css` as real CSS. SKILL.md says "inline these files verbatim into a `<style>` tag." Zero ambiguity.

### Anti-Pattern 2: One mega-prompt for all 5 doc types

**What people do:** Write one giant interview script that branches inline with "if pitch, ask X; if handbook, ask Y…" all in SKILL.md.
**Why it's wrong:** (a) Makes SKILL.md unreadable, (b) every run loads context for all 5 branches even though only one runs, (c) adding a 6th type means editing the mega-prompt instead of dropping a new file.
**Do this instead:** SKILL.md branches *to a file* (`interview/<type>.md`). Each file is focused on its own type. Adding a type = adding a file.

### Anti-Pattern 3: Skipping the arc gate when the user is "in a hurry"

**What people do:** Add a `--no-arc` or `--fast` flag that bypasses the story-arc approval step.
**Why it's wrong:** The arc gate is the moat. Skipping it produces pretty but incoherent docs — the exact failure mode this skill exists to prevent. Out-of-scope per PROJECT.md ("Story-First methodology gate is mandatory").
**Do this instead:** No bypass. The gate is non-negotiable. If the user wants speed, the right move is to make the arc step itself fast (concise table, clear approval prompt) — not to remove it.

### Anti-Pattern 4: Reading user's `~/work/caseproof/DOCUMENTATION-SYSTEM.md` at runtime

**What people do:** Have SKILL.md load the user's local copy of the design system.
**Why it's wrong:** (a) Most users (Delfi, Monika, public installers) don't have that file, (b) couples skill output to the user's local filesystem state, (c) breaks the "self-contained at install time" requirement.
**Do this instead:** Embed the design system as `skill/design/SYSTEM.md` at release time. Update it via repo updates, not by reading local files.

### Anti-Pattern 5: Multi-file output (separate CSS, JS, asset folder)

**What people do:** Output `index.html` + `styles.css` + `components/` directory.
**Why it's wrong:** Out-of-scope per PROJECT.md. The whole point is portability — emailing one file, dropping it on a desktop. Multi-file breaks that immediately.
**Do this instead:** Single self-contained `.html` file. Inline CSS. Web fonts via Google Fonts CDN URL only. No JS dependencies.

### Anti-Pattern 6: Building install.sh before the skill works

**What people do:** Start with the install plumbing because it feels like a foundation.
**Why it's wrong:** install.sh is trivial once `skill/` is complete. Building it first means iterating on installation while the actual product is still broken — wrong order of work.
**Do this instead:** Build the skill, prove it works locally (just symlink `skill/` into `~/.claude/skills/deshtml/` for development), *then* automate the install.

---

## Integration Points

### External Services

| Service | Integration Pattern | Notes |
|---------|---------------------|-------|
| GitHub (raw.githubusercontent.com) | Read-only download of `install.sh` and repo tarball/clone | No auth required (public repo). HTTPS only. Cache-bust via release tags. |
| Google Fonts CDN | `<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap">` inlined in output HTML | Acceptable per PROJECT.md constraints. The only external dependency the *output* document carries. |
| Claude Code runtime | Skill loaded from `~/.claude/skills/deshtml/SKILL.md` when `/deshtml` is invoked | Discovery automatic via filesystem. No registration step. |

### Internal Boundaries

| Boundary | Communication | Notes |
|----------|---------------|-------|
| install.sh ↔ skill/ | One-way file copy | install.sh treats skill/ as opaque payload. No coupling beyond "copy this directory". |
| SKILL.md ↔ interview/ | One-way reference (SKILL.md reads, never the reverse) | All interview files share an identical schema so SKILL.md routing is uniform. |
| interview/<type>.md ↔ story-arc.md | One-way handoff (each interview file ends by directing Claude to read story-arc.md) | story-arc.md is type-agnostic. |
| story-arc.md ↔ design/ | One-way reference (story-arc references SYSTEM.md for section-writing rules) | story-arc reads SYSTEM.md only; never CSS files. |
| SKILL.md ↔ design/ | One-way read (only at render phase, after arc approved) | SKILL.md picks format, inlines CSS, adapts skeleton. |
| Output HTML ↔ filesystem | Single file write to cwd | No directories created, no other files written. |

---

## Sources

- [Skill authoring best practices — Anthropic](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices) — progressive disclosure, ≤500-line SKILL.md, one-level-deep references, frontmatter constraints (HIGH confidence)
- [Extend Claude with skills — Claude Code Docs](https://code.claude.com/docs/en/skills) — `~/.claude/skills/` install location, slash-command discovery (HIGH confidence)
- [github-cli-claude-skill install.sh](https://github.com/doug-skinner/github-cli-claude-skill) — reference install.sh pattern: `set -e`, `mkdir -p`, idempotent update via `git pull` (MEDIUM confidence — single example, but pattern is consistent across other community skills)
- [claude-superskills install pattern](https://github.com/ericgandrade/claude-superskills) — second example of `curl -fsSL ... | bash` shape (MEDIUM confidence)
- `~/.claude/get-shit-done/` and `~/.claude/skills/gsd-new-project/SKILL.md` — local GSD installation as the proof-of-shape: separates `bin/` (tooling) from `templates/` (assets) from `references/` (methodology), with skill stubs in `~/.claude/skills/` that route into the toolkit (HIGH confidence — directly observed)
- `~/work/caseproof/DOCUMENTATION-SYSTEM.md` (642 lines) — canonical design system source, embedded into `skill/design/` at release time (HIGH confidence — directly read)
- `.planning/PROJECT.md` — scope, constraints, key decisions (HIGH confidence — directly read)

---
*Architecture research for: Claude Code skill (deshtml) — installable HTML document generator with story-first methodology gate*
*Researched: 2026-04-27*
