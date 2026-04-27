---
phase: 02-story-arc-gate-handbook-end-to-end
reviewed: 2026-04-27T23:08:49Z
depth: standard
files_reviewed: 8
files_reviewed_list:
  - skill/SKILL.md
  - skill/story-arc.md
  - skill/interview/handbook.md
  - skill/audit/run.sh
  - skill/audit/rules.md
  - skill/design/components.css
  - skill/design/palette.css
  - skill/design/SYSTEM.md
findings:
  critical: 0
  high: 3
  medium: 3
  low: 3
  info: 2
  total: 11
status: issues
---

# Phase 02: Code Review Report

**Reviewed:** 2026-04-27T23:08:49Z
**Depth:** standard
**Files Reviewed:** 8
**Status:** issues

## Summary

Phase 2 ships a small, well-scoped skill: a flow-control SKILL.md, a story-arc gate, a handbook interview, and a post-generation audit script. The Markdown skill files (SKILL.md, story-arc.md, interview/handbook.md, audit/rules.md) are clear, internally consistent, and respect the lazy-load discipline laid out in D2-01..D2-25. The CSS files (components.css, palette.css) and SYSTEM.md are extraction artifacts and are not reviewed for design choices per the review-guidance note.

The high-stakes file is `skill/audit/run.sh`. The 02-04 fix correctly addressed the two empirically-found bugs (harvester missing components.css; `javascript:` over-matching documentation prose). However, the review surfaced **three additional security false-negatives** and **three correctness gaps** in the same script that the 5-test smoke suite did not exercise. None are exploited by the current handbook fixture, but each is a hole the audit was meant to seal — and since "the audit is the moat" per the phase's own framing, every bypass in run.sh is a real concern.

The findings below are reproducible against the committed `8281c04` script — each was verified by constructing a minimal HTML payload and observing exit 0 (bypass) or exit 1 (silent failure).

---

## High

### HI-01: Inline event-handler regex misses tab/newline-prefixed `on*=` attributes (security false-negative)

**File:** `skill/audit/run.sh:118`
**Issue:** The Rule 3 regex hardcodes a literal SPACE before `on[a-z]+`:

```
command grep -nEi ' on[a-z]+[[:space:]]*=' "$output_file"
```

If an attribute is preceded by a tab or newline (common when HTML is pretty-printed across lines), the audit silently passes a JS-executing handler. Reproduced:

```
<a class="hl"
	onclick="evil()">tab-prefixed</a>
```

Audit exits 0. Per D-17 ("no JS in output, ever"), this is a bypass of one of the audit's three security rules.

**Fix:**
```bash
if command grep -nEi '[[:space:]]on[a-z]+[[:space:]]*=' "$output_file" >&2; then
```

### HI-02: `javascript:` URL regex misses single-quoted and unquoted attributes (security false-negative)

**File:** `skill/audit/run.sh:123`
**Issue:** The 02-04 fix correctly scoped the rule to URL-attribute contexts but hardcoded a double-quote:

```
(href|src|action|formaction|xlink:href)[[:space:]]*=[[:space:]]*"[[:space:]]*javascript:
```

Both single-quoted (`href='javascript:bad()'`) and unquoted (`href=javascript:bad()` — HTML5-valid) attributes bypass. Reproduced:

```html
<a href='javascript:bad()'>x</a>          <!-- exit 0 -->
<a href=javascript:bad()>x</a>            <!-- exit 0 -->
```

Same severity rationale as HI-01 — this is a security rule, and the URL-attribute scoping intent applies to both quote styles.

**Fix:** Match either quote or no quote:

```bash
if command grep -nEi "(href|src|action|formaction|xlink:href)[[:space:]]*=[[:space:]]*[\"']?[[:space:]]*javascript:" "$output_file" >&2; then
```

(Note: this regex still misses `&#x6a;avascript:`-style HTML-entity-encoded attacks, which would require entity-decoding before matching — acceptable for V1 since the generator is Claude, not adversarial input, but flag for V2 if the audit ever runs on user-pasted HTML.)

### HI-03: Class-allowlist harvester misses compound-selector-only classes used by the canonical reference

**File:** `skill/audit/run.sh:78`
**Issue:** The harvester regex only catches standalone class selectors of the form `^\s*\.foo\s*{`. Classes that exist ONLY in compound (`.nav-a.active`) or descendant (`.role-card .rc-label`) selectors in components.css and are NOT enumerated as `class="..."` in components.html or handbook.html will not appear in the allowlist.

Concrete miss list (verified by harvest-vs-reference diff against `pm-system.reference.html`): `active`, `topic-break`, `hs-l`, `hs-n`, `name`, `sub`. All six appear in real markup the user might generate (`<a class="nav-a active">`, `<h3 class="topic-break">`, `<div class="hs-n">`, `<span class="name">`).

