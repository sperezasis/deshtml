---
phase: 02-story-arc-gate-handbook-end-to-end
plan: 03
subsystem: audit
tags: [audit, bash, shellcheck, ci, design-system, mechanical-gate]

# Dependency graph
requires:
  - phase: 02-story-arc-gate-handbook-end-to-end
    plan: 01
    provides: skill/design/components.html (markup allowlist source), skill/design/typography.css (type-scale labels)
  - phase: 01-foundation-installer-design-assets
    plan: 02
    provides: .github/workflows/shellcheck.yml (CI gate scaffold), bin/install.sh (Bash 3.2 / `command grep` discipline pattern)
provides:
  - skill/audit/run.sh (post-generation audit, four mechanical gates, BSD-safe, bash 3.2 compatible)
  - skill/audit/rules.md (human-readable rule reference, ≤150 lines)
  - .github/workflows/shellcheck.yml extension (second step lints skill/audit/)
affects: [02-02-plan, 02-04-plan, phase-03-other-doc-types]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Mechanical-gate audit — every rule is a grep or set difference. Zero LLM judgment at the audit boundary."
    - "Live class-allowlist harvest — single source of truth from components.html (markup) + typography.css (scale labels). No hand-maintained list."
    - "Two-pass :root strip — `s/:root[[:space:]]*\\{[^}]*\\}//g` for inline (single-line) blocks; `/:root[[:space:]]*\\{/,/^[[:space:]]*\\}/d` range delete for multi-line blocks. Both shapes are stripped before the hex grep."
    - "command-grep / command-sed discipline — every grep and sed prefixed with `command` to bypass shell aliases (ugrep on Santiago's machine). Phase 1 audit deviation #1 preempted by design."
    - "Bash 3.2.57 compatibility — no mapfile, no readarray, no case-conversion expansions, no associative arrays. Same discipline as bin/install.sh (D-09)."

key-files:
  created:
    - "skill/audit/run.sh (140 lines, executable 0755, 4 rules + --explain flag)"
    - "skill/audit/rules.md (135 lines, ≤150 cap, 4-rule reference + non-goals)"
  modified:
    - ".github/workflows/shellcheck.yml (added second step: scandir ./skill/audit)"

key-decisions:
  - "Two-pass :root strip (deviation from plan's single-pass sed). Plan provided one sed range delete that only matched closing `}` at start-of-line; failed when CSS inlining produced `:root{...}` on a single line. Two-pass approach handles both shapes."
  - "Comment wording adjusted to satisfy verify-grep. Plan's prose `# - bash 3.2 compatible: no mapfile, no readarray, no \\${var,,}, no \\`declare -A\\`.` matches the verify gate's `! grep -E 'mapfile|readarray|declare -A'` (matches in comments too). Reworded to `no array-fill builtins, no case-conversion expansions, no associative-array declarations` — same meaning, no false-trigger."
  - "shellcheck Approach A (second step) over Approach B (additional_files). Per plan recommendation; minimizes diff to Phase 1 file."

patterns-established:
  - "Verify-gate-aware comment phrasing: when a verify check uses `! grep -E pattern` to assert absence of code patterns, the matching prose must not appear in comments either. Pattern is 'document the constraint abstractly; let the code speak for itself.'"
  - "Two-pass sed for nested-brace block deletion: BSD sed's range-delete `/A/,/B/d` requires line-anchored boundaries. For HTML where blocks may be inlined onto a single line, do an inline-shape pass first (`s/A{[^}]*}//g`) then the multi-line range delete."

requirements-completed: [DESIGN-06]

# Metrics
duration: ~30min
completed: 2026-04-27
---

# Phase 02 Plan 03: Post-Generation Audit Summary

**The mechanical gate is shipped. `skill/audit/run.sh` exits 0 on a clean handbook and non-zero on hex literals outside `:root`, unknown classes, banned tags/attrs, or leftover `<link rel=stylesheet>` tags. Class allowlist is harvested live from `components.html` + `typography.css` — single source of truth, no separate list to maintain.**

## Performance

- **Duration:** ~30min (rules.md write + run.sh write + iterate on :root strip + shellcheck extension + smoke tests)
- **Started:** 2026-04-27 (this session, after 02-01)
- **Completed:** 2026-04-27
- **Tasks:** 3
- **Files modified:** 3 (two created, one updated)

## Accomplishments

