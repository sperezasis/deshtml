#!/usr/bin/env bash
# skill/audit/run.sh
# Post-generation audit for deshtml output (DESIGN-06).
# Usage: bash run.sh [--explain] <output.html>
# Exit 0 = pass. Non-zero = violation count, with details on stderr.
#
# macOS notes:
# - `command grep` and `command sed` bypass shell aliases (ugrep on Santiago's machine).
# - BSD grep + BSD sed: no GNU long options, POSIX BREs / `-E` for ERE only.
# - bash 3.2 compatible: no Bash-4-only features (no array-fill builtins, no
#   case-conversion expansions, no associative-array declarations).
set -euo pipefail

EXPLAIN=0
if [ "${1:-}" = "--explain" ]; then
  EXPLAIN=1
  shift
fi

output_file="${1:-}"
if [ -z "$output_file" ] || [ ! -f "$output_file" ]; then
  echo "usage: bash run.sh [--explain] <output.html>" >&2
  exit 2
fi

SKILL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
components_html="${SKILL_DIR}/design/components.html"
components_css="${SKILL_DIR}/design/components.css"
typography_css="${SKILL_DIR}/design/typography.css"

# Harvest classes from every format skeleton — handbook, overview, presentation,
# and any future formats added under design/formats/ (D3-18). The wildcard
# auto-extends the allowlist with no script edit.
format_skels=( "${SKILL_DIR}"/design/formats/*.html )

# Verify required design-system files exist; format skeletons are checked
# via the empty-glob guard below.
for f in "$components_html" "$components_css" "$typography_css"; do
  if [ ! -f "$f" ]; then
    echo "audit: missing $f" >&2
    exit 2
  fi
done

# Empty-glob guard. In bash 3.2 (macOS default), an unmatched glob expands to
# the literal pattern, NOT an empty list. Without this guard, the harvester
# would try to read a file named "*.html" and fail noisily. The bash-4-only
# nullglob option (shopt) is unavailable on macOS — so we test the first entry.
if [ ! -e "${format_skels[0]}" ]; then
  echo "audit: no format skeletons found in ${SKILL_DIR}/design/formats/" >&2
  exit 2
fi

violations=0
allowed_file="$(mktemp -t deshtml-audit 2>/dev/null || mktemp -t deshtml-audit.XXXXXX)"
trap 'rm -f "$allowed_file"' EXIT

explain() {
  if [ "$EXPLAIN" -eq 1 ]; then
    printf '  > %s\n' "$1" >&2
  fi
}

# ───────────────────────────────────────────────────────────────────
# Rule 1 — hex literals outside :root
# ───────────────────────────────────────────────────────────────────
# Strip the :root block, then grep the remainder for any `#XXXXXX`
# literal. The strip handles three shapes:
#   a) inline single-line: `:root { --a:#fff; }` on one line.
#   b) multi-line: `:root {\n ... \n}` (from palette.css).
#   c) trailing content on the closing-brace line: `} .x { color:#BAD; }`
#      — pre-fix this was eaten with the closing brace and bypassed Rule 1
#      (ME-03). Awk now strips only up to and including the matching `}`
#      and preserves whatever follows on the same line.
hex_lines="$(
  awk '
    BEGIN { in_root = 0 }
    !in_root && /:root[[:space:]]*\{/ {
      # Same-line open + close: strip everything from `:root` to the
      # first `}` on this line; preserve any trailing content.
      if (match($0, /:root[[:space:]]*\{[^}]*\}/)) {
        $0 = substr($0, 1, RSTART - 1) substr($0, RSTART + RLENGTH)
        print; next
      }
      # Multi-line :root opens; skip until closing `}`.
      in_root = 1
      sub(/:root[[:space:]]*\{.*$/, "", $0)
      print; next
    }
    in_root && /\}/ {
      # Closing brace of :root: drop everything up to and including it,
      # print whatever trails (catches injected `} .x{color:#BAD;}`).
      sub(/^[^}]*\}/, "", $0)
      in_root = 0
      print; next
    }
    in_root { next }
    { print }
  ' "$output_file" \
    | command grep -nE '#[0-9a-fA-F]{3,8}\b' || true
)"
if [ -n "$hex_lines" ]; then
  printf 'VIOLATION: hex literal(s) outside :root\n' >&2
  printf '%s\n' "$hex_lines" >&2
  explain "Hex literals are only allowed inside :root { ... } in palette.css. Use var(--token-name) instead."
  violations=$((violations + 1))
fi

# ───────────────────────────────────────────────────────────────────
# Rule 2 — class allowlist (harvested live from the design system files)
# Sources: components.html (markup contracts), typography.css (text scale labels),
#          components.css (component CSS — sidebar, hero, all 16 component families),
#          formats/*.html (every format skeleton: handbook + overview +
#          presentation + any future format dropped into formats/, per D3-18).
# ───────────────────────────────────────────────────────────────────
{
  command grep -oE 'class="[^"]+"' "$components_html"
  for skel in "${format_skels[@]}"; do
    command grep -oE 'class="[^"]+"' "$skel"
  done
  for css in "$typography_css" "$components_css"; do
    # Standalone class selectors at start of line (existing strict harvest).
    command grep -oE '^[[:space:]]*\.[a-zA-Z_][a-zA-Z0-9_-]*[[:space:]]*\{' "$css" \
      | command sed -E 's/^[[:space:]]*\.([^[:space:]{]+).*/class="\1"/'
    # Compound + descendant selectors. Take the selector list before `{`,
    # split on `,` `>` `+` `~` and whitespace, then emit every `.name` token.
    # Catches `.nav-a.active`, `.hero-stat .hs-n`, `.sb-brand .name`, etc.
    # that the strict regex above misses (HI-03).
    command sed -nE 's/^([^{}]+)\{.*$/\1/p' "$css" \
      | tr ',>+~' '\n' \
      | tr -s '[:space:]' '\n' \
      | command grep -oE '\.[a-zA-Z_][a-zA-Z0-9_-]*' \
      | command sed -E 's/^\./class="/; s/$/"/'
  done
} \
  | command sed -E 's/class="//; s/"$//' \
  | tr ' ' '\n' \
  | command grep -v '^$' \
  | command sort -u > "$allowed_file"