The 02-04 SUMMARY says "every class used in the fixture (35 distinct) resolves," which is true for that one fixture — but the canonical reference uses 6 classes that the harvester would still false-positive on. This will trigger the audit retry loop (max 2 rounds) for any handbook that uses standard active-state markup or sidebar branding.

**Severity rationale:** High, not Critical, because the file is still written on round-3 failure (loud surfacing per D2-21). But it forces avoidable retry rounds and erodes user trust in the audit.

**Fix options:**
1. **Quick:** Add a second harvest regex that catches compound/descendant selectors:
   ```bash
   command grep -oE '\.[a-zA-Z_][a-zA-Z0-9_-]*' "$css" \
     | command sed -E 's/^\.//'
   ```
   This over-harvests (would pick up CSS comments containing `.foo`), but the union with the existing strict regex keeps the strict semantics for primary classes and only adds names. Alternative: filter to lines that look like CSS rules.
2. **Correct:** Parse selectors properly — split each rule's selector list on `,`, then split each selector on whitespace/`>`/`+`/`~`, then extract `\.foo` tokens. ~6 lines of awk.
3. **Cheapest:** Enumerate the 6 missing classes in components.html under a new "States and modifiers" section so the existing class="..." harvest picks them up. Single-source-of-truth aligned.

---

## Medium

### ME-01: `set -euo pipefail` + empty-class output silently aborts the audit

**File:** `skill/audit/run.sh:87-93`
**Issue:** When the output HTML has zero `class="..."` attributes, the inner pipeline `grep -oE 'class="[^"]+"'` returns exit 1 (no matches). Under `pipefail` inside `$()`, bash 3.2 (macOS) propagates that exit through the assignment and `set -e` aborts the script before any VIOLATION line is printed. Reproduced with a class-free HTML body — script exits 1 with no stderr output, no `AUDIT FAILED` line, no diagnostic.

The current handbook flow always emits classes, so this is latent. But if a future Phase-3 doc-type's skeleton ever ships with low/no class density (e.g., a minimal presentation slide), or if the user-approved arc maps to plain `<p>` markup, the audit dies silently and SKILL.md's retry loop will see exit 1 with no violation message to address.

**Fix:** Add `|| true` to the assignment, OR move the empty-result handling explicitly:
```bash
used_classes="$(
  ...
  | command sort -u || true
)"
```
Same pattern the script already uses for `hex_lines` on line 56-60.

### ME-02: `<link rel="stylesheet">` regex misses single-quoted attribute

**File:** `skill/audit/run.sh:132`
**Issue:** Same quote-style asymmetry as HI-02. `<link rel='stylesheet' href='foo.css'>` bypasses Rule 4. Reproduced:

```html
<link rel='stylesheet' href='foo.css'>      <!-- exit 0 -->
```

OUTPUT-05 (self-contained file) is the contract this rule enforces. A surviving stylesheet link breaks `file://` rendering on the user's machine. Same severity as HI-02 in principle, but downgraded to Medium because the format skeleton is the only realistic source of `<link rel="stylesheet">` and it uses double quotes — Claude is unlikely to introduce single-quoted variants on its own.

**Fix:**
```bash
command grep -nEi '<link[[:space:]]+rel=[\"'"'"']stylesheet'
```

Or simpler: just check for any `<link[[:space:]]+rel=` containing `stylesheet`:
```bash
command grep -nEi '<link[[:space:]][^>]*rel=[^>]*stylesheet'
```

### ME-03: Hex-literal Rule 1 bypassable by injecting CSS on the `:root` closing-brace line

**File:** `skill/audit/run.sh:56-60`
**Issue:** The two-pass strip (`s/:root\s*\{[^}]*\}//g` then `/:root\s*\{/,/^\s*\}/d`) deletes ENTIRE LINES from the `:root {` line through the line containing `}`. If a CSS rule is appended on the same line as the closing brace, it is also deleted. Reproduced:

```css
:root {
  --a: #ff0000;
} .injected { color: #BAD000; }   /* hex bypassed */
```

Audit exits 0 — the `#BAD000` literal is hidden because the entire closing-brace line is consumed.

This requires Claude to emit CSS in this specific shape, which is unlikely organically — but it IS a hole in a mechanical-rule audit. Same severity rationale as ME-02.

**Fix:** Use a proper CSS-aware extraction (awk that tracks brace depth) OR replace the `:root` block with a placeholder that preserves line boundaries, then grep for hex on the resulting text without consuming the closing-brace line's trailing content:

```awk
awk '
  /:root[[:space:]]*\{/ { in_root=1; next }
  in_root && /\}/        { in_root=0; sub(/^[^}]*\}/, ""); print; next }
  in_root                 { next }
                          { print }
' "$output_file" | command grep -nE '#[0-9a-fA-F]{3,8}\b'
```

