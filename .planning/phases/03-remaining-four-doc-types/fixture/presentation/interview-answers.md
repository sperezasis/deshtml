# Fixture: presentation — interview answers

Reproducible inputs for the Phase 3 presentation fixture run (D3-20 + RESEARCH OQ-3).

Subject: "Phase 3 status update — deshtml." Audience: Caseproof team in
a recurring product-update meeting. Format: Presentation (always — D3-01
forces format=presentation when type=presentation). Slide count: 5.

## Pre-run

Same as pitch fixture. PLUS: confirm `~/.claude/skills/deshtml/design/formats/presentation.html`
exists (plan 03-01 output) — without it, Step 6's variable skeleton load fails.

## Invocation

```
/deshtml
```

## Q1 — Document type

> presentation

## Q2 — Audience

> Caseproof product team in a regular Tuesday product-update meeting. They've heard "deshtml" before but haven't seen what Phase 3 ships.

## Q3 — The takeaway

> Phase 3 ships all five doc types end-to-end; v0.1.0 is on the runway after Phase 4 README + launch hardening.

## Q4 — Slide outline

> Let Claude propose 5 slides. Suggested order: (1) status header, (2) what shipped in Phase 3, (3) the audit story, (4) what's next in Phase 4, (5) ask + close.

## Q5 — Tone

> (default — handbook tone in titles, more energetic in body per pitch.md / presentation.md Pattern 8 calibration)

## Q6 — Inclusions / exclusions

> Include: the slide counter visible on every slide. Include: the GSD-style install one-liner on the "what shipped" slide. Avoid: speaker notes (out-of-scope for v1 per CONTEXT.md "Deferred Ideas").

## After Q6 — Approval

Skill prints `Format: presentation` (forced by type=presentation per D3-01). Verifier compares arc against `expected-arc.md`. If acceptable:

> approve

Verifier expects: `2026-04-28-phase-3-status-update-presentation.html`, audit exit 0 (Rule 5 schema check passes too — presentation.md follows DOC-06), default browser opens, scroll-snap works on first slide.
