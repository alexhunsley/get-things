#!/bin/zsh
#
# Checks out a given release tag of project (using git worktree that is then removed from main repo),
# and shows a diff between that and the main checkout folder on your machine.
# 
# This script assumes you have Beyond Compare installed. If you don't,
# edit DIFF_EXECUTABLE to use kdiff3 or something similar.
# 
# Whatever diff program you use needs to not exit until the diff has been closed. 
# If your diff program *doesn't* do this, you must add the param 'nodel' to the end 
# of your invocation of this script, e.g.:
#
#     co-diff.zsh 5.3.16 nodel
#
# which will cause the checkout dir to not be deleted. You'll have to manually delete
# that worktree/folder after you're finished your diff.
#
# Alex Hunsley 
#

echo "\n"

# Diff executable, including full path if it is not on your path.
# If you set this to empty string, no diff will be attempted.
# DIFF_EXECUTABLE="bcomp"

DIFF_EXECUTABLE="/Applications/Beyond Compare.app/Contents/MacOS/bcomp"
#DIFF_EXECUTABLE="kdiff3"

if [[ ! -z ${DIFF_EXECUTABLE} ]]; then
	which ${DIFF_EXECUTABLE} &> /dev/null
	if [ ! $? -eq 0 ]; then
  		echo "\nCouldn't find diff program '${DIFF_EXECUTABLE}' on path, exiting.\nPlease edit co-diff.zsh and supply path to a diff program.\n\n"
  	exit 1
	fi
fi

if [[ -z ${PROJECT_DIR} ]]; then
	echo "\nYou must have PROJECT_DIR defined before running this script. Define it in your .zshrc (or appropriate rc file)\nto point at your main checkout folder.\n\n"
	exit 1
fi

# This script creates a copy of the ${PROJECT_DIR} dir at the same level,
# named like "<originalName>--4.3.17--forDiff".

# TODO We could check if the main checkout has any local changes,
# and exit the script if so.
# For hints on how we'd do this, see https://stackoverflow.com/a/3879077/348476
pushd "${PROJECT_DIR}"

export VERSION=$1

PARENT_DIR=$PROJECT_DIR:h

COPY_DIR="${PROJECT_DIR}--${VERSION}--forDiff"

rm -rf "${COPY_DIR}"

git worktree prune

if (( $# == 0 ))
then
	echo "\nThis command checks out a given release tag of the project and shows a diff between that\nand the current checkout.\n\nUsage:\n    co-diff.zsh <tag, branch, or commit> [no-del]\n\nIf you provide any second parameter, the copy of the repo won't be deleted on exit.\n"
	exit 1
fi

#export TAG="releasetag/$1"
export TAG="$1"

if ! git rev-parse "$TAG" >/dev/null 2>&1; then
  echo "\nSorry, the tag $TAG doesn't exist. Exiting.\n\n";
  exit 1
fi

echo "Copying project to ${COPY_DIR} at tag ${TAG}...\n"

# Do a worktree checkout of code at the given tag.
# This is reasonably fast because it doesn't copy across the whole .git dir.
#
# git worktree remove doesn't seem to have an option to leave the actual files there,
# so we make the worktree somewhere else, rename it, then force remove the worktree ---
# so git can't delete the worktree files as it there aren't where it expects them to be
git worktree add "${COPY_DIR}--actualWorktree" ${TAG}

mv "${COPY_DIR}--actualWorktree" "${COPY_DIR}"

# this .git file is just a small text file pointing to main repo, but may as well remove to tidy up
rm -f "${COPY_DIR}/.git"

# HA! good luck deleting those files, git! teeheedee!
git worktree remove -f -f "${COPY_DIR}--actualWorktree"

# if diff executable specified (non-empty string)
if [[ -z $DIFF_EXECUTABLE ]]; then
	echo "Done. (Not doing a diff since DIFF_EXECUTABLE is empty)"
else
	echo "Done. Launching diff...\n"

	if (( $# < 2 ))
	then
		echo "(will delete copy dir when Best Compare exits)"
	fi

	echo "\n\n"

	# bcomp command and kdiff3 don't return until that beyond compare tab/window has been closed.
	# not sure about other programs
	"${DIFF_EXECUTABLE}" "$COPY_DIR" "$PROJECT_DIR"
fi

######################################################
######################################################
######################################################
######################################################
# TODO - REFUSE TO DELETE WORKING TREE IF THERE ARE ANY LOCAL CHANGES, AND WARN USER!

if (( $# < 2 ))
then
	echo "\nDeleting copy of project..."

	rm -rf "$COPY_DIR"
else
	echo "\n(Not deleting ${COPY_DIR} - please do this yourself when you've finished your diff!)\n\n"
fi

git worktree prune

echo "\nAll done.\n\n"

popd

--- BEGIN LICENSE KEY ---
Gi5OXC1z7wnIpUto8Llb9uVA-WwxxsK4U9AswiRFkcGvX4wNi7OboP3Ja
zvs2Bprot0gCi53jRcsuyGZBuD4DMa2KJBoN+bQoovB-ZSTRO+sd-s8-N
KmWp-bIvHiQgV+rFfCzvEqGMrOvHmgnv4CtiaWzyCr5O7sF7v8rM8Zdv0
Y58TduYmVcuIZy5EdskpjtyKXOBrK3FgnFTgIWIx1g7KxrtKHZ921Xup1
C-zV+qSbP5RRKwWGREciuiP3EuuxCeegxBHh0e38p2iRPv6oOrkivZQ7D
0nPK1KU9SyvvByf5TippgrKsEePXHl745qVN0DOPopKsm33AKRVLT9lDU
--- END LICENSE KEY -----