- `skill/audit/rules.md` (135 lines) describes the four rules in script-execution order, documents the live class-allowlist harvest, the `--explain` flag (verbosity-only; no exit-code change), the SKILL.md retry contract (max 2 rounds; round 3 is loud), and four non-goals (no provenance, no auto-fix, no semantic structure, no CSS linting).
- `skill/audit/run.sh` (140 lines, mode 0755) implements all four rules. BSD-safe, bash 3.2 compatible, every grep/sed prefixed with `command` to bypass aliases. `--explain` adds context without changing exit codes. Exit codes: 0 = pass, 1 = violations, 2 = usage error.
- `.github/workflows/shellcheck.yml` extended with a second step that scans `./skill/audit` on every push and PR to main. Same action version (`ludeeus/action-shellcheck@2.0.0`), same severity (`warning`), same `SHELLCHECK_OPTS` (`-e SC1091`) as the existing `./bin` step.
- Plan's automated verify gates pass: rules.md ≤150 lines + all required strings; run.sh executable + bash -n valid + zero Bash-4 features + every grep/sed is `command`-prefixed + all four rules present in regex; workflow contains both `scandir: ./bin` and `scandir: ./skill/audit` with two action references.
- All five smoke tests pass: clean handbook → exit 0; injected hex literal → exit 1; injected unknown class → exit 1; injected `<script>` → exit 1; leftover `<link rel="stylesheet">` → exit 1.

## Task Commits

1. **Task 1: Write skill/audit/rules.md** — `5bbbbcf` (docs)
2. **Task 2: Write skill/audit/run.sh** — `994bf4e` (feat)
3. **Task 3: Extend .github/workflows/shellcheck.yml** — `6a40136` (chore)

## Files Created/Modified

- `skill/audit/rules.md` (created, 135 lines) — Maintainer reference for the four audit rules. SKILL.md does NOT read this file at runtime; it's documentation for Phase 3 maintainers extending the audit.
- `skill/audit/run.sh` (created, 140 lines, executable) — The bash audit script SKILL.md invokes at Step 7 via the Bash tool. Stateless: takes a path, exits with a code, writes details to stderr.
- `.github/workflows/shellcheck.yml` (modified, +7 lines) — Added second `Run shellcheck on skill/audit/` step. Phase 1's `./bin` step is unchanged.

## The Four Rules (script-execution order)

| # | Rule | Pattern (BSD-safe) | What it catches |
|---|------|--------------------|-----------------|
| 1 | Hex literals outside `:root` | `command sed -E 's/:root[[:space:]]*\{[^}]*\}//g' \| command sed -E '/:root[[:space:]]*\{/,/^[[:space:]]*\}/d' \| command grep -nE '#[0-9a-fA-F]{3,8}\b'` | `style="color:#ff0000"`, hex in inlined `<style>` blocks outside `:root` |
| 2 | Class allowlist | `command grep -oE 'class="[^"]+"'` over output, set-difference against allowlist (built live from `components.html` + `typography.css` `^\.<name>{` selectors) | `class="custom-banner"`, `class="my-section"`, anything not in design system |
| 3a | Banned tags | `command grep -nEi '<(script\|iframe\|object\|embed)\b'` | `<script>`, `<iframe>`, `<object>`, `<embed>` |
| 3b | Inline event handlers | `command grep -nEi ' on[a-z]+[[:space:]]*='` | `onclick=`, `onload=`, `onerror=`, etc. |
| 3c | javascript: URLs | `command grep -nEi 'javascript:'` | `<a href="javascript:void(0)">` |
| 4 | Leftover `<link rel="stylesheet">` | `command grep -nE '<link[[:space:]]+rel="stylesheet"'` | Skeleton's dev-time `<link>` tag that survived inlining (IN-01) |

## Class-Harvest Pipeline

The audit's allowlist is built on every run from two sources:

```bash
{
  command grep -oE 'class="[^"]+"' "${SKILL_DIR}/design/components.html"
  command grep -oE '^\.[a-zA-Z_][a-zA-Z0-9_-]*[[:space:]]*\{' "${SKILL_DIR}/design/typography.css" \
    | command sed -E 's/^\.([^[:space:]{]+).*/class="\1"/'
} \
  | command sed -E 's/class="//; s/"$//' \
  | tr ' ' '\n' \
  | command grep -v '^$' \
  | command sort -u > "$allowed_file"
```

