# Phase 2: Story-Arc Gate + Handbook End-to-End — Research

**Researched:** 2026-04-27
**Domain:** Claude Code skill internals (SKILL.md flow control, `$ARGUMENTS` substitution, sub-file lazy loading), self-review prompt engineering, bash audit script on macOS, single-file HTML inlining and atomic writes.
**Confidence:** HIGH (skill semantics + macOS tooling verified against current docs and live `man`/`--version` output) / MEDIUM (self-review prompt patterns — well-cited but not empirically tested in this codebase).

---

## Summary

Phase 2 stitches Phase 1's design fragments into a working `/deshtml` skill that runs an interview, gates on a story arc, audits the rendered output, and writes a single self-contained HTML to the user's CWD. The most consequential research findings, with action items for the planner:

1. **`$ARGUMENTS` is the canonical mode-detection input.** When the user types `/deshtml @notes.md`, `$ARGUMENTS` expands to the literal string `@notes.md` — Claude Code does NOT resolve `@`-mentions before the skill runs. SKILL.md's mode-detection branch must inspect `$ARGUMENTS` as raw text. `[CITED: code.claude.com/docs/en/skills §"Pass arguments to skills"]`
2. **SKILL.md is loaded once per invocation, not per turn.** Once the skill is invoked, the rendered SKILL.md "enters the conversation as a single message and stays there for the rest of the session." Sub-files referenced from SKILL.md are read by Claude on demand via the `Read` tool. This validates D2-01's lazy-load discipline. `[CITED: code.claude.com/docs/en/skills §"Skill content lifecycle"]`
3. **The SKILL.md token cap is 500 lines per Anthropic guidance, not 200.** D2-01's 200-line self-imposed cap is stricter than required and is fine — it leaves headroom for Phase 3's four additional doc-type stubs without ever needing to refactor. `[CITED: platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices §"Token budgets"]`
4. **The audit script must use `command grep`, not `grep`.** This shell aliases `grep` to `ugrep` (already flagged in Phase 1's audit deviation #1). Hard-code `command grep` in `audit/run.sh` to bypass aliases on Santiago's machine and any user with similar shell config. `[VERIFIED: ran type and grep --version in this session]`
5. **macOS uses BSD grep + BSD sed.** GNU long options (`--regexp`, `--null-data`) are unavailable. Stick to POSIX BREs and ERE via `-E`. `sed -i` requires an empty-string backup arg on BSD (`sed -i '' 's/.../.../'`). `[VERIFIED: /usr/bin/sed --version returned BSD usage; /usr/bin/grep --version reports BSD]`
6. **`open <file>` is non-blocking by default.** It hands off to LaunchServices and returns immediately, which is what we want — terminal flow continues straight to the path-print line. `open` does not need `&` or `nohup`. `[CITED: man open(1)]`
7. **Self-review prompt engineering is the highest-risk piece.** Confirmed by `.planning/research/SUMMARY.md` ("budget 2-3 iteration rounds"). The mitigations below give a concrete, mechanical-first design that constrains the LLM rather than asking it nicely.

**Primary recommendation:** Implement SKILL.md as a step-numbered checklist that explicitly tells Claude when to read each sub-file (one-level-deep, never chained). Keep the audit script in pure bash with `command grep`/`command sed` and harvest the class allowlist mechanically from `components.html` at every audit run (no separate hand-maintained list). Inline `palette.css` + `typography.css` via a Read+concat+Write sequence performed by Claude (not a separate script), because inlining is a one-shot per output and a script would add a dependency without saving tokens.

---

## User Constraints (from CONTEXT.md)

### Locked Decisions

Verbatim from `02-CONTEXT.md`:

**SKILL.md structure (D2-01, D2-02):** `skill/SKILL.md` ≤200 lines, flow-control only. Sub-files: `skill/story-arc.md`, `skill/interview/handbook.md`, `skill/audit/rules.md`. Lazy-loading discipline — SKILL.md never inlines content.

**Mode detection (D2-03, D2-04, D2-05):** Mechanical, not heuristic. `@<path>` present → source mode (Phase 2 stub). Else prose >200 chars → source mode (stub). Else → interview mode. First interactive question = doc type; only `handbook` branch is implemented in Phase 2; other four types return `coming in Phase 3` stub.

**Handbook interview (D2-06, D2-07, D2-08):** ≤5 questions, schema `audience → material → section conventions → tone notes → handoff to story-arc`. No required-field validation — empty answers proceed with defaults.

**Story-arc gate (D2-09 through D2-14):**
- Table columns exactly: `#`, `Beat`, `Section`, `One sentence`, `Reader feels`.
- Below the table, render `## Read the One Sentence column top-to-bottom` joining `One sentence` cells into one paragraph.
- Self-review checks: (a) handbook-tone, (b) causality-chain, (c) name-the-thing. Status line under each section. Failures auto-fix in place but show the fix.
- Approval whitelist (case-insensitive, exact-after-trim): `approve`, `approved`, `looks good`, `lgtm`, `ship it`, `go`, `proceed`, `aprobado`, `dale`. **No fuzzy matching.** Anything else = revision request, no iteration cap.

**Output writer (D2-15 through D2-18):**
- Inline `palette.css` + `typography.css` into a single `<style>` block, replacing the `<link>` tags from `formats/handbook.html`.
- Filename: `YYYY-MM-DD-<slug>-handbook.html`. Slug = kebab-case from first 4-5 words of H1. On collision: `-2`, `-3`. Local-time today.
- After write: `open "<absolute-path>"`, then print absolute path on its own line. No emoji, no banner.

**Audit (D2-19 through D2-22):**
- Rules: hex literals outside `:root` are violations; class allowlist harvested from `components.html`; tag/attr denylist (`<script>`, `<iframe>`, `<object>`, `<embed>`, `on*=`, `javascript:`).
- Script: `skill/audit/run.sh`. Invoked from SKILL.md via Bash tool after write, before `open`. Exit 0 = pass. Max 2 retry rounds; round 3 surfaces violations to user with the file written anyway.
- `--explain` flag for dev mode (file/line context).

**Visual contract (D2-23, D2-24, D2-25):**
- Generated handbook visually indistinguishable from `pm-system.html` at structural-shell level.
- Test fixture: deshtml-about-itself handbook (recommended subject for D2-24).
- Browser matrix: Chrome + Safari side-by-side; iOS Safari forced-dark-mode test.

### Claude's Discretion

- `interview/handbook.md` format (flat numbered list vs YAML-front-mattered prose) — pick what reads cleaner.
- Stub-message wording for source mode and the four future doc types — ≤2 sentences.
- `audit/rules.md` shape (markdown prose vs JSON config) — bash-readable either way.
- Audit language: bash preferred (parity with `bin/install.sh`, no new dep), Python acceptable if regex gets ugly.
- Self-review status placement (extra column in arc table vs status line below each row) — pick what's least visually noisy.
- Approval whitelist may grow during execution — D2-12 is the floor.

### Deferred Ideas (OUT OF SCOPE)

- Multi-language tone rubric (Spanish skip-tone-check fallback in V1 is acceptable).
- Audit auto-fix mode (V1 only flags + regenerates).
- Arc-gate undo (`/deshtml --revise <file.html>` is V2).
- Token-budget alarms in self-review (V2).
- Audit configuration via project file (V1 is opinionated).
- CSS scroll-snap presentation format (Phase 3, not Phase 2).

---

## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| SKILL-01 | `/deshtml` (no args) launches from-scratch interview | §"SKILL.md flow" + §"Mode detection" (this doc) |
| SKILL-03 | Skill detects mode at turn 1, never silently falls back | §"Mode detection — `$ARGUMENTS` semantics" |
| SKILL-04 | First interactive question = document type, branches the run | §"SKILL.md flow" Step 3 |
| SKILL-05 | SKILL.md ≤200 lines, flow-control only | §"Skill content lifecycle" + §"Progressive disclosure" |
| ARC-01 | Arc table with the canonical 5 columns | Constrained by D2-09; rendered verbatim in `story-arc.md` |
| ARC-02 | "One sentence" column rendered as flowing paragraph below table | §"Self-review prompt patterns" |
| ARC-03 | Automated self-review pass before showing arc to user | §"Self-review prompt patterns" — concrete prompt template |
| ARC-04 | Block HTML generation until explicit approval | §"Approval gate mechanics" |
| ARC-05 | Revision loop until approved | §"Approval gate mechanics" |
| DOC-02 | Handbook doc type wired end-to-end | §"Output writer — Read+concat+Write inlining" |
| DOC-07 | ≤5 questions before arc | Constrained by D2-06; structural |
| DESIGN-06 | Post-generation audit rejects hex outside `:root`, unknown classes, banned tags | §"Audit script — bash on macOS" |
| OUTPUT-01 | Single self-contained `.html` to CWD | §"Output writer" |
| OUTPUT-02 | `YYYY-MM-DD-<slug>-handbook.html` with `-2`/`-3` collision | §"Filename and collision detection" |
| OUTPUT-03 | `open <file>` after write | §"`open` semantics on macOS" |
| OUTPUT-04 | Print absolute path | §"Output writer" |
| OUTPUT-05 | HTML opens correctly via `file://` | §"Single-file HTML inlining" |

---

## Project Constraints (from CLAUDE.md)

`/Users/sperezasis/CLAUDE.md` is the methodology source of truth. Phase 2 must enforce these in the self-review pass:

| Directive | Enforcement Mechanism in Phase 2 |
|-----------|----------------------------------|
| Tone: handbook, not pitch — describe what IS, don't sell. | Self-review check (a) — pattern-match against the 8-10 BAD→GOOD pairs harvested verbatim from CLAUDE.md into `skill/story-arc.md` (per D2-14). |
| Titles are structural facts or directives. | Self-review check (a)/(c) — every title must contain a concrete noun naming the section. |
| Name the thing — don't abstract into vague nouns. | Self-review check (c) — flag titles containing only abstract nouns ("shape," "approach," "way," "kind," "idea"). |
| Causality chain: each section follows from the previous. | Self-review check (b) — each section's lead question must answer the previous section's setup. |
| Subtitles explain, don't add. | Implicit in check (a) — flag subtitles that introduce a new noun absent from the title. |
| Each section answers ONE question. | Pre-arc check during interview-to-arc handoff — the arc-row spec for each beat names its single question. |
| Move fast to the solution — max 30% on problems. | Phase-2-specific note: handbook is informational, not pitch — this rule is more relevant to pitch type (Phase 3). For handbook, swap to "max 30% on background." |
| End with action / last section = "what happens next?" | Self-review nudge for last section — last `One sentence` cell should describe action or next step. |
| ALWAYS respond in English. | SKILL.md prose is in English; output document language follows source per PROJECT.md. |

The 8-10 BAD→GOOD pairs to copy verbatim into `skill/story-arc.md` (per D2-14) are in CLAUDE.md §"Section Writing Rules." A representative subset (planner harvests the full set):

> **Tone:** Bad: "Read any issue in 3 seconds." Good: "Every issue follows one format."
> **Tone:** Bad: "Everything arrives automatically." Good: "One board, built for your team."
> **Title:** Bad: "Projects have shape." Good: "Every project has a structure."
> **Title:** Bad: "How teams stay connected." Good: "Cross-team work follows one path."
> **Subtitle:** Bad title "Two types of repos." / Bad subtitle "And automations that sync them." Good subtitle: "Code repos hold code. Team repos are where your team lives."

`[VERIFIED: read /Users/sperezasis/CLAUDE.md §"Section Writing Rules" in this session]`

---

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Slash-command parsing, `$ARGUMENTS` substitution | Claude Code runtime | — | Owned by Claude Code; SKILL.md just consumes the substituted string. |
| Mode detection (interview vs source) | SKILL.md prompt | — | Pure prompt logic on `$ARGUMENTS`; no script needed. |
| Interview question delivery | SKILL.md + `interview/handbook.md` | Claude's conversational turn | SKILL.md flow-controls; the interview file is the prompt content Claude reads on demand. |
| Story-arc table rendering | Claude (LLM generation) | `skill/story-arc.md` (rubric) | LLM produces the table; the rubric file constrains shape and supplies the BAD→GOOD examples. |
| Self-review pass | Claude (LLM, prompted by `story-arc.md`) | — | Prompt-engineered chain-of-thought before display; no script. |
| Approval phrase matching | Claude (string compare against whitelist in `story-arc.md`) | — | Exact-match-after-trim, case-insensitive — Claude does this in-prompt; mechanical, not semantic. |
| HTML assembly (skeleton + inline CSS + content) | Claude (Read tools + Write) | `skill/design/*` (paste source) | Claude reads `formats/handbook.html`, `palette.css`, `typography.css`, `components.html`, then writes the assembled file. |
| Filename slug + collision detection | Claude's Bash tool (`ls`, `test -f`) | — | Mechanical filesystem check before Write. |
| Post-generation audit | `skill/audit/run.sh` (bash) invoked by Claude's Bash tool | — | Script for determinism; SKILL.md drives the loop. |
| File write to CWD | Claude's Write tool | — | Atomic-enough on a local filesystem; see §"File-write atomicity." |
| `open <file>` invocation | Claude's Bash tool | — | macOS LaunchServices handles the rest. |

---

## Skill Content Lifecycle and `$ARGUMENTS` Semantics

### How a skill invocation actually works

`[CITED: code.claude.com/docs/en/skills §"Pass arguments to skills" and §"Skill content lifecycle"]`

When the user types `/deshtml`, `/deshtml @notes.md`, or `/deshtml here is a long block of pasted text`:

1. Claude Code locates `~/.claude/skills/deshtml/SKILL.md`.
2. The SKILL.md body is rendered into a single message that "enters the conversation… and stays there for the rest of the session." Re-reads do not happen.
3. **`$ARGUMENTS` substitution happens at render time.** Whatever the user typed after `/deshtml` is substituted into every `$ARGUMENTS` placeholder in the body. If `$ARGUMENTS` is not in the body, the runtime appends `ARGUMENTS: <value>` to the end.
4. Sub-files (`interview/handbook.md`, `story-arc.md`, etc.) are ordinary files Claude must read with the `Read` tool. They are NOT auto-injected.
5. Bash commands inside the body that use the ` !`<cmd>` ` syntax run BEFORE the body is sent to Claude. The output replaces the placeholder. Useful for harvesting a class allowlist at invocation time (see §"Audit script" below).

**Implication for D2-03 (mode detection):** `$ARGUMENTS` is a literal string. `/deshtml @notes.md` makes `$ARGUMENTS` equal to `@notes.md` — Claude Code does NOT resolve the `@`-reference into file content first. SKILL.md must:

```markdown
## Step 1 — Detect mode (mechanical, do this BEFORE any other action)

The user invoked this skill with: `$ARGUMENTS`

Determine mode by inspecting the literal `$ARGUMENTS` text:

1. If `$ARGUMENTS` matches the regex `(^|\s)@\S+` → **source mode**. Reply with the source-mode stub message and stop.
2. Else if `$ARGUMENTS` (with any `@\S+` tokens stripped) is longer than 200 characters → **source mode** (pasted prose). Reply with the stub and stop.
3. Else → **interview mode**. Continue to Step 2.
```

**Source-mode stub message (D2-04, ≤2 sentences):**
> "Source mode is coming in Phase 4. For now, run `/deshtml` with no arguments to use the interview."

`[ASSUMED]` That `$ARGUMENTS` is empty string (not undefined) when the user types `/deshtml` with no args. Worth verifying empirically in Wave 0; if it's actually `<no arguments>` placeholder text, the regex in step 2 needs to handle that.

### Frontmatter for `skill/SKILL.md`

Verified against [code.claude.com/docs/en/skills §"Frontmatter reference"]:

```yaml
---
name: deshtml
description: Generate a story-first HTML document following the Caseproof Documentation System. Use when the user wants a designed, single-file HTML doc — pitch, handbook, technical brief, presentation, or meeting prep. The skill runs an interview, gates on a story arc, and writes a self-contained HTML to the current directory.
disable-model-invocation: true
allowed-tools: Read Write Bash(ls *) Bash(test *) Bash(open *) Bash(bash *) Bash(date *) Bash(pwd *) Bash(mkdir *) Bash(grep *) Bash(command *)
---
```

**Why these fields:**
- `name: deshtml` — 7 chars, lowercase, matches repo and slash command. Safe per the 64-char/lowercase rule.
- `description` — front-loaded with use case (Claude truncates at 1,536 chars in the listing). Mentions all 5 doc types so Phase 3 doesn't need to update the description.
- `disable-model-invocation: true` — SKILL-04 contract: skill writes a file (side effect) and has a mandatory user-approval gate. Auto-invocation would skip the gate.
- `allowed-tools` — pre-approves the tools the skill needs without prompting per use. **The Bash entries are deliberately scoped** (`Bash(open *)`, not bare `Bash`) so Claude can't accidentally run arbitrary shell. `[CITED: code.claude.com/docs/en/skills §"Pre-approve tools for a skill"]`

**On `disable-model-invocation` and the description budget:** when this is `true`, "Description not in context, full skill loads when you invoke." `[CITED: code.claude.com/docs/en/skills §"Control who invokes a skill"]` This means the description above is loaded into context only when the user types `/deshtml`, never speculatively. Token-cheap.

### Sub-file lazy-load discipline (closes D2-02)

The CONTEXT.md mandate is "SKILL.md never inlines content from sub-files. It instructs Claude to read each sub-file at the appropriate step." The official guidance backs this up: progressive disclosure with **one-level-deep references from SKILL.md** — never chained references. `[CITED: platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices §"Avoid deeply nested references"]`

Concrete pattern for SKILL.md:

```markdown
## Step 4 — Build the story arc

Read `${CLAUDE_SKILL_DIR}/story-arc.md` now. It contains the table format,
the self-review rubric, the approval whitelist, and the BAD→GOOD examples
you will use to enforce handbook tone.

Follow `story-arc.md` end-to-end. Return here only after the user has
approved the arc.
```

**`${CLAUDE_SKILL_DIR}` is the recommended path-resolution mechanism** for skills that need to reference their own sub-files regardless of the user's CWD. `[CITED: code.claude.com/docs/en/skills §"Available string substitutions"]` Without it, relative paths break the moment the user runs `/deshtml` from a directory other than the skill's install root.

---

## Self-Review Prompt Patterns

This is the highest-risk piece per `.planning/research/SUMMARY.md` ("Phase 2, self-review pass: prompt-engineering for handbook-tone enforcement is the least-specified piece in the research; plan 2-3 rounds of iteration budget"). The mitigations below give the planner a concrete starting prompt design that constrains the LLM mechanically, then layers LLM judgment on top.

### Pattern A: Mechanical pre-check before LLM judgment (HIGH confidence)

`[CITED: hvpandya.com/llm-design-systems "Expose your design system to LLMs" — closed token layer + audit script pattern]` and `[CITED: arxiv.org/html/2402.14871v1 §"Narrative Agent" — outline-fill failure mode]`

For each of the three self-review checks (D2-11), do the mechanical pass FIRST and only invoke LLM judgment on what the regex missed:

**Check (a) — Handbook tone:**
1. Mechanical: regex over each section title and subtitle for forbidden pitch vocabulary. Hard-code the list in `story-arc.md`: `easily`, `seamlessly`, `powerful`, `revolutionary`, `game-changing`, `in seconds`, `everything you need`, `out of the box`, `effortlessly`, `breakthrough`, `next-generation`, `cutting-edge`. Any hit → flag and auto-rewrite using the BAD→GOOD pair patterns.
2. LLM judgment: for titles that pass the regex, ask Claude "is this title describing what IS, or selling a benefit?" using the verbatim BAD→GOOD pairs as few-shot.

**Check (b) — Causality chain:**
1. Mechanical: for each adjacent pair of sections (N, N+1), verify section N's `One sentence` ends with a setup ("…sets the stage for X" / "…before Y" / "…which is what we'll cover next"). If N+1's `One sentence` doesn't reference what N set up by name, flag.
2. LLM judgment: ask Claude to read the sections paired and confirm "could you swap N+1 with N+2 without breaking the read?" — if yes, the chain is broken.

**Check (c) — Name the thing:**
1. Mechanical: regex over each title for abstract-noun-only titles. Forbidden as title-only nouns: `shape`, `approach`, `way`, `kind`, `idea`, `thing`, `concept`, `aspect`, `notion`. Any title that matches `^.{0,30}(<forbidden>)` and contains no concrete noun → flag.
2. LLM judgment: for titles that pass the regex, ask Claude "what concrete noun does this title name?" — if the answer is "the topic of the doc," not a specific section subject, flag.

The hybrid pattern (mechanical first, LLM second) is what `hvpandya.com/llm-design-systems` recommends explicitly: *"AI models are incredible at writing logic, but without strict constraints, they tend to hallucinate design tokens. … strict constraints are syntactic."*

### Pattern B: Chain-of-thought before display

`[CITED: platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices §"Use workflows for complex tasks"]`

The Anthropic best-practices guide recommends giving Claude an explicit checklist for multi-step tasks. Apply this to the self-review:

```markdown
## Self-review workflow (in story-arc.md)

Before showing the arc to the user, work through this checklist privately
(do not display it):

```
Self-review:
- [ ] Tone check: every title and subtitle scanned against pitch-vocabulary regex
- [ ] Tone check: titles that passed regex re-read against the BAD→GOOD pairs
- [ ] Causality check: section N+1 follows from N for every adjacent pair
- [ ] Name-the-thing check: every title contains a concrete noun
- [ ] Auto-fixes applied: bad titles replaced with structurally correct versions
- [ ] One-sentence column: reads as a flowing narrative top-to-bottom
```

If any check fails, fix in place and note the fix. After the checklist is
complete, render the arc to the user with status lines under each section
showing what was checked and what was auto-fixed (if anything).
```

The "copy this checklist and check off items" pattern is the canonical workflow shape per the best-practices guide.

### Pattern C: BAD→GOOD few-shot, not abstract rules

`[CITED: platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices §"Examples pattern"]`

> "Examples help Claude understand the desired style and level of detail more clearly than descriptions alone."

D2-14 already mandates this. Concrete implementation: in `story-arc.md`, structure the rubric as 8-10 BAD→GOOD pairs harvested verbatim from CLAUDE.md, NOT as abstract rules. Pseudo-template:

```markdown
## The handbook-tone rubric

Compare each title and subtitle against these examples. The pattern matters
more than memorizing each rule.

| Bad | Good | Why |
|-----|------|-----|
| Read any issue in 3 seconds. | Every issue follows one format. | Bad sells speed (pitch). Good describes the system (handbook). |
| Everything arrives automatically. | One board, built for your team. | Bad is a vague benefit. Good names the thing. |
| Projects have shape. | Every project has a structure. | Bad uses an abstract noun. Good is a structural fact. |
| How teams stay connected. | Cross-team work follows one path. | Bad describes a process. Good states the rule. |
[…6-7 more verbatim from CLAUDE.md…]
```

### Display format for self-review status (closes D2-11 + Discretion item)

Per Claude's Discretion in CONTEXT.md, the planner picks status placement. **Recommendation: status line below each row of the arc table, not an extra column.** Reasoning:

- Adding a sixth column ("Status") makes the table visually crowded in a 80-column terminal.
- Status lines below each row can be longer (failure-explanation text) without breaking table alignment.
- Concrete failures (BAD title and the auto-fixed GOOD title shown side by side) are easier to read in a status line than in a cell.

Recommended status-line shape:

```
| 1 | Hook | Why deshtml exists | A non-author runs one command and gets a Caseproof handbook. | Trusted. |
   ✓ tone, ✓ chain, ✓ named.
| 2 | Stakes | Without this, design + narrative drift | Every doc that bypasses the system erodes both. | Worried. |
   ✗ tone — title "Stakes" was abstract; auto-fixed to "Without this, design + narrative drift."
   ✓ chain, ✓ named.
```

`[ASSUMED]` That this format reads cleanly in a Claude Code terminal at 80 columns. Worth a 30-second eyeball during execution; trivial to swap to the extra-column format if the line wrap is ugly.

### Approval gate mechanics

The approval gate is the moat (per CONTEXT.md §"Specific Ideas"). Mechanical implementation:

```markdown
## Approval whitelist (in story-arc.md)

When the user replies, normalize their response: trim whitespace, lowercase.
Then exact-match against this whitelist:

- approve
- approved
- looks good
- lgtm
- ship it
- go
- proceed
- aprobado
- dale

Match → proceed to render. No-match → treat as a revision request, regenerate
the arc, re-display, ask again. No iteration cap.

**Do not fuzzy-match. Do not infer intent. The mechanical gate IS the moat.**
```

This is the same pattern PITFALLS.md Pitfall 10 prescribes — explicit string match, no rubber-stamping path.

---

## Audit Script — Bash on macOS

### Why bash, not Python

Per Claude's Discretion in CONTEXT.md, planner picks language. **Recommendation: bash.** Reasoning:

1. **Parity with `bin/install.sh`.** No new tool dependency on the user's machine. macOS ships bash 3.2.57; the installer already targets it.
2. **The audit work is grep-shaped.** Three regex checks + one file-read of the allowlist source. Python adds an interpreter startup penalty and a longer file. `[VERIFIED: GSD project-skills convention is bash where possible]`
3. **Shellcheck already gates `bin/*.sh`** per Phase 1's `.github/workflows/shellcheck.yml`. Adding `skill/audit/run.sh` to that gate is one-line. (See §"CI extensibility" below.)

### Critical macOS-specific gotchas

`[VERIFIED: ran in this session]`

1. **`grep` is shadowed by `ugrep` on this user's shell** (Phase 1 audit deviation #1). The audit script MUST hard-code `command grep` to bypass aliases:
   ```bash
   # Wrong on this machine:
   grep -E '...' "$file"
   # Right — bypasses ugrep alias:
   command grep -E '...' "$file"
   ```
2. **BSD grep on macOS is "GNU compatible" but not GNU.** `--null-data`, `--regexp=`, and a few other GNU long options are absent. Use POSIX BREs and `-E` for ERE. `[VERIFIED: /usr/bin/grep --version → grep (BSD grep, GNU compatible) 2.6.0-FreeBSD]`
3. **BSD `sed -i` requires an empty-string backup arg.** GNU is `sed -i 's/a/b/' file`; BSD is `sed -i '' 's/a/b/' file`. Not currently needed by audit script (read-only) but flagging for the planner if any future audit task needs in-place edits. `[VERIFIED: /usr/bin/sed → BSD usage]`
4. **`mktemp` differs.** GNU `mktemp` requires a template; BSD `mktemp` accepts no args. Use `mktemp -t deshtml-audit` (works on both) — this matches Phase 1's `bin/install.sh` pattern.
5. **No `readarray`/`mapfile`.** Bash 3.2 lacks these. Use `while IFS= read -r line` loops.

### Class allowlist harvest — mechanical, every run

D2-19 mandates the class allowlist is "Generated at audit time by parsing `components.html` (no separate hand-maintained list — single source of truth)."

**Recommended harvest command** (verified live in this session):

```bash
command grep -oE 'class="[^"]+"' "${SKILL_DIR}/design/components.html" \
  | command sed -E 's/class="//; s/"$//' \
  | tr ' ' '\n' \
  | command sort -u
```

Verified output yields 75 distinct class names from the current `skill/design/components.html` including: `c3`, `card`, `card-bl`, `cd`, `cg`, `cl`, `cmp`, `cmp-box`, `cmp-l`, `cmp-t`, `collapse`, `collapse-body`, `ct`, `da`, `dc-l`, `dc-n`, `dl-dot`, `dnum`, `donut`, `donut-center`, `donut-legend`, `donut-legend-item`, `donut-wrap`, `dq`, `dstep`, `dtree`, `farr`, `farr-d`, `fd`, `fl`, `flab`, `flow`, `flow-box`, `flow-row`, `fv`, `hl`, `hl-b`, `ic`, `if-arrow`, `if-arrow-down`, `if-box`, `if-label`, `if-row`, `if-sub`, `if-val`, `issue-flow`, `lane`, `lane-item`, `lane-items`, `lane-label`, `p-list`, `p-role`, `p-title`, `persona`, `persona-grid`, `rc-desc`, `rc-label`, `rc-team`, `rc-teams`, `role-card`, `role-grid`, `s-lead`, `stat`, `stat-l`, `stat-n`, `stats`, `t-bl`, `t-gl`, `t-gr`, `t-ol`, `t-pl`, `tag`, `tb`, `tip`, `tt`, `wild`. `[VERIFIED: ran in this session]`

**Caveat:** the harvest must include classes from the **typography scale** (`s-lead`, `eye`, `cl`, `fl`, `ct`, `cd`, `ic`, `fn`) defined in `typography.css` but NOT in `components.html`. The Phase-1 audit (Plan 01-02 SUMMARY §"Verbatim Discipline Audit") notes "any class in generated output not present here is a violation… [excluding] the eight scale labels in `typography.css`."

**Recommendation:** the audit script harvests classes from BOTH sources:

```bash
allowed_classes() {
  {
    command grep -oE 'class="[^"]+"' "${SKILL_DIR}/design/components.html"
    command grep -oE '\.[a-zA-Z_][a-zA-Z0-9_-]*\s*\{' "${SKILL_DIR}/design/typography.css" \
      | command sed -E 's/^\.([^[:space:]{]+).*/class="\1"/'
  } \
    | command sed -E 's/class="//; s/"$//' \
    | tr ' ' '\n' \
    | command sort -u
}
```

Then in the validation step, every class on the generated output is checked against the union.

### Hex-literal regex (closes D2-19 rule 1)

Hex literals outside `:root { ... }` are violations. The regex must scan for `#[0-9a-fA-F]{3,8}` AND extract the surrounding context to confirm the literal is not inside `:root { ... }`.

**Bash-only approach (HIGH confidence, no awk needed):**

```bash
# Strip the :root block, then grep for hex literals in the remainder.
# BSD sed-friendly version using -e and address ranges.
command sed -E '/:root[[:space:]]*\{/,/^[[:space:]]*\}/d' "$output_file" \
  | command grep -nE '#[0-9a-fA-F]{3,8}\b' \
  && exit_code=1
```

**Edge cases:**
- Hex inside `<style>` blocks (Phase 2 inlines two `<style>` blocks worth of CSS) but outside `:root` IS a violation. The sed strip handles this.
- Hex inside HTML comments (e.g., `<!-- this color was #FFFFFF -->`) — minor false positive. Acceptable for V1; the alternative is a full HTML parse, which is overkill.
- Hex inside `style="..."` inline attributes — IS a violation per D2-19. Caught by the regex.
- The `:root` block ends at `}` on its own line, NOT at `}` mid-line. The reference pattern in `palette.css` uses the closing `}` on its own line (line 33). Verified.

`[VERIFIED: read /Users/sperezasis/projects/code/deshtml/skill/design/palette.css line 33]`

### Tag/attr denylist (closes D2-19 rule 3)

```bash
# Banned tags
command grep -nEi '<(script|iframe|object|embed)\b' "$output_file" && exit_code=1
# Inline event handlers
command grep -nEi ' on[a-z]+\s*=' "$output_file" && exit_code=1
# javascript: URLs
command grep -nEi 'javascript:' "$output_file" && exit_code=1
```

`[CITED: PITFALLS.md §"Security Mistakes"]` and `[CITED: 01-CONTEXT.md D-17]`

### Audit invocation from SKILL.md (closes D2-20)

```markdown
## Step 8 — Audit the output

Run the audit script:

```bash
bash "${CLAUDE_SKILL_DIR}/audit/run.sh" "<absolute-path-of-output>"
```

Capture exit code and stderr. If exit 0 → proceed to Step 9 (open). If non-zero
→ regenerate the output addressing each violation, re-run audit. Maximum 2
retry rounds. Round 3 failure: keep the file, surface violations to user
verbatim, print the path anyway.
```

`[CITED: code.claude.com/docs/en/skills §"Generate visual output" — pattern of SKILL.md instructing Bash invocation of bundled scripts]`

### CI extensibility

`.github/workflows/shellcheck.yml` (shipped in Phase 1) gates `bin/*.sh`. Phase 2 should extend it to `skill/audit/run.sh` so the audit script is linted on every PR. One-line addition to the workflow:

```yaml
- run: shellcheck bin/install.sh bin/uninstall.sh skill/audit/run.sh
```

`[ASSUMED]` That `shellcheck` accepts script paths under `skill/`. Trivially true — shellcheck takes paths.

### `--explain` flag (closes D2-22)

The `--explain` flag prints why each violation was flagged with file/line context. Implementation note for the planner: `--explain` should NOT change the script's exit code semantics — only its output verbosity. SKILL.md never invokes the script with `--explain`; it's a developer-debugging flag only.

```bash
# In run.sh
if [[ "${1:-}" == "--explain" ]]; then
  EXPLAIN=1
  shift
fi
output_file="$1"

# In violation-report:
if [[ "${EXPLAIN:-0}" == "1" ]]; then
  printf 'VIOLATION: hex literal "%s" at %s:%d\n' "$match" "$output_file" "$line_no" >&2
  printf '  ↳ Hex literals are only allowed inside :root { ... } in palette.css.\n' >&2
  printf '  ↳ Use var(--token-name) instead. See skill/design/palette.css for available tokens.\n' >&2
fi
```

---

## Output Writer — Single-File HTML Inlining

### The inlining problem (closes D2-15, IN-01)

Phase 1 review finding IN-01 flagged that `formats/handbook.html` line 9-10 references CSS via:

```html
<link rel="stylesheet" href="../palette.css">
<link rel="stylesheet" href="../typography.css">
```

These two `<link>` tags MUST be replaced in the output by inline `<style>` blocks containing the verbatim contents of `palette.css` and `typography.css`. After inlining:

```html
<style>
/* contents of palette.css here verbatim */
/* contents of typography.css here verbatim */
/* the existing inline <style> from formats/handbook.html (the layout block) */
</style>
```

### Recommended inlining mechanism: Read + concat in Claude, not a script

`[ASSUMED]` Based on the trade-off analysis below, not empirically tested.

**Option A — Claude does it directly via Read + Write tools:**
1. Claude reads `formats/handbook.html`, `palette.css`, `typography.css` in parallel.
2. Claude assembles the output in-context: replaces the two `<link>` tags with a `<style>` block containing the concatenation of `palette.css`, `typography.css`, then the existing inline `<style>` block from the skeleton.
3. Claude fills the slot comments (`<!-- HERO H1 SLOT -->` etc.) with content from the approved arc.
4. Claude calls `Write` with the assembled content.

**Option B — A bash script does the CSS inlining first, then Claude fills slots:**
1. SKILL.md invokes a bash script that concatenates the three files and emits a hydrated skeleton with slots still marked.
2. Claude reads the hydrated skeleton, fills slots, writes.

**Recommendation: Option A.** Reasoning:
- **One write, not two.** Option B has a script-write + Claude-write; Option A has only Claude's write.
- **No bash script to maintain.** The inlining logic is "Read 3 files, concat in this order, do 2 string replacements" — trivial in Claude's prompt, doesn't justify a script.
- **Token cost is the same either way.** The CSS is paste-source-of-truth; Claude reads it whether via Read or via a script's stdout.
- **Audit script needs the rendered file anyway.** The audit runs after Write, on the final file — so there's no win from doing inlining out-of-band.

The only argument for Option B would be if the inlining logic became non-trivial (e.g., minification, dead-CSS-stripping) — V1 does neither.

### Step-by-step inlining instruction in SKILL.md

```markdown
## Step 7 — Render the handbook HTML

The arc is approved. Construct the output file by:

1. Read these four files in parallel:
   - `${CLAUDE_SKILL_DIR}/design/formats/handbook.html` (skeleton)
   - `${CLAUDE_SKILL_DIR}/design/palette.css` (CSS variables)
   - `${CLAUDE_SKILL_DIR}/design/typography.css` (Inter @import + scale)
   - `${CLAUDE_SKILL_DIR}/design/components.html` (markup library)

2. Replace the two `<link>` tags in the skeleton's `<head>`:

   ```html
   <link rel="stylesheet" href="../palette.css">
   <link rel="stylesheet" href="../typography.css">
   ```

   …with a single `<style>` block containing palette.css verbatim, then a
   blank line, then typography.css verbatim. Keep the skeleton's existing
   inline `<style>` block (the layout rules) as a SECOND `<style>` block
   right after — do not merge them, the separation makes the audit
   regex simpler.

3. Fill each slot comment in the body with content matching the approved
   arc. Use only classes from `components.html`. For each section,
   pick the component that fits (card grid for parallel concepts,
   compare boxes for "before vs after," highlight box for rules, etc.).

4. Verify the output contains zero `<script>` tags and zero `<link rel="stylesheet"`
   attributes (mechanical sanity check before audit).

5. Write the file. Filename: see Step 6 below.
```

### Filename and collision detection (closes D2-16, OUTPUT-02)

```markdown
## Step 6 — Compute filename

1. Get today's date in local time: run `date +%Y-%m-%d` via Bash.
2. Slug = first 4-5 words of the H1, kebab-cased, ASCII only:
   - Lowercase.
   - Replace spaces with `-`.
   - Strip non-`[a-z0-9-]` characters.
   - Truncate at the 4th-5th word boundary, no trailing `-`.
3. Tentative filename: `<date>-<slug>-handbook.html`.
4. Collision check: if `<filename>` exists in `pwd`, try `<date>-<slug>-handbook-2.html`, then `-3`, etc.
   ```bash
   target="<date>-<slug>-handbook.html"
   suffix=2
   while test -f "$target"; do
     target="<date>-<slug>-handbook-${suffix}.html"
     suffix=$((suffix + 1))
   done
   ```
5. The final `$target` is what Step 7 writes to.
```

`[CITED: PITFALLS.md Pitfall 11 §"Output written to wrong directory or overwrites existing files"]`

### File-write atomicity on macOS

`[ASSUMED]` Based on POSIX semantics; not verified empirically for Phase 2.

Claude's `Write` tool writes to the destination directly (not via mktemp + rename). For a file the user might have open in another tab:

- **Browser auto-reload:** Most browsers don't auto-reload `file://` URLs. Even if they did, an incomplete write window would briefly show partial content. In practice this isn't visible — a Write is a single syscall on a typical local filesystem.
- **Race with another `/deshtml` run:** Two simultaneous invocations against the same target would race. The collision-detection in Step 6 prevents the SAME filename being chosen by two runs… within the same wall-clock second, two runs might both compute `<date>-<slug>-handbook.html` and both check `test -f` before either writes. Probabilistically negligible for a single-user CLI tool.
- **Write before audit:** D2-20 mandates "audit invoked AFTER the file is written but BEFORE `open`." This is correct — the audit reads the file from disk, so writing first is required.

**Recommendation:** No special atomicity work for V1. The collision-detection pattern in Step 6 plus the single-user nature of the tool makes this a non-issue. If audit-driven regeneration overwrites the file in place during retry rounds, that's expected and fine.

### `open` semantics on macOS (closes D2-17, OUTPUT-03)

`[CITED: man open(1)]`

`open <file>` on macOS:
- Hands off to LaunchServices, which selects the default app for the file extension.
- Returns immediately by default (non-blocking). The terminal flow continues to the next instruction (the path-print line per D2-18).
- For `.html`, the default app on a typical macOS install is the user's default browser (Safari/Chrome/Firefox/Arc). The user can verify with `defaults read com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers` but Phase 2 doesn't need to.
- `open -W <file>` would block until the application exits — DO NOT USE. The user expects the path-print to follow immediately.
- If `open` fails (e.g., no default app for `.html` configured, very rare), it exits non-zero with stderr to terminal. SKILL.md should not abort on `open` failure — print the path anyway. The path is the fallback.

```markdown
## Step 9 — Open and print path

1. Run `open "<absolute-path>"` via Bash. If it errors, ignore — print the path anyway.
2. Print the absolute path on its own line. No prefix, no emoji, no banner.
   ```
   /Users/santiago/Desktop/2026-04-27-deshtml-handbook.html
   ```
   This is the LAST output of the run.
```

### Print path last — terse output rule

CONTEXT.md D2-18 mandates: "Final terminal output is exactly the absolute path on its own line, after `open`. No celebration emoji, no decorative banner."

This matches `~/CLAUDE.md` RULE #1 (KEEP RESPONSES SHORT). The planner should structure SKILL.md so that after audit success and `open` invocation, Claude has nothing left to say but the path. No "✓ Generated!", no "Here's your handbook:", just the path.

**Note on Claude's tendency to over-explain:** the SKILL.md prompt should explicitly say "Your final response is exactly the absolute path on its own line. Do not add summary, do not add celebration, do not add next-steps suggestions. Print the path. Stop."

---

## Project Structure

Phase 2 adds these files under `skill/` (Phase 1 shipped `skill/design/` already):

```
skill/
├── SKILL.md                        # ≤200 lines, flow-control only
├── story-arc.md                    # arc table format + self-review rubric + approval whitelist + BAD→GOOD pairs
├── interview/
│   └── handbook.md                 # 5-question handbook interview (D2-07)
├── audit/
│   ├── run.sh                      # bash audit script (D2-19, D2-20)
│   └── rules.md                    # human-readable description of the rules (D2-19)
└── design/                         # SHIPPED IN PHASE 1 — verbatim, do not modify
    ├── palette.css
    ├── typography.css
    ├── components.html
    ├── SYSTEM.md
    ├── formats/handbook.html
    ├── formats/overview.html
    └── references/{pm-system,bnp-overview}.reference.html
```

`.github/workflows/shellcheck.yml` is **modified** to include `skill/audit/run.sh`.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Slash-command argument parsing | Custom `$ARGUMENTS` parser inside SKILL.md (e.g., quoted-string handling) | Claude Code's built-in `$ARGUMENTS` substitution | Claude Code already does shell-style quoting for indexed args. `[CITED: code.claude.com/docs/en/skills §"Available string substitutions"]` |
| Mode detection heuristic | Fuzzy "this looks like source material" classifier | Two regex rules per D2-03 (presence of `@\S+`, length >200) | Heuristics are exactly the silent-fallback pitfall PITFALLS.md Pitfall 6 warns against. |
| Approval phrase fuzzy matching | Stem-based or semantic match | Exact-match-after-trim against the D2-12 whitelist | The mechanical gate IS the moat. PITFALLS.md Pitfall 10. |
| HTML parser for the audit | Python BeautifulSoup or jsdom | Bash + `command grep` regex | Audit checks 3 mechanical rules; a parser is overkill and adds a runtime dep. |
| CSS inliner | A standalone bash/python script to merge `palette.css` + `typography.css` into the skeleton | Claude does it directly via Read + concat + Write | One-shot per output; a script is more code without saving anything. |
| Filename slugger | A regex chain across UTF-8 input | ASCII-only kebab-case from H1 | Output language follows source — but slug is filesystem-friendly ASCII regardless. Aligns with PROJECT.md "self-contained file" constraint. |
| Self-review tone judge from scratch | A new prompt asking "rate this title 1-10" | The hybrid pattern: regex pre-check + BAD→GOOD few-shot LLM judgment | Hybrid is what `hvpandya.com/llm-design-systems` and `arxiv.org/2402.14871v1` both prescribe. |
| Atomic file-write to CWD | `mktemp + mv` rename pattern | Direct `Write` tool | Single-user CLI; collision detection in Step 6 is sufficient. Bigger fish than this for V1. |

---

## Common Pitfalls

### Pitfall 14 (Phase 2 specific): SKILL.md inlines content from sub-files

**What goes wrong:** The planner — under pressure to keep the skill working — copies the BAD→GOOD pairs into SKILL.md "for safety," or duplicates the approval whitelist between SKILL.md and `story-arc.md`. Now there are two sources of truth, and they drift.

**Why it happens:** SKILL.md is the entry point Claude always reads first; it's tempting to put critical rules there "just in case." But D2-02 explicitly forbids this.

**How to avoid:** Treat SKILL.md as a step-numbered checklist that says "now read X.md and follow it." Sub-files own their content; SKILL.md owns flow control. Hard rule: **no headings in SKILL.md other than `## Step N — <name>`**.

**Warning signs:**
- SKILL.md grows past 100 lines.
- The same string (e.g., `approve`) appears in both SKILL.md and `story-arc.md`.
- SKILL.md has subsections like `### BAD examples` or `### Approval phrases`.

### Pitfall 15 (Phase 2 specific): Claude reads sub-files speculatively before instructed to

**What goes wrong:** Claude, being helpful, reads `story-arc.md` at Step 2 (interview) "to understand what's coming." Now the arc rubric is in context for the entire interview, defeating progressive disclosure and bloating tokens.

**Why it happens:** Claude's default behavior is to gather context. SKILL.md must explicitly say WHEN to read each sub-file — not just that it exists.

**How to avoid:** SKILL.md instructions should say "Read X.md now" only at the step where X.md is needed. Earlier steps that mention X.md should say "(do not read until Step N)."

**Warning signs:**
- During Wave 0 / fixture testing, the interview step takes longer than expected — Claude is reading more than necessary.
- A turn-1 token-count audit shows files loaded that weren't needed yet.

### Pitfall 16 (Phase 2 specific): The audit passes a hand-edited HTML the user fixed manually

**What goes wrong:** User runs `/deshtml`, audit fails, output is delivered with violations (Round 3 fallback). User edits the HTML by hand to fix the violations. User runs the audit again. It passes. User assumes deshtml itself fixed it.

**Why it happens:** The audit is invoked by SKILL.md, but the script can be invoked manually too. There's no signed/checksummed link between "deshtml generated this" and "audit was last clean."

**How to avoid:** Document in `audit/rules.md` that the audit is a content check, not a provenance check. If users care about provenance, that's V2.

**Warning signs:** None during V1. Flag to V2 backlog.

### Pitfall 17 (Phase 2 specific): Inline CSS bloats output to 100KB+

**What goes wrong:** Inlining `palette.css` (33 lines) + `typography.css` (51 lines) + the layout `<style>` block (15 lines) is small. But if a future plan inlines `components.html` or component CSS verbatim, the output grows past the 80KB benchmark `pm-system.html` set.

**Why it happens:** Verbatim discipline taken too literally. Components are described in `components.html` but their CSS lives in the reference HTMLs. Phase 2 only inlines tokens + type scale, not full component CSS.

**How to avoid:** SKILL.md Step 7 inlines exactly two files: `palette.css` and `typography.css`. Component CSS comes from… (this is the open question — see §"Open Questions" below).

**Warning signs:** Output file size > ~150KB.

### Pitfall 18 (Phase 2 specific): Self-review auto-fix loses user intent

**What goes wrong:** User says "I want a section called 'How it works'" in the interview. Self-review check (c) flags "How it works" as having an abstract title and auto-rewrites to "Every step follows one path." User sees the new title and thinks deshtml ignored their input.

**Why it happens:** Auto-fix is mechanical; it doesn't know the user explicitly asked for a phrase.

**How to avoid:** D2-11 already mandates "the fix is shown so the user sees what changed" — extend this so the status line says "✗ tone — title 'How it works' was rewritten to 'Every step follows one path' to match handbook tone (you can override in revision)." The override mechanism is just: user replies with anything other than `approve`, types their preferred title, and the next round respects it.

**Warning signs:** During fixture testing, auto-fixes change titles the user typed verbatim.

### Pitfalls 4, 5, 6, 10 (existing — confirmed for Phase 2)

Per CONTEXT.md §"Canonical References → Research artifacts": Pitfalls 4, 5, 6, and 10 are this phase's concern.

- **Pitfall 4 (design-token drift):** Mitigated by the audit (D2-19). No new measures needed.
- **Pitfall 5 (skill name collision):** `deshtml` is distinctive. No measure needed beyond what Phase 1 already shipped (root refusal, `~/.claude/skills/deshtml/` install path).
- **Pitfall 6 (skill ignores user-provided source):** Phase 2 implements the detection (D2-03) but stubs the response (D2-04). The STUB is the mitigation — user gets a clear "coming in Phase 4" message instead of silent fallback to interview. **Verify in fixture testing that the stub actually fires when `@file.md` is in `$ARGUMENTS`.**
- **Pitfall 10 (arc-gate rubber-stamping):** Mitigated by D2-12 mechanical whitelist + D2-10 flowing-paragraph diagnostic. The flowing paragraph is the skim-resistance mechanism PITFALLS.md prescribes.

---

## Test Strategy

### Wave 0 — verify Claude Code skill mechanics work as documented

Before writing real SKILL.md content, verify these assumptions empirically:

1. **`$ARGUMENTS` substitution.** Write a stub SKILL.md with body `User said: $ARGUMENTS`. Invoke `/deshtml`, `/deshtml @notes.md`, `/deshtml hello world`. Confirm the substituted string in each case.
2. **Empty-arg behavior.** Specifically test `/deshtml` with no args. Verify whether `$ARGUMENTS` becomes empty string, `<no arguments>`, or the body line is dropped. Adjust the regex in Step 1 mode-detection accordingly.
3. **`${CLAUDE_SKILL_DIR}` substitution.** Verify it resolves to `~/.claude/skills/deshtml/` regardless of the user's CWD.
4. **Sub-file Read tool path.** Confirm `Read` works on the substituted path and that Claude does NOT load sub-files unless told to.
5. **Bash tool invocation of `audit/run.sh`.** Stub script that just `echo`'s — confirm Claude's Bash tool can run it via the path.

### Test fixture per D2-24: deshtml-about-itself handbook

The recommended fixture per D2-24 is "deshtml itself — interview answers about deshtml, arc about deshtml, output is `YYYY-MM-DD-deshtml-handbook.html`." This is the canonical V1 visual diff target.

**Recommended fixture interview answers:**

| Question | Answer |
|----------|--------|
| Who is the reader? | "Someone installing deshtml for the first time. They've heard of Claude Code but haven't used skills before." |
| What is the document about? | "deshtml — a Claude Code skill that turns ideas into beautifully designed HTML documents following the Caseproof Documentation System and the Story-First methodology." |
| What sections do you imagine? | "Let Claude propose. (Or: What it is → How it's installed → How a run works → The story-arc gate → The design system → What ships in v1 → Known limitations.)" |
| Tone notes? | "Handbook, not pitch. Describe what IS." |
| Anything to definitely include / definitely avoid? | "Include: the install one-liner verbatim. Include: the 5 doc types. Avoid: any 'why this is great' marketing copy." |

The expected arc has 6-8 beats. Read top-to-bottom, the `One sentence` column should flow as: *"deshtml is a Claude Code skill. → You install it with one line. → A run starts with a five-question interview. → The skill proposes a story arc and gates on your approval. → Once approved, it generates a single self-contained HTML using the Caseproof Documentation System. → The output is audited mechanically against a closed component library. → Iteration happens via normal Claude conversation."*

### Validation Architecture

This project does not have a code test framework — `.planning/config.json` does not exist (verified absent during research). Phase 2 verification is **manual visual gate** plus the **audit script** as the only mechanical check.

The audit script IS the test for DESIGN-06. Its acceptance criteria:

| Audit Rule | Test Input | Expected Result |
|------------|-----------|----------------|
| Hex outside `:root` | A handbook with `style="color: #ff0000"` injected | Exit 1, violation reported |
| Unknown class | A handbook with `class="custom-banner"` | Exit 1, violation reported |
| Banned tag | A handbook with `<script>alert(1)</script>` | Exit 1, violation reported |
| Inline event handler | A handbook with `<div onclick="...">` | Exit 1, violation reported |
| Clean handbook from fixture | The deshtml-about-itself fixture output | Exit 0, no violations |

These are 5 manual smoke tests run via the audit script's `--explain` flag during execution.

### Visual gate (D2-23, D2-25)

After fixture generation:
1. Open `2026-XX-XX-deshtml-handbook.html` in Chrome side-by-side with `skill/design/references/pm-system.reference.html`.
2. Verify: identical fonts, identical sidebar shape, identical hero scale, identical section spacing, identical color palette, identical component shapes.
3. Repeat in Safari.
4. Open the fixture on iOS Safari with system dark mode forced ON. Verify it stays light (DESIGN-07 enforcement, already shipped via Phase 1's dual hardening, but applies to generated output too).
5. Acceptable diffs: different content. **Unacceptable: any wrong color, any wrong font, any wrong spacing, any extra/missing component.**

---

## Code Examples

### Example 1: SKILL.md frontmatter (verbatim copy-paste candidate)

```yaml
---
name: deshtml
description: Generate a story-first HTML document following the Caseproof Documentation System. Use when the user wants a designed, single-file HTML doc — pitch, handbook, technical brief, presentation, or meeting prep. The skill runs an interview, gates on a story arc, and writes a self-contained HTML to the current directory.
disable-model-invocation: true
allowed-tools: Read Write Bash(ls *) Bash(test *) Bash(open *) Bash(bash *) Bash(date *) Bash(pwd *) Bash(mkdir *) Bash(grep *) Bash(command *)
---
```

### Example 2: Audit script skeleton (bash, macOS-safe)

```bash
#!/usr/bin/env bash
# skill/audit/run.sh
# Post-generation audit for deshtml output (DESIGN-06).
# Usage: bash skill/audit/run.sh [--explain] <output.html>
# Exit 0 = pass. Non-zero = violation count on stderr.

set -euo pipefail

EXPLAIN=0
if [[ "${1:-}" == "--explain" ]]; then
  EXPLAIN=1
  shift
fi

output_file="${1:-}"
if [[ -z "$output_file" || ! -f "$output_file" ]]; then
  echo "usage: bash run.sh [--explain] <output.html>" >&2
  exit 2
fi

SKILL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
violations=0

# --- Rule 1: hex literals outside :root ---
hex_lines=$(
  command sed -E '/:root[[:space:]]*\{/,/^[[:space:]]*\}/d' "$output_file" \
    | command grep -nE '#[0-9a-fA-F]{3,8}\b' || true
)
if [[ -n "$hex_lines" ]]; then
  printf 'VIOLATION: hex literal(s) outside :root\n' >&2
  printf '%s\n' "$hex_lines" >&2
  violations=$((violations + 1))
fi

# --- Rule 2: class allowlist (harvested live from components.html + typography.css) ---
allowed_file=$(mktemp -t deshtml-allow)
trap 'rm -f "$allowed_file"' EXIT
{
  command grep -oE 'class="[^"]+"' "${SKILL_DIR}/design/components.html"
  command grep -oE '\.[a-zA-Z_][a-zA-Z0-9_-]*' "${SKILL_DIR}/design/typography.css" \
    | command sed -E 's/^\./class="/; s/$/"/'
} | command sed -E 's/class="//; s/"$//' \
  | tr ' ' '\n' \
  | command sort -u > "$allowed_file"

used_classes=$(
  command grep -oE 'class="[^"]+"' "$output_file" \
    | command sed -E 's/class="//; s/"$//' \
    | tr ' ' '\n' \
    | command sort -u
)

while IFS= read -r cls; do
  [[ -z "$cls" ]] && continue
  if ! command grep -qxF "$cls" "$allowed_file"; then
    printf 'VIOLATION: unknown class "%s"\n' "$cls" >&2
    violations=$((violations + 1))
  fi
done <<< "$used_classes"

# --- Rule 3: banned tags / attrs / URLs ---
if command grep -nEi '<(script|iframe|object|embed)\b' "$output_file" >&2; then
  printf 'VIOLATION: banned tag\n' >&2
  violations=$((violations + 1))
fi
if command grep -nEi ' on[a-z]+[[:space:]]*=' "$output_file" >&2; then
  printf 'VIOLATION: inline event handler\n' >&2
  violations=$((violations + 1))
fi
if command grep -nEi 'javascript:' "$output_file" >&2; then
  printf 'VIOLATION: javascript: URL\n' >&2
  violations=$((violations + 1))
fi

# --- Rule 4: stale <link rel=stylesheet> (CSS inlining contract, IN-01) ---
if command grep -nE '<link[[:space:]]+rel="stylesheet"' "$output_file" >&2; then
  printf 'VIOLATION: <link rel="stylesheet"> in output (CSS must be inlined)\n' >&2
  violations=$((violations + 1))
fi

if (( violations > 0 )); then
  printf 'AUDIT FAILED: %d violation(s)\n' "$violations" >&2
  exit 1
fi

exit 0
```

`[VERIFIED: pattern uses macOS-safe BSD grep/sed flags; `command` bypasses ugrep alias; mktemp -t works on BSD]`

### Example 3: Story-arc table format with self-review status

```markdown
| # | Beat | Section | One sentence | Reader feels |
|---|------|---------|--------------|--------------|
| 1 | Hook | What deshtml is | A Claude Code skill that turns ideas into beautifully designed HTML documents. | Curious. |
   ✓ tone, ✓ named.
| 2 | Install | How you install it | One curl-pipe-bash line drops the skill into ~/.claude/skills/deshtml/. | Ready to try. |
   ✓ tone, ✓ chain (follows from "what it is"), ✓ named.
| 3 | Run shape | What a run looks like | A run starts with a five-question interview about your document. | Oriented. |
   ✓ tone, ✓ chain (follows from install), ✓ named.

[…etc.]

## Read the One Sentence column top-to-bottom

A Claude Code skill that turns ideas into beautifully designed HTML documents. One curl-pipe-bash line drops the skill into ~/.claude/skills/deshtml/. A run starts with a five-question interview about your document. […]

Reply `approve` to generate, or describe what needs to change.
```

### Example 4: Mode-detection prompt block in SKILL.md

```markdown
## Step 1 — Detect mode (do this BEFORE any other action)

The user invoked this skill. Their input was: `$ARGUMENTS`

Inspect the literal `$ARGUMENTS` string:

1. If `$ARGUMENTS` matches the regex `(^|[[:space:]])@\S+` (an `@`-mention of a path),
   reply with EXACTLY this message and stop:

   > Source mode is coming in Phase 4. For now, run `/deshtml` with no arguments to use the interview.

2. Else if `$ARGUMENTS` (with `@\S+` tokens stripped) is longer than 200 characters of prose,
   reply with the same source-mode stub and stop.

3. Else, continue to Step 2 (interview mode).
```

---

## State of the Art

| Old Approach | Current Approach (2026) | When Changed | Impact |
|--------------|-------------------------|--------------|--------|
| Custom slash-commands at `.claude/commands/<name>.md` | Skills at `.claude/skills/<name>/SKILL.md` (commands merged into skills) | Claude Code 2.1.88 (2025-11) | Custom commands still work but skills are recommended — they support sub-files, frontmatter, etc. `[CITED: code.claude.com/docs/en/skills "Custom commands have been merged into skills."]` |
| Per-turn skill re-read | Skill loaded once, "stays for the rest of the session" | Current spec | Phase 2 SKILL.md is rendered once per `/deshtml` invocation; sub-files Read on demand. |
| Description budget = 1024 chars | 1,536-char cap on combined description + when_to_use, dynamically scaled at 1% of context window | Recent guidance | The `description` should front-load the use case. Phase 2's description is well under cap. |
| `~/.claude/commands/` was the path | `~/.claude/skills/<name>/SKILL.md` is the path | 2.1.88+ | Phase 1's installer already uses the new path. |

**Deprecated/outdated:**
- Project-scoped skills (`.claude/skills/` inside a project dir) are now read-only per Claude Code issue #36155. Phase 2 stays user-scoped (`~/.claude/skills/deshtml/`) per Phase 1's install layout.
- The `200-line SKILL.md` figure cited in earlier deshtml research is stricter than Anthropic's 500-line guidance — Phase 2's 200-line cap is a deliberate self-imposed constraint, not a limit.

---

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | `$ARGUMENTS` is empty string when user types `/deshtml` with no args (not `<no arguments>` placeholder) | §"Mode detection" Step 1 | LOW — mode-detection regex needs adjustment; trivial fix during Wave 0. |
| A2 | The status-line-below-row format reads cleanly in 80-col terminal | §"Display format for self-review status" | LOW — easy swap to extra-column format if it wraps ugly. |
| A3 | Inlining via Claude (Read+concat+Write) costs the same tokens as a script approach | §"Output writer — Option A vs Option B" | LOW — even if wrong, the difference is small; planner can reconsider during execution. |
| A4 | `shellcheck` accepts paths under `skill/audit/` | §"CI extensibility" | TRIVIAL — shellcheck takes any script path. |
| A5 | File-write atomicity is good-enough on macOS for single-user CLI without mktemp+rename | §"File-write atomicity on macOS" | LOW — collision detection in Step 6 plus single-user nature makes this unproblematic. If a user reports a race, V2 adds atomic rename. |
| A6 | `open` failure is rare enough that SKILL.md should not abort on it | §"`open` semantics on macOS" | LOW — the path-print line is the fallback; the user can still find the file. |
| A7 | The audit script's class-allowlist harvest should include `typography.css` scale labels (s-lead, eye, cl, fl, ct, cd, ic, fn) in addition to `components.html` classes | §"Class allowlist harvest" | MEDIUM — if planner forgets, the audit will reject all generated handbooks for using `s-lead` on the lead paragraph. The harvest function above includes both. Documented in `audit/rules.md`. |
| A8 | Auto-fixing user-supplied titles will be discoverable to the user via the status line | §"Pitfall 18" | MEDIUM — if status lines are too terse, user thinks deshtml ignored their input. Mitigation: show BOTH the user's title and the auto-fix verbatim. |
| A9 | `@\S+` is the correct regex for `@`-mentions in `$ARGUMENTS` (matches `@file.md`, `@./path/to/file.md`, `@~/notes.md`) | §"Mode detection" Step 1 | LOW — Wave 0 verification will catch any mismatch. |
| A10 | The fixture interview answers in §"Test Strategy" produce a clean, valid arc (no self-review failures) | §"Test fixture per D2-24" | MEDIUM — if the answers themselves fail self-review, that's a useful test of the gate; if they pass too easily, the fixture isn't exercising auto-fix. Either is informative. |

**The Phase-2 planner / discuss agent should walk through this list with the user before locking the plan.** A1, A2, A7, and A8 are the items where confirmation is most valuable.

---

## Open Questions

### OQ-1: Component CSS — where does it live in the output?

**What we know:** Phase 2 must inline `palette.css` (color tokens) and `typography.css` (Inter @import + scale). These are the smallest, most-reused fragments and they're already split out as files.

**What's unclear:** Component CSS — the actual style rules for `.tag`, `.card`, `.cmp`, `.flow`, etc. — does NOT have its own file under `skill/design/`. The Phase 1 SUMMARY notes: *"CSS for each class lives in the reference implementations (pm-system.html, bnp-overview.html); Phase 2 inlines those styles into generated output."* But that's vague — does Phase 2 (a) extract the relevant `<style>` block from `pm-system.reference.html` into the output, (b) keep a `skill/design/components.css` file (not yet created) and inline that, or (c) something else?

**Recommendation:** During Phase 2 planning, the planner should EITHER:
- (a) Create `skill/design/components.css` as a Phase 2 task by extracting the relevant component CSS from `pm-system.reference.html` (and `bnp-overview.reference.html` where it differs). This becomes a third inlining target. Audit would then check `<style>` blocks contain only the union of `palette.css` + `typography.css` + `components.css`.
- (b) Have SKILL.md read `pm-system.reference.html` and extract the `<style>` block at render time. Brittle — couples Phase 2's output to the structure of a 1,726-line reference file. Not recommended.
- (c) Lazy: ship Phase 2 with just `palette.css` + `typography.css` inlined and accept that components are mostly defined by classes the audit allows but that have no inline CSS. The output WILL render with default browser styles for most components. This is wrong but might be what "minimum end-to-end" means in CONTEXT.md.

**Strong recommendation: Option (a).** Create `skill/design/components.css` in Phase 2's first plan. Output inlines three CSS files. Audit class allowlist gains a third source. This is the right shape for Phase 3 to extend (presentation type adds scroll-snap rules, etc.).

This question is the single biggest planning decision Phase 2 has to make — bigger than self-review prompt design — because it determines whether the output actually looks like `pm-system.html` or just shares its skeleton.

### OQ-2: Section component selection logic

**What we know:** `components.html` is the closed allowlist. SKILL.md must "fill each `<!-- SECTION X BODY SLOT -->` with content matching the approved arc, using only classes from `skill/design/components.html`" (D2-15).

**What's unclear:** How does Claude pick *which* component for each section? "This beat is about asymmetric info → use compare boxes" requires Claude to make a judgment call. The arc table doesn't say which component each beat uses.

**Recommendation:** `story-arc.md` (or a Step 7 sub-file like `skill/render/component-picker.md`) provides a cheat-sheet: "If the section is comparing two things → `.cmp`. If it's a list of parallel concepts → `.cg c3`. If it's a rule or warning → `.hl hl-b`/`.hl hl-r`. If it's a numbered process → `.flow` or `.dtree`. Otherwise → plain `<p>`/`<h3>`." This gives Claude a deterministic decision tree without locking it into one component per beat.

### OQ-3: How does the audit handle the dev-only `<style>` block in the output?

**What we know:** Phase 1 review IN-02 noted that `components.html` has dev-only viewer chrome (`body { padding: 40px; … }`) that is "scoped to components.html only … never copied into generated output." The output from SKILL.md should NOT contain this block.

**What's unclear:** Audit Rule 1 strips `:root { ... }` then greps for hex. If the dev-only chrome leaks into the output (because Claude pasted too eagerly from `components.html`), the chrome itself uses `var(--g2)` — no hex literal — but it does contain non-token rules like `padding: 40px`. The current audit doesn't catch that.

**Recommendation:** Add an Audit Rule 5: the only `<style>` blocks allowed in the output are (a) the inlined `palette.css` block, (b) the inlined `typography.css` block, (c) the layout `<style>` block from the format skeleton, and (d) the inlined `components.css` (if OQ-1 is resolved as Option a). Any fifth `<style>` block is a violation.

This is a Phase-3 hardening item more than a Phase-2 must-have, but flagging.

### OQ-4: Is Wave 0 verification of `$ARGUMENTS` empirical?

**What we know:** A1 in the Assumptions Log flags that `$ARGUMENTS` empty-arg behavior is unverified.

**What's unclear:** Should the planner allocate a Wave 0 task that does an empirical "stub SKILL.md, invoke three ways, verify substitution" test before the real implementation begins?

**Recommendation:** YES — one 5-minute Wave 0 task. Cheap insurance against building the mode-detection regex against the wrong substituted-string assumption.

---

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Bash 3.2+ | `skill/audit/run.sh` | ✓ | 3.2.57 (arm64-apple-darwin25) | — |
| BSD grep | audit script | ✓ | grep (BSD) 2.6.0-FreeBSD | use `command grep` to bypass ugrep alias |
| BSD sed | audit script | ✓ | macOS default | use `-i ''` for in-place (not used in V1) |
| `mktemp` | audit script (allowlist temp file) | ✓ | macOS default | `-t deshtml-audit` form portable |
| `open` | OUTPUT-03 | ✓ | macOS default `/usr/bin/open` | linux/win out of scope per PROJECT.md |
| `date +%Y-%m-%d` | filename slug | ✓ | POSIX | — |
| `command` (shell builtin) | audit script (alias bypass) | ✓ | bash builtin | — |
| `shellcheck` | CI for `audit/run.sh` | UNKNOWN locally | — | already present in `.github/workflows/shellcheck.yml`; the workflow runs in GH Actions where shellcheck is provisioned |
| Default browser for `.html` | OUTPUT-03 (auto-open) | ✓ (assumed) | LaunchServices-managed | print path anyway if `open` errors |

**Missing dependencies with no fallback:** None.

**Missing dependencies with fallback:** None.

`[VERIFIED: ran sw_vers, bash --version, /usr/bin/grep --version, /usr/bin/sed --version, type -a open, man open in this session]`

---

## Validation Architecture

`.planning/config.json` does not exist for this project. `nyquist_validation` cannot be checked — treating as enabled per fallback rule.

### Test Framework

| Property | Value |
|----------|-------|
| Framework | None — manual visual gate + `audit/run.sh` as the only mechanical check |
| Config file | None |
| Quick run command | `bash skill/audit/run.sh <generated.html>` |
| Full suite command | `bash skill/audit/run.sh --explain <generated.html>` against the deshtml-about-itself fixture |
| Phase gate | Visual diff approval from Santiago, audit script exit 0 |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|--------------|
| SKILL-01 | `/deshtml` with no args launches interview | manual-only | type `/deshtml`, observe Q1 fires | ❌ Wave 0 |
| SKILL-03 | Mode detection at turn 1, no silent fallback | manual-only | type `/deshtml @nonexistent.md`, verify stub fires (not interview) | ❌ Wave 0 |
| SKILL-04 | First Q = doc type, branches | manual-only | type `/deshtml`, verify Q1 = doc type | ❌ Wave 0 |
| SKILL-05 | SKILL.md ≤200 lines | automated | `wc -l skill/SKILL.md` ≤ 200 | ❌ post-write |
| ARC-01..04 | Arc gate produces table, gates on approval | manual-only | run fixture, verify table format + approval gate fires | ❌ Wave 0 |
| ARC-05 | Revision loop | manual-only | reply with non-approval, verify regenerate | ❌ Wave 0 |
| DOC-02 | Handbook end-to-end | manual-only | run fixture, get HTML | ❌ Wave 0 |
| DOC-07 | ≤5 questions before arc | automated | count questions in `skill/interview/handbook.md` | ❌ post-write |
| DESIGN-06 | Audit rejects violations | automated | `bash audit/run.sh tests/bad-hex.html` exits 1 | ❌ Wave 0 |
| OUTPUT-01 | Single self-contained HTML in CWD | manual + automated | run fixture, `ls *.html`; `audit/run.sh` confirms no `<link>` | ❌ Wave 0 |
| OUTPUT-02 | Filename pattern + collision | automated | run fixture twice, verify `-2` suffix | ❌ Wave 0 |
| OUTPUT-03 | `open <file>` fires | manual-only | run fixture, observe browser opens | ❌ Wave 0 |
| OUTPUT-04 | Print absolute path | manual-only | run fixture, observe terminal | ❌ Wave 0 |
| OUTPUT-05 | Opens correctly via `file://` | manual-only | double-click HTML, observe render | ❌ Wave 0 |

### Sampling Rate

- **Per task commit:** `wc -l skill/SKILL.md` (≤200 line check); `bash skill/audit/run.sh` against last fixture if relevant.
- **Per wave merge:** Re-run the fixture interview end-to-end; visual diff against `pm-system.html`.
- **Phase gate:** `/gsd-verify-work` with the deshtml-about-itself fixture; visual approval from Santiago in Chrome + Safari + iOS Safari forced-dark-mode.

### Wave 0 Gaps

- [ ] `skill/SKILL.md` — flow control + mode detection + step-numbered checklist.
- [ ] `skill/story-arc.md` — table format, self-review rubric, BAD→GOOD pairs, approval whitelist.
- [ ] `skill/interview/handbook.md` — 5-question handbook interview.
- [ ] `skill/audit/rules.md` — human-readable rules description.
- [ ] `skill/audit/run.sh` — bash audit script.
- [ ] `.github/workflows/shellcheck.yml` — extend to lint `skill/audit/run.sh`.
- [ ] OQ-1 resolution — likely a `skill/design/components.css` extracted from `pm-system.reference.html`.
- [ ] Wave 0 empirical verification of `$ARGUMENTS` semantics (5 min stub SKILL.md test).

---

## Sources

### Primary (HIGH confidence)

- [Extend Claude with skills — Claude Code Docs](https://code.claude.com/docs/en/skills) — frontmatter reference, `$ARGUMENTS` substitution, `${CLAUDE_SKILL_DIR}`, skill content lifecycle, `disable-model-invocation`, allowed-tools scoping, sub-file Read pattern.
- [Skill authoring best practices — platform.claude.com](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices) — 500-line cap, progressive disclosure, one-level-deep references, BAD→GOOD examples pattern, evaluation-driven development, BSD-vs-GNU forward-slash paths.
- `man open(1)` (macOS) — non-blocking by default, `-W` blocks, LaunchServices delegation. `[VERIFIED: ran in this session]`
- `/usr/bin/grep --version`, `/usr/bin/sed --version`, `bash --version` — verified BSD tooling on macOS 26.3.1, bash 3.2.57. `[VERIFIED: ran in this session]`
- `/Users/sperezasis/CLAUDE.md` §"Documentation Methodology — Story First" + §"Section Writing Rules" — methodology source of truth, BAD→GOOD pairs to copy verbatim into `skill/story-arc.md`.
- `/Users/sperezasis/projects/code/deshtml/.planning/phases/02-story-arc-gate-handbook-end-to-end/02-CONTEXT.md` — locked decisions D2-01 through D2-25.
- `/Users/sperezasis/projects/code/deshtml/.planning/phases/01-foundation-installer-design-assets/01-02-SUMMARY.md` — Phase 1 hand-off.
- `/Users/sperezasis/projects/code/deshtml/.planning/phases/01-foundation-installer-design-assets/01-REVIEW.md` finding IN-01 — `<link>` inlining contract.
- `/Users/sperezasis/projects/code/deshtml/skill/design/SYSTEM.md` rule 6 — explicit mandate to inline `<link>` tags.

### Secondary (MEDIUM confidence)

- [Expose your design system to LLMs — Hardik Pandya](https://hvpandya.com/llm-design-systems) — closed token layer + audit script pattern; informs hybrid-check (mechanical regex + LLM judgment).
- [LLM Based Multi-Agent Generation of Semi-structured Documents — arXiv 2402.14871](https://arxiv.org/html/2402.14871v1) — narrative-agent pattern, outline-fill failure mode; informs causality-chain check.
- `.planning/research/PITFALLS.md` Pitfalls 4, 5, 6, 10 — confirmed applicable to Phase 2.
- `.planning/research/SUMMARY.md` "self-review prompt-engineering is the least-specified piece" — confirmed; this RESEARCH.md gives concrete patterns.

### Tertiary (LOW confidence — flagged for Wave 0 verification)

- A1 (empty-`$ARGUMENTS` behavior) — verify empirically before locking mode-detection regex.
- A8 (auto-fix discoverability) — verify during fixture testing.

---

## Metadata

**Confidence breakdown:**
- Skill semantics ($ARGUMENTS, lifecycle, sub-file Read): HIGH — verified against current code.claude.com/docs.
- macOS tooling (BSD grep/sed/open/bash): HIGH — verified live in this session.
- Audit script structure: HIGH — bash patterns straightforward; class harvest verified live.
- Self-review prompt patterns: MEDIUM — well-cited references but not empirically tested in this codebase.
- CSS inlining strategy (Option A): MEDIUM — recommended on token-cost reasoning; not measured.
- OQ-1 (component CSS source): LOW — Phase 1 hand-off is ambiguous; needs planning decision.

**Research date:** 2026-04-27
**Valid until:** 2026-05-27 (skill format is stable, but `$ARGUMENTS` empty-arg behavior is the one item that could change quietly between Claude Code releases)
