# Fixture: technical-brief — expected arc shape

## Expected number of rows

5-6 rows. Tech-brief beats: decision → context → alternatives → trade-offs
→ recommendation → next-steps (or compressed to 5: decision, context,
alternatives, trade-offs, recommendation). <5 means alternatives/trade-offs
were dropped — that's the heart of a tech brief; flag.

## Expected format auto-selection (D3-01)

Step 5b should print exactly one line:

> Format: handbook

Because: type=technical-brief is NOT presentation; arc has ≥4 rows → handbook.

## Expected flowing paragraph

> Distribution is the first thing a user touches; we made it match GSD.
> A packaged installer (npm / Homebrew / .pkg) brings registry overhead and
> signing keys. Curl-pipe-bash brings none of that. The trade-off is trust
> at install time. We accept it because the audit script is the user-readable
> review surface. The recommendation: ship pipe-bash; revisit if binary deps
> land.

Acceptable variations: any phrasing that lands the decision-alternatives-
trade-offs spine. NOT acceptable: a "selling-the-decision" tone (engineers
read for facts; that's why tech-brief uses verbatim CLAUDE.md tone — handbook
in titles AND body).

## Expected section titles (verbatim CLAUDE.md handbook tone, BODY too)

Engineers read for facts; selling is wrong here (RESEARCH §Pattern 8 tech-brief row).
Self-review should show ≥0 auto-fixes; if more than 1 fix surfaces, the interview
answers may have leaked sales tone (re-ask the user).

Concrete-noun audit: every title names a thing (`distribution`, `package`,
`installer`, `trade-offs`, `recommendation`).

## Visual diff target (Handbook format)

Side-by-side with `~/work/caseproof/gh-pm/pm/pm-framework/diagrams/pm-system.html`:
same palette, same Inter font, same H1 scale (56px / 800 / -2.5px tracking),
same H2 scale (36px / 800), same 220px black sidebar (DOC-03 = Handbook
format), same 70px / 30px section spacing.

iOS Safari forced-dark-mode: stays light.

## What the verifier looks for

Before typing `approve`:
1. Five columns.
2. 5-6 rows.
3. `Format: handbook` printed below the arc.
4. Status lines all green (handbook tone is the natural fit; any auto-fix
   suggests the answers slipped into pitch tone — flag).
5. Flowing paragraph reads as a decision write-up.

Before opening:
1. Filename matches `YYYY-MM-DD-<slug>-technical-brief.html`.
2. Sidebar is present (Handbook signature — 220px black).
3. Compare to pm-system.html: every visual layer matches.