Output: ~83 distinct class names (75 from `components.html` markup + 8 type-scale labels from `typography.css`: `s-lead`, `eye`, `cl`, `fl`, `ct`, `cd`, `ic`, `fn`). Phase 3 adding new components to `components.html` automatically expands the allowlist on the next audit run.

## Exit-Code Contract

| Code | Meaning | SKILL.md Step 7 behavior |
|------|---------|--------------------------|
| 0 | Pass | Proceed to Step 8 (`open`). |
| 1 | Violations | Read stderr, regenerate output, retry. Max 2 retry rounds; round 3 keeps the file, surfaces violations to user verbatim, opens anyway. |
| 2 | Usage error / missing inputs | Stop and surface to user — this is a Phase-3 maintainer bug, not a generation issue. |

## Smoke-Test Inputs (re-runnable by Phase 3 maintainers)

Each test creates a minimal-shape HTML with `:root{--blue:#6BA4F8;}` in a `<style>` block plus one violation pattern, then asserts the audit's exit code.

| # | Input | Expected exit |
|---|-------|---------------|
| 1 | `<div class="hl">ok</div>` (clean) | 0 |
| 2 | `<div style="color:#ff0000" class="hl">bad</div>` (hex outside :root) | non-zero |
| 3 | `<div class="custom-banner">bad</div>` (unknown class) | non-zero |
| 4 | `<script>alert(1)</script>` (banned tag) | non-zero |
| 5 | `<link rel="stylesheet" href="palette.css">` (leftover link) | non-zero |

The full smoke-test bash block lives in the plan's `<verify>` block; Phase 3 maintainers can re-run it after extending the audit to confirm no regressions.

## CI Workflow Extension

`.github/workflows/shellcheck.yml` now contains TWO `Run shellcheck on …` steps, both using `ludeeus/action-shellcheck@2.0.0` with `severity: warning` and `SHELLCHECK_OPTS: -e SC1091`:

1. **Step 1 (Phase 1)** — `scandir: ./bin` — lints `bin/install.sh`, `bin/uninstall.sh`.
2. **Step 2 (Phase 2 Plan 03)** — `scandir: ./skill/audit` — lints `skill/audit/run.sh` (and any future audit scripts Phase 3 adds).

Triggers (`push: branches: [main]` / `pull_request: branches: [main]`) are unchanged. Phase 1's step is preserved verbatim — this commit is purely scope extension.

## Decisions Made

1. **Two-pass `:root` strip rather than the plan's single-pass.** The plan provided `command sed -E '/:root[[:space:]]*\{/,/^[[:space:]]*\}/d' "$output_file"` as the strip step. This works only when the closing `}` is anchored at start-of-line (true for `palette.css` source where `}` is on line 56 alone). After CSS inlining, however, the rendered HTML may collapse `:root{...}` onto a single line `<style>:root{--blue:#6BA4F8;}\n</style>`. With a single-pass, sed never finds a line matching `^[[:space:]]*\}` and either deletes nothing or deletes through EOF — both are wrong. **Fix:** prepend an inline-shape pass `command sed -E 's/:root[[:space:]]*\{[^}]*\}//g'` that strips single-line `:root{...}` blocks, then the multi-line range delete handles the palette.css-shape case.

2. **Comment wording adjusted to bypass verify-grep false-trigger.** The plan's recommended file-header comment listed the prohibited Bash-4 features by name: `# - bash 3.2 compatible: no mapfile, no readarray, no ${var,,}, no declare -A.` But the verify gate uses `! command grep -E 'mapfile|readarray|declare -A' skill/audit/run.sh` to assert absence — and grep matches comments too. Rewrote the comment to describe the constraint abstractly: `no array-fill builtins, no case-conversion expansions, no associative-array declarations`. Same semantic content, no false trigger. Pattern flagged for the patterns-established list: when a verify-grep asserts absence of code patterns, comments must not contain those patterns either.

3. **shellcheck Approach A (second step) over Approach B (`additional_files`).** Per the plan's recommendation. The diff to `.github/workflows/shellcheck.yml` is +7 lines (vs. mutating Phase 1's existing step), and per-directory severity tuning stays trivial.

4. **Heredoc form for the class-iteration loop, not `<<<` string.** Bash 3.2 supports both, but the plan's recommended form `done <<EOF\n...\nEOF` is portable across older Bash 3.x quirks where `<<<` empty-string handling differs. No semantic difference for our use; followed the plan.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 — Bug] Plan's single-pass `:root` strip didn't handle inline blocks**

