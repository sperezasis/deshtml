# Fixture: pitch — interview answers

Reproducible inputs for the Phase 3 pitch fixture run (D3-20).
The human verifier in plan 03-04 pastes these answers, in order, into the
running `/deshtml` interview AFTER picking `pitch` as the doc type.

Subject: "Pitching deshtml to a small-team CTO." Audience: a technical
decision-maker (CTO of a 5-15-person product team). Ask: greenlight to
build deshtml-equivalent tooling internally, OR pilot deshtml directly.
Expected format: Overview (1-3 sections per D3-01 mapping).

## Pre-run

Verifier confirms:
1. `~/.claude/skills/deshtml/SKILL.md` exists and includes Step 5b (plan 03-01).
2. `~/.claude/skills/deshtml/interview/pitch.md` exists (plan 03-02).
3. Working directory is OUTSIDE the deshtml repo (recommended: `~/Desktop/` or `/tmp/deshtml-fixture/`).
4. Claude Code session is fresh.

## Invocation

```
/deshtml
```

## Q1 — Document type

> pitch

Expected: Step 3 reads `interview/pitch.md` (per plan 03-01's Step 3 substitution).

## Q2 — Audience

> A small-team CTO (5-15 engineers). Mid-tenure, ships their own internal tooling. Hasn't seen deshtml; has seen one of my Caseproof handbooks before.

## Q3 — The ask

> Greenlight to either pilot deshtml on our team for one quarter, or fund building an equivalent in our stack.

## Q4 — The problem

> Our team's docs read like docs because no one has the time to make them read like products. Designed write-ups exist for big launches, never for everything else.

## Q5 — Your solution

> deshtml is a Claude Code skill that turns ideas into Caseproof-designed HTML in one command. Story-arc gate keeps the writing tight. No design knowledge required.

## Q6 — Inclusions / exclusions

> Include: the install one-liner. Avoid: any "10x productivity" or "revolutionary" framing — the audience reads pitch decks all day; that vocabulary triggers eyerolls.

## After Q6 — Approval

Skill prints `Format: overview` (3 sections expected → matches D3-01 rule). Verifier compares arc against `expected-arc.md`. If acceptable:

> approve

Verifier expects the skill to:
1. Compute filename: `2026-04-28-pitching-deshtml-pitch.html` (or with `-2` suffix on collision).
2. Render with palette + typography + components inlined; format = overview (1440px linear, no sidebar).
3. Run `audit/run.sh` (exit 0 expected).
4. Run `open` on the absolute path.
5. Print the absolute path on its own line as the LAST output.
