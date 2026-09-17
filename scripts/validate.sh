#!/usr/bin/env bash
# validate.sh — submission structure / hygiene checks
# Usage: bash scripts/validate.sh <base_sha> <head_sha>
# Writes: validation_result.txt, validation_summary.md
# Exit 0 even on failure — caller decides to fail job after reading result.

set -u

BASE_SHA="${1:-origin/main}"
HEAD_SHA="${2:-HEAD}"

CONFIG="submission-config.yml"

# --- helpers ---
failures=0
warnings=0
pass_msgs=()
fail_msgs=()
warn_msgs=()

pass()  { pass_msgs+=("$1"); }
fail()  { fail_msgs+=("$1"); failures=$((failures+1)); }
warn()  { warn_msgs+=("$1"); warnings=$((warnings+1)); }

echo "Base: $BASE_SHA  Head: $HEAD_SHA"

# --- config parsing (simple grep, no yq dependency) ---
get_config_list() {
  # Extract list under key: e.g., allowed_extensions
  local key="$1"
  awk -v k="$key:" '
    $0 ~ "^"k {flag=1; next}
    flag && /^[^ ]/ {flag=0}
    flag && /^- / {gsub(/^[[:space:]]*-[[:space:]]*/,""); print}
    flag && /^  - / {gsub(/^[[:space:]]*-[[:space:]]*/,""); print}
  ' "$CONFIG" 2>/dev/null
}

ALLOWED_EXTS=$(get_config_list allowed_extensions | tr '[:upper:]' '[:lower:]' | tr '\n' ' ' )
PROHIBITED=$(get_config_list prohibited_patterns | tr '\n' ' ')
echo "Allowed: $ALLOWED_EXTS"
echo "Prohibited patterns: $PROHIBITED"

# --- diff detection ---
# Try range diff, fallback to HEAD only
if git rev-parse --verify "$BASE_SHA" >/dev/null 2>&1 && git rev-parse --verify "$HEAD_SHA" >/dev/null 2>&1; then
  CHANGED=$(git diff --name-only --diff-filter=ACMRT "$BASE_SHA"..."$HEAD_SHA" 2>/dev/null || git diff --name-only --diff-filter=ACMRT origin/main...HEAD 2>/dev/null || git diff --name-only HEAD~1 2>/dev/null || echo "")
  CHANGED_ALL=$(git diff --name-status "$BASE_SHA"..."$HEAD_SHA" 2>/dev/null | head -n 200 || echo "")
else
  CHANGED=$(git diff --name-only --diff-filter=ACMRT HEAD~1 2>/dev/null || git ls-files 2>/dev/null | head -n 100 || echo "")
  CHANGED_ALL="$CHANGED"
fi

# Also handle staged but not committed (local testing) and untracked
if [ -z "$CHANGED" ]; then
  CHANGED=$(git diff --cached --name-only --diff-filter=ACMRT 2>/dev/null | head -n 100 || echo "")
fi
if [ -z "$CHANGED" ]; then
  # Fallback: list Practical-* files on disk (includes untracked for local dev)
  CHANGED=$(find Practical-* -type f 2>/dev/null | head -n 100 || echo "")
  # Also include any staged/untracked .github/scripts changes for protected-path check
  EXTRA=$(git diff --cached --name-only --diff-filter=ACMRT 2>/dev/null; git ls-files --others --exclude-standard 2>/dev/null | head -n 50)
  if [ -n "$EXTRA" ]; then
    CHANGED=$(printf "%s\n%s" "$CHANGED" "$EXTRA" | sort -u | head -n 100)
  fi
fi

echo "Changed files:"
echo "$CHANGED"
echo "---"

# Normalise to array
mapfile -t FILES <<< "$CHANGED"

# Filter empty, .gitkeep, and trim
FILTERED=()
for f in "${FILES[@]}"; do
  f=$(echo "$f" | xargs)
  [ -z "$f" ] && continue
  [[ "$f" == *".gitkeep" ]] && continue
  [[ "$f" == *".gitignore" ]] && continue
  [ -z "$f" ] && continue
  FILTERED+=("$f")
done
FILES=("${FILTERED[@]}")