- **Found during:** Task 2 smoke test #2 (injected hex literal)
- **Issue:** Smoke test 2's input `<style>:root{--blue:#6BA4F8;}\n</style>` collapses the `:root` block onto a single line. The plan's sed range delete `/:root[[:space:]]*\{/,/^[[:space:]]*\}/d` looks for a line matching `^[[:space:]]*\}` to terminate the range. With everything on one line, the closing `}` is mid-line followed by `</style>` — no `^[[:space:]]*\}` match. Sed either deletes nothing (false negative; smoke 2 passed when it should fail) or deletes to EOF (false positive). Test 2 hit the former: the `:root{...}` was not stripped, the `--blue:#6BA4F8;` survived as a "violation," and the body div's `color:#ff0000` was hidden among many false positives. The test reported "audit failed" but for the wrong reason — and after I tried a normalize-first approach, smoke 1 (clean handbook) started failing because the normalize separated `:root` from its `{`.
- **Fix:** Two-pass strip: first pass `s/:root[[:space:]]*\{[^}]*\}//g` removes any `:root{...}` block contained on a single line (BSD `sed -E` regex; `[^}]*` is greedy-up-to-first-`}` so it stops at the right place); second pass is the original range delete for multi-line blocks. Both passes are cheap and complementary. Smoke tests now pass cleanly: smoke 1 (clean) exits 0; smoke 2 (hex) catches `#ff0000` in the body div as the only violation.
- **Files modified:** `skill/audit/run.sh` lines 49-62 (Rule 1 block).
- **Verification:** All 5 smoke tests pass; static-check verify block passes; `bash -n` valid.
- **Committed in:** `994bf4e` (Task 2).

**2. [Rule 3 — Blocking] File-header comment matched the verify-gate's negative grep**

- **Found during:** Task 2 first verify run
- **Issue:** The plan's recommended file header included `# - bash 3.2 compatible: no mapfile, no readarray, no ${var,,}, no declare -A.` But the verify gate `! command grep -E 'mapfile|readarray|declare -A' skill/audit/run.sh` matches comments too — so it failed against my own comment, not against actual code.
- **Fix:** Rewrote the comment to describe the constraint abstractly without naming the prohibited builtins: `no array-fill builtins, no case-conversion expansions, no associative-array declarations`. Same meaning; satisfies the negative grep.
- **Files modified:** `skill/audit/run.sh` line 10-11 (file header comment).
- **Verification:** Static checks pass.
- **Committed in:** `994bf4e` (Task 2).

---

**Total deviations:** 2 auto-fixed (1 Rule 1 bug, 1 Rule 3 blocking). Both were caught by the plan's own verify gate / smoke tests; no scope creep, no architectural changes.

## Bash 3.2 Compatibility Constraint

Inherited from Phase 1 D-09 and applies recursively to every bash file in this project:

- No `mapfile` / `readarray` (Bash 4+).
- No `${var,,}` / `${var^^}` case-conversion (Bash 4+).
- No `declare -A` associative arrays (Bash 4+).
- No `<<<` heredoc-string is fine in 3.2 but heredoc form is preferred for portability.
- Use `[ ... ]` test, not `[[ ... ]]`, when feasible (script uses both pragmatically; both are 3.2-safe).

Verified by `bash --version` → `GNU bash, version 3.2.57(1)-release (arm64-apple-darwin25)` on this machine.

## `command grep` / `command sed` Discipline

Inherited from Phase 1 audit deviation #1 (Plan 01-02 SUMMARY). Santiago's shell aliases `grep` to `ugrep`, which has subtly different regex semantics. Every `grep` and `sed` invocation in `skill/audit/run.sh` is prefixed with `command` to force the system binary:

```bash
command grep -oE 'class="[^"]+"' "$file"   # not: grep -oE ...
command sed -E 's/foo/bar/g' "$file"        # not: sed -E ...
```

Static check: `! command grep -E '(^|[^a-zA-Z_])grep\b' skill/audit/run.sh | command grep -v 'command grep'` (the verify gate uses a simpler positive form: `command grep -q 'command grep' skill/audit/run.sh`).

## Non-Goals (V1, deferred to V2)

Discharged from CONTEXT.md §"Deferred Ideas" and rules.md:

