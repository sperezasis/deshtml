# Context mode — draft from prior conversation, confirm with one prompt

SKILL.md reads this file when Step 1.5 detects 2+ context signals in the
prior conversation. Follow it end-to-end. Return to SKILL.md Step 5 (filename
+ collision check) only after Step E hands off via story-arc.md approval.
The context-mode branch bypasses Step 2 (doc type) and Step 3 (interview)
entirely — those questions are answered from the conversation, not from a
fresh interview, unless the user rejects the draft.

Never silently fall back to interview mode (SKILL-03). If the draft is too
thin to proceed, Step C announces it loudly and routes to Step 2.

## Step A — Build the draft

Read the prior conversation. Build a draft answer set with these fields:

| Field | Source | Confidence |
|---|---|---|
| `docType` | Conversation mentions of doc type, OR inferred from content shape | high / medium / low |
| `audience` | Mentions of who it's for | high / medium / low |
| `material` | Subject-matter content discussed | high / medium / low |
| `sections` | Outline / structure discussed (or "Claude proposes") | high / medium / low |
| `tone` | Voice / register hints (or default per type) | high / medium / low |
| `inclusions` | Specific include / avoid notes | high / medium / low |

Mark each field's confidence. If a field can't be inferred at all, leave it
empty (NOT a confident guess — empty).

The doc-type inference uses the same decision tree as `source-mode.md` Step B
(handbook / pitch / presentation / meeting-prep / technical-brief). If
ambiguous, default to `handbook`.

## Step B — Display the draft

Render the draft as a single block to the user. Use this exact shape:

```
Drafted from our conversation:

- Type: <docType>
- Audience: <audience-or-blank>
- Material: <material-or-blank>
- Sections: <sections-or-"Claude proposes">
- Tone: <tone-or-default>
- Inclusions: <inclusions-or-"none">
```

Empty fields are shown as the literal word `(empty)` so the user can see what
was inferred vs not.

## Step C — Ask the user to confirm, edit, or restart

Use `AskUserQuestion` with `header: "Draft"`, `question: "Use this draft?"`,
`multiSelect: false`, and these three options:

1. "Yes — generate the arc now" — Skip the interview entirely, jump to Step D (story-arc.md).
2. "Edit specific fields" — Step C-Edit. Re-prompt only the fields the user wants to change.
3. "Start fresh interview" — Drop the draft, return to SKILL.md Step 2.

Branch on the answer:

- **Yes** → continue to Step D.
- **Edit specific fields** → Step C-Edit (below).
- **Start fresh interview** → STOP this file. Tell the user `Restarting from interview mode.` Then return control to SKILL.md so it proceeds to Step 2.
- **"Other" + free-text instructions** → treat the text as a revision message. Apply the user's edits to the draft and re-display per Step B. Re-ask Step C.

### Step C-Edit — per-field re-prompt

Use `AskUserQuestion` with up to 4 questions in a single batch — one question
per field the user wants to change. For each editable field, provide 2-3
sensible options plus the auto-"Other" for free-text override. Use the same
option presets the per-type interview uses (see `interview/<type>.md`).

After the batch returns, merge the edits into the draft and re-display per
Step B. Re-ask Step C until the user picks "Yes" or "Start fresh interview".

### Thin-draft fallback

If the draft has fewer than 3 fields with non-empty values OR if `docType`
couldn't be inferred at all, do NOT show Step B/C. Instead, emit EXACTLY:

> Conversation context is too thin to draft from. Switching to full interview.

Then return to SKILL.md Step 2 and run the interview from scratch. This is
the only allowed context-mode → interview-mode transition, and it is loud.

## Step D — Hand off to story-arc.md

Read `${CLAUDE_SKILL_DIR}/story-arc.md` now and follow it from Step A onward.
Build the arc using the confirmed draft as the source for `Material` and
`Sections`. The arc gate, self-review, approval whitelist, and revision loop
all stay single-source in story-arc.md.

## Step E — Return to SKILL.md

On approval, return to SKILL.md and proceed to Step 5 (filename + collision
check). Step 5 uses the confirmed `docType` for the filename suffix
(`-handbook.html`, `-presentation.html`, etc.). Step 5b, Step 6, Step 7,
Step 8 run unchanged.

## What this file must NOT do

- Must not be inlined into SKILL.md.
- Must not silently fall back to interview mode — the only allowed transition
  is the loud thin-draft fallback in Step C.
- Must not duplicate story-arc.md's table schema, self-review pass, or
  approval whitelist.
- Must not invent answers that the conversation did not contain. Empty fields
  stay empty (shown as `(empty)`); the user can fill them at Step C-Edit.
- Must not auto-approve the draft. The user always confirms via Step C.
