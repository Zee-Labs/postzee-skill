#!/bin/bash
# =============================================================
# Postzee Skill — Release automation
# =============================================================
# Builds a release in three steps:
#   1. (Optional) bump the version in skills/postzee/SKILL.md
#   2. Create the git tag matching the SKILL.md frontmatter version
#   3. Push commit + tag, which triggers .github/workflows/release.yml
#      (builds postzee-skill.zip and publishes a GitHub Release)
#
# The release workflow refuses to publish if `git tag vX.Y.Z` is pushed
# but SKILL.md still says a different version — this script keeps them
# in lockstep.
#
# Usage:
#   ./release.sh              Tag the version currently in SKILL.md and push
#                             (use this when you already bumped manually)
#   ./release.sh patch        3.4.1 → 3.4.2, commit + tag + push
#   ./release.sh minor        3.4.1 → 3.5.0, commit + tag + push
#   ./release.sh major        3.4.1 → 4.0.0, commit + tag + push
#   ./release.sh set X.Y.Z    Bump to an exact version, commit + tag + push
#
# Flags (combine freely):
#   --dry-run / -n            Show what would happen, change nothing
#   --no-push                 Do everything locally, skip the final push
#   --yes / -y                Skip the confirmation prompt
#   --branch BRANCH           Allow running from a non-main branch
#   --help / -h               Print this help
# =============================================================

set -euo pipefail

# ---- Constants ------------------------------------------------------------

REPO_ROOT="$(cd "$(dirname "$(readlink -f "$0" 2>/dev/null || realpath "$0")")" && pwd)"
SKILL_FILE="$REPO_ROOT/skills/postzee/SKILL.md"
DEFAULT_BRANCH="main"

# ANSI colors (skip if output is not a TTY)
if [ -t 1 ]; then
  C_RED=$'\033[0;31m'
  C_GREEN=$'\033[0;32m'
  C_YELLOW=$'\033[0;33m'
  C_BLUE=$'\033[0;34m'
  C_BOLD=$'\033[1m'
  C_RESET=$'\033[0m'
else
  C_RED=""; C_GREEN=""; C_YELLOW=""; C_BLUE=""; C_BOLD=""; C_RESET=""
fi

err() { echo "${C_RED}❌ $*${C_RESET}" >&2; }
warn() { echo "${C_YELLOW}⚠️  $*${C_RESET}" >&2; }
ok() { echo "${C_GREEN}✅ $*${C_RESET}"; }
info() { echo "${C_BLUE}ℹ️  $*${C_RESET}"; }
step() { echo ""; echo "${C_BOLD}▸ $*${C_RESET}"; }

# ---- Arg parsing ----------------------------------------------------------

ACTION="tag-current"      # tag-current | bump-patch | bump-minor | bump-major | bump-set
EXACT_VERSION=""
DRY_RUN=0
SKIP_PUSH=0
SKIP_CONFIRM=0
ALLOW_BRANCH=""

print_usage() {
  cat <<'USAGE'
Postzee Skill — Release automation

Builds a release in three steps:
  1. (Optional) bump the version in skills/postzee/SKILL.md
  2. Create the git tag matching the SKILL.md frontmatter version
  3. Push commit + tag, which triggers .github/workflows/release.yml
     (builds postzee-skill.zip and publishes a GitHub Release)

The release workflow refuses to publish if "git tag vX.Y.Z" is pushed but
SKILL.md still says a different version — this script keeps them in lockstep.

Usage:
  ./release.sh              Tag the version currently in SKILL.md and push
                            (use this when you already bumped manually)
  ./release.sh patch        3.4.1 → 3.4.2, commit + tag + push
  ./release.sh minor        3.4.1 → 3.5.0, commit + tag + push
  ./release.sh major        3.4.1 → 4.0.0, commit + tag + push
  ./release.sh set X.Y.Z    Bump to an exact version, commit + tag + push

Flags (combine freely):
  --dry-run / -n            Show what would happen, change nothing
  --no-push                 Do everything locally, skip the final push
  --yes / -y                Skip the confirmation prompt
  --branch BRANCH           Allow running from a non-main branch
  --help / -h               Print this help
USAGE
  exit 1
}

while [ $# -gt 0 ]; do
  case "$1" in
    patch)        ACTION="bump-patch"; shift ;;
    minor)        ACTION="bump-minor"; shift ;;
    major)        ACTION="bump-major"; shift ;;
    set)
      ACTION="bump-set"
      shift
      EXACT_VERSION="${1:-}"
      if [ -z "$EXACT_VERSION" ]; then
        err "'set' requires a version (e.g., 'set 4.0.0')"
        exit 1
      fi
      shift
      ;;
    --dry-run|-n) DRY_RUN=1; shift ;;
    --no-push)    SKIP_PUSH=1; shift ;;
    --yes|-y)     SKIP_CONFIRM=1; shift ;;
    --branch)     shift; ALLOW_BRANCH="${1:-}"; [ -z "$ALLOW_BRANCH" ] && { err "--branch requires a name"; exit 1; }; shift ;;
    --help|-h)    print_usage ;;
    *)            err "Unknown argument: $1"; print_usage ;;
  esac