- **No provenance check.** A user can hand-edit a generated handbook to fix violations; the audit only checks content, not history. Pitfall 16 — V2 backlog.
- **No auto-fix.** V1 only flags. SKILL.md regenerates the whole output, max 2 rounds.
- **No semantic structure check.** The audit doesn't care about `<main>` tags or section nesting. That's the format-skeleton's job.
- **No CSS linting.** Multiple `<style>` blocks instead of one is fine; the audit checks rules, not aesthetics.

## Issues Encountered

- The plan's smoke-test verify block uses `! bash skill/audit/run.sh "$TMP_HEX" 2>/dev/null` — this works because in a `! cmd` pipeline, set -e doesn't fire on the negated command. But the verify is sensitive to the order of operations: a quirky bash interaction caused smoke 1 (clean) to print "PASS" even when the audit had failed because set -e behavior inside `if-then-else` differs from top-level. Resolved by re-running each test with `if cmd; then echo PASS; else echo FAIL; exit 1; fi` form during local debugging — the plan's verify form is fine because it doesn't ALSO exit on the success cases.
- macOS `mktemp -t deshtml-audit` creates a file like `/tmp/deshtml-audit.XXXXXX`. The `||` fallback to `mktemp -t deshtml-audit.XXXXXX` covers Linux variants where the BSD form errors out. Verified working on this machine.

## User Setup Required

None — no external service configuration required. Locally, shellcheck is not installed (CI catches it).

## Next Phase Readiness

**Plan 02-02 (SKILL.md flow) can now reference the audit script.** Step 7 invokes `bash "${CLAUDE_SKILL_DIR}/audit/run.sh" "<absolute-path>"`. The retry contract is documented in `skill/audit/rules.md` and the script's exit codes (0/1/2) honor it.

**Plan 02-04 (visual gate + canonical fixture) is unblocked.** The `deshtml-about-itself` handbook generated end-to-end will be audited via `bash skill/audit/run.sh <fixture>`. Expected: exit 0 on the canonical handbook (proves the retry loop works on a clean fixture); intentional violations injected into a copy of the fixture exercise the retry loop in SKILL.md Step 7. Plan 02-04 owns those end-to-end tests.

**Phase 3 extensibility:** When new doc types ship (pitch, technical brief, presentation, meeting prep), they may add new component families to `components.html`. The audit picks them up automatically on the next run — no script change required. New banned-tag patterns (e.g., `<form>` for the technical-brief format if Phase 3 decides forms are out of scope) can be added by appending one `command grep -nEi` line to Rule 3. The script is structured so each rule is independently editable.

**Open follow-up for Phase 3:** if the presentation format uses `scroll-snap` (Phase 3 spike), the inlined CSS may include `scroll-snap-type:` declarations. These are NOT hex literals and NOT classes; the audit doesn't care. But if Phase 3 needs to verify scroll-snap CSS landed, that's a NEW rule (Rule 5: presentation-specific), not a modification of Rule 1-4.

## Self-Check: PASSED

Verification of all claimed artifacts:

- `skill/audit/rules.md` — FOUND (135 lines, ≤150 cap, all 4 rules + non-goals + retry contract).
- `skill/audit/run.sh` — FOUND (140 lines, executable 0755, `bash -n` valid, all 4 rules implemented).
- `.github/workflows/shellcheck.yml` — FOUND (2 shellcheck steps: `./bin` + `./skill/audit`, both `ludeeus/action-shellcheck@2.0.0`, both `severity: warning`).
- Commit `5bbbbcf` — FOUND (`docs(02-03): add skill/audit/rules.md — human-readable rule reference`).
- Commit `994bf4e` — FOUND (`feat(02-03): add skill/audit/run.sh — post-generation audit script`).
- Commit `6a40136` — FOUND (`chore(02-03): extend shellcheck workflow to lint skill/audit/`).
- Plan automated gate (Task 1, rules.md): all required strings + ≤150 lines — ALL PASS.
- Plan automated gate (Task 2, run.sh): static checks (no Bash-4 features, all `command grep`/`command sed`, all 4 rules) + 5 smoke tests (clean → 0; hex/class/script/link → non-zero) — ALL PASS.
- Plan automated gate (Task 3, workflow): both scandir steps + same action version + severity warning + push/pr triggers — ALL PASS.

---
*Phase: 02-story-arc-gate-handbook-end-to-end*
*Completed: 2026-04-27*
