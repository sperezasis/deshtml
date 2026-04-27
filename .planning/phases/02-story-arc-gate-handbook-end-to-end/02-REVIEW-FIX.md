---
phase: 02-story-arc-gate-handbook-end-to-end
fixed_at: 2026-04-28T01:35:00Z
review_path: .planning/phases/02-story-arc-gate-handbook-end-to-end/02-REVIEW.md
iteration: 1
findings_in_scope: 9
fixed: 9
skipped: 0
status: all_fixed
---

# Phase 02: Code Review Fix Report

**Fixed at:** 2026-04-28T01:35:00Z
**Source review:** `.planning/phases/02-story-arc-gate-handbook-end-to-end/02-REVIEW.md`
**Iteration:** 1

**Summary:**
- Findings in scope: 9 (3 high, 3 medium, 3 low) + 2 info documented in REVIEW.md
- Fixed: 9
- Skipped: 0

All 17 smoke tests pass: original 5 (clean handbook, hex outside `:root`,
unknown class, banned `<script>`, leftover `<link>`) + 9 new bypass-vector
tests proving the high/medium fixes hold + 2 negative regressions
(`data-on=` attribute, literal text "javascript:" in body) + the canonical
fixture `/tmp/deshtml-fixture/2026-04-28-deshtml-handbook.html`.

## Fixed Issues

### HI-01: Inline event-handler regex misses tab/newline-prefixed `on*=` attributes

**Files modified:** `skill/audit/run.sh`
**Commits:** `be1165a`, `13885a0`
**Applied fix:** Replaced literal-space anchor with `(^|[[:space:]])` so
the regex matches handlers preceded by space, tab, OR a line break (grep
is line-oriented, so newline-prefixed handlers land at column 0 of the
next line and need the `^` alternative). Verified against tab-prefixed,
newline-prefixed, and CR-prefixed inputs — all flagged.

### HI-02: `javascript:` URL regex misses single-quoted and unquoted attributes

**Files modified:** `skill/audit/run.sh`
**Commit:** `8470517`
**Applied fix:** Changed the URL-attribute regex to accept any quote
style: `[\"']?` after `=` (with optional whitespace). Verified against
double-quoted, single-quoted, and unquoted (HTML5-valid) `javascript:`
hrefs — all flagged. Negative regression: literal text "javascript:"
appearing in body content still passes (the URL-attribute scoping holds).

### HI-03: Class-allowlist harvester misses compound-selector-only classes

**Files modified:** `skill/audit/run.sh`
**Commit:** `d0fea1f`
**Applied fix:** Added a second harvest pass that takes each CSS rule's
selector list, splits on `,` `>` `+` `~` and whitespace, then extracts
every `.name` token. Catches `active`, `topic-break`, `hs-l`, `hs-n`,
`name`, `sub` plus every other compound/descendant class in
`components.css`. Verified: a synthetic HTML using all 6 missing classes
exits 0; the unknown-class regression test still flags `custom-banner`.

### ME-01: `set -euo pipefail` + empty-class output silently aborts

**Files modified:** `skill/audit/run.sh`
**Commit:** `6864f69`
**Applied fix:** Appended `|| true` to the `used_classes` pipeline
(matches the pattern already used for `hex_lines`). Verified: a
zero-class body now exits 0 instead of aborting silently with no
violation message.

### ME-02: `<link rel='stylesheet'>` regex misses single-quoted attribute

**Files modified:** `skill/audit/run.sh`
**Commit:** `2e3266c`
**Applied fix:** Switched to the simpler form
`<link[[:space:]][^>]*rel=[^>]*stylesheet` which matches any quote style
and tolerates other attributes appearing before `rel=`. Verified against
double-quoted and single-quoted variants — both flagged.

### ME-03: Hex-literal Rule 1 bypassable via `:root` closing-brace line

**Files modified:** `skill/audit/run.sh`
**Commit:** `bb22289`
**Applied fix:** Replaced the two-pass sed strip with a brace-aware awk
pass that strips the `:root { ... }` block but preserves any content
trailing on the closing-brace line. Verified: the injection pattern
`} .x { color: #BAD000; }` is now flagged; the three legitimate shapes
(clean multi-line `:root`, clean single-line `:root`, body-style hex
outside `:root`) all behave identically to before.

### LO-01: SKILL.md class-allowlist wording is stale post-fix

**Files modified:** `skill/SKILL.md`
**Commit:** `c0ae8d4`
**Applied fix:** Replaced the typography-only sentence with one that
names all four allowlist sources (`design/components.html`,
`design/components.css`, `design/typography.css`,
`design/formats/handbook.html`) so the writer's mental model matches
the audit's actual behavior.

### LO-02: `Bash(pwd *)` semantically odd

**Files modified:** `skill/SKILL.md`
**Commit:** `00ebf7b`
**Applied fix:** Changed `Bash(pwd *)` to `Bash(pwd)` in the frontmatter
allowed-tools. `pwd` accepts only `-L`/`-P` flags, no path arguments, so
the glob was meaningless. Cosmetic alignment.

### LO-03: SKILL.md Step 2 fallback grammar reads oddly

**Files modified:** `skill/SKILL.md`
**Commit:** `8a09cfe`
**Applied fix:** Replaced the `<type>`-template-with-`that` form with a
direct fallback message: "That is not one of the five document types.
Run `/deshtml` and pick `handbook` to continue." Functional behavior
unchanged; reads cleaner.

## Companion changes (not findings, but driven by the fix pass)

### `skill/audit/rules.md` refresh

**Commit:** `7183c04`
**Applied:** Updated the implementation snippets in Rule 1, Rule 2,
Rule 3, and Rule 4 to match the post-fix run.sh code. Added a smoke-test
table appendix listing all 15 maintainer-runnable inputs (5 original +
HI-01a/b, HI-02a/b, HI-03, ME-01, ME-02, ME-03 + 2 negative regressions).
Added a known-limitation note about HTML-entity-encoded `javascript:`
URLs (acceptable for V1; flag for V2 if the audit ever consumes
adversarial input).

### `02-REVIEW.md` IN-* annotations

The two info-level findings (IN-01, IN-02) are intentional — documented
in REVIEW.md with `Decision (2026-04-28 fix pass): No action required`
notes per the fix-pass instruction.

## Skipped Issues

None.

## Verification

All 17 smoke tests passed after the final commit (`7183c04`):

| Group | Tests | Result |
|-------|-------|--------|
| Original 5 (plan 02-03) | clean, hex, unknown class, `<script>`, `<link>` | 5/5 PASS |
| New bypass vectors | HI-01a/b/c, HI-02a/b, HI-03, ME-01, ME-02, ME-03 | 9/9 PASS |
| Negative regressions | `data-on=` attribute, literal "javascript:" prose | 2/2 PASS |
| Canonical fixture | `/tmp/deshtml-fixture/2026-04-28-deshtml-handbook.html` | 1/1 PASS |

`bash -n skill/audit/run.sh` clean. `bash 3.2` compatibility preserved
(awk is POSIX, sed flags are BSD-safe).

---

_Fixed: 2026-04-28T01:35:00Z_
_Fixer: Claude (gsd-code-fixer)_
_Iteration: 1_