done

# ---- Helpers --------------------------------------------------------------

run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "  ${C_YELLOW}[dry-run]${C_RESET} $*"
  else
    eval "$@"
  fi
}

read_skill_version() {
  grep -E '^version:[[:space:]]*' "$SKILL_FILE" | head -n1 | sed -E 's/^version:[[:space:]]*//'
}

semver_bump() {
  local current="$1"
  local bump="$2"
  local major minor patch
  IFS='.' read -r major minor patch <<<"$current"
  if ! [[ "$major" =~ ^[0-9]+$ && "$minor" =~ ^[0-9]+$ && "$patch" =~ ^[0-9]+$ ]]; then
    err "Cannot parse semver '$current' from SKILL.md"
    exit 1
  fi
  case "$bump" in
    patch) patch=$((patch + 1)) ;;
    minor) minor=$((minor + 1)); patch=0 ;;
    major) major=$((major + 1)); minor=0; patch=0 ;;
    *) err "Unknown bump type: $bump"; exit 1 ;;
  esac
  echo "$major.$minor.$patch"
}

ensure_clean_tree() {
  if [ "$DRY_RUN" -eq 1 ]; then return; fi
  if ! git diff --quiet || ! git diff --cached --quiet; then
    err "Working tree has uncommitted changes."
    git status --short
    err "Commit or stash them before releasing."
    exit 1
  fi
}

ensure_branch() {
  local current
  current=$(git rev-parse --abbrev-ref HEAD)
  local expected="${ALLOW_BRANCH:-$DEFAULT_BRANCH}"
  if [ "$current" != "$expected" ]; then
    if [ -n "$ALLOW_BRANCH" ]; then
      err "Asked to release from '$ALLOW_BRANCH' but you're on '$current'."
      exit 1
    fi
    warn "You're on '$current', not '$DEFAULT_BRANCH'."
    warn "Pass --branch $current if this is intentional, or switch first."
    exit 1
  fi
}

ensure_tag_free() {
  local tag="$1"
  if git rev-parse "$tag" >/dev/null 2>&1; then
    err "Tag $tag already exists locally."
    err "Use 'git tag -d $tag' to delete it, or pick a different version."
    exit 1
  fi
  if [ "$DRY_RUN" -eq 0 ] && git ls-remote --exit-code --tags origin "$tag" >/dev/null 2>&1; then
    err "Tag $tag already exists on origin."
    err "If this is a re-release, you must delete the remote tag explicitly:"
    err "  git push --delete origin $tag"
    exit 1
  fi
}

confirm() {
  if [ "$SKIP_CONFIRM" -eq 1 ] || [ "$DRY_RUN" -eq 1 ]; then return; fi
  echo ""
  read -rp "${C_BOLD}Proceed?${C_RESET} [y/N] " ans
  case "$ans" in
    y|Y|yes|YES) ;;
    *) err "Aborted."; exit 1 ;;
  esac
}

# Replace the four version markers inside SKILL.md. Each pattern is anchored
# tightly so the historical "v3.4.1 introduced X" annotation in the file
# table stays untouched.
update_skill_version() {
  local from="$1"
  local to="$2"

  if [ "$DRY_RUN" -eq 1 ]; then
    info "Would rewrite SKILL.md: $from → $to"
    info "  - frontmatter:        version: $to"
    info "  - prose pin:          (\`$to\` in this file)"
    info "  - upgrade hint:       installed version (\`$to\`)"
    info "  - JSON sample:        \"currentVersion\": \"$to\""
    return
  fi

  # macOS sed needs an explicit empty backup arg; use perl for portability.
  perl -i -pe "s/^version:\s*\Q$from\E\s*$/version: $to/" "$SKILL_FILE"
  perl -i -pe "s/\(\`\Q$from\E\` in this file\)/(\`$to\` in this file)/g" "$SKILL_FILE"
  perl -i -pe "s/installed version \(\`\Q$from\E\`\)/installed version (\`$to\`)/g" "$SKILL_FILE"
  perl -i -pe "s/\"currentVersion\":\s*\"\Q$from\E\"/\"currentVersion\": \"$to\"/g" "$SKILL_FILE"

  # Sanity: confirm the new version landed in the frontmatter.
  local actual
  actual=$(read_skill_version)
  if [ "$actual" != "$to" ]; then
    err "SKILL.md frontmatter still says '$actual' after edit; expected '$to'."
    err "Aborting before commit/tag — inspect SKILL.md and rerun."
    exit 1
  fi
  ok "SKILL.md updated to version $to"
}

# ---- Main flow ------------------------------------------------------------

