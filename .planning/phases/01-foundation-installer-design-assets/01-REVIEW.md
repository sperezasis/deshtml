---
phase: 01-foundation-installer-design-assets
reviewed: 2026-04-27T15:00:09Z
depth: standard
files_reviewed: 11
files_reviewed_list:
  - bin/install.sh
  - bin/uninstall.sh
  - VERSION
  - LICENSE
  - README.md
  - .github/workflows/shellcheck.yml
  - skill/design/palette.css
  - skill/design/typography.css
  - skill/design/components.html
  - skill/design/SYSTEM.md
  - skill/design/formats/handbook.html
  - skill/design/formats/overview.html
findings:
  critical: 0
  high: 0
  medium: 3
  low: 2
  info: 2
  total: 7
status: issues
---

# Phase 1: Code Review Report

**Reviewed:** 2026-04-27T15:00:09Z
**Depth:** standard
**Files Reviewed:** 12 (11 source + 12th `formats/overview.html` counted in list)
**Status:** issues_found (3 medium, 2 low, 2 info — no critical/high)

## Summary

The installer (`bin/install.sh`) implements the `main()` wrapper, root refusal, temp-dir staging, atomic swap, and rollback contract laid out in `01-CONTEXT.md` (D-01..D-10) faithfully. `bash -n` passes; D-04 truncation safety is real; no `read`, no Bash 4 features, no `sudo`, no third-party hosts. The uninstaller, VERSION, LICENSE, README, and shellcheck workflow are all correctly shaped.

Three medium-priority issues are worth fixing before the installer ever sees a real release:

1. The atomic-swap section (lines 48–58 of `install.sh`) is **not fully signal-safe**. The `trap` only cleans `$tmp` — if the script is killed between `mv "$DEST" "$backup"` and `mv "$stage" "$DEST"`, the destination is gone, the backup is orphaned, and rerunning the installer still works (it falls into the no-existing-install branch) but the user has a stale `deshtml.old.<pid>` directory. The rollback path only fires on `mv` non-zero exit, not on signal interruption.
2. `git clone ... >/dev/null 2>&1` swallows stderr, so a failed install gives users zero diagnostic context — they only see "Failed to clone v0.0.1" with no reason (network? bad tag? auth?).
3. `skill/design/formats/handbook.html` line 20 contains a hex literal (`#c7c7cc`) inside the skeleton's inline `<style>`. Per `01-CONTEXT.md` D-15 / DESIGN-01, hex literals are only allowed inside `palette.css`; this exact value already exists there as `--g4`. Phase 2's documented audit pass will flag this.

The verbatim design extraction (palette, typography, components, references, SYSTEM.md, both format skeletons) is structurally sound. No HTML syntax errors, no missing meta tags, no `<script>` tags (D-17 honored), both skeletons declare `color-scheme: light` plus the matching meta tags (D-16 honored). Per phase guidance, design choices were not flagged.

---

## Medium

### MD-01: Atomic-swap window leaks orphan directories on signal interruption

**File:** `bin/install.sh:48-61`
**Issue:** The script's `trap 'rm -rf "$tmp"' EXIT` only cleans the `mktemp -d` staging directory. The atomic-swap block creates two more sibling directories (`${DEST}.installing.$$` at line 44 and `${DEST}.old.$$` at line 49) that the trap does not know about. The rollback at line 55 only runs if `mv` itself returns non-zero — a `SIGINT`, `SIGTERM`, or `SIGKILL` arriving between line 50 (`mv "$DEST" "$backup"`) and line 51 (`mv "$stage" "$DEST"`) leaves the user with no `~/.claude/skills/deshtml/` directory plus orphan `deshtml.installing.<pid>` and `deshtml.old.<pid>` siblings. Rerunning the installer recovers (the new clone takes the empty branch on line 59), but the orphans persist forever and the original install is silently lost.