used_classes="$(
  command grep -oE 'class="[^"]+"' "$output_file" \
    | command sed -E 's/class="//; s/"$//' \
    | tr ' ' '\n' \
    | command grep -v '^$' \
    | command sort -u || true
)"

unknown_count=0
while IFS= read -r cls; do
  [ -z "$cls" ] && continue
  if ! command grep -qxF "$cls" "$allowed_file"; then
    printf 'VIOLATION: unknown class "%s"\n' "$cls" >&2
    explain "Class \"$cls\" is not in components.html or typography.css. Add it to the design system first, or rewrite the markup to use an existing component."
    unknown_count=$((unknown_count + 1))
  fi
done <<EOF
$used_classes
EOF
if [ "$unknown_count" -gt 0 ]; then
  violations=$((violations + 1))
fi

# ───────────────────────────────────────────────────────────────────
# Rule 3 — banned tags / attrs / URLs
# ───────────────────────────────────────────────────────────────────
if command grep -nEi '<(script|iframe|object|embed)\b' "$output_file" >&2; then
  printf 'VIOLATION: banned tag (script|iframe|object|embed)\n' >&2
  explain "Output must contain zero scripts, iframes, objects, or embeds (D-17, PROJECT.md self-contained-file constraint)."
  violations=$((violations + 1))
fi
if command grep -nEi '(^|[[:space:]])on[a-z]+[[:space:]]*=' "$output_file" >&2; then
  printf 'VIOLATION: inline event handler\n' >&2
  explain "Inline event handlers (onclick, onload, etc.) execute JS. Output must be pure HTML+CSS."
  violations=$((violations + 1))
fi
if command grep -nEi "(href|src|action|formaction|xlink:href)[[:space:]]*=[[:space:]]*[\"']?[[:space:]]*javascript:" "$output_file" >&2; then
  printf 'VIOLATION: javascript: URL\n' >&2
  explain "javascript: URLs in href/src/action attributes execute JS. Output must be pure HTML+CSS. (Note: the literal text 'javascript:' inside element content is allowed — only attribute values are checked.)"
  violations=$((violations + 1))
