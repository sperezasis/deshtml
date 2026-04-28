# Fixture: meeting-prep — interview answers

Reproducible inputs for the Phase 3 meeting-prep fixture run (D3-20).

Subject: "Demo run-through with Delfi." Audience: Delfi (target reader
per PROJECT.md). Format: Overview (3 sections per D3-01 mapping for
1-3-section docs). Sections: context, demo flow, anticipated questions.

## Pre-run

Same as pitch fixture.

## Invocation

```
/deshtml
```

## Q1 — Document type

> meeting prep

(User types `meeting prep` with a space; SKILL.md normalizes to `meeting-prep`.)

## Q2 — Meeting purpose

> Walk Delfi through deshtml end-to-end so she can run it herself by the end of the call.

## Q3 — Audience

> Delfi (technical-curious but non-developer). She's seen the install one-liner; hasn't used Claude Code skills before.

## Q4 — Talking points

> 1) What deshtml is in 30 seconds. 2) Install + first run together. 3) Pick a doc type, run an interview, approve the arc. 4) Show the audit fire on a manually-broken file. 5) Open the generated HTML side-by-side with a Caseproof reference.

## Q5 — Open questions / risks

> Risk: she may want to skip the arc gate ("can we just generate?"). Plan: explain the gate IS the value (Pitfall 10 mitigation surfaces here as a UX moment). Open question: does the install one-liner work on her macOS version? Confirm pre-call.

## Q6 — Inclusions / exclusions

> Include: the install one-liner. Include: a screenshot or one-sentence summary of "what the audit looks like when it fires." Avoid: any reference to internal phase numbers or planning docs (Delfi shouldn't need to know about Phases 1-4).

## After Q6 — Approval

Skill prints `Format: overview` (3 sections expected → matches D3-01 rule). Verifier compares arc against `expected-arc.md`. If acceptable:

> approve

Verifier expects: `2026-04-28-demo-run-through-with-delfi-meeting-prep.html`, audit exit 0, default browser opens, absolute path LAST line.
