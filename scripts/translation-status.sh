#!/usr/bin/env bash
#
# translation-status.sh — walk Documentation/ and report Vietnamese
# translation coverage. Writes TRANSLATION_STATUS.md at the repo root.
#
# A "source file" is any .rst / .txt / .md under Documentation/ that is
# not inside Documentation/translations/. A translation exists if the
# corresponding path under Documentation/translations/vi_VN/ is present.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
. "$SCRIPT_DIR/lib/common.sh"

DOC_ROOT="$REPO_ROOT/Documentation"
VI_ROOT="$REPO_ROOT/$VI_VN_REL"
OUT="$REPO_ROOT/TRANSLATION_STATUS.md"

[[ -d "$DOC_ROOT" ]] || die "Documentation/ missing — run scripts/init-upstream.sh first"

ref="$(read_upstream_field ref || echo master)"
sha="$(read_upstream_field commit || echo '<unknown>')"
synced_at="$(read_upstream_field synced_at || echo '<unknown>')"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT
sources="$tmp_dir/sources"      # one path per line
coverage="$tmp_dir/coverage"    # lines: "0|1 section rel"

# Collect source files (excluding translations/ tree entirely).
(
  cd "$DOC_ROOT"
  find . \
    \( -name '*.rst' -o -name '*.txt' -o -name '*.md' \) \
    -not -path './translations/*' \
    -not -path './output/*' \
    | sed 's|^\./||' \
    | LC_ALL=C sort
) > "$sources"

# Build the coverage file: "flag<TAB>section<TAB>rel"
# flag=1 if vi_VN translation exists, else 0.
while IFS= read -r rel; do
  section="${rel%%/*}"
  [[ "$section" == "$rel" ]] && section='(root)'
  flag=0
  [[ -f "$VI_ROOT/$rel" ]] && flag=1
  printf '%d\t%s\t%s\n' "$flag" "$section" "$rel"
done < "$sources" > "$coverage"

total=$(wc -l < "$sources" | tr -d ' ')
translated=$(awk -F'\t' '$1 == 1' "$coverage" | wc -l | tr -d ' ')
pct=0
(( total > 0 )) && pct=$(( translated * 100 / total ))

{
  echo "# Trạng thái dịch thuật — Vietnamese Translation Status"
  echo
  echo "Sinh tự động bởi \`scripts/translation-status.sh\`. Đừng chỉnh tay."
  echo
  echo "- Upstream ref: \`$ref\`"
  echo "- Upstream commit: \`${sha:0:12}\`"
  echo "- Đồng bộ lần cuối: \`$synced_at\`"
  echo "- Nguồn: \`Documentation/\` (loại trừ \`Documentation/translations/\`)"
  echo "- Đích: \`$VI_VN_REL/\`"
  echo "- Tổng số tệp nguồn: **$total**"
  echo "- Đã dịch: **$translated** (${pct}%)"
  echo
  echo "## Tóm tắt theo mục"
  echo
  echo "| Mục | Đã dịch | Tổng | % |"
  echo "|---|---:|---:|---:|"
  awk -F'\t' '
    { total[$2]++; if ($1 == 1) done[$2]++ }
    END {
      for (s in total) print s "\t" (done[s]+0) "\t" total[s]
    }' "$coverage" \
    | LC_ALL=C sort \
    | awk -F'\t' '{
        pct = $3 > 0 ? int($2*100/$3) : 0
        printf "| `%s` | %d | %d | %d%% |\n", $1, $2, $3, pct
      }'
  echo
  echo "## Danh sách tệp"
  echo
  echo "Dấu \`[x]\` nghĩa là đã có tệp tương ứng trong \`$VI_VN_REL/\`."
  echo

  awk -F'\t' '
    {
      section = $2
      rel = $3
      if (section != last) {
        printf "\n### %s\n\n", section
        last = section
      }
      mark = ($1 == 1) ? "[x]" : "[ ]"
      printf "- %s `%s`\n", mark, rel
    }' "$coverage"
} > "$OUT"

log "wrote $OUT — $translated/$total translated (${pct}%)"