`curl | bash` mostly hides Ctrl-C from the script, but `kill <pid>` from another shell, an OOM kill, or a closed terminal still produces the gap. Threat-model entry T-01-02 claims "writes go to `mktemp -d` first; the existing `~/.claude/skills/deshtml/` is only swapped at the end via `mv`, with rollback if swap fails" — this is true for non-zero `mv` exit but not for signal interruption.

**Fix:** Extend the trap to clean both stage and backup paths if they exist, and have it restore from backup if the destination is missing:

```bash
# Right after computing $stage and $backup:
trap '
  rm -rf "$tmp" "$stage" 2>/dev/null
  if [ -d "${DEST}.old.$$" ] && [ ! -d "$DEST" ]; then
    mv "${DEST}.old.$$" "$DEST"
  fi
  rm -rf "${DEST}.old.$$" 2>/dev/null
' EXIT
```

Place the extended trap registration after `local stage=...` / `local backup=...` are computed so the names are in scope. Keep the original `trap 'rm -rf "$tmp"' EXIT` until that point so the early-exit paths (failed curl, failed clone) are still covered.

### MD-02: Silenced `git clone` stderr hides root cause from the user

**File:** `bin/install.sh:32-35`
**Issue:** `git clone --depth 1 --branch "v${version}" "$REPO_URL" "$tmp/deshtml" >/dev/null 2>&1 || { echo "Failed to clone deshtml v${version} from $REPO_URL" >&2; exit 1; }` swallows both stdout and stderr. When the install fails — bad network, missing tag (which will happen often given D-02's "release = bump VERSION + push tag" model has a window where VERSION is bumped before the tag exists), DNS issue, GitHub outage — the user is told only "Failed to clone deshtml v0.0.1 from https://...". They cannot self-diagnose, cannot file a useful issue, cannot tell whether to retry or to wait. This worsens the public-install UX exactly when it matters most.

**Fix:** Redirect only stdout, let git's diagnostic stderr through:

```bash
echo "Installing deshtml v${version}..."
if ! git clone --depth 1 --branch "v${version}" "$REPO_URL" "$tmp/deshtml" >/dev/null; then
  echo "Failed to clone deshtml v${version} from $REPO_URL" >&2
  echo "See git output above for the cause." >&2
  exit 1
fi
```

shellcheck is happy with both forms.

### MD-03: Hex literal in `handbook.html` skeleton violates the audit rule the skeleton itself documents

**File:** `skill/design/formats/handbook.html:20`
**Issue:** `.sidebar { ... color: #c7c7cc; }`. Per `01-CONTEXT.md` D-15 and `SYSTEM.md` "Rules Phase 2 must respect": "Hex literals only inside `palette.css`. Generated HTML uses `var(--token-name)` everywhere else (DESIGN-01)." The value `#c7c7cc` is already defined in `palette.css` as `--g4: #C7C7CC` (case-insensitive match). When Phase 2's audit pass runs the documented regex check (DESIGN-06), this literal will fail the audit on the very skeleton that was supposed to be the paste source. Either Phase 2 will need a special-case carve-out for the skeletons (bad — undermines the audit), or this gets fixed now.

**Fix:** Replace the literal with the existing token:

```css
.sidebar {
  position: fixed; top: 0; left: 0;
  width: 220px; height: 100vh;
  background: var(--black);
  color: var(--g4);
}
```

Verify against `pm-system.reference.html` to confirm the source uses the same value. If the reference uses a different gray for sidebar text, use whichever existing token matches (`--g6` is `#98989D`, `--g4` is `#C7C7CC`).

---

## Low

### LO-01: VERSION content is interpolated into `git clone --branch` without format validation

**File:** `bin/install.sh:19-23, 32`
**Issue:** Line 19 reads `VERSION` from `main`, strips whitespace, and passes the result to `git clone --branch "v${version}"`. The empty-string check on line 20 catches a blank file, but a corrupted, comment-laden, or malformed VERSION (`0.0.1 # released today`, `v0.0.1`, multi-line) would still flow through. Because line 32 quotes `"v${version}"`, this is **not** a command-injection risk — git would just fail to find the tag. But the failure surfaces as the same vague "Failed to clone" message from MD-02, with no hint that the VERSION file itself is malformed.

**Fix:** Add a semver regex check after the whitespace strip:

```bash
version="$(curl -fsSL "$RAW_VERSION_URL" | tr -d '[:space:]')"
if [ -z "$version" ]; then
  echo "Could not fetch VERSION from $RAW_VERSION_URL" >&2
  exit 1
fi
if ! echo "$version" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
  echo "VERSION file content is not a valid semver: '$version'" >&2
  exit 1
fi
```

Mirrors the format already enforced on the local `VERSION` file by Plan 01-01's acceptance check.

### LO-02: `mkdir -p "$(dirname "$DEST")"` runs before the destructive `rm -rf "$stage"`

**File:** `bin/install.sh:43-46`
**Issue:** `rm -rf "$stage"` on line 45 is defensive against a leftover `${DEST}.installing.<pid>` from a previous interrupted run with the same PID. With `set -e` and `set -u`, this is safe — `$stage` is set on line 44 — but combined with the orphan-leak from MD-01, two installer runs that happen to share a PID could surprise each other. PID reuse on macOS is unlikely in practice (PIDs go up to ~99999 before wrapping) but not impossible across reboots. The risk is bounded (the user just loses a stale staging dir they did not know existed) but worth a note.

**Fix:** Use `mktemp -d` for the staging directory too, so each run gets a fresh unique name with no PID-collision surface:

```bash
local stage
stage="$(mktemp -d "${DEST}.installing.XXXXXX" 2>/dev/null || mktemp -d -t deshtml-stage)"
# Then cp -R into $stage instead of creating it implicitly via cp -R.
```

This also removes the need for the `rm -rf "$stage"` line entirely. Trade-off: MD-01's trap extension needs to track the new `$stage` path either way.

---

## Info

### IN-01: Format skeletons reference CSS via relative `<link>`, not inline `<style>`

**File:** `skill/design/formats/handbook.html:9-10`, `skill/design/formats/overview.html:9-10`
**Issue:** Both skeletons load `palette.css` and `typography.css` via `<link rel="stylesheet" href="../palette.css">`. The end-product (per PROJECT.md "Constraints" — "Inline CSS; ... no asset folders") must be a single self-contained HTML file. Phase 2 has the inlining responsibility per D-12 ("the planner's call" — at extraction time or at paste time, this plan chose paste time). That is fine, but a future Phase 2 plan must explicitly replace these `<link>` tags with `<style>...</style>` blocks; if it forgets, the generated `.html` opened from the user's working directory will have two broken stylesheet references and will render with browser-default fonts and no palette.

No fix required in Phase 1. Flagging as a hand-off contract that Phase 2's planner must read SYSTEM.md and these skeletons together. Recommend Phase 2's plan acceptance criterion include a grep that the generated output contains zero `<link rel="stylesheet"` tags.

### IN-02: `components.html` viewer-style `<style>` block is harmless dev-only chrome

**File:** `skill/design/components.html:10-17`
**Issue:** Lines 15–16 declare `body { padding: 40px; max-width: 960px; margin: 0 auto; }` and a `section` border. These rules are scoped to `components.html` only (the viewer page) and are never copied into generated output — Phase 2 reads markup from this file, not styling. No action needed; calling it out so a future reviewer does not flag it as a "non-token style".

**Decision (2026-04-27):** ACCEPTED AS-IS. The dev-only viewer chrome stays. Phase 2 reads markup from this file, never styling — the `body` and `section` rules cannot leak into generated output. A clarifying comment was added to the `<style>` block in `components.html` itself documenting this contract for future reviewers.

---

## Notes (out of review scope per phase guidance)

- **Reference HTMLs (`skill/design/references/*.reference.html`)** were treated as read-only ground truth per the phase prompt and not reviewed.
- **Design-system class names, palette values, type scale, layout choices** are locked upstream (D-13..D-16) and were not flagged.
- **Performance, alternative architectures, alternative installer patterns** are out of v1 scope.

---

_Reviewed: 2026-04-27T15:00:09Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
