#!/usr/bin/env bash
set -euo pipefail

while IFS= read -r -d '' path; do
  if ! git diff --quiet -- "$path"; then
    printf 'staged Markdown path has unstaged changes: %s\n' "$path" >&2
    exit 1
  fi
done < <(git diff --cached --name-only --diff-filter=ACMR -z -- '*.md')
