---
phase: 03-remaining-four-doc-types
reviewed: 2026-04-28
depth: standard
status: issues
findings_total: 5
findings_critical: 0
findings_high: 0
findings_medium: 1
findings_low: 3
findings_info: 1
---

# Phase 3 Code Review

Files reviewed: `skill/SKILL.md`, `skill/design/formats/presentation.html`, `skill/audit/run.sh`, `skill/audit/rules.md`, `skill/interview/{pitch,technical-brief,presentation,meeting-prep,handbook}.md`.

Empirically verified: audit harvester clean/dirty/Rule-5 paths all fire correctly on bash 3.2.57.

---

## Medium

### MED-01 — Step 5 hard-codes `-handbook.html` filename suffix for all five doc types

**File:** `skill/SKILL.md:79,84,87`

Step 5 (filename computation) was last updated in Phase 2 when only `handbook` existed. Phase 3 wired four new doc types into Steps 2/5b/6 but did not generalize Step 5's filename. Lines 79, 84, and 87 literally write `-handbook.html` regardless of `${type}`. So a `pitch` invocation produces `2026-04-28-the-h1-handbook.html`, not `…-pitch.html`. This breaks 03-CONTEXT.md Pitfall 11's stated guarantee ("the TYPE suffix prevents collision across types") and means same-day runs across types collide via `-2`, `-3` suffixes instead of being distinguishable by name. Plan 03-04's fixture verification didn't catch this because inputs were staged into `fixture/<type>/` subdirs — the actual generated output filenames aren't recorded in FIXTURE-NOTES.md.

**Fix:**
```markdown
3. Tentative filename: `<date>-<slug>-<type>.html` in the current working
   directory (where `<type>` is the kebab-case doc type from Step 2 —
   `handbook`, `pitch`, `technical-brief`, `presentation`, `meeting-prep`).
4. Collision check: append `-2`, `-3`, … keeping `-<type>` before the suffix:
   `target="<date>-<slug>-<type>.html"` then `<date>-<slug>-<type>-${suffix}.html`.
```

---

## Low

### LOW-01 — Step 6 instructs reading only `formats/handbook.html` for the audit allowlist

**File:** `skill/SKILL.md:148-151`

Step 6 item 3 still tells Claude that the audit harvests its allowlist from `design/formats/handbook.html` (singular). Plan 03-03 made the harvester wildcard over `formats/*.html`, and Step 6 itself routes to `${format}.html` (line 114). When the chosen format is `presentation`, Claude is being told the audit allowlist comes from `handbook.html` — under-stating the `.deck`, `.slide`, `.slide-counter`, `.slide-nav` classes it can use. Functionally non-blocking (the audit harvests them anyway), but instructionally misleading and stale post-D3-18.

**Fix:**
```markdown
3. Use only classes from the design system (`design/components.html`,
   `design/components.css`, `design/typography.css`,
   `design/formats/*.html`). The audit in Step 7 harvests its
   allowlist from those four sources via the wildcard glob (D3-18);
   failing here means a guaranteed retry.
```

### LOW-02 — Step 6 heading and language remain handbook-centric

**File:** `skill/SKILL.md:110, 186`

Step 6's H2 still reads "Render the handbook HTML" even though Phase 3 made it multi-format. Same drift in the example final output line 186 (`2026-04-27-deshtml-handbook.html`). Pure documentation hygiene; no runtime impact, but dilutes the skill's self-description for the four new types.

**Fix:** Rename the heading to `## Step 6 — Render the HTML` and update the example final output to use a placeholder type (e.g., `2026-04-27-deshtml-handbook.html` is fine as illustrative, but add a comment explaining the type suffix varies).

### LOW-03 — `presentation.html` has TWO inline `<style>` blocks; SKILL.md Step 6.1 only mentions ONE

**File:** `skill/SKILL.md:131-132` vs `skill/design/formats/presentation.html:23-97`

Step 6 item 1.e says "Keep the skeleton's existing inline `<style>` block (the layout rules) as a SECOND `<style>` block right after — do not merge them." Singular. But presentation.html ships TWO inline `<style>` blocks (layout/snap/counter at 23-74, slide-deck typography H1/H2/body at 75-97). A literal reading could drop the second block, killing the slide-typography scale (H1 80px, H2 56px, body 22px / `var(--g9)`). 03-RESEARCH §Pattern 6 + 03-01-SUMMARY both establish that the second block is intentional and must be preserved.

**Fix:** Adjust Step 6.1.e to: "Keep the skeleton's existing inline `<style>` block(s) (layout rules and, for presentation, the slide-deck type scale) as additional `<style>` blocks right after — do not merge them with the inlined CSS files." Also disambiguate the "TOTAL_SLIDES_LITERAL" reference (line 146) by saying "in the first inline `<style>` block."

---

## Info

### INFO-01 — `command grep -q 'story-arc.md'` in Rule 5 matches anywhere in the file

**File:** `skill/audit/run.sh:222`

Rule 5's check (c) verifies the literal string `story-arc.md` appears anywhere in an interview file. A future interview file could accidentally satisfy the check via prose like "we used to point at story-arc.md but now we don't" while actually omitting the hand-off contract. Today all five files put the reference inside `## Hand-off` (verified), so the false-positive risk is theoretical. V1-acceptable; flag for V2 if any file ever embeds `story-arc.md` outside the handoff.

**Fix (V2 candidate):**
```bash
awk '/^## Hand-off/{f=1; next} /^## /{f=0} f' "$interview" \
  | command grep -q 'story-arc.md' || schema_violations=$((schema_violations + 1))
```

**V2 carryover (2026-04-28):** Not fixed in Phase 3 review-fix pass. Theoretical false-positive risk only — all five V1 interview files keep the `story-arc.md` reference inside `## Hand-off`. Re-evaluate at Phase 4 / V2 if any new interview file embeds the string outside the handoff section.

---

## Approved (not flagged)

- Spike-outcome hybrid verification (qlmanage + canonical pattern check) per 03-01-SUMMARY Rule-2 user-proxy decision.
- `var(--g8)` → `var(--g9)` carryover fix already folded in 03-04 commit `947cde4`.
- Pitch/presentation tone defaults referencing "pitch" — verbatim CLAUDE.md tone descriptors per 03-02-SUMMARY Deviation #1.
- Question-count regex returns 5 for all five interview files — no Rule 5 false trips.
- bash 3.2.57 empty-glob guard verified empirically.
- Four new interview files type-distinctive per Pitfall 19.
- Presentation CSS scroll-snap matches 03-RESEARCH §Pattern 3 verbatim.
