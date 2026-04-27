# Pitfalls Research

**Domain:** Claude Code skill that generates designed HTML, distributed via curl-pipe-bash installer
**Researched:** 2026-04-27
**Confidence:** HIGH (verified against current Claude Code docs, recent installer post-mortems, and the project's own design-system + methodology files)

---

## Critical Pitfalls

These are the failure modes most likely to make `deshtml` either unsafe to install, visually wrong, or methodologically incoherent.

---

### Pitfall 1: Interactive prompts hang silently when installed via `curl | bash`

**What goes wrong:**
The installer script asks "where should I install?" or "overwrite existing skill?" and the terminal just freezes. User Ctrl-Cs out, partial files remain on disk, skill is half-installed and broken.

**Why it happens:**
When `curl ... | bash` runs, bash's `stdin` is the pipe (the script bytes from curl), not the user's keyboard. Any `read` in the installer reads from the pipe, gets garbage or EOF, and either consumes script content as input or hangs waiting for bytes that will never come. This is the single most-cited failure of curl-pipe-bash installers (starship, platformsh, nix all hit it). See [Troubleshooting: Why Bash Script Input Prompts Fail When Executing Remotely via cURL](https://linuxvox.com/blog/execute-bash-script-remotely-via-curl/).

**How to avoid:**
- Make the installer fully non-interactive by default. No `read` calls in the happy path.
- If a prompt is unavoidable (e.g., overwrite confirmation), read from `/dev/tty` explicitly: `read -r answer < /dev/tty`. Detect if `/dev/tty` is unavailable (CI, Docker) and fall back to safe default.
- Detect piped invocation with `[ -t 0 ]` and print a clear "non-interactive mode, using defaults" line so the user understands what's about to happen.
- Provide environment-variable overrides for every choice (`DESHTML_FORCE=1`, `DESHTML_PREFIX=$HOME/.claude`).

**Warning signs:**
- Any `read`, `select`, or `confirm` in the install script without `< /dev/tty`.
- Manual testing only via `bash install.sh` (which works) but never `curl ... | bash` (which hangs).

**Phase to address:**
Distribution / installer phase. Must be fixed before the install one-liner is published in the README.

---

### Pitfall 2: Partial install on dropped connection leaves a broken skill

**What goes wrong:**
User pastes the curl-pipe-bash command on a flaky hotel WiFi. Connection drops mid-script. Bash has already executed the first half (e.g., wrote `SKILL.md` but not the templates). `/deshtml` now exists, runs, and produces broken output because the templates are missing. User assumes the skill is just buggy.

**Why it happens:**
`curl | bash` is not atomic. Bash starts executing as bytes arrive; a network failure leaves a half-executed script. This is the number-one technical critique of the curl-pipe-bash pattern alongside the security risk. See [Friends don't let friends Curl | Bash | Sysdig](https://www.sysdig.com/blog/friends-dont-let-friends-curl-bash) and [Janis Lesinskis' Blog](https://www.lesinskis.com/dont-pipe-curl-into-bash.html).

**How to avoid:**
- Wrap the entire install logic in a single shell function `main()` and call `main "$@"` only on the **last line** of the script. If the download is truncated mid-file, `main` is never defined and bash errors out instead of executing partial logic.
- Use `set -euo pipefail` so any command failure aborts the install.
- Stage all downloaded files to a temp dir (`mktemp -d`), then atomically `mv` into place at the end. If anything fails before the `mv`, the user's `~/.claude/skills/deshtml/` is untouched.
- Print a clear `Install complete.` line as the last action; document in README "if you don't see this line, re-run the installer".

**Warning signs:**
- Install script that writes directly to `~/.claude/skills/deshtml/` instead of staging.
- No `main()` wrapper — top-level statements that will execute incrementally as bytes arrive.

**Phase to address:**
Distribution / installer phase. Atomicity is non-negotiable for a public installer.

---

### Pitfall 3: Story-First methodology degenerates into outline-and-fill

**What goes wrong:**
The skill produces a story arc table, the user approves it, and then the generator writes sections that read like generic chapter summaries — competent prose that maps to the beats but loses the narrative force. The "one sentence" column read top-to-bottom flowed; the actual sections do not. Output looks designed but reads flat.

**Why it happens:**
LLMs default to outline-filling: each section is generated independently from its row in the table, so causality between sections evaporates. Multi-agent document research confirms this is the dominant failure mode — "Without the Narrative Agent, this kind of structure emerges only by accident, if at all" ([LLM Based Multi-Agent Generation of Semi-structured Documents](https://arxiv.org/html/2402.14871v1)). On top of that, Santiago's CLAUDE.md has explicit Section Writing Rules (handbook-not-pitch tone, name-the-thing titles, causality chain, subtitles-explain-don't-add) that are easy to acknowledge in the prompt and silently violate in generation.

**How to avoid:**
- Generate sections **sequentially**, passing the previous section's final paragraph + the next beat into the prompt. The model must explicitly bridge causality, not invent it from a row.
- After generation, run a **rules-check pass**: feed the draft + the Section Writing Rules back into the model with "for each section, identify which rule (if any) is violated and rewrite the offender". This is the LLM-design-system "audit script" pattern adapted to prose. See [Expose your design system to LLMs](https://hvpandya.com/llm-design-systems).
- Make the arc-approval table the authoritative spec: the "one sentence" column for section N+1 must be derivable from the section N body. If it isn't, the arc was wrong, not the prose.
- Forbid pitch-vocabulary in the generation prompt by name: no "easily", "seamlessly", "powerful", "in seconds", "everything you need".

**Warning signs:**
- Two consecutive sections that could be reordered without losing meaning → causality chain broken.
- Title contains a verb-as-marketing ("Read any issue in 3 seconds") instead of a structural fact ("Every issue follows one format").
- Subtitle introduces a new noun the title doesn't mention.
- Section ends without setting up the next.

**Phase to address:**
Generation pipeline phase. The rules-check pass should be a hard gate before the HTML is written, not an optional polish step.

---

### Pitfall 4: Design-system token drift — invented colors, sizes, components

**What goes wrong:**
Generated HTML uses `#6CA5F9` (off by one digit from `--blue: #6BA4F8`), or `font-size: 15px` for body text (should be 14px), or invents a "warning yellow" because the prompt mentioned a caution. Looks plausible. Fails design-fidelity check immediately for anyone who knows the system.

**Why it happens:**
LLMs hallucinate design tokens whenever the constraint isn't enforced syntactically. "AI models are incredible at writing logic, but without strict constraints, they tend to hallucinate design tokens" ([Expose Your Design System to LLMs](https://hardik.substack.com/p/expose-your-design-system-to-llms)). The DOCUMENTATION-SYSTEM.md has 12 named accent colors and 7 grays — too many for the model to keep straight from memory across a long generation.

**How to avoid:**
- Ship the **exact CSS variable block** from DOCUMENTATION-SYSTEM.md as a verbatim template fragment. The generator inserts it as a literal string copy, never regenerates it.
- Generation prompt forbids hex literals in output CSS: only `var(--token-name)` allowed. Validate post-generation with a regex sweep — any `#[0-9a-fA-F]{3,8}` outside the variable block is a failure.
- Same approach for typography: ship a `<style>` block of class definitions (`.s-lead`, `.eye`, `.cl`, `.ct`, `.cd`, etc.) verbatim from DOCUMENTATION-SYSTEM.md. The generator only writes HTML using those classes, never new CSS.
- Keep a **closed component list** in the skill: tags, inline code, tooltips, highlight boxes, tables, card grids, plus the named flow/showcase/stat/highlight components from the design system. Generation may not invent new component classes.

**Warning signs:**
- Generator output contains a hex code outside the verbatim variable block.
- Output CSS contains class names that don't appear in DOCUMENTATION-SYSTEM.md component library.
- Inline `style="..."` attributes in the body (a sign the model couldn't find the right class and improvised).

**Phase to address:**
Template + generation phase. Verbatim fragments + post-generation regex audit must both be in place before the first end-to-end test.

---

### Pitfall 5: Skill name collision with built-in Claude Code skill

**What goes wrong:**
A future Claude Code update introduces a built-in `/deshtml` (or `/design`, or any name we squat on) and the user's installed skill is silently displaced — the built-in takes precedence with no conflict warning. User runs `/deshtml`, gets unexpected behavior, can't figure out why.

**Why it happens:**
This has happened repeatedly in Claude Code: ["Built-in skills silently introduced by updates conflict with existing custom skills, with no way to disable them"](https://github.com/anthropics/claude-code/issues/33080) and ["Slash commands blocked when skill exists with same name"](https://github.com/anthropics/claude-code/issues/14945).

**How to avoid:**
- Pick a name that's distinctive and unlikely to collide: `deshtml` is good (specific, unusual), generic names like `design`, `doc`, `html`, `slides` are not.
- Install location should be unambiguous: `~/.claude/skills/deshtml/` (user scope) — avoid project-scoped install for V1 since project-scoped skills are now read-only ([Issue #36155](https://github.com/anthropics/claude-code/issues/36155)).
- Document the collision risk in README so users can diagnose `/deshtml` behaving wrong after a Claude Code update.
- Provide an uninstall command (`rm -rf ~/.claude/skills/deshtml`) that's literally one line, so a user who wants to switch back to a hypothetical built-in can do so cleanly.

**Warning signs:**
- Anthropic announces new built-in skills in a Claude Code release — check whether names collide.
- `/skills` output doesn't list `deshtml` after install (could be the listing bug from [Issue #14733](https://github.com/anthropics/claude-code/issues/14733), but verify).

**Phase to address:**
Naming + install layout phase (early). Cheap to fix before launch, expensive after.

---

### Pitfall 6: Skill ignores user-provided source material when invoked with arguments

**What goes wrong:**
User runs `/deshtml @draft.md` expecting the skill to use `draft.md` as source. The skill ignores it and runs the from-scratch interview anyway. User pastes a long draft inline — skill ignores that too and asks "what's your topic?".

**Why it happens:**
Two distinct bugs collide. First, Claude Code has an open bug where slash-command argument substitution fails when file references are involved ([Issue #640: Skills invoked as slash commands without arguments ignore skill instructions](https://github.com/code-yeongyu/oh-my-openagent/issues/640)). Second, even when arguments arrive correctly, skills written for the from-scratch path often have no branching for "source provided" — the prompt template doesn't even check.

**How to avoid:**
- The very first instruction in SKILL.md must be: detect mode. "If the user attached files, pasted >200 chars of source, or referenced `@file`, use **source mode**: skip interview, extract beats from source, present arc table from inferred structure. Otherwise use **interview mode**."
- Echo the detected mode back to the user before asking anything: "Source mode: read draft.md (1,400 words), drafting story arc..." — gives the user one line to interrupt if detection was wrong.
- In source mode, never re-ask for things already in the source (audience, topic, document type if inferable). Asking the user for things they just provided is the worst skill UX failure.

**Warning signs:**
- SKILL.md jumps straight into "Question 1: What's your document type?" without checking for source material.
- User reports "I gave it my draft and it ignored it" in early testing.

**Phase to address:**
Skill structure / SKILL.md phase. Mode detection is the first instruction, before any other behavior.

---

### Pitfall 7: Generated HTML breaks under forced dark mode

**What goes wrong:**
User opens the generated HTML on iOS Safari with system dark mode on. Browser auto-inverts the carefully tuned `#FFFFFF` background and `#2C2C2E` text — now the page is dark with washed-out grays, the colored highlight boxes (`--blue-l: #F0F5FE`) become near-black, the design is unrecognizable. Same in Chrome on Android with "Force dark mode" enabled in flags.

**Why it happens:**
Browsers and OSes apply automatic inversion when the page hasn't declared a color scheme. "Browsers and systems sometimes force dark mode onto websites, overriding custom color schemes, breaking layouts, or distorting brand identities" ([How to Prevent System or Browser From Forcing Dark Mode](https://www.xjavascript.com/blog/how-to-prevent-force-dark-mode-by-system/)). The Caseproof Documentation System is intentionally light-only — there's no dark variant — so any auto-inversion destroys it.

**How to avoid:**
- Add `<meta name="color-scheme" content="light">` to the head of every generated HTML.
- Add `color-scheme: light;` to `:root` in the CSS.
- For iOS Safari specifically, add `<meta name="supported-color-schemes" content="light">`.
- Skip `prefers-color-scheme: dark` media queries entirely — V1 is light-only by design.

**Warning signs:**
- Generated HTML opens dark on a phone with system dark mode on.
- Highlight boxes (`hl-b`, `hl-g`, etc.) lose their soft pastel feel.

**Phase to address:**
Template phase. Two meta tags + one CSS line — must be in the template skeleton from day one.

---

### Pitfall 8: Google Fonts CDN failure produces ugly system-font fallback

**What goes wrong:**
User opens the generated HTML offline, on a corporate network that blocks fonts.googleapis.com, or six months from now when the CDN URL has changed. The Inter font never loads, the fallback kicks in, and the document renders in default sans-serif with completely different metrics — line breaks shift, the careful 56px hero with `letter-spacing: -2.5px` looks broken because system fonts don't kern the same.

**Why it happens:**
The DOCUMENTATION-SYSTEM.md mandates Inter via Google Fonts. Inter has very specific tracking — system fonts substitute at different widths. Email clients strip web fonts entirely (Gmail supports only Roboto and Google Sans natively, [Email On Acid](https://www.emailonacid.com/blog/article/email-development/web-fonts-google-fonts/)). Corporate firewalls regularly block third-party CDNs.

**How to avoid:**
- Keep Google Fonts CDN as the primary loader (per DOCUMENTATION-SYSTEM.md), but commit to a robust fallback stack: `font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;` — already present in DOCUMENTATION-SYSTEM.md, must not be stripped during generation.
- Test the document with Inter blocked (DevTools → Network → block `fonts.googleapis.com`) at least once during template development. If the layout collapses without Inter, the design isn't truly self-contained — accept that or inline the font.
- Document this as a known limitation in the README: "documents look best with internet access; offline rendering uses system fonts."
- For V2 only: consider an `--inline-fonts` flag that base64-embeds Inter into the HTML (~200KB per weight, big but truly self-contained). Out of scope for V1.

**Warning signs:**
- Generated HTML missing the fallback font stack.
- Hero h1 with `letter-spacing: -2.5px` (calibrated for Inter) renders badly with system fonts in offline test.

**Phase to address:**
Template phase. Fallback stack verbatim from the design system; offline test in QA.

---

### Pitfall 9: Anchor links in slide-deck format hide content behind sticky header

**What goes wrong:**
The presentation document type uses `:target` or anchor navigation between slides. User clicks a nav link, browser scrolls to the anchor, but the section title is hidden behind the sticky pill nav from the Handbook layout. Looks like the click did nothing, or the slide is missing its title.

**Why it happens:**
DOCUMENTATION-SYSTEM.md Handbook format includes a "sticky bar + floating pill" nav. Anchor jumps default to placing the target at scroll position 0, which is behind anything `position: fixed` or `position: sticky`. Universal CSS-anchor pitfall. See [How to prevent anchor links from scrolling behind a sticky header](https://gomakethings.com/how-to-prevent-anchor-links-from-scrolling-behind-a-sticky-header-with-one-line-of-css/).

**How to avoid:**
- Add `scroll-margin-top: 80px` (or whatever the sticky-bar height is) to all section/anchor targets in the template. One line, fixes everything.
- Also add `scroll-padding-top: 80px` on `:root` for fragment-navigation cases.
- Test by clicking every sidebar/pill nav item in a generated Handbook doc — every section title must land cleanly below the nav, not under it.

**Warning signs:**
- Clicking a nav link in a generated Handbook hides the section heading.
- Hash-deep-links (`docs.html#section-3`) on first load scroll to the wrong place.

**Phase to address:**
Template phase, specifically Handbook + presentation formats.

---

### Pitfall 10: Story-arc approval gate gets skipped or rubber-stamped

**What goes wrong:**
Skill presents the arc table, user says "looks good" without reading it carefully (or just hits enter), generator produces 1,500 words against a flawed arc, user discovers the structural problem only after seeing the full HTML. Now they're editing prose to fix structure — the slowest possible path.

**Why it happens:**
Two issues. First, users skim approval prompts when the table looks plausible — especially Delfi/Monika who don't yet have the methodology in their bones. Second, if the skill rushes from "here's the arc" → "generating now..." without an explicit pause, the user has no real chance to push back. Even worse: if the table looks competent because the model is good at producing competent-looking tables, users learn to trust it and stop checking.

**How to avoid:**
- The arc table presentation must end with a **forced full-stop**: "Reply `approve` to generate, or describe what needs to change." Anything other than `approve` means edit, not generate.
- Present the "one sentence" column **as a connected paragraph** under the table: "Read top to bottom: *[s1] [s2] [s3] [s4]...*". If it doesn't read as a flowing narrative, the user can see it immediately — much harder to skim than a table.
- For each section, also state explicitly which Story Rule it satisfies ("answers ONE question", "ends with action", etc). Forces the model to actually check.
- After generation, include a footer comment in the HTML source: `<!-- arc: [beat1 -> beat2 -> beat3] -->` so a future reader can verify the arc was the one approved.

**Warning signs:**
- Approval flow that doesn't require an explicit string ("approve", "yes, generate", "looks good").
- Skill generates HTML on the same turn as showing the arc.
- Generated docs that read fine section-by-section but feel disjointed end-to-end.

**Phase to address:**
Skill flow / SKILL.md phase. The gate is the project's claimed moat — it has to be a real gate.

---

### Pitfall 11: Output written to wrong directory or overwrites existing files

**What goes wrong:**
User runs `/deshtml` from `~/Desktop`, expects output there, but the skill writes to the current Claude Code working directory which is somewhere else. Or worse: skill writes `output.html` and silently overwrites a file with the same name from a previous run.

**Why it happens:**
Claude Code's working directory is not always what the user thinks. Skills often default to project-root or user-home without checking. And generic filenames (`output.html`, `document.html`) collide on second invocation in the same dir.

**How to avoid:**
- Write to the **current working directory** (`process.cwd()` / `pwd`), per PROJECT.md requirement. State the absolute path in the success message: "Wrote /Users/sperezasis/Desktop/pitch-bnp.html".
- Generate filenames from the document's slug + document type: `pitch-bnp.html`, `handbook-pm-system.html`, `deck-q3-roadmap.html`. Never `output.html`.
- If the target file exists, append a numeric suffix (`pitch-bnp-2.html`) instead of overwriting. Mention the rename in the success line.
- Never write outside the current working directory without an explicit user request.

**Warning signs:**
- Test invocation produces a file in `~/.claude/skills/deshtml/` instead of the user's pwd.
- Second `/deshtml` run in the same directory silently overwrites the first output.

**Phase to address:**
Skill structure phase. File-writing logic must be explicit about cwd and collision handling from the first version.

---

### Pitfall 12: Over-questioning during interview mode

**What goes wrong:**
User runs `/deshtml`, picks "pitch", and gets asked 14 questions before any output appears. Halfway through they give up. The questions ask things the model could have inferred (audience, length, tone) or things that don't actually change the output (favorite color of the brand?).

**Why it happens:**
LLM skill authors over-correct for under-specified inputs by asking everything. Each question feels harmless individually; together they're a wall.

**How to avoid:**
- Cap interview at **5 questions max** for any document type. PROJECT.md already requires "branching by document type upfront" — keep the per-type questions tight.
- Per type, identify the 3-5 questions that actually change the story arc. Everything else: infer or default with a stated assumption ("Assuming a 5-minute read; adjust by replying with target length").
- Combine related questions into one: not "who's the audience?" + "what do they care about?" but "who reads this, and what do they need to walk away with?".
- Provide one-line examples in every question so the user can pattern-match instead of writing from scratch.

**Warning signs:**
- Interview mode asks more than 5 questions before generating an arc.
- Any question whose answer doesn't visibly change the arc table.
- User testing where Delfi or Monika abandon mid-interview.

**Phase to address:**
Interview design phase, per document type. Calibrate against real users (Delfi, Monika) before launch.

---

### Pitfall 13: Mega-skill that tries to do five document types with one prompt

**What goes wrong:**
SKILL.md is one giant 600-line prompt that branches internally for pitch / handbook / brief / deck / meeting-prep. Token bloat hurts performance, the branching logic is fragile, and changing one document type's behavior risks breaking the others.

**Why it happens:**
The "mega-skill trap" is the most-cited Claude Code skill mistake: "One skill, one job. Don't build 'mega-skills'... mega-skills typically have lower accuracy and composability." ([7 Rules for Creating an Effective Claude Code Skill](https://uxplanet.org/7-rules-for-creating-an-effective-claude-code-skill-2d81f61fc7cd)).

**How to avoid:**
- Keep SKILL.md small (the meta-instructions: detect mode, branch by document type, run methodology gate, audit output).
- Put per-document-type prompts in separate files (`pitch.md`, `handbook.md`, `brief.md`, `deck.md`, `meeting.md`) loaded only after the type is known.
- Put the verbatim design-system fragments (CSS variables, component library, layout templates) in their own files (`design-system.css`, `components.html`) read at template-assembly time, not loaded into the planning context.
- Per Anthropic's skill best practices: "Claude loads FORMS.md, REFERENCE.md, or EXAMPLES.md only when needed. For Skills with multiple domains, organize content by domain to avoid loading irrelevant context."

**Warning signs:**
- SKILL.md grows past ~200 lines.
- Adding a new document type requires editing the main SKILL.md branching logic.
- Per-type instructions diverge slowly because they share a prompt and conflict.

**Phase to address:**
Skill structure phase, before the second document type is added.

---

## Technical Debt Patterns

Shortcuts that look fine in V1 but become traps.

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Skip atomic install (write directly to `~/.claude/skills/deshtml/`) | Simpler installer script | First flaky-network user files an issue, partial install corrupts skill | Never — atomic install is table stakes for a public installer |
| Hex codes inline in generation output (no token-only constraint) | Faster initial template work | Drift detected by hand months later, no automated guard | Never — the project's core value is design fidelity |
| One mega SKILL.md for all document types | Shipping V1 faster | Adding/changing types becomes risky, token bloat hurts every invocation | Only if shipping a single document type; refactor before adding the second |
| Skip the rules-check pass after generation | Saves one model call per document | Section Writing Rules drift silently; Santiago hand-edits every output | Never for the four people the project is built for |
| No uninstall instructions in README | Less doc to write | Users with stale installs can't cleanly switch versions | Acceptable in V0 (Santiago-only); blocking for public launch |
| Generic filename (`output.html`) | Simpler write logic | Second invocation in same dir overwrites first; data loss | Never — slug-based names are trivial to add |
| No version pinning in the install URL (e.g., `main` branch HEAD) | Always-latest install | A bad commit on main breaks everyone's next install; no way to roll back to a known-good version | Acceptable only if releases are tagged and the README points to a tag |

---

## Integration Gotchas

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| Google Fonts CDN | Assume it's always reachable | Always include the system-font fallback stack verbatim from DOCUMENTATION-SYSTEM.md; test offline once |
| `~/.claude/skills/` | Assume directory exists | `mkdir -p ~/.claude/skills/deshtml` in installer; don't fail if `.claude` is fresh |
| Claude Code slash command resolution | Assume `/deshtml @file.md` reliably passes the file | Detect `@` references in the prompt body too, since argument substitution has known bugs ([Issue #640](https://github.com/code-yeongyu/oh-my-openagent/issues/640)) |
| Browsers' forced dark mode | Assume light-only design stays light | Declare `color-scheme: light` and the meta tag; never rely on the browser respecting design intent silently |
| Email clients (if user pastes the HTML into Gmail) | Assume web fonts and `<style>` survive | They don't — Gmail strips `<style>`, falls back to system fonts. Document that emailed docs degrade; recommend attaching the .html file or using the system-font fallback |
| Print / PDF (Cmd-P from browser) | Assume flexbox/grid sections page-break cleanly | `display: flex` and `display: grid` interact badly with `page-break-inside`. Add `@media print` with `display: block` overrides for top-level section containers if print is a real use case |
| GitHub raw URLs in the install one-liner | Hardcode `raw.githubusercontent.com/.../main/install.sh` | Pin to a release tag for reproducibility; add a `?` query string buster trick if users hit CDN cache staleness |

---

## Performance Traps

This is a single-user CLI skill — no real "scale" axis. The relevant traps are token cost and latency per invocation.

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| Loading all per-type prompts upfront | First model turn is slow, large context window consumed before any work happens | Load only the chosen type's prompt after the user picks document type | Noticeable from the first run; gets worse as more types are added |
| Loading verbatim design-system CSS into the planning context | Every interview turn re-reads ~600 lines of design system | Load the CSS only at HTML-assembly time, after the arc is approved | Hits as soon as DOCUMENTATION-SYSTEM.md grows or is duplicated into the skill |
| Per-section sequential generation with no caching | Long doc takes a long time | Acceptable for V1 — quality > speed. If it becomes painful, batch sections in chunks of 2-3 | Only matters for handbook documents with 8+ sections |
| Re-running the full audit pass after every minor edit (if added later) | Slow iteration | Run audit only on first generation; trust the user's manual edits | Only if a re-audit feature is added |

---

## Security Mistakes

The installer is the only meaningful security surface (the skill itself runs in Claude Code's sandbox).

| Mistake | Risk | Prevention |
|---------|------|------------|
| Serving install.sh over HTTP or non-pinned HTTPS | MITM injects malicious payload; users execute arbitrary code as their user | Use `https://` exclusively; rely on GitHub's TLS (HSTS preloaded). Never recommend `curl -k` (skips TLS verification) anywhere in the docs |
| Install one-liner without `--fail` / `-fsSL` flags | Silent failure prints HTML error page into bash, partial weird execution | Use `curl -fsSL` (`-f` fails on HTTP errors, `-s` silent, `-S` show errors, `-L` follow redirects). Same for `wget` if offered |
| Installer downloads additional files at runtime from arbitrary URLs | Supply-chain risk; one compromised dependency host compromises every user | All install assets ship in the same git repo; no runtime fetches from third parties beyond the initial install URL |
| Installer requires `sudo` for any step | Privilege escalation expands blast radius of any vulnerability | `~/.claude/skills/deshtml/` is in the user's home — never need `sudo`. If the installer asks for it, the install is wrong |
| Server-side detection of curl-pipe-bash (sending different content based on User-Agent) | Even self-hosted, it would let an attacker who compromised the server hide malicious code from manual review | We don't self-host the install script — it lives in the public GitHub repo. Document this in the README so reviewers can audit the same bytes that get executed |
| No checksum / signature for the install script | User can't verify they got the bytes the maintainer published | Out of scope for V1 (curl-pipe-bash by definition skips this). Document the script URL in the README so security-conscious users can `curl ... -o install.sh && less install.sh && bash install.sh` instead. See [How to build a trustworthy curl pipe bash workflow](https://dev.to/operous/how-to-build-a-trustworthy-curl-pipe-bash-workflow-4bb) |
| README says "just run this" without showing what the script does | Users can't make an informed trust decision | README includes a "What the installer does" section: 4-5 bullet points, in plain English, of every action the script takes |

---

## UX Pitfalls

| Pitfall | User Impact | Better Approach |
|---------|-------------|-----------------|
| Asking the user for things already in their attached source | Frustration, "didn't you read it?" feeling, abandonment | Mode detection at turn 1; in source mode, never re-ask things present in source |
| Showing the arc table and immediately starting to generate | User has no real chance to course-correct; silent rubber-stamping | Forced explicit approval string before any generation |
| Output succeeds with no clear "where did it go?" message | User can't find the file | Print absolute path of the generated file as the last line |
| Iteration only via "regenerate the whole thing" | Small fixes require re-running the whole pipeline | PROJECT.md correctly says iteration happens via normal Claude conversation — make sure the output HTML is small enough to fit in context for follow-up edits |
| Interview questions that don't visibly affect output | Users learn the questions are theater and stop answering thoughtfully | Every question must change the arc or the section content; if not, drop it |
| English-only error messages when input is Spanish | Mild friction for Spanish-input users (Santiago, Delfi) | Per Santiago's standing rule, skill replies in English regardless of input language — this is correct, document it so users don't think it's a bug |
| Silent fallback when Google Fonts fails | Document looks subtly wrong, user can't tell why | Accept the fallback (no inline base64 in V1) but note it in the README "known limitations" |
| Single test on Santiago's Mac before publishing | Works locally, breaks on Linux / different shell / different Claude Code version | Test matrix: macOS + Linux × bash + zsh × Claude Code latest + previous, before the install URL is shared publicly |

---

## "Looks Done But Isn't" Checklist

Things that pass casual inspection but aren't actually shipping-ready.

- [ ] **Installer works locally:** Often missing — never tested via `curl ... | bash` against the live URL. Verify with the actual public URL, not just `bash install.sh`.
- [ ] **Skill produces a document:** Often missing — verify the **arc-approval gate** is real (responding "no" or "change X" actually re-drafts; the skill doesn't generate prematurely).
- [ ] **Output is self-contained HTML:** Often missing — verify by **opening the file from `/tmp/` with no internet** (DevTools offline mode). Layout must remain intact even with Google Fonts blocked.
- [ ] **Design fidelity:** Often missing — verify generated HTML against the reference implementations (`pm-system.html`, `bnp-overview.html`) **side-by-side in the same browser**. Same font, same spacing, same component shapes.
- [ ] **Five document types:** Often missing — verify that `brief`, `deck`, and `meeting prep` actually have distinct prompts and arcs, not just type-labeled clones of `pitch`.
- [ ] **README install one-liner:** Often missing — verify it's **literally copy-pasteable** with no edits, on a fresh shell, with no prior `~/.claude/skills/` directory.
- [ ] **Uninstall:** Often missing — verify the documented uninstall command actually removes the skill cleanly and `/deshtml` is gone after.
- [ ] **Source-mode invocation:** Often missing — test `/deshtml @some-draft.md` and verify the skill **uses the draft** instead of asking interview questions.
- [ ] **Second invocation in same dir:** Often missing — run `/deshtml` twice in a row in the same directory; verify the second run doesn't overwrite the first output.
- [ ] **Dark mode:** Often missing — open the generated HTML on iOS Safari with system dark mode on; verify it stays light.
- [ ] **Sticky-nav anchors:** Often missing — click every nav item in a generated Handbook; verify section titles land below the sticky bar, not under it.
- [ ] **Story rules audit:** Often missing — verify the audit pass actually runs and actually rewrites violations (not just prints them as warnings).

---

## Recovery Strategies

When pitfalls slip through, how to recover.

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| Partial install on flaky network | LOW | User re-runs the install one-liner. If atomicity is in place (Pitfall 2 fix), this just works. If not, document the manual cleanup: `rm -rf ~/.claude/skills/deshtml && curl ... \| bash` |
| Design-system drift discovered post-launch | MEDIUM | Add the post-generation regex audit (Pitfall 4 fix). Old installs keep working until users re-install for the fix |
| Generic LLM prose on output | MEDIUM | Add the rules-check pass (Pitfall 3 fix). Existing outputs need manual edits or a regenerate; communicate the upgrade in the README |
| Built-in skill name collision after Claude Code update | HIGH | Rename the skill (`deshtml2`, `cp-deshtml`); republish installer; document migration. Painful — much better to pick a distinctive name upfront (Pitfall 5) |
| Output overwriting user files | HIGH | If reported, add the suffix-on-collision logic immediately and apologize; consider adding a "wrote N files" log file in `~/.claude/skills/deshtml/.history` for V2 |
| Approval gate skipped silently | LOW | Tighten the prompt to require the literal `approve` string; ship as a patch |
| Dark-mode inversion in the wild | LOW | Add the meta tag + CSS line; users get the fix on next install or on next generation (depending on whether the CSS is in the template or in the generated output) |

---

## Pitfall-to-Phase Mapping

How roadmap phases should address these pitfalls.

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| 1. Interactive prompts hang via curl-pipe-bash | Distribution / installer phase | Test the live install one-liner end-to-end in a fresh terminal; no prompts should appear without `/dev/tty` redirection |
| 2. Partial install on dropped connection | Distribution / installer phase | Install script ends with `main "$@"` and stages to temp dir; simulate truncation by `head -c 1000 install.sh \| bash` and confirm no partial state |
| 3. Story-First degenerates into outline-fill | Generation pipeline phase | Sequential section generation + post-generation rules-check pass exists and runs on every output |
| 4. Design-system token drift | Template + generation phase | Regex audit (no hex outside the variable block, no class names outside the component library) runs as a hard gate |
| 5. Skill name collision | Naming + install layout phase (early) | Name confirmed distinctive; install path unambiguous; collision risk documented |
| 6. Skill ignores user-provided source | Skill structure / SKILL.md phase | First instruction is mode detection; verify `/deshtml @draft.md` uses the draft |
| 7. Forced dark mode breaks design | Template phase | Meta tag + `color-scheme: light` in every generated HTML; iOS Safari dark-mode test passes |
| 8. Google Fonts CDN failure | Template phase | Fallback stack present verbatim; offline rendering test confirms degradation is graceful |
| 9. Sticky-nav anchor links hide content | Template phase (Handbook + presentation) | `scroll-margin-top` on all anchor targets; click-test every nav link in generated output |
| 10. Arc-approval gate skipped or rubber-stamped | Skill flow / SKILL.md phase | Approval requires explicit `approve` string; "one sentence" column rendered as flowing paragraph for skim resistance |
| 11. Wrong directory / overwritten files | Skill structure phase | Output written to cwd; absolute path printed; collision-suffix test passes (run twice in a row) |
| 12. Over-questioning during interview | Interview design phase | Per-type interview ≤ 5 questions; tested with Delfi or Monika before launch |
| 13. Mega-skill / token bloat | Skill structure phase, before adding the second document type | SKILL.md ≤ 200 lines; per-type prompts in separate files loaded on demand |

---

## Sources

**Curl-pipe-bash distribution risks:**
- [Friends don't let friends Curl | Bash | Sysdig](https://www.sysdig.com/blog/friends-dont-let-friends-curl-bash) — atomicity, integrity, server-side detection
- [Janis Lesinskis' Blog - Another reason why piping the outputs of curl into bash is a security risk](https://www.lesinskis.com/dont-pipe-curl-into-bash.html) — partial-execution failure modes
- [How to build a trustworthy curl pipe bash workflow - DEV Community](https://dev.to/operous/how-to-build-a-trustworthy-curl-pipe-bash-workflow-4bb) — `main()` wrapper pattern, atomic install
- [Troubleshooting: Why Bash Script Input Prompts Fail When Executing Remotely via cURL](https://linuxvox.com/blog/execute-bash-script-remotely-via-curl/) — `/dev/tty` solution
- [Interactive install fails when running "curl | sh" — starship/starship#7133](https://github.com/starship/starship/issues/7133) — real-world example
- [Stijn-K/curlbash_detect](https://github.com/Stijn-K/curlbash_detect) — proof that servers can detect piped invocation

**Claude Code skill best practices and known bugs:**
- [Extend Claude with skills — Claude Code Docs](https://code.claude.com/docs/en/skills) — official skill structure
- [Skill authoring best practices — Claude API Docs](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices) — official guidance, mega-skill anti-pattern
- [7 Rules for Creating an Effective Claude Code Skill](https://uxplanet.org/7-rules-for-creating-an-effective-claude-code-skill-2d81f61fc7cd) — community rules including "one skill, one job"
- [Built-in skills silently introduced by updates conflict with existing custom skills — anthropics/claude-code#33080](https://github.com/anthropics/claude-code/issues/33080) — name collision risk
- [Slash commands blocked when skill exists with same name — anthropics/claude-code#14945](https://github.com/anthropics/claude-code/issues/14945)
- [Project-level skills in .claude/skills/ are now uneditable — anthropics/claude-code#36155](https://github.com/anthropics/claude-code/issues/36155) — affects install-location decisions
- [Skills invoked as slash commands without arguments ignore skill instructions — code-yeongyu/oh-my-openagent#640](https://github.com/code-yeongyu/oh-my-openagent/issues/640) — argument-substitution bug
- [User-provided skills in ~/.claude/skills/ not appearing in /skills command — anthropics/claude-code#14733](https://github.com/anthropics/claude-code/issues/14733)

**LLM design-token drift and document generation:**
- [Expose your design system to LLMs — Hardik Pandya](https://hvpandya.com/llm-design-systems) — closed token layer, audit scripts
- [Expose Your Design System to LLMs — substack](https://hardik.substack.com/p/expose-your-design-system-to-llms) — same author, longer form
- [LLM Based Multi-Agent Generation of Semi-structured Documents — arXiv 2402.14871](https://arxiv.org/html/2402.14871v1) — narrative-agent pattern, why outline-fill produces flat prose
- [Can Large Language Models Design CSS? — Striking Loo](https://strikingloo.github.io/llm-css-design) — empirical limits of LLM CSS

**Self-contained HTML, fonts, dark mode, anchors:**
- [Can I Add Google Fonts to My Email Designs? — Email On Acid](https://www.emailonacid.com/blog/article/email-development/web-fonts-google-fonts/) — Gmail strips web fonts except Roboto/Google Sans
- [How to Prevent System or Browser From Forcing Dark Mode on Your Website](https://www.xjavascript.com/blog/how-to-prevent-force-dark-mode-by-system/) — `color-scheme: light` + meta tag
- [prefers-color-scheme — MDN](https://developer.mozilla.org/en-US/docs/Web/CSS/@media/prefers-color-scheme) — official reference
- [How to prevent anchor links from scrolling behind a sticky header](https://gomakethings.com/how-to-prevent-anchor-links-from-scrolling-behind-a-sticky-header-with-one-line-of-css/) — `scroll-margin-top`
- [TIL: Grid and flex doesn't work in PDF print format](https://discuss.frappe.io/t/til-grid-and-flex-doesnt-work-in-pdf-print-format-use-table-instead/124209) — print-mode pitfall
- [How to fix unexpected gaps when printing flex-based elements in Safari — DEV](https://dev.to/nicolasjengler/how-to-fix-unexpected-gaps-when-printing-flex-based-elements-in-safari-1hk1)

**Project-internal references:**
- `/Users/sperezasis/projects/code/deshtml/.planning/PROJECT.md`
- `/Users/sperezasis/CLAUDE.md` — Story-First methodology and Section Writing Rules
- `/Users/sperezasis/work/caseproof/DOCUMENTATION-SYSTEM.md` — palette, typography, layout, component library

---
*Pitfalls research for: deshtml — Claude Code skill that generates designed HTML via curl-pipe-bash install*
*Researched: 2026-04-27*
