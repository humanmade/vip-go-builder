#!/bin/bash -e
#
# Deploy your branch on VIP Go.
#

BRANCH="${CIRCLE_BRANCH}"
DEPLOY_SUFFIX="${DEPLOY_SUFFIX:--built}"
SRC_DIR="$PWD"
BUILD_DIR="/tmp/vip-go-build"

if [[ -z "$BRANCH" ]]; then
	echo "No branch specified!"
	exit 1
fi

if [[ -d "$BUILD_DIR" ]]; then
	echo "WARNING: ${BUILD_DIR} already exists. You may have accidentally cached this"
	echo "directory. This will cause issues with deploying."
	exit 1
fi

COMMIT=$(git rev-parse HEAD)
DEPLOY_BRANCH="${BRANCH}${DEPLOY_SUFFIX}"
echo "Deploying $BRANCH to $DEPLOY_BRANCH"

# If the deploy branch doesn't already exist, create it from the empty root.
if ! git rev-parse --verify "remotes/origin/$DEPLOY_BRANCH" >/dev/null 2>&1; then
	echo -e "\nCreating $DEPLOY_BRANCH..."
	git worktree add --detach "$BUILD_DIR"
	cd "$BUILD_DIR"
	git checkout --orphan "$DEPLOY_BRANCH"
else
	echo "Using existing $DEPLOY_BRANCH"
	git worktree add --detach "$BUILD_DIR" "remotes/origin/$DEPLOY_BRANCH"
	cd "$BUILD_DIR"
	git checkout "$DEPLOY_BRANCH"
fi

# Ensure we're in the right dir
cd "$BUILD_DIR"

# Remove existing files
git rm -rfq .

# Sync built files
echo -e "\nSyncing files..."
if ! command -v 'rsync'; then
	sudo apt-get install -q -y rsync
fi

rsync -av "$SRC_DIR/" "$BUILD_DIR" --exclude ".git"

# Add changed files
git add .

if [ -z "$(git status --porcelain)" ]; then
	echo "No changes to built files."
	exit
fi

# Print status!
echo -e "\nSynced files. Changed:"
git status -s

# Double-check our user/email config
if ! git config user.email; then
	git config user.name "CircleCI"
	git config user.email "ryan+circle-vip-go@hmn.md"
fi

# Commit it.
MESSAGE=$( printf 'Build changes from %s\n\n%s' "${COMMIT}" "${CIRCLE_BUILD_URL}" )
git commit -m "$MESSAGE"

# Push it (real good).
git push origin "$DEPLOY_BRANCH"
