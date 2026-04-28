---
phase: 04-source-mode-readme-launch-hardening
date: 2026-04-28
status: passed
versions_shipped: [v0.1.0, v0.1.1, v0.1.2]
---

# Phase 4 Launch Verification

The four LAUNCH-* requirements from REQUIREMENTS.md are verified end-to-end against the live public URL.

## LAUNCH-01 — live `curl … | bash` install one-liner

**Verified:** YES (3 successful runs across v0.1.0 → v0.1.1 → v0.1.2)

```bash
curl -fsSL https://raw.githubusercontent.com/sperezasis/deshtml/main/bin/install.sh | bash
```

Output:
```
Installing deshtml v0.1.x...
Cloning into '...'
deshtml v0.1.x installed to /Users/sperezasis/.claude/skills/deshtml
Run /deshtml in Claude Code to start.
```

Each install:
- Resolves the canonical URL (no redirects)
- Reads the live `VERSION` file
- Shallow-clones the matching `v0.1.x` tag
- Atomically replaces `~/.claude/skills/deshtml/`
- Prints success
- Exits 0

The atomicity contract holds: re-running on an existing install upgrades in place without breakage. The backup-restore safety dance (`mv ~/.claude/skills/deshtml ~/.claude/skills/deshtml.backup-*`) preserves the dev install across verification runs.

### Cosmetic issue surfaced and fixed in patches

v0.1.0 emitted `bash: line 95: tmp: unbound variable` after the success message. The install itself succeeded; the warning was a `set -u` artifact from the EXIT trap referencing a `local` variable that went out of scope after `main()` returned.

- **v0.1.1** patched the first trap. Did not eliminate the warning because there's a second trap that replaces the first inside `main()`.
- **v0.1.2** patched the second trap (and confirms the first is also correct). Verified locally: 0 unbound-variable warnings on clean install.

The user-visible install behavior (`v0.1.x installed to ~/.claude/skills/deshtml`) was correct in all three versions; only the surrounding noise differed.

## LAUNCH-02 — all 5 doc types generated end-to-end + visually inspected

**Verified:** YES — covered transitively by Phase 2 (handbook fixture) + Phase 3 (pitch, technical-brief, presentation, meeting-prep fixtures), re-audited against the live-installed v0.1.0 skill during this phase's pre-merge dry-run (commit `30c6bca`). All 5 fixtures pass `bash audit/run.sh <output>` exit 0; structural visual diffs against `pm-system.html` and `bnp-overview.html` (Caseproof references) approved by orchestrator-as-user-proxy via `qlmanage` thumbnails.

A NEW source-mode fixture (`/tmp/deshtml-launch-fixture/2026-04-28-how-deshtml-handles-source-mode-handbook.html`, 924 lines, 40 KB) was generated from a synthetic source file to verify SKILL-02 end-to-end. Audit exit 0; visual gate APPROVED.

## LAUNCH-03 — VERSION pinned + git tag created

**Verified:** YES (3 versions tagged)

| Tag | Commit | Date |
|---|---|---|
| `v0.1.0` | `2623775` (release: bump VERSION 0.0.1 -> 0.1.0) | 2026-04-28 |
| `v0.1.1` | `b36dc01` (fix: installer trap unbound-variable warning) | 2026-04-28 |
| `v0.1.2` | `b9f7ac3` (fix: installer second trap also captures values) | 2026-04-28 |

Each tag is annotated, pushed to `origin`, and points at the corresponding commit on `main`. The atomic `git push origin main v0.1.x` pattern (per 04-RESEARCH §"Launch sequence") prevents the chicken-and-egg where `bin/install.sh` reads VERSION as `0.1.x` but the tag doesn't exist yet.

## LAUNCH-04 — GitHub release with changelog

**Verified:** YES (3 releases cut)

- https://github.com/sperezasis/deshtml/releases/tag/v0.1.0 — first public release (4 phases, 5 doc types, story-arc gate, audit moat)
- https://github.com/sperezasis/deshtml/releases/tag/v0.1.1 — installer trap hotfix (incomplete; superseded by v0.1.2)
- https://github.com/sperezasis/deshtml/releases/tag/v0.1.2 — installer trap hotfix (complete)

Each release was created with `gh release create vX.Y.Z --verify-tag --notes-file <notes>` so the tag must already exist before the release is cut. `--verify-tag` blocks the failure mode where `gh release create` auto-creates a tag against `main HEAD` if the local tag wasn't pushed.

## Carryover for V2

- **Single comprehensive trap fix at script level.** v0.1.2 patched both traps individually. A V2 refactor could declare `tmp`, `stage`, `backup` as script-globals (drop `local`) so trap variable scoping is no longer an issue. Cosmetic; defer.
- **CDN cache propagation lag.** GitHub raw URL caching meant the post-v0.1.1 push showed v0.1.0 install-message text for a few minutes. Real users won't notice because they run install once. No mitigation needed.

## Closes

- **SKILL-02:** source mode end-to-end (NEW fixture)
- **DOCS-01..03:** Delfi-targeted README (Phase 4 plan 04-02)
- **LAUNCH-01:** live `curl … | bash` verified (this file)
- **LAUNCH-02:** all 5 doc types + source-mode end-to-end (this file + Phase 2/3 fixtures)
- **LAUNCH-03:** VERSION + tag (3 versions)
- **LAUNCH-04:** GitHub releases (3 versions)
