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
handbook_skel="${SKILL_DIR}/design/formats/handbook.html"

for f in "$components_html" "$components_css" "$typography_css" "$handbook_skel"; do
  if [ ! -f "$f" ]; then
    echo "audit: missing $f" >&2
    exit 2
  fi
done

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
# Strip the :root block in two passes so both inline (`:root{...}` on
# one line, common after CSS inlining) and multi-line (`:root {\n ... \n}`
# from palette.css) shapes are handled. Then grep the remainder for any
# `#XXXXXX` literal — those are the violations.
hex_lines="$(
  command sed -E 's/:root[[:space:]]*\{[^}]*\}//g' "$output_file" \
    | command sed -E '/:root[[:space:]]*\{/,/^[[:space:]]*\}/d' \
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
#          formats/handbook.html (skeleton layout classes).
# ───────────────────────────────────────────────────────────────────
{
  command grep -oE 'class="[^"]+"' "$components_html"
  command grep -oE 'class="[^"]+"' "$handbook_skel"
  for css in "$typography_css" "$components_css"; do
    command grep -oE '^[[:space:]]*\.[a-zA-Z_][a-zA-Z0-9_-]*[[:space:]]*\{' "$css" \
      | command sed -E 's/^[[:space:]]*\.([^[:space:]{]+).*/class="\1"/'
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
    | command sort -u
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
if command grep -nEi ' on[a-z]+[[:space:]]*=' "$output_file" >&2; then
  printf 'VIOLATION: inline event handler\n' >&2
  explain "Inline event handlers (onclick, onload, etc.) execute JS. Output must be pure HTML+CSS."
  violations=$((violations + 1))
fi
if command grep -nEi '(href|src|action|formaction|xlink:href)[[:space:]]*=[[:space:]]*"[[:space:]]*javascript:' "$output_file" >&2; then
  printf 'VIOLATION: javascript: URL\n' >&2
  explain "javascript: URLs in href/src/action attributes execute JS. Output must be pure HTML+CSS. (Note: the literal text 'javascript:' inside element content is allowed — only attribute values are checked.)"
  violations=$((violations + 1))
fi

# ───────────────────────────────────────────────────────────────────
# Rule 4 — no leftover <link rel="stylesheet">
# ───────────────────────────────────────────────────────────────────
if command grep -nE '<link[[:space:]]+rel="stylesheet"' "$output_file" >&2; then
  printf 'VIOLATION: <link rel="stylesheet"> in output (CSS must be inlined; SKILL.md Step 6)\n' >&2
  explain "The format skeleton uses <link> for dev-time. SKILL.md must inline palette.css + typography.css + components.css into a single <style> block and remove the <link> tags before writing."
  violations=$((violations + 1))
fi

# ───────────────────────────────────────────────────────────────────
# Done
# ───────────────────────────────────────────────────────────────────
if [ "$violations" -gt 0 ]; then
  printf 'AUDIT FAILED: %d violation type(s)\n' "$violations" >&2
  exit 1
fi

exit 0
