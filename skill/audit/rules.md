# Post-generation audit — rules

`skill/audit/run.sh` is the post-generation audit. SKILL.md invokes it after
Write and before `open`. Exit 0 = pass; non-zero = list of violations on stderr.

This file describes what the script checks, in script-execution order. It is a
maintainer reference, NOT a runtime input — SKILL.md never reads this file.

## Why these rules

- **Mechanical, not heuristic.** Every rule is a grep or a set difference. No
  LLM judgment at the audit boundary. The mechanical gate is the moat
  (PITFALLS Pitfall 10 — same logic that makes the arc-gate exact-match).
- **Single source of truth.** Class allowlist is harvested LIVE from
  `skill/design/components.html` (markup) and `skill/design/typography.css`
  (type-scale labels). No separate list to maintain.
- **Extensible.** Phase 3 may add new component families; the harvest picks
  them up automatically the moment they land in `components.html`.

## Rule 1 — Hex literals outside `:root`

**What it catches:** Any `#XXXXXX` (3-8 hex digits) literal that appears
outside the `:root { ... }` block in any `<style>` tag, OR in any `style="..."`
inline attribute, OR in HTML body text outside comments.

**Why:** DESIGN-01 mandates colors come from CSS variables only. A stray
hex literal means a generator bypassed `var(--token)` and risks drift
from the Caseproof palette. PITFALLS Pitfall 4.

**Implementation:** `command sed -E '/:root[[:space:]]*\{/,/^[[:space:]]*\}/d'`
strips the `:root` block; `command grep -nE '#[0-9a-fA-F]{3,8}\b'` greps
the remainder.

**Known false positives (acceptable for V1):** Hex literals inside HTML
comments (e.g., `<!-- this color was #FFFFFF -->`). The alternative is a
full HTML parse; not worth the complexity.

**Example violation:** `<div style="color: #ff0000;">` → flagged.
**Example clean:** `<div style="color: var(--red);">` → passes.

## Rule 2 — Class allowlist (harvested live)

**What it catches:** Any class name in a `class="..."` attribute that does
NOT appear in the union of:
1. Classes enumerated in `skill/design/components.html` (markup allowlist).
2. Type-scale class selectors defined in `skill/design/typography.css`
   (`.s-lead`, `.eye`, `.cl`, `.fl`, `.ct`, `.cd`, `.ic`, `.fn`).

**Why:** DESIGN-03 mandates the closed component library — no freelance
markup. Adding `class="custom-banner"` because a generated section
"needed it" is exactly the design-drift PITFALLS Pitfall 4 warns about.

**Implementation:** harvest with `command grep -oE 'class="[^"]+"'` over
the two source files, sed off the `class="..."` quoting, split multi-class
attributes on whitespace, sort -u into a temp allowlist file. Then
`command grep -oE 'class="[^"]+"'` over the audit target, same split, and
check each used class against the allowlist via `command grep -qxF`.

**Why not maintain a JSON allowlist file:** Two sources of truth = drift.
The harvest is fast (< 50ms on the current 75-class allowlist) and the
only "maintenance" needed is adding new components to `components.html`.

**Example violation:** `<div class="custom-banner">` → flagged.
**Example clean:** `<div class="hl hl-b">` → passes (both `.hl` and `.hl-b` are in `components.html`).

## Rule 3 — Banned tags and attributes

**What it catches:**
- `<script>`, `<iframe>`, `<object>`, `<embed>` tags (case-insensitive).
- Inline event handlers: `on*=` attributes (`onclick`, `onload`, `onerror`, etc.).
- `javascript:` URLs anywhere in the document.

**Why:** D-17 from Phase 1 (no JS in output, ever) plus PROJECT.md "no
external JS dependencies" plus security: the output is shareable; a
`<script>` tag in a Caseproof handbook is a content-injection vector.

**Implementation:**
- `command grep -nEi '<(script|iframe|object|embed)\b'`
- `command grep -nEi ' on[a-z]+[[:space:]]*='`
- `command grep -nEi 'javascript:'`

Each grep that finds a match flags a violation.

**Example violation:** `<script>alert(1)</script>` → flagged.
**Example violation:** `<a href="javascript:void(0)">` → flagged.
**Example violation:** `<button onclick="...">` → flagged.

## Rule 4 — No leftover `<link rel="stylesheet">`

**What it catches:** Any `<link rel="stylesheet" ...>` tag in the output.

**Why:** OUTPUT-05 mandates the file open correctly via `file://` —
no asset folders, no external CSS. The format skeletons reference
`<link rel="stylesheet" href="../palette.css">` and
`<link rel="stylesheet" href="../typography.css">` for dev-time use only;
SKILL.md Step 6 inlines those CSS files into a `<style>` block and
deletes the `<link>` tags. If a `<link rel="stylesheet">` survives,
the inlining failed and the output won't render correctly off the
skill author's machine. Phase 1 review IN-01 caught this; D2-15 closes it.

**Implementation:** `command grep -nE '<link[[:space:]]+rel="stylesheet"'`.

## --explain flag

`bash skill/audit/run.sh --explain <output.html>` prints WHY each violation
was flagged, with file/line context. SKILL.md never invokes this flag; it's
for maintainers iterating on the audit rules themselves.

The flag does NOT change exit-code semantics — only output verbosity.
Exit 0 still means clean; non-zero still means violations found.

## Audit retry contract (with SKILL.md)

SKILL.md Step 7 implements the retry loop. The audit script itself is
stateless — it just reports. The contract:

- Exit 0 → SKILL.md proceeds to `open` (Step 8).
- Non-zero, retry round ≤ 2 → SKILL.md regenerates the HTML addressing
  each violation, re-runs the audit. Maximum 2 retry rounds.
- Non-zero, retry round 3 → SKILL.md keeps the file, prints the verbatim
  violation list to the user, then proceeds to `open` anyway. The file
  is never silently delivered with violations — failure is loud.

## What this audit does NOT do (non-goals)

- **Does not check provenance.** A user can hand-edit a generated handbook
  to fix violations. The audit only checks content. (Pitfall 16 — flagged
  to V2 backlog.)
- **Does not auto-fix.** V1 only flags. SKILL.md regenerates. V2 may add
  auto-fix mode (deferred per CONTEXT.md §"Deferred Ideas").
- **Does not enforce semantic structure.** The audit doesn't care whether
  the document has a `<main>` tag or whether sections are nested correctly.
  That's the format-skeleton's job (Phase 1 + plan 02-01).
- **Does not lint CSS.** Three `<style>` blocks instead of one is fine;
  the audit checks rules, not aesthetics.
