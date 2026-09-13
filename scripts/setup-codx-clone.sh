#!/usr/bin/env bash
# Sets up a fresh, isolated CODX working copy of this repo -- a real
# clone that can never push, on any machine, in one command. See
# AGENTS.md's "Your environment" section for why this exists and
# docs/project-log.md's 2026-09-13 entry for the incident that showed a
# git-config-only approach isn't enough (an inherited GIT_ASKPASS env
# var bypassed it) -- the actual safeguard is .githooks/pre-push
# (tracked in this repo), wired in here via `core.hooksPath`.
#
# Usage: scripts/setup-codx-clone.sh [target-directory]
#   (default target: ~/Documents/bookspell-codex)
#
# Safe to re-run against an existing CODX clone -- it only re-points
# core.hooksPath, it won't touch history or re-clone over real local
# changes.
#
# NEVER run this against CLDO's or CLDA's own clone -- it would make
# THAT clone unable to push too. This script only belongs in CODX's own
# separate directory.

set -euo pipefail

REPO_URL="https://github.com/M4kuWo/bookspell.git"
TARGET="${1:-$HOME/Documents/bookspell-codex}"

if [ -d "$TARGET/.git" ]; then
  echo "Existing git repo found at $TARGET -- re-pointing its hooks path only, not touching its history."
  cd "$TARGET"
  ORIGIN_URL="$(git config --get remote.origin.url || true)"
  if [ "$ORIGIN_URL" != "$REPO_URL" ]; then
    echo "WARNING: $TARGET's origin ($ORIGIN_URL) doesn't match this repo ($REPO_URL)." >&2
    echo "Refusing to touch a clone of a different repository. Pass a different target directory." >&2
    exit 1
  fi
else
  echo "Cloning into $TARGET ..."
  git clone "$REPO_URL" "$TARGET"
  cd "$TARGET"
fi

git config core.hooksPath .githooks
chmod +x .githooks/pre-push

echo
echo "Done. $TARGET is now a CODX clone: pushes are unconditionally blocked"
echo "via .githooks/pre-push (git config core.hooksPath .githooks)."
echo
echo "Verify it yourself before trusting it:"
echo "  cd $TARGET && git push origin main"
echo "  -> should fail immediately with the hook's own BLOCKED message,"
echo "     before any network activity."
