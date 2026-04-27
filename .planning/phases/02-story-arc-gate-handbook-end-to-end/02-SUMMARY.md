---
phase: 02-story-arc-gate-handbook-end-to-end
status: COMPLETE
completed: 2026-04-28
plans:
  - 02-01-SUMMARY.md  # components.css extraction
  - 02-02-SUMMARY.md  # SKILL.md flow + story-arc + handbook interview
  - 02-03-SUMMARY.md  # post-generation audit
  - 02-04-SUMMARY.md  # visual-gate fixture + end-to-end validation
plans_complete: 4
plans_total: 4
commits: 13
duration: ~3h aggregate
requirements_closed:
  - SKILL-01
  - SKILL-03
  - SKILL-04
  - SKILL-05
  - ARC-01
  - ARC-02
  - ARC-03
  - ARC-04
  - ARC-05
  - DOC-02
  - DOC-07
  - DESIGN-06
  - OUTPUT-01
  - OUTPUT-02
  - OUTPUT-03
  - OUTPUT-04
  - OUTPUT-05
---

# Phase 2: Story-Arc Gate + Handbook End-to-End — Phase Summary

**Phase 2 closes with a working `/deshtml` skill that takes a user from `/deshtml` to a Caseproof-faithful single-file HTML handbook, gates HTML generation behind a mandatory story-arc approval, and rejects design-system drift mechanically via a post-generation audit. The canonical `deshtml-about-itself` fixture ran end-to-end and visually matched `pm-system.html` at every structural layer.**

## What ships

The skill payload at `skill/` is now complete for the handbook doc type:

```
skill/
├── SKILL.md                          (171 lines, 8-step flow controller)
├── story-arc.md                      (151 lines, arc rubric + 9-phrase whitelist)
├── interview/
│   └── handbook.md                   (45 lines, DOC-06 schema, 5 questions)
├── audit/
│   ├── run.sh                        (140 lines, executable, 4 mechanical rules)
│   └── rules.md                      (135 lines, human-readable reference)
└── design/
    ├── palette.css                   (extended in 02-01: --sb-* + *-d tokens)
    ├── typography.css                (Phase 1)
    ├── components.css                (694 lines, extracted in 02-01)
    ├── components.html               (Phase 1, markup allowlist source)
    ├── SYSTEM.md                     (Phase 1, three-file inlining contract)
    └── formats/
        └── handbook.html             (Phase 1, 960px sidebar skeleton)
```

The fixture artifacts at `.planning/phases/02-story-arc-gate-handbook-end-to-end/fixture/` make Phase 2 reproducible:

```
fixture/
├── interview-answers.md              (canonical Q1-Q6 inputs + approve)
├── expected-arc.md                   (6-8-row shape + flowing-paragraph diagnostic)
└── FIXTURE-NOTES.md                  (empirical run record)
```

## The four plans

### Plan 02-01 — components.css extraction (2 commits)

See: `02-01-SUMMARY.md`.

Extracted `skill/design/components.css` (694 lines) verbatim from `pm-system.reference.html` lines 7-697 minus three de-duplication deletions. Sixteen color literals were tokenized; palette.css was extended with the upstream-documented sidebar sub-palette (`--sb-hover`, `--sb-group`, `--sb-nav`, `--sb-nav-hover`) and darker accent variants (`--blue-d`, `--green-d`, `--red-d`, `--orange-d`, `--purple-d`, `--teal-d`). SYSTEM.md Rule 6 was rewritten to lock the three-file inlining order: palette → typography → components.

Closed: DESIGN-06 (in part — audit rule depends on this file).

### Plan 02-02 — SKILL.md flow + story-arc + handbook interview (3 commits)

See: `02-02-SUMMARY.md`.

