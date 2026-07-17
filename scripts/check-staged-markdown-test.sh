#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
guard="$script_dir/check-staged-markdown.sh"
test_repo="$(mktemp -d "${TMPDIR:-/tmp}/staged-markdown-hook.XXXXXX")"
trap 'rm -rf "$test_repo"' EXIT

git -C "$test_repo" init --quiet
git -C "$test_repo" config user.email test@example.com
git -C "$test_repo" config user.name "Staged Markdown Test"
printf '# staged version\n' > "$test_repo/README.md"
git -C "$test_repo" add README.md
printf '\nunstaged version\n' >> "$test_repo/README.md"

if output=$(cd "$test_repo" && "$guard" 2>&1); then
  printf 'guard accepted divergent staged and working-tree Markdown\n' >&2
  exit 1
fi
case "$output" in
  *"staged Markdown path has unstaged changes: README.md"*) ;;
  *)
    printf 'guard failure lacked the expected context: %s\n' "$output" >&2
    exit 1
    ;;
esac

git -C "$test_repo" add README.md
(cd "$test_repo" && "$guard")
printf 'staged Markdown guard regression passed\n'