cd "$REPO_ROOT"

if [ ! -f "$SKILL_FILE" ]; then
  err "SKILL.md not found at $SKILL_FILE"
  err "Are you running this from the postzee-skill repo root?"
  exit 1
fi

CURRENT_VERSION=$(read_skill_version)
if [ -z "$CURRENT_VERSION" ]; then
  err "Could not read 'version:' from $SKILL_FILE"
  exit 1
fi

# Decide target version based on action.
case "$ACTION" in
  tag-current)  TARGET_VERSION="$CURRENT_VERSION" ;;
  bump-patch)   TARGET_VERSION=$(semver_bump "$CURRENT_VERSION" patch) ;;
  bump-minor)   TARGET_VERSION=$(semver_bump "$CURRENT_VERSION" minor) ;;
  bump-major)   TARGET_VERSION=$(semver_bump "$CURRENT_VERSION" major) ;;
  bump-set)
    TARGET_VERSION="$EXACT_VERSION"
    if ! [[ "$TARGET_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      err "Version '$TARGET_VERSION' is not a valid semver (X.Y.Z)"
      exit 1
    fi
    ;;
esac

TARGET_TAG="v$TARGET_VERSION"

# ---- Plan summary ---------------------------------------------------------

echo "${C_BOLD}═══════════════════════════════════════════════════${C_RESET}"
echo "${C_BOLD}  Postzee Skill — Release plan${C_RESET}"
echo "${C_BOLD}═══════════════════════════════════════════════════${C_RESET}"
echo ""
echo "  Current SKILL.md version:  ${C_BOLD}$CURRENT_VERSION${C_RESET}"
echo "  Target version:            ${C_BOLD}$TARGET_VERSION${C_RESET}"
echo "  Target tag:                ${C_BOLD}$TARGET_TAG${C_RESET}"
echo "  Action:                    $ACTION"
echo "  Dry run:                   $([ $DRY_RUN -eq 1 ] && echo yes || echo no)"
echo "  Push to origin:            $([ $SKIP_PUSH -eq 1 ] && echo no || echo yes)"
echo ""

# ---- Pre-flight checks ----------------------------------------------------

step "Pre-flight checks"

ensure_branch
ok "On branch $DEFAULT_BRANCH (or override)"

ensure_clean_tree
ok "Working tree clean"

ensure_tag_free "$TARGET_TAG"
ok "Tag $TARGET_TAG is available"

confirm

# ---- Version bump (if requested) ------------------------------------------

if [ "$ACTION" != "tag-current" ]; then
  step "Bumping SKILL.md version"
  update_skill_version "$CURRENT_VERSION" "$TARGET_VERSION"

  step "Committing version bump"
  COMMIT_MSG="chore(skill): bump version $CURRENT_VERSION → $TARGET_VERSION"
  run git add skills/postzee/SKILL.md
  run git commit -m "\"$COMMIT_MSG\""
  ok "Commit created"
else
  # No bump — verify SKILL.md is already at TARGET_VERSION (it must be, since
  # we read it from there, but defensive check).
  if [ "$CURRENT_VERSION" != "$TARGET_VERSION" ]; then
    err "Inconsistent state: target=$TARGET_VERSION but SKILL.md=$CURRENT_VERSION"
    exit 1
  fi
fi

# ---- Tag ------------------------------------------------------------------

step "Creating tag $TARGET_TAG"
TAG_MSG="Release $TARGET_TAG"
run git tag -a "$TARGET_TAG" -m "\"$TAG_MSG\""
ok "Tag $TARGET_TAG created"

# ---- Push -----------------------------------------------------------------

if [ "$SKIP_PUSH" -eq 1 ]; then
  step "Skipping push (--no-push)"
  warn "Don't forget to: git push origin $DEFAULT_BRANCH && git push origin $TARGET_TAG"
else
  step "Pushing branch + tag to origin"
  run git push origin "$DEFAULT_BRANCH"
  run git push origin "$TARGET_TAG"
  ok "Pushed"
fi

# ---- Done -----------------------------------------------------------------

echo ""
echo "${C_BOLD}═══════════════════════════════════════════════════${C_RESET}"
ok "Release $TARGET_TAG initiated."
if [ "$DRY_RUN" -eq 1 ]; then
  warn "(dry run — nothing was actually changed)"
elif [ "$SKIP_PUSH" -eq 1 ]; then
  info "Local commit + tag created. Push when ready."
else
  REPO_OWNER="Zee-Labs/postzee-skill"
  echo "  Watch the build:    https://github.com/$REPO_OWNER/actions"
  echo "  Release page:       https://github.com/$REPO_OWNER/releases/tag/$TARGET_TAG"
  echo "  Latest ZIP URL:     https://github.com/$REPO_OWNER/releases/latest/download/postzee-skill.zip"
fi
echo "${C_BOLD}═══════════════════════════════════════════════════${C_RESET}"