Three new files:
- `skill/SKILL.md` (171 lines, ≤200 cap) — the 8-step flow controller. Mode detection at turn 1 (regex `(^|[[:space:]])@\S+` for source mode + >200-char prose threshold + empty-string interview-mode default). Doc-type branch enumerates all 5 types (handbook implemented; pitch/technical-brief/presentation/meeting-prep stubbed with "coming in Phase 3"). Three-CSS-file inlining at Step 6. Audit invocation at Step 7. `open` + path-print at Step 8.
- `skill/story-arc.md` (151 lines) — arc table rubric + flowing-paragraph diagnostic + 5 verbatim BAD→GOOD pairs from `/Users/sperezasis/CLAUDE.md` + 9-phrase approval whitelist (D2-12) + 3 self-review checks (tone, chain, named) + revision loop.
- `skill/interview/handbook.md` (45 lines, ≤80 cap) — 5 questions in DOC-06 schema order with empty-default fallbacks.

Closed: SKILL-01, SKILL-03, SKILL-04, SKILL-05, ARC-01, ARC-02, ARC-03, ARC-04, ARC-05, DOC-02, DOC-07, OUTPUT-01, OUTPUT-02, OUTPUT-03, OUTPUT-04 (mechanical wiring; OUTPUT-05 empirically verified by 02-04).

### Plan 02-03 — post-generation audit (3 commits)

See: `02-03-SUMMARY.md`.

`skill/audit/run.sh` (140 lines, executable, bash 3.2 / BSD-safe) implements four mechanical gates:

1. Hex literals outside `:root` (two-pass strip handles inline + multi-line `:root` shapes).
2. Class allowlist (live harvest from components.html + typography.css; expanded in 02-04 to also include components.css selectors + handbook.html skeleton classes).
3. Banned tags (`<script>`, `<iframe>`, `<object>`, `<embed>`) + inline event handlers + `javascript:` URLs (scoped to URL attribute contexts in 02-04).
4. Leftover `<link rel="stylesheet">` tags.

`skill/audit/rules.md` (135 lines) is the human-readable rule reference. `.github/workflows/shellcheck.yml` extended with a second step linting `./skill/audit`.

Closed: DESIGN-06 (mechanical implementation).

### Plan 02-04 — visual-gate fixture + end-to-end validation (3 commits)

See: `02-04-SUMMARY.md`.

Three fixture artifacts committed (interview-answers.md, expected-arc.md, FIXTURE-NOTES.md). The canonical handbook ran end-to-end:

- Output: `/tmp/deshtml-fixture/2026-04-28-deshtml-handbook.html` — 1023 lines, 45,835 bytes.
- Audit exit: 0 (after the 02-04 harvester+`javascript:` fix).
- Visual gate: APPROVED via `qlmanage -t -s 1400` thumbnail comparison against `pm-system.html`. Match on palette, Inter font, H1 56px / 800 / -2.5px tracking, H2 36px / 800, 220px black sidebar, blue eyebrow, gray body, `--hl-b` highlight box. Acceptable diffs are content-only.

Closed: OUTPUT-05 empirically verified.

## Total work

| Metric | Count |
|--------|-------|
| Plans completed | 4 of 4 |
| Per-task commits | 11 (`d7a85e4`, `6d0c3f2`, `5bbbbcf`, `994bf4e`, `6a40136`, `721d4cc`, `de61e51`, `ae4ff61`, `5c1f375`, `8281c04`, `97bbdde`) |
| Final-docs commit | 1 (this commit) |
| Files created | 9 (components.css, SKILL.md, story-arc.md, interview/handbook.md, audit/run.sh, audit/rules.md, fixture/interview-answers.md, fixture/expected-arc.md, fixture/FIXTURE-NOTES.md) |
| Files modified | 4 (palette.css, SYSTEM.md, .github/workflows/shellcheck.yml, audit/run.sh from 02-04 fix) |
| Requirements closed | 17 |
| Aggregate duration | ~3h across two sessions (2026-04-27, 2026-04-28) |

## Cross-plan deviation: audit-harvester completeness

The most important deviation surfaced across plan boundaries: plan 02-03 sized the audit's class-allowlist around components.html + typography.css. When plan 02-04 ran the fixture, the real generated handbook used many classes from components.css (the bulk of the design system, shipped by 02-01) and from the skeleton's inline `<style>` (handbook.html). 19 false-positive class violations blocked the round-1 audit.

