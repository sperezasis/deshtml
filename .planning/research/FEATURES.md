# Feature Research

**Domain:** Claude Code skill — opinionated HTML document generator (story-first methodology, Caseproof Documentation System)
**Researched:** 2026-04-27
**Confidence:** HIGH (driven by PROJECT.md, DOCUMENTATION-SYSTEM.md, and the existing GSD skill pattern Santiago already uses; LOW only on Delfi-as-user assumptions, flagged inline)

---

## 0. Framing

`deshtml` is not a "doc generator" in the generic sense. It is a single-command wrapper around two highly opinionated assets:

1. **The Story-First methodology** (root `CLAUDE.md`) — an arc table that MUST be approved before any HTML is written.
2. **The Caseproof Documentation System** (642-line spec) — palette, typography, component library, two formats (Handbook 960px / Overview 1440px).

Every feature decision below is filtered through one question: **does it protect the design+narrative moat, or does it dilute it?** Anything that lets a non-author bypass the arc gate or alter the visual system is an anti-feature, full stop.

Audiences in priority order: Santiago (will use it weekly, knows the system), Monika (work, knows Caseproof context), Delfi (personal, **non-technical, this is the hardest user — if she can't ship a doc, V1 fails**), public installers (allowed but not designed for).

---

## 1. Cross-Cutting Features

These apply to all five document types.

### 1.1 Table Stakes (Cross-Cutting)

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| **One-line install** (curl-pipe-bash, GSD-style) | Santiago's standard install bar; non-technical users won't tolerate multi-step setup | LOW | Mirror GSD installer; drops files into `~/.claude/skills/deshtml/`. Uninstall = single `rm -rf` line documented in README. |
| **`/deshtml` global command** | Skill must appear in any directory once installed | LOW | Standard Claude Code skill manifest; no per-project config |
| **First question = document type** (5 choices, numbered) | Branches the entire downstream prompt; every doc type has a different arc shape | LOW | Numbered list with 1-line description each so Delfi picks without reading docs |
| **Source-material ingestion via `@file.md`** | Native Claude Code attachment syntax users already know | LOW | Markdown + plain text are first-class. PDF: skip in V1 (use Claude's existing PDF read if user attaches one, but don't promise it). |
| **Source-material ingestion via pasted text** | User pastes a Slack thread / email / notes block in the prompt; skill treats it as source | LOW | No special parsing — just include in context. |
| **Story arc gate** (mandatory approval before HTML) | THE moat. Skipping it = pretty but incoherent docs. | MEDIUM | Output the table in the chat, ask explicitly "Approve / revise?", do NOT generate HTML until user says approve (or equivalent). Re-render the table after each revision pass. |
| **Story arc as table with the exact 5 columns** | `#, Beat, Section, One sentence, Reader feels` — defined in CLAUDE.md, non-negotiable | LOW | Validate column structure in the prompt itself. |
| **"One sentence column reads as a complete narrative" check** | Explicit rule from CLAUDE.md; without it, arcs feel like outlines not stories | LOW | After drafting the arc, the skill should re-read the "One sentence" column top-to-bottom and confirm it flows. |
| **Format auto-selection** (Handbook 960 vs Overview 1440) | Spec rule: 4+ sections → Handbook, 1-3 sections → Overview. User shouldn't have to know this. | LOW | Decision based on approved arc length. Show user which format was picked and why. |
| **Single self-contained `.html` output** in CWD | "Email it, drop it on a desktop, share it" — Santiago's actual distribution model | LOW | Inline `<style>`, Google Fonts via CDN link, zero external assets, zero JS deps. |
| **Strict palette + typography adherence** | Output must be visually indistinguishable from the reference implementations | MEDIUM | Inline the canonical CSS variables block verbatim from DOCUMENTATION-SYSTEM.md. No overrides. |
| **Component-library-only HTML** (no freelance markup) | Freelance HTML breaks visual consistency | MEDIUM | Skill prompt must list the 14+ components with class names and force the model to choose from them. Fall back to plain `<p>` only when nothing fits. |
| **File naming convention** | Predictable, sortable, doesn't collide | LOW | `YYYY-MM-DD-{slug}-{type}.html` (e.g., `2026-04-27-bnp-overview-pitch.html`). Slug = kebab-case from title. Suffix the type so the file type is obvious in a folder. |
| **Open the file at the end** | Generation is invisible until the user opens it; auto-open closes the loop, especially for Delfi | LOW | `open <file>` on macOS at the end of the run (after generation succeeds). Print the absolute path either way. |
| **README explains everything in one screen** | Public install means the README is the entire UX surface for first-time users | LOW | What it is, install, usage, 5 doc types, link to DOCUMENTATION-SYSTEM.md, uninstall. No more. |

### 1.2 Differentiators (Cross-Cutting)

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| **Two-pass arc revision** (skill proposes a critique of its own arc before showing it to user) | Catches "two questions per section," "no causality chain," "headlines don't tell the story" violations from CLAUDE.md before the user has to | MEDIUM | A self-review pass against the section-writing rules. Cheap to add, high quality lift. |
| **Handbook-tone enforcement** (skill rewrites pitch-flavored language to handbook-flavored language during generation) | CLAUDE.md is explicit: "describe what IS, don't sell." This is the most common failure mode for AI-generated copy. | MEDIUM | Bake the bad/good examples from CLAUDE.md into the system prompt as few-shot. |
| **"Name the thing" check** | CLAUDE.md rule: titles must name the concrete noun (repos, board), not abstractions | LOW | Self-review pass on titles before writing HTML. |
| **Anchor-based slide navigation for presentations** | Single-file deck that behaves like slides via `#slide-1`, `#slide-2` and `scroll-snap` — no JS, no framework | MEDIUM | One-time CSS recipe; reusable for every presentation. |
| **Document-type-tailored arc templates** | Each of the 5 types has a known good shape (see per-type sections below); the skill seeds the arc with that shape, not a blank slate | MEDIUM | Reduces cold-start friction massively for Delfi. |
| **Source-material → arc proposal** (when user passes `@draft.md`, skill proposes the arc directly from the source instead of interviewing) | Power-user path: Santiago has a draft, doesn't want to be interviewed | MEDIUM | Detect `@file` in invocation; skip interview, jump to arc proposal grounded in source. |
| **Print absolute path of output file at end** | User can paste it back into chat to iterate | LOW | Trivial but high UX value. |

### 1.3 Anti-Features (Cross-Cutting — DO NOT BUILD in V1)

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|-----------------|-------------|
| **In-skill revision loop** ("/deshtml revise section 3") | Feels natural | Reinventing chat. Claude Code already handles iterative editing via normal conversation. Doubles surface area. | Document in README: "to revise, just chat with Claude — `change section 3 to X`." |
| **Configurable design tokens / themes / palettes** | "What if I want a dark mode? company brand?" | Defeats the entire moat. The opinion IS the product in V1. | Out of Scope per PROJECT.md. Revisit V2 only if real demand emerges. |
| **Multi-file output** (separate CSS, sidebar in own file, asset folder) | "Cleaner code" | Breaks portability — single file is the distribution model. | Inline everything. |
| **Auto-publishing** (push to GitHub Pages, get a share URL) | "Make it shareable" | Requires accounts, auth, hosting, retention policy — not a skill, that's a service. | User decides where to put the HTML. |
| **Telemetry / analytics / "phone home"** | "Know what works" | Public skill, trust-killer, no infra to receive it. | None. Out of Scope per PROJECT.md. |
| **Re-running `/deshtml` against generated HTML** (structured re-edit) | "I want to add a section to my last doc" | Round-trip parsing of generated HTML is fragile and never the right way to edit. | Edit via chat; if structural change needed, regenerate. |
| **Image generation / diagram generation** | "Pitch decks need images" | Out of scope for a single-file pure-HTML skill. Image generation is a separate, expensive capability. | See §1.4 below — handle visuals as deliberate gaps. |
| **PDF export** | "I want a PDF" | Browser print-to-PDF already works on the output (the design system was built with print in mind via the Caseproof palette). | Document in README: "open in Chrome → Print → Save as PDF." |
| **Hosted/web/no-Claude-Code distribution** | "Not everyone uses Claude Code" | Out of Scope per PROJECT.md. | Terminal install only. |
| **Auth, user accounts, project-level config** | "Save my preferences" | No backend, no preferences worth saving in V1. | None. |
| **Markdown output mode** | "Sometimes I just want markdown" | This is a different product. Claude Code already writes markdown natively. | Use Claude Code directly. |
| **Multi-language UX surfaces** (translated prompts) | "Accessibility" | Maintenance burden; Santiago's audience speaks English/Spanish; Claude handles input in either. | Output language follows source material; UX is whatever the user types. |
| **Versioning / "undo" of generated docs** | "What if I overwrite?" | Filename convention with date + type minimizes collision; user is responsible for git/backups. | Filename convention. Document it. |
| **Configurable component library / "add a custom component"** | Power-user request | Erodes the system; one off-spec component infects every future doc. | Locked to DOCUMENTATION-SYSTEM.md components. New components → spec change → V2. |

### 1.4 Visuals (Images / Charts / Diagrams) — Cross-Cutting Decision

This deserves its own subsection because every doc type touches it.

**Decision: leave visuals as labeled gaps (placeholders), not auto-generated, not auto-embedded as data URIs in V1.**

| Asset Type | V1 Behavior | Rationale |
|---|---|---|
| **Photos / screenshots / brand images** | Skill inserts a placeholder block: `<div class="image-gap" data-prompt="screenshot of board view"></div>` styled as a dashed-border 16:9 box with a label | User drops in their image after; doesn't slow generation; doesn't bloat HTML with random data URIs |
| **Charts / metrics** | Use the existing `.donut-wrap` and `.stats` components (CSS-only, no images, in the design system) | Spec already covers this case |
| **Diagrams / flows** | Use the existing `.flow`, `.issue-flow`, `.dtree`, `.role-grid` components (CSS-only) | Spec already covers this case |
| **Logos** | Same as photos — placeholder block | User pastes their own |
| **Auto-embed local images via data URIs** | Anti-feature in V1 | Bloats output, breaks the "small portable HTML" model, requires file I/O the skill shouldn't own |
| **AI-generated illustrations** | Anti-feature in V1 | Out of scope; different product |

If user passes `@draft.md` that references images by path, the skill inserts placeholders with the original filename so the user knows what to drop in.

### 1.5 Onboarding (Critical for Delfi — Non-Technical First-Time User)

| Feature | Why Essential for Delfi | Complexity | Notes |
|---------|------------------------|------------|-------|
| **Install command Santiago can text her** | She will not Google. Santiago needs to send one line in iMessage. | LOW | Already a requirement. Test that the curl line fits in one iMessage bubble. |
| **First-run greeting that names the 5 doc types in plain language** | "Pitch / Handbook / Brief / Deck / Meeting prep" needs human descriptions, not jargon | LOW | Each option = one sentence Delfi can recognize without context. |
| **Opinionated defaults — never ask "what format do you want?"** | Choice is friction; she doesn't have a strong opinion on Handbook vs Overview | LOW | Auto-pick from arc length (already a table-stakes feature). |
| **Show a 3-line example arc table before the real one** | Story-first is a foreign concept to most people; one tiny example removes the abstract feeling | LOW | "Here's what an arc looks like — now let's make yours." |
| **Plain-English questions in the interview** | "What's the reader's job-to-be-done?" → bad. "Who is reading this and what do they need to do after?" → good. | LOW | Interview prompt-engineering. |
| **At-end output: open the file + print path** | She doesn't know what CWD is | LOW | Already a table-stakes feature, repeated here for emphasis. |
| **README written for someone who has never seen Claude Code** | The README is the install onboarding; it has to assume zero context | LOW | Lead with "what you'll get" (screenshot of output), not "how it works." |

**Anti-feature for onboarding:** A multi-screen wizard, a config file, a "first-time setup" step. Install = one line. First run = answer 4-6 questions. That's it.

### 1.6 Update / Uninstall

| Feature | Behavior | Complexity | Notes |
|---------|----------|------------|-------|
| **Update** | Re-run install command — overwrites `~/.claude/skills/deshtml/` | LOW | Document in README: "to update, re-run the install line." No version-pinning, no migration logic in V1. |
| **Uninstall** | `rm -rf ~/.claude/skills/deshtml/` — single line in README | LOW | Don't ship an "uninstaller script." It's one `rm`. Document the line. |
| **Version visible in skill** | A `VERSION` file inside the skill directory; skill mentions version in its first-run greeting | LOW | Helps debugging when Santiago asks Delfi "what version are you on?" |

**Anti-features for update/uninstall:**
- An auto-update check on every run (latency, network dependency, anti-pattern for a local skill)
- A dedicated `/deshtml-uninstall` command (gimmicky; `rm -rf` is the universal answer)

---

## 2. Per-Document-Type Features

For each of the 5 V1 doc types: table stakes, differentiators, anti-features.

### 2.1 Pitch

**Definition:** Problem → Solution → Ask. Convince a stakeholder. Format = Overview (1440px), 1-3 sections typically.

#### Table Stakes

| Feature | Why | Notes |
|---|---|---|
| **Hero section with headline + subtitle + lead** | Pitch lives or dies on the first 5 seconds | Hero h1 = the ask, subtitle = the why, per type scale |
| **"Max 30% of the document on problems" enforcement** | Explicit rule in CLAUDE.md | Self-review pass on the arc: count beats labeled "problem" vs "solution"+"ask" |
| **Explicit "Ask" section as the closer** | "End with action" rule from CLAUDE.md | Last beat must be a directive — what happens next, who does what |
| **Stats row component for credibility numbers** | Pitches need numeric anchors | Use `.stats` component |
| **Compare boxes for "before vs after" or "us vs alternatives"** | Pitch staple | Use `.cmp` component |

#### Differentiators

| Feature | Why |
|---|---|
| **Tailored arc template:** Hook → Stakes → Solution → Proof → Ask (5 beats default) | Removes the cold-start problem for Delfi. She picks "Pitch," gets a working skeleton. |
| **Handbook-tone rewrite is especially aggressive for pitches** | Pitches are where AI most wants to write hype. Aggressive rewrite is the differentiator. |

#### Anti-Features

| Anti-Feature | Why Avoid |
|---|---|
| **Multi-slide pitch** (use Presentation type instead) | Don't blur the Pitch / Presentation distinction |
| **CTA buttons / forms** | Static HTML, not a landing page |
| **Marketing language defaults** ("revolutionary," "game-changing") | Violates handbook tone |

---

### 2.2 Handbook / System Overview

**Definition:** Reference doc — describes how something works. Format = Handbook (960px with sidebar), 4+ sections typically. **This is the canonical Caseproof doc shape.**

#### Table Stakes

| Feature | Why | Notes |
|---|---|---|
| **Sidebar navigation with anchored sections** | Defining feature of the Handbook format | Per DOCUMENTATION-SYSTEM.md layout spec |
| **Sticky top bar** | Per spec | — |
| **Floating pill (back-to-top or section indicator)** | Per spec | — |
| **Section dividers between major beats** | Per spec spacing constants | — |
| **Topic-break h3s within sections** | Per spec — handbook structure relies on these | — |
| **Tables, card grids, highlight boxes available** | Reference docs lean heavily on these | — |
| **Collapsible details for reference content** | Spec rule: detail belongs in tooltips/collapses, not on the surface | Use `.collapse` |

#### Differentiators

| Feature | Why |
|---|---|
| **Auto-generate the sidebar nav from the approved arc** | Sidebar mirrors arc beats 1:1; user doesn't manually maintain it |
| **"Causality chain" check between sections** | CLAUDE.md rule that handbook structure depends on most heavily |
| **Tailored arc template:** the "what is it / how it's structured / how you use it / edge cases / what's next" shape | Mirrors the pm-system.html reference exactly |

#### Anti-Features

| Anti-Feature | Why Avoid |
|---|---|
| **Multi-page handbook** (Table of Contents → links to other files) | Single-file rule |
| **Search bar inside the handbook** | Browser Cmd-F is sufficient; adding search = JS = breaks "no JS deps" |
| **Edit links / Git integration** | Out of scope for a static generator |

---

### 2.3 Technical Brief

**Definition:** Architecture / decision write-up for engineers. Format = Handbook (probably) or Overview (if short). 3-6 sections.

#### Table Stakes

| Feature | Why | Notes |
|---|---|---|
| **Code blocks (inline `.ic` and block-level)** | Engineers need code | Block-level: simple `<pre><code>` styled per design system |
| **Decision matrix / comparison tables** | Technical decisions live in tradeoff tables | Use `.tb` and `.cmp` |
| **Flow diagrams for architecture** | `.flow` and `.issue-flow` components | — |
| **Decision tree component for branching logic** | `.dtree` | — |
| **"Decision" / "Rationale" / "Consequences" structure** | ADR-shaped | The arc template should mirror this |

#### Differentiators

| Feature | Why |
|---|---|
| **Tailored arc template:** Context → Decision → Alternatives Considered → Tradeoffs → Consequences → Open Questions | ADR-style; engineers recognize this immediately |
| **Highlight boxes for "Rule" / "Warning" / "Constraint"** | Brief is full of these; the highlight component is purpose-built | Use `.hl-r` for warnings, `.hl-b` for rules |
| **Inline code styling honors the design system** | Engineers will notice if `<code>` looks generic | Use `.ic` class |

#### Anti-Features

| Anti-Feature | Why Avoid |
|---|---|
| **Syntax highlighting** (Prism, highlight.js) | Adds JS dep; breaks single-file portability; violates "no JS" constraint |
| **Mermaid diagrams** | Adds JS dep; design system has its own diagram components |
| **Auto-generated TOC from headings** | Sidebar already does this in Handbook format |

---

### 2.4 Presentation / Slide Deck

**Definition:** Single-page HTML where each "slide" is a section, navigated via anchors and scroll-snap. Format = custom (neither Handbook nor Overview — see below).

#### Table Stakes

| Feature | Why | Notes |
|---|---|---|
| **Anchor-based slide navigation** (`#slide-1`, `#slide-2`, …) | Single file, no JS, share a URL `file.html#slide-3` to jump | CSS-only; `scroll-snap-type: y mandatory` on body, `scroll-snap-align: start` on each slide |
| **Full-viewport slides** (`100vh` per slide) | Slide model expectation | — |
| **Hero typography on every slide** | Slides are headline-driven; body type scale is too small | Use the Hero h1 / subtitle scale from spec |
| **Slide number indicator** (bottom corner) | Audience expects "3 / 12" | CSS-only counter using `counter-reset` / `counter-increment` |
| **Keyboard navigation hint shown briefly on first slide** ("Use ↓ / Page Down") | Otherwise user doesn't know how to advance | Static text, no JS needed; browser handles arrow keys via scroll |
| **Print stylesheet that gives one slide per page** | Decks get printed | `@page` + `@media print` rules |

#### Differentiators

| Feature | Why |
|---|---|
| **Tailored arc template:** Title → Context (1-2 slides) → Core idea (1 slide, big) → Detail slides (3-6) → Ask | Real deck shape, not "slidified document" |
| **Big-number slide layout** (one stat, hero-sized, full-screen) | Recognizable presentation idiom; uses `.stat-n` at 80-120px |
| **Quote slide layout** | Common deck idiom; design-system-styled |
| **Section-divider slides** (color block + label) | Real decks use these; trivial in CSS |

#### Anti-Features

| Anti-Feature | Why Avoid |
|---|---|
| **Reveal.js / Impress.js / any slide framework** | Adds heavy JS dep; defeats single-file model |
| **Click-through animations / transitions** | JS dep; animations age badly; design system doesn't define them |
| **Speaker notes panel** | Requires JS; print-to-PDF with notes can be a V2 feature |
| **Embedded video** | Defeats portability if local file; if YouTube embed, fine but document as "user adds the iframe themselves" |
| **PowerPoint / Keynote export** | Out of scope; different product |
| **Aspect-ratio toggle (16:9 vs 4:3)** | 16:9 only — opinionated |

---

### 2.5 Meeting Prep

**Definition:** Briefing doc for an upcoming meeting — context, goals, talking points, decisions needed. Format = Overview (1440px), 2-4 sections. Short and dense.

#### Table Stakes

| Feature | Why | Notes |
|---|---|---|
| **Header block: meeting title, date, attendees, duration** | Every meeting brief has these four | Render as a clean `.flow` row at the top |
| **"Goal of this meeting" section as the first beat** | A meeting without a clear goal is a wasted meeting; CLAUDE.md "end with action" applies inverted — start with action too | One sentence, hero-styled |
| **"Decisions needed" section as a numbered list** | The reason a meeting brief exists | Use `.dtree` or numbered list |
| **"Talking points" / "What I'll say" section** | Briefing's core utility | Card grid or simple list |
| **"Context the other side has" vs "Context only I have"** | Asymmetric-info framing — the most useful meeting-prep structure | Use `.cmp` |

#### Differentiators

| Feature | Why |
|---|---|
| **Tailored arc template:** Goal → Context → Decisions Needed → My Position → Risks/Pushback → Next Steps | Real prep shape, not "agenda" |
| **Highlight box for "If they push back, say:" rebuttals** | The single most useful thing in a real prep doc | Use `.hl-o` (orange = caution) |
| **Compact format optimized for a 5-minute pre-meeting read** | Different from a handbook — density matters more than scan-ability | Tighter spacing variant |

#### Anti-Features

| Anti-Feature | Why Avoid |
|---|---|
| **Calendar integration / pulling from Google Calendar** | Out of scope; no auth, no APIs |
| **Action-items tracking / post-meeting follow-up** | Different product; meeting prep is pre-meeting only |
| **Sharing with attendees** | This is a *personal* brief; sharing it changes the doc shape entirely |

---

## 3. Feature Dependencies

```
Install (one-liner)
    └──enables──> /deshtml command
                      └──requires──> First-question = doc type
                                          └──branches into──> 5 type-specific arc templates
                                                                    └──feeds──> Story arc gate (mandatory approval)
                                                                                      └──gates──> HTML generation
                                                                                                        └──requires──> Caseproof CSS variables (verbatim)
                                                                                                        └──requires──> Component-library-only HTML
                                                                                                        └──produces──> Single .html file with naming convention
                                                                                                                              └──triggers──> open + print path

Source ingestion (@file or pasted)
    └──short-circuits──> Interview
                            └──jumps to──> Story arc proposal grounded in source

Self-review pass on arc (handbook-tone, name-the-thing, causality, "one sentence flows")
    └──enhances──> Story arc gate (catches violations before user sees them)

Format auto-selection (Handbook vs Overview)
    └──depends on──> Approved arc length
        └──affects──> Sidebar generation (Handbook only)
        └──affects──> Max-width and padding constants

Presentation type ──conflicts with──> Format auto-selection
    (Presentation uses its own custom layout, not Handbook/Overview)

Visuals as placeholders ──conflicts with──> Auto-embed images as data URIs
    (Pick one; V1 picks placeholders)

Update = re-run install ──conflicts with──> Auto-update check on each run
    (Pick one; V1 picks manual re-run)
```

### Dependency Notes

- **Story arc gate gates everything:** no HTML is written without explicit user approval of the arc. This is the single most important dependency in the system.
- **Component-library-only HTML depends on the system prompt enumerating components:** the LLM must be told the closed set of allowed classes; otherwise it will invent freelance markup.
- **Source ingestion short-circuits the interview but NOT the arc gate:** even with a draft, the user must approve the arc.
- **Format auto-selection depends on the approved arc:** can't pick Handbook vs Overview until the arc length is known.
- **Presentation is structurally different:** it uses neither Handbook nor Overview layout. Treat it as a third format internally, even though we say "5 doc types, 2 formats" externally.

---

## 4. MVP Definition

### Launch With (V1)

Minimum to validate "non-author runs one command, gets a Caseproof-grade HTML doc."

- [ ] One-line install / uninstall
- [ ] `/deshtml` global command
- [ ] First question = doc type (5 numbered options)
- [ ] All 5 type-specific arc templates
- [ ] Story arc gate (mandatory approval, table format with the 5 canonical columns)
- [ ] Self-review pass on arc (handbook tone, name-the-thing, causality, "one sentence flows")
- [ ] Source-material ingestion (`@file.md` and pasted text)
- [ ] Format auto-selection (Handbook 4+, Overview 1-3, Presentation = its own thing)
- [ ] Single self-contained HTML output in CWD with `YYYY-MM-DD-{slug}-{type}.html` naming
- [ ] Auto-open file at end + print absolute path
- [ ] Strict palette + typography + component-library adherence
- [ ] Visuals as labeled placeholder gaps
- [ ] README that works for a non-technical first-time user
- [ ] Anchor-based slide navigation for Presentation type

### Add After Validation (V1.x)

- [ ] Print stylesheet polish for Presentation type → PDF export workflow doc
- [ ] Section-level "improve this section" via chat instructions baked into the README (not new commands — just better docs)
- [ ] Additional arc templates within existing types (e.g., "founder pitch" vs "internal pitch" sub-templates)
- [ ] Better handling of attached PDFs as source material

### Future Consideration (V2+)

- [ ] Configurable design tokens (only if a real second design system emerges) — see PROJECT.md "Opinionated V1, configurable V2" decision
- [ ] Additional doc types based on observed demand
- [ ] Image embedding as data URIs (only if users actually request it; placeholders may be enough)
- [ ] Optional auto-update check
- [ ] Dark mode for the design system

---

## 5. Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
|---------|-----------|---------------------|----------|
| One-line install | HIGH | LOW | P1 |
| `/deshtml` command | HIGH | LOW | P1 |
| Doc-type-first interview | HIGH | LOW | P1 |
| 5 tailored arc templates | HIGH | MEDIUM | P1 |
| Story arc gate | HIGH | MEDIUM | P1 |
| Self-review pass on arc | HIGH | MEDIUM | P1 |
| Source ingestion (`@file`, pasted) | HIGH | LOW | P1 |
| Format auto-selection | HIGH | LOW | P1 |
| Component-library-only HTML | HIGH | MEDIUM | P1 |
| Strict palette/typography | HIGH | LOW | P1 |
| Single-file output + naming convention | HIGH | LOW | P1 |
| Auto-open + print path | MEDIUM | LOW | P1 |
| Visuals as placeholders | MEDIUM | LOW | P1 |
| README for non-technical users | HIGH | LOW | P1 |
| Anchor-based slide nav (Presentation) | HIGH | MEDIUM | P1 |
| Handbook-tone aggressive rewrite | HIGH | MEDIUM | P1 (it IS the moat) |
| Print stylesheet for Presentation | MEDIUM | LOW | P2 |
| Source-material → arc proposal (skip interview) | MEDIUM | MEDIUM | P2 |
| Sub-templates within doc types | LOW | MEDIUM | P3 |
| PDF source ingestion | LOW | MEDIUM | P3 |
| Configurable design tokens | LOW (V1) | HIGH | P3 / V2 |
| Image embedding as data URIs | LOW | MEDIUM | P3 |
| Dark mode | LOW | HIGH | P3 / V2 |

**Priority key:**
- P1: Must have for V1 launch
- P2: Add in V1.x once V1 is validated
- P3: Future / V2

---

## 6. Competitor / Reference Analysis

| Capability | GSD (the install pattern reference) | Manual Claude Code prompting (today's baseline) | deshtml (V1) |
|---|---|---|---|
| One-line install | Yes | N/A | Yes (mirror GSD exactly) |
| Story-first methodology enforcement | Yes (in `/gsd-new-project`) | No (depends on user prompting) | Yes (mandatory arc gate) |
| Caseproof Documentation System adherence | No (different domain) | No (depends on user attaching the spec each time) | Yes (baked in) |
| Single-file portable HTML output | No | Possible but inconsistent | Yes (defining feature) |
| Doc-type branching | No | No | Yes (5 types) |
| Non-technical user friendly | Partial (PM tool) | No (requires Claude Code fluency) | Yes (THE design constraint for Delfi) |

**Insight:** The competitor isn't another HTML generator — it's "Santiago manually crafting each doc" or "user prompts Claude Code from scratch every time and re-attaches the spec." `deshtml`'s entire value is collapsing both into one command without losing fidelity.

---

## Sources

- `/Users/sperezasis/projects/code/deshtml/.planning/PROJECT.md` — requirements, out-of-scope, key decisions (HIGH confidence)
- `/Users/sperezasis/CLAUDE.md` — Story-First methodology, section writing rules (HIGH confidence)
- `/Users/sperezasis/work/caseproof/DOCUMENTATION-SYSTEM.md` — palette, typography, components, layout (HIGH confidence, lines 1-400 read)
- `~/.claude/get-shit-done/` — GSD installer pattern as reference for install/uninstall UX (HIGH confidence, structure inspected)
- Delfi-as-non-technical-user assumptions — derived from PROJECT.md "Audience" section; LOW confidence on her specific behavior, MEDIUM confidence on directional design implications (flagged inline in §1.5)

---
*Feature research for: deshtml (Claude Code skill — opinionated story-first HTML doc generator)*
*Researched: 2026-04-27*
