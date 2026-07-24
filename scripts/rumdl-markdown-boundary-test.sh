#!/usr/bin/env bash
set -euo pipefail

readonly root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
readonly work="$(mktemp -d "$root/.rumdl-boundary.XXXXXX")"
cd "$root"
trap 'rm -rf "$work"' EXIT

cat > "$work/fixture.md" <<'EOF'
1. one
3. two

| Name | Value |
| ---- | ----- |
| a | b |
EOF
cp "$work/fixture.md" "$work/mutation.md"
rumdl check --deny-config-warnings -- "$work/fixture.md"
rumdl fmt --silent --extend-enable MD029,MD060 --config 'MD060.enabled = true' -- "$work/fixture.md"
expected=$'1. one\n2. two\n\n| Name | Value |\n| ---- | ----- |\n| a    | b     |\n'
actual="$(cat "$work/fixture.md")"$'\n'
[[ "$actual" == "$expected" ]] || { printf 'unexpected formatted boundary fixture:\n%s' "$actual" >&2; exit 1; }

if rumdl check --deny-config-warnings --extend-enable MD060 -- "$work/mutation.md"; then
  printf 'formatter override mutation unexpectedly succeeded\n' >&2
  exit 1
fi

call_sites=$(find "$root" -path "$root/.git" -prune -o -type f ! -name mise.lock -exec grep -l 'rumdl fmt' {} + | sort)
expected_sites="$root/lefthook/lint.yml
$root/mise-tasks/check/markdown-format
$root/mise-tasks/format/markdown
$root/scripts/rumdl-markdown-boundary-test.sh"
[[ "$call_sites" == "$expected_sites" ]] || { printf 'formatter call-site inventory changed:\n%s\n' "$call_sites" >&2; exit 1; }
printf 'rumdl formatter boundary regression passed\n'
