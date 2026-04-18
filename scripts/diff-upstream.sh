#!/usr/bin/env bash
#
# diff-upstream.sh — preview what `sync-upstream.sh` would change, without
# touching the working tree. Useful before running a real sync.
#
# Usage: scripts/diff-upstream.sh [REF]
#   REF defaults to UPSTREAM ref (usually "master").

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
. "$SCRIPT_DIR/lib/common.sh"

REF="${1:-$(read_upstream_field ref || echo master)}"

require_cmd git rsync diff

trap cleanup_scratch EXIT

sparse_clone "$REF" "$SCRATCH_DIR"

new_sha="$(upstream_sha "$SCRATCH_DIR")"
old_sha="$(read_upstream_field commit || echo "<none>")"
log "current: ${old_sha:0:12}    upstream $REF: ${new_sha:0:12}"

log "file-level change set (excludes Documentation/translations/vi_VN/):"
rsync -ain --delete \
  --exclude="/translations/vi_VN" \
  "$SCRATCH_DIR/Documentation/" \
  "$REPO_ROOT/Documentation/" | awk '
    /^>f\+\+\+/ { print "  A " $2; next }
    /^\*deleting/ { print "  D " $2; next }
    /^>f/       { print "  M " $2; next }'

log "full unified diff (Documentation/, excluding vi_VN/):"
diff -ruN \
  --exclude=vi_VN \
  "$REPO_ROOT/Documentation" \
  "$SCRATCH_DIR/Documentation" || true
