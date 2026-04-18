#!/usr/bin/env bash
#
# sync-upstream.sh — pull a newer version of Documentation/ from upstream
# while preserving Documentation/translations/vi_VN/ intact.
#
# Usage: scripts/sync-upstream.sh [REF]
#   REF defaults to whatever UPSTREAM file says (usually "master").
#
# Prints a summary of added / modified / deleted files so the translator
# knows which vi_VN/ pages may have gone stale.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
. "$SCRIPT_DIR/lib/common.sh"

REF="${1:-$(read_upstream_field ref || echo master)}"

require_cmd git rsync

trap cleanup_scratch EXIT

sparse_clone "$REF" "$SCRATCH_DIR"

new_sha="$(upstream_sha "$SCRATCH_DIR")"
old_sha="$(read_upstream_field commit || true)"

if [[ -n "$old_sha" && "$old_sha" == "$new_sha" ]]; then
  log "already at ${new_sha:0:12}; nothing to do."
  exit 0
fi

log "diff summary (excludes Documentation/translations/vi_VN/):"
# rsync --dry-run --itemize-changes gives per-file change codes.
#  >f+++++++++  = new file
#  >f.st......  = modified
#  *deleting    = deletion (with --delete)
rsync -ain --delete \
  --exclude="/translations/vi_VN" \
  "$SCRATCH_DIR/Documentation/" \
  "$REPO_ROOT/Documentation/" | awk '
    /^>f\+\+\+/ { added++;    print "  A " $2; next }
    /^\*deleting/ { deleted++; print "  D " $2; next }
    /^>f/       { modified++; print "  M " $2; next }
  END {
    printf "\n  total: %d added, %d modified, %d deleted\n",
      added+0, modified+0, deleted+0 > "/dev/stderr"
  }'

log "applying changes..."
rsync -a --delete \
  --exclude="/translations/vi_VN" \
  "$SCRATCH_DIR/Documentation/" \
  "$REPO_ROOT/Documentation/"

log "refreshing COPYING and LICENSES/"
cp -f "$SCRATCH_DIR/COPYING" "$REPO_ROOT/COPYING"
rm -rf "$REPO_ROOT/LICENSES"
cp -a "$SCRATCH_DIR/LICENSES" "$REPO_ROOT/LICENSES"

commit_date="$(upstream_commit_date "$SCRATCH_DIR")"
write_upstream_file "$REF" "$new_sha" "$commit_date"

log "synced to $REF @ ${new_sha:0:12} ($commit_date)"
log "review with: git status && git diff --stat"