Plan 02-04 fixed this in `8281c04` by extending the harvester to read components.css selectors + handbook.html skeleton classes. Allowlist grew from ~28 to ~140 classes. All 5 original 02-03 smoke tests still pass; new precision checks added for the URL-context-scoped `javascript:` rule.

This is the canonical example of **why the visual-gate fixture exists**: it's the only plan that exercises the full skill end-to-end with real generated output, so it's the only place where allowlist-completeness gaps can surface.

## Phase 2 ROADMAP success criteria — all closed

| # | Criterion | Closed by |
|---|-----------|-----------|
| 1 | Interview launches on no-args, doc type first, ≤5 questions for handbook | 02-02 (mechanical), 02-04 (empirical) |
| 2 | Arc table 5-column + flowing paragraph + approval gate | 02-02 (mechanical), 02-04 (empirical) |
| 3 | Revision loop on arc | 02-02 (mechanical) |
| 4 | Filename pattern + open + path-print + file:// works | 02-02 (mechanical), 02-04 (empirical) |
| 5 | Audit rejects violations confirmed by side-by-side compare | 02-03 (mechanical), 02-04 (empirical + harvester fix) |
| 6 | SKILL.md ≤200 lines, lazy-loads sub-files | 02-02 (mechanical), 02-04 (empirical) |

## What Phase 3 inherits

1. **SKILL.md flow is proven.** Phase 3 only needs to flip the 4 `Phase-3 stubs` in SKILL.md Step 2 from "coming in Phase 3" to real routes into `interview/<type>.md`, and ship those interview files following the DOC-06 schema. The structure is locked.
2. **Audit auto-grows.** New component families added to components.html or components.css are picked up by the next audit run. No script change needed for new classes — only for genuinely new patterns (e.g., scroll-snap rules for presentation).
3. **Reproducible-fixture pattern.** Phase 3's per-type fixtures should follow the 02-04 layout: `interview-answers.md` (inputs) + `expected-arc.md` (shape) + `FIXTURE-NOTES.md` (empirical record). Future regressions replay deterministically.
4. **`cp -R` local-install shortcut.** Bypasses `bin/install.sh` (which requires a tagged release). Phase 3 fixtures use it; Phase 4 LAUNCH-01 still re-tests the curl-pipe-bash flow against the live URL.
5. **Visual-diff target pattern.** Compare each generated doc type against its Caseproof reference. Handbook → `pm-system.html` (proven). Pitch/meeting-prep → `bnp-overview.html` (Overview format). Presentation → no reference yet — Phase 3 spike (per ROADMAP) creates one.

## What Phase 4 must still verify

- Curl-pipe-bash installer against the LIVE URL on a fresh machine (LAUNCH-01).
- iOS Safari forced-dark-mode on the GENERATED handbook (deferred from 02-04; structurally hardened, empirical re-test in LAUNCH-02 alongside the other 4 doc types).
- Filename collision branch and audit retry loop (mechanically implemented; observation-pending).
- Cross-machine reproducibility — re-clone the repo, re-install via curl-pipe-bash, re-run the fixture, confirm output matches.

## Self-Check: PASSED

All four per-plan SUMMARY files exist:

- `02-01-SUMMARY.md` — FOUND.
- `02-02-SUMMARY.md` — FOUND.
- `02-03-SUMMARY.md` — FOUND.
- `02-04-SUMMARY.md` — FOUND.

All 11 per-task commits present in `git log` on `phase-02-story-arc-handbook`. Visual-gate fixture artifacts exist at `.planning/phases/02-story-arc-gate-handbook-end-to-end/fixture/`. SKILL.md at 171 lines. Audit script executable. components.css 694 lines, zero hex outside `:root`. Allowlist harvest expanded post-fixture. Phase 2 contract holds end-to-end.

---
*Phase 2 of 4 complete. Phase 3 (Remaining Four Doc Types) unblocked.*