if [ ${#FILES[@]} -eq 0 ]; then
  fail "No files detected in submission. Did you add files under Practical-XX/YourName/? (Checked diff $BASE_SHA...$HEAD_SHA)"
fi

# --- Check 1: Directory structure ---
# Must be Practical-XX/StudentName/file  where Practical-XX = Practical-01..99, StudentName non-empty
PRACTICAL_RE='^Practical-[0-9]{2}/[^/]+/[^/]+$'
# Also allow Practical-X (single digit) as warning
for f in "${FILES[@]}"; do
  # Skip .gitkeep and .gitignore and hidden
  if [[ "$f" == *".gitkeep" ]] || [[ "$f" == *".gitignore" ]]; then
    continue
  fi
  # Check protected paths
  if [[ "$f" == .github/* ]] || [[ "$f" == scripts/* ]] || [[ "$f" == "submission-config.yml" ]]; then
    fail "Prohibited edit to protected path: \`$f\` — students must not modify repository configuration."
    continue
  fi
  if ! echo "$f" | grep -Eq "$PRACTICAL_RE"; then
    # Provide helpful hint
    if echo "$f" | grep -Eq '^Practical-[0-9]+/'; then
      # Has Practical prefix but bad depth
      if echo "$f" | grep -Eq '^Practical-[0-9]{2}/[^/]+$'; then
        fail "Missing file inside student directory: \`$f\` — expected \`Practical-XX/YourName/filename.ext\`."
      else
        fail "Invalid path: \`$f\` — expected \`Practical-XX/YourName/filename.ext\` (e.g., \`Practical-01/Ajit-Kumar/problem1.cpp\`)."
      fi
    elif echo "$f" | grep -Eq '^Practical-'; then
      fail "Invalid practical prefix: \`$f\` — use \`Practical-01\`, \`Practical-02\`, ... (two digits)."
    else
      fail "File outside practical directory: \`$f\` — all submissions must be inside \`Practical-XX/YourName/\`."
    fi
  else
    # Valid structure — check practical number 01-99
    PRAC=$(echo "$f" | grep -oE 'Practical-[0-9]{2}' | head -1)
    NUM=$(echo "$PRAC" | grep -oE '[0-9]{2}')
    # Strip leading zero for arithmetic
    NUM_INT=$((10#$NUM))
    if [ "$NUM_INT" -lt 1 ] || [ "$NUM_INT" -gt 99 ]; then
      warn "Unusual practical number: \`$f\`"
    fi
  fi
done

# Check student directory exists and non-empty
if [ ${#fail_msgs[@]} -eq 0 ] || true; then
  # Count distinct Practical-XX/Student combos
  COMBOS=$(printf "%s\n" "${FILES[@]}" | grep -E '^Practical-[0-9]{2}/[^/]+/' | cut -d/ -f1-2 | sort -u)
  if [ -z "$COMBOS" ]; then
    # already failed
    :
  else
    pass "Directory structure check — found $(echo "$COMBOS" | wc -l) student submission folder(s): $(echo "$COMBOS" | tr '\n' ', ')"
  fi
fi

# --- Check 2: Allowed extensions ---
for f in "${FILES[@]}"; do
  [[ "$f" == *".gitkeep" ]] && continue
  [[ "$f" == .github/* ]] && continue
  # Skip directories
  [ -d "$f" ] && continue
  ext="${f##*.}"
  ext_lower=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
  # If file has no extension
  if [[ "$f" == "$ext" ]] || [[ "$f" == *"/"* ]] && [[ "$ext" == *"/"* ]]; then
    # No dot — treat as no extension
    fail "File without extension: \`$f\` — allowed: $ALLOWED_EXTS"
    continue
  fi
  # Check against allowed list
  if ! echo " $ALLOWED_EXTS " | grep -qw "$ext_lower"; then
    # Check if prohibited
    if echo " $PROHIBITED " | grep -qw "*.$ext_lower" 2>/dev/null || [[ "$ext_lower" == "exe" || "$ext_lower" == "out" || "$ext_lower" == "o" || "$ext_lower" == "class" || "$ext_lower" == "pyc" ]]; then
      fail "Prohibited file type: \`$f\` (.\`$ext_lower\` not allowed)."
    else
      fail "Disallowed extension: \`$f\` — allowed: $ALLOWED_EXTS"
    fi
  fi
done
if [ $failures -eq 0 ]; then
  pass "File extension check — all files have allowed extensions ($ALLOWED_EXTS)"
fi

# --- Check 3: Prohibited patterns ---
for f in "${FILES[@]}"; do
  base=$(basename "$f")
  dir=$(dirname "$f")
  # Exact prohibited substrings
  for pat in $PROHIBITED; do
    # Strip glob chars for substring check
    clean=$(echo "$pat" | sed 's/^\*\.//; s/^\*//; s/\*$//')
    if echo "$f" | grep -qi "$clean"; then
      # Only flag if pattern matches file/dir name, not just any substring in path
      if echo "$base" | grep -qi "$clean" 2>/dev/null || echo "$f" | grep -qi "$clean" 2>/dev/null; then
        # Avoid double report for extensions already handled
        if [[ "$pat" == "*.exe" || "$pat" == "*.out" || "$pat" == "*.o" || "$pat" == "*.class" ]]; then
          : # already reported
        else
          # For directory patterns like __pycache__, .vscode, node_modules
          if [[ "$f" == *"$clean"* ]]; then
            fail "Prohibited file/directory: \`$f\` matches prohibited pattern \`$pat\`."
          fi
        fi
      fi
    fi
  done
  # Explicit checks
  if [[ "$f" == *".vscode"* ]] || [[ "$f" == *".idea"* ]] || [[ "$f" == *"node_modules"* ]] || [[ "$f" == *"__pycache__"* ]]; then
    # Already handled but ensure
    :
  fi
done

# --- Check 4: File size ---
MAX_MB=$(grep -E '^max_file_size_mb:' "$CONFIG" 2>/dev/null | grep -oE '[0-9]+' | head -1)
MAX_MB=${MAX_MB:-5}
MAX_TOTAL=$(grep -E '^max_total_size_mb:' "$CONFIG" 2>/dev/null | grep -oE '[0-9]+' | head -1)
MAX_TOTAL=${MAX_TOTAL:-50}
total_kb=0
for f in "${FILES[@]}"; do
  [ -f "$f" ] || continue
  size_kb=$(du -k "$f" 2>/dev/null | cut -f1)
  size_kb=${size_kb:-0}
  total_kb=$((total_kb + size_kb))
  max_kb=$((MAX_MB * 1024))
  if [ "$size_kb" -gt "$max_kb" ]; then
    fail "File too large: \`$f\` ($((size_kb/1024)) MB) exceeds ${MAX_MB} MB limit."
  fi
done
total_mb=$((total_kb / 1024))
if [ "$total_kb" -gt $((MAX_TOTAL * 1024)) ]; then
  fail "Total submission too large: ${total_mb} MB exceeds ${MAX_TOTAL} MB limit."
else
  pass "Size check — total ${total_mb} MB within ${MAX_TOTAL} MB, each file ≤ ${MAX_MB} MB."
fi

# --- Check 5: Protected path edits already done ---

# --- Summary ---
echo "Failures: $failures  Warnings: $warnings  Passes: ${#pass_msgs[@]}"

# Write machine-readable result
if [ $failures -gt 0 ]; then
  echo "STATUS=FAIL" > validation_result.txt
else
  echo "STATUS=PASS" > validation_result.txt
fi
echo "FAILURES=$failures" >> validation_result.txt
echo "WARNINGS=$warnings" >> validation_result.txt
echo "FILES=${#FILES[@]}" >> validation_result.txt

# Write markdown summary
{
  echo "### Validation Summary"
  echo ""
  echo "**Files checked:** ${#FILES[@]}"
  echo "**Base:** \`$BASE_SHA\` → **Head:** \`$HEAD_SHA\`"
  echo ""
  if [ ${#pass_msgs[@]} -gt 0 ]; then
    echo "#### ✅ Passed"
    for m in "${pass_msgs[@]}"; do echo "- $m"; done
    echo ""
  fi
  if [ ${#warn_msgs[@]} -gt 0 ]; then
    echo "#### ⚠️ Warnings"
    for m in "${warn_msgs[@]}"; do echo "- $m"; done
    echo ""
  fi
  if [ ${#fail_msgs[@]} -gt 0 ]; then
    echo "#### ❌ Failures"
    for m in "${fail_msgs[@]}"; do echo "- $m"; done
    echo ""
  fi
  if [ $failures -eq 0 ]; then
    echo "> ✅ **All validation checks passed.**"
  else
    echo "> ❌ **Validation failed with $failures issue(s).** Please fix and push again."
  fi
  echo ""
  echo "**Changed files:**"
  for f in "${FILES[@]}"; do echo "- \`$f\`"; done
} > validation_summary.md

cat validation_summary.md
echo "---"
cat validation_result.txt

# Do not exit non-zero — let caller handle
exit 0
