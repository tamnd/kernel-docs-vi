# Shared helpers for scripts/*.sh
# shellcheck shell=bash

set -euo pipefail

UPSTREAM_URL_DEFAULT="https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
UPSTREAM_FILE="${REPO_ROOT}/UPSTREAM"
SCRATCH_DIR="${REPO_ROOT}/_upstream"

# Paths we care about from the kernel tree. Anything outside this list is
# discarded — this is what keeps the checkout small.
SPARSE_PATHS=(Documentation LICENSES COPYING)

# Translation root that must never be overwritten by sync. Anything under
# Documentation/translations/vi_VN/ is "ours" and is preserved across syncs.
VI_VN_REL="Documentation/translations/vi_VN"

log()  { printf '\033[1;34m[kernel-docs-vi]\033[0m %s\n' "$*" >&2; }
warn() { printf '\033[1;33m[kernel-docs-vi]\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31m[kernel-docs-vi]\033[0m %s\n' "$*" >&2; exit 1; }

require_cmd() {
  for c in "$@"; do
    command -v "$c" >/dev/null 2>&1 || die "missing required command: $c"
  done
}

# sparse_clone <ref> <dest>
# Blobless + shallow + sparse partial clone of upstream. Only SPARSE_PATHS
# end up on disk. Transfer for Documentation+LICENSES+COPYING is ~40-60MB
# vs ~1.5GB for a full clone.
sparse_clone() {
  local ref="$1" dest="$2"
  local url="${UPSTREAM_URL:-$UPSTREAM_URL_DEFAULT}"

  rm -rf "$dest"
  log "cloning $url @ $ref (blobless, depth=1, sparse)"
  git clone \
    --filter=blob:none \
    --no-checkout \
    --depth=1 \
    --single-branch \
    --branch "$ref" \
    "$url" "$dest"

  (
    cd "$dest"
    git sparse-checkout init --cone
    git sparse-checkout set "${SPARSE_PATHS[@]}"
    git checkout "$ref"
  )
}

# upstream_sha <dir>   -> full commit SHA of HEAD in the clone
upstream_sha() { git -C "$1" rev-parse HEAD; }

# upstream_commit_date <dir>  -> ISO-8601 committer date of HEAD
upstream_commit_date() { git -C "$1" show -s --format=%cI HEAD; }

# write_upstream_file <ref> <sha> <commit_date>
write_upstream_file() {
  local ref="$1" sha="$2" commit_date="$3"
  local synced_at
  synced_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  cat > "$UPSTREAM_FILE" <<EOF
# Provenance of the upstream Documentation/ tree mirrored in this repo.
# Updated by scripts/init-upstream.sh and scripts/sync-upstream.sh.
ref: $ref
commit: $sha
date: $commit_date
source: ${UPSTREAM_URL:-$UPSTREAM_URL_DEFAULT}
synced_at: $synced_at
EOF
}

# read_upstream_field <key>
read_upstream_field() {
  local key="$1"
  [[ -f "$UPSTREAM_FILE" ]] || return 1
  awk -v k="$key" '$1 == k":" { print $2; exit }' "$UPSTREAM_FILE"
}

# cleanup_scratch — always safe to call; used in traps.
cleanup_scratch() { rm -rf "$SCRATCH_DIR"; }