---

## Low

### LO-01: SKILL.md Step 6 instructs Claude to use a class subset that is narrower than what the audit accepts

**File:** `skill/SKILL.md:122-123`
**Issue:**
```
Use ONLY classes that appear in `components.html` (markup allowlist) or in
`typography.css` (`.s-lead`, `.eye`, `.cl`, `.fl`, `.ct`, `.cd`, `.ic`, `.fn`).
```

After the 02-04 audit-script fix, the audit also harvests classes from `components.css` and the skeleton's `class="..."` attributes. SKILL.md still describes the pre-fix narrower view. This is conservative (Claude won't generate classes the audit rejects), but the wording is now stale and a Phase-3 maintainer reading SKILL.md will think the audit and the writer disagree.

**Fix:** Update the line to match the audit's actual allowlist sources, or simplify to "Use only classes from the design system (`design/components.html`, `design/components.css`, `design/typography.css`, `design/formats/handbook.html`). The audit in Step 7 enforces this list."

### LO-02: SKILL.md `allowed-tools` includes `Bash(pwd *)` but `pwd` takes no arguments

**File:** `skill/SKILL.md:5`
**Issue:** The frontmatter declares `Bash(pwd *)`. `pwd` with `*` doesn't usefully constrain anything (pwd accepts only `-L`/`-P` flags, no path arguments) and `Bash(pwd)` would suffice. Minor — Claude Code's allow-list pattern matching probably treats `pwd *` permissively, so it works, but the entry is semantically odd. Same applies to the `Bash(date *)` entry, though `date` does take format args so that one is appropriate.

**Fix:** Change `Bash(pwd *)` → `Bash(pwd)`. Cosmetic.

### LO-03: SKILL.md Step 2 fallback grammar reads oddly

**File:** `skill/SKILL.md:50-52`
**Issue:**
> If the second reply is still not in the list, reply with the Phase-3-stub language using `that` in place of `<type>` and stop.

This produces literal output like ``` `that` is coming in Phase 3. Try `handbook` for now. ``` — readable but a touch awkward. A clearer fallback would be a different sentence ("That is not one of the five document types. Run `/deshtml` and pick `handbook` to continue.") rather than reusing the Phase-3-stub template.

**Fix:** Optional — prose-level polish. Functional behavior is correct.

---

## Info

### IN-01: Audit `--explain` flag doesn't add `--explain` to usage in `audit/rules.md` test snippets

**File:** `skill/audit/rules.md:105`
**Issue:** rules.md says "`bash skill/audit/run.sh --explain <output.html>` prints WHY each violation was flagged." The script supports it, but the documentation in rules.md says (line 5) "Usage: bash run.sh [--explain] <output.html>" matches the script's own usage line. No bug — just noting that rules.md is internally consistent on this point.

**Decision (2026-04-28 fix pass):** No action required. The reviewer
confirmed rules.md is internally consistent. Resolution: keep as-is.

### IN-02: Audit script comment claims bash 3.2 compatibility; verified empirically

**File:** `skill/audit/run.sh:9-12`
**Issue:** Comment claims bash 3.2 + BSD grep/sed compatibility. Spot-checked against the real macOS bash 3.2.57 shipped with the system. All language features used (`[[:space:]]` POSIX classes, `$((arith))`, `command` builtin, `mktemp` fallback chain, here-doc, simple `for`/`while` loops) are bash 3.2-safe. No `${var,,}` case conversion, no `${arr[@]}` declared-array tricks, no `mapfile`/`readarray`. Compatibility claim holds.

**Decision (2026-04-28 fix pass):** No action required. The fix pass
added one new awk pass (Rule 1, ME-03) and one extra sed pass (Rule 2,
HI-03); both use only POSIX awk / BSD-sed-safe features. Compatibility
claim still holds. Resolution: keep as-is.

---

## Notes on what this review intentionally did NOT flag

- **CSS values, naming, design choices in `components.css` and `palette.css`.** Per review-guidance note, these are verbatim extractions from `pm-system.reference.html` per D-14; only genuine syntax bugs would be in scope. None found.
- **`disable-model-invocation: true` in SKILL.md frontmatter.** This is the documented Claude Code skill convention for slash-command-only skills; correct here.
- **The `${CLAUDE_SKILL_DIR}` references in SKILL.md.** Documented runtime variable resolved by Claude Code skill loader.
- **"Performance" of the audit harvester (~140-class allowlist regenerated per run).** rules.md notes <50ms; out of v1 scope per review template.
- **The `pwd` / `date` allowed-tools details beyond LO-02** — Claude Code's tool gating handles these permissively.
- **Phase-2 stubs for the four future doc types** — D2-05 explicitly mandates the five-option list complete from Phase 2.

---

_Reviewed: 2026-04-27T23:08:49Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
