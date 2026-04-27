# Fixture: deshtml-about-itself handbook — interview answers

Reproducible inputs for the Phase 2 visual-gate fixture run (D2-24).
The human verifier in plan 02-04 pastes these answers, in order, into
the running `/deshtml` interview.

## Pre-run

Before invoking the skill, the human verifier confirms:
1. `~/.claude/skills/deshtml/` exists (skill is installed locally for the verification — see "Local install" below).
2. Working directory is somewhere OUTSIDE the deshtml repo (recommended: `~/Desktop/` or `/tmp/deshtml-fixture/`) so the generated HTML doesn't accidentally get committed.
3. Claude Code session is fresh (no prior `/deshtml` history in the conversation).

## Local install (run before the fixture)

Plan 02-04 Task 1 stages the working copy of `skill/` at `~/.claude/skills/deshtml/`:

```bash
mkdir -p "$HOME/.claude/skills"
rm -rf "$HOME/.claude/skills/deshtml"
cp -R "/Users/sperezasis/projects/code/deshtml/skill" "$HOME/.claude/skills/deshtml"
```

This bypasses `bin/install.sh` (which requires a tagged release that does not yet
exist — that's Phase 4 LAUNCH-03's job). Phase 4 LAUNCH-01 will validate the
curl-pipe-bash flow against the live URL; Phase 2 only needs the payload installed
locally so `/deshtml` resolves.

## Invocation

```
/deshtml
```

(No arguments — interview mode.)

## Q1 — Document type

> handbook

Expected: skill proceeds to Step 3 (interview).

## Q2 — Audience

> Someone installing deshtml for the first time. They've heard of Claude Code but haven't used skills before.

## Q3 — Material

> deshtml — a Claude Code skill that turns ideas into beautifully designed HTML documents following the Caseproof Documentation System and the Story-First methodology.

## Q4 — Sections

> Let Claude propose. Suggested beats if useful: What it is → How it's installed → How a run works → The story-arc gate → The design system → What ships in v1 → Known limitations.

## Q5 — Tone notes

> Handbook, not pitch. Describe what IS.

## Q6 — Inclusions / exclusions

> Include: the install one-liner verbatim. Include: the 5 doc types. Avoid: any "why this is great" marketing copy.

## After Q6 — Approval

Skill proposes the arc. Verifier compares against `expected-arc.md`. If acceptable:

> approve

Verifier expects the skill to:
1. Compute filename: `2026-04-28-deshtml-handbook.html` (or with `-2`/`-3` suffix if a collision exists).
2. Render the HTML with palette + typography + components inlined.
3. Run `audit/run.sh` (exit 0 expected).
4. Run `open` on the absolute path.
5. Print the absolute path on its own line as the LAST output.