fi

# ───────────────────────────────────────────────────────────────────
# Rule 4 — no leftover <link rel="stylesheet">
# ───────────────────────────────────────────────────────────────────
if command grep -nEi '<link[[:space:]][^>]*rel=[^>]*stylesheet' "$output_file" >&2; then
  printf 'VIOLATION: <link rel="stylesheet"> in output (CSS must be inlined; SKILL.md Step 6)\n' >&2
  explain "The format skeleton uses <link> for dev-time. SKILL.md must inline palette.css + typography.css + components.css into a single <style> block and remove the <link> tags before writing."
  violations=$((violations + 1))
fi

# ───────────────────────────────────────────────────────────────────
# Rule 5 — interview schema check (D3-10 active enforcement; Pitfall 20)
# ───────────────────────────────────────────────────────────────────
# Iterate every interview file and verify the four DOC-06 structural anchors.
# Failures count toward $violations exactly like the other rules.
# Schema source of truth: skill/interview/handbook.md.
interview_dir="${SKILL_DIR}/interview"

if [ -d "$interview_dir" ]; then
  schema_violations=0
  for interview in "$interview_dir"/*.md; do
    # Empty-glob guard (bash 3.2): if no .md files exist, skip silently.
    [ ! -e "$interview" ] && break
    interview_name="$(basename "$interview")"

    # Check (a): Must have `## The N questions` heading.
    if ! command grep -qE '^## The [0-9]+ questions?' "$interview"; then
      printf 'VIOLATION: interview/%s missing `## The N questions` heading (DOC-06)\n' "$interview_name" >&2
      explain "Every interview file must contain a \`## The N questions\` heading where N matches the actual question count. Schema source: skill/interview/handbook.md."
      schema_violations=$((schema_violations + 1))
    fi

    # Check (b): Must have `## Hand-off` heading.
    if ! command grep -qE '^## Hand-off' "$interview"; then
      printf 'VIOLATION: interview/%s missing `## Hand-off` heading (DOC-06)\n' "$interview_name" >&2
      explain "Every interview file must contain a \`## Hand-off\` section that points Claude at story-arc.md."
      schema_violations=$((schema_violations + 1))
    fi

    # Check (c): Hand-off must reference story-arc.md.
    if ! command grep -q 'story-arc.md' "$interview"; then
      printf 'VIOLATION: interview/%s missing `story-arc.md` reference (DOC-06)\n' "$interview_name" >&2
      explain "The interview file must hand off to story-arc.md after the questions. Otherwise the arc gate (ARC-04) is bypassable."
      schema_violations=$((schema_violations + 1))
    fi

    # Check (d): Question count must be in [3, 5] (DOC-07 cap + sanity floor).
    q_count="$(command grep -cE '^[0-9]+\.[[:space:]]+\*\*' "$interview")"
    if [ "$q_count" -gt 5 ]; then
      printf 'VIOLATION: interview/%s has %d questions (>5; DOC-07 cap)\n' "$interview_name" "$q_count" >&2
      explain "DOC-07 caps interviews at <=5 questions. The schema-drift check sees ${q_count}."
      schema_violations=$((schema_violations + 1))
    fi
    if [ "$q_count" -lt 3 ]; then
      printf 'VIOLATION: interview/%s has %d questions (<3; below sanity floor)\n' "$interview_name" "$q_count" >&2
      explain "Interviews with <3 questions can't capture audience+material+tone. Schema source: skill/interview/handbook.md (5 questions)."
      schema_violations=$((schema_violations + 1))
    fi
  done

  if [ "$schema_violations" -gt 0 ]; then
    violations=$((violations + 1))
  fi
fi

# ───────────────────────────────────────────────────────────────────
# Done
# ───────────────────────────────────────────────────────────────────
if [ "$violations" -gt 0 ]; then
  printf 'AUDIT FAILED: %d violation type(s)\n' "$violations" >&2
  exit 1
fi

exit 0
