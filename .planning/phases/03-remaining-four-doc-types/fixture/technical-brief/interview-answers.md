# Fixture: technical-brief — interview answers

Reproducible inputs for the Phase 3 technical-brief fixture run (D3-20).

Subject: "Why we chose curl-pipe-bash for distribution." Audience: Caseproof
engineers, mid-tenure, familiar with the codebase but not with this specific
decision. Decision: pipe-bash over a packaged installer. Expected format:
Handbook (5-6 sections per D3-01 mapping for ≥4-section docs).

## Pre-run

Same as pitch fixture (skill installed at `~/.claude/skills/deshtml/`,
fresh Claude Code session, CWD outside the deshtml repo).

## Invocation

```
/deshtml
```

## Q1 — Document type

> technical brief

(User types `technical brief` with a space; SKILL.md normalizes to `technical-brief` per plan 03-01 Step 2 + Step 3 substitution.)

## Q2 — Audience

> Caseproof engineers. Mid-tenure (1-3 years on the team), comfortable in bash and Node. Have seen GSD's installer; have NOT seen deshtml's design choices written up.

## Q3 — The decision

> Ship deshtml's distribution as `curl https://… | bash`, not as an npm package or a Mac .pkg installer.

## Q4 — Alternatives considered

> 1) npm package (`npm install -g deshtml`). 2) Homebrew formula. 3) Mac .pkg signed installer. 4) Manual git-clone + symlink.

## Q5 — Trade-offs that drove the choice

> Curl-pipe-bash matches GSD's pattern (audience already knows it). Zero packaging overhead. No registry account / signing key / formula PR. Audit-friendly (script is human-readable). Trade-off: requires user trust at install time; mitigated by hosting on a known repo + the `set -euo pipefail` discipline. Not a fit if we ever add binary deps; deshtml is pure prompt + templates so binary deps are unlikely.

## Q6 — Inclusions / exclusions

> Include: the explicit GSD-shaped install one-liner. Include: the trust-at-install-time rationale. Avoid: vague claims like "industry standard" — name the actual pattern (GSD).

## After Q6 — Approval

Skill prints `Format: handbook` (5+ sections expected → matches D3-01 rule). Verifier compares arc against `expected-arc.md`. If acceptable:

> approve

Verifier expects: `2026-04-28-why-we-chose-curl-pipe-technical-brief.html` (or `-2`/`-3` on collision), audit exit 0, default browser opens, absolute path is LAST line.
