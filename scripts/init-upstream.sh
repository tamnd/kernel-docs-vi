#!/usr/bin/env bash
#
# init-upstream.sh — first-time import of Linux kernel Documentation/.
#
# Usage: scripts/init-upstream.sh [REF]
#   REF defaults to "master" (torvalds/linux HEAD).
#
# Fetches only Documentation/, LICENSES/, and COPYING via a
# blobless + shallow + sparse partial clone, copies them into the repo,
# and writes the UPSTREAM provenance file.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
. "$SCRIPT_DIR/lib/common.sh"

REF="${1:-master}"

require_cmd git rsync

trap cleanup_scratch EXIT

sparse_clone "$REF" "$SCRATCH_DIR"

log "copying Documentation/ (preserving any existing $VI_VN_REL)"
mkdir -p "$REPO_ROOT/Documentation"
rsync -a --delete \
  --exclude="/translations/vi_VN" \
  "$SCRATCH_DIR/Documentation/" \
  "$REPO_ROOT/Documentation/"

log "copying COPYING and LICENSES/"
cp -f "$SCRATCH_DIR/COPYING" "$REPO_ROOT/COPYING"
rm -rf "$REPO_ROOT/LICENSES"
cp -a "$SCRATCH_DIR/LICENSES" "$REPO_ROOT/LICENSES"

sha="$(upstream_sha "$SCRATCH_DIR")"
commit_date="$(upstream_commit_date "$SCRATCH_DIR")"
write_upstream_file "$REF" "$sha" "$commit_date"

log "done. upstream ref=$REF sha=${sha:0:12} date=$commit_date"
log "next: scripts/translation-status.sh to generate TRANSLATION_STATUS.md"
