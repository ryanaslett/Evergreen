#!/bin/bash
# Proof of concept showing that re-rolls can be *fast* without checking out all of core.


ISSUEID='1920862'
PATCH='1920862-51.patch'
COMMENT_DATE_OF_PATCH='May 9, 2014 at 7:22pm'
DRUPAL8_REPOSITORY='../Drupal_no_checkout'

# Right now this assumes that I have a repository checked out
# Under ../Drupal_no_checkout created with:
# git clone http://git.drupal.org/project/drupal.git -n Drupal_no_checkout

# TODO: Take in arguments/Make it loop.

# The -s options create a shared clone of the local repo
# (it uses symlinks to the original .git in DRUPAL8_REPOSITORY
# This is much faster and saves disk space.
# The -n prevents the clone from checking out a working directory
echo "cloning"
git clone -n -s -q ${DRUPAL8_REPOSITORY} issue_${ISSUEID}
cd issue_${ISSUEID}
wget https://drupal.org/files/issues/${PATCH}

# This reads the patch and checks out *only the files that have changed*
# ignoring newly added files
lsdiff --strip=1 -s ${PATCH} |awk '!/^\+/ {print $2}' |xargs git checkout HEAD
echo "applying patch"
git apply ${PATCH}

if [ $? -ne 0 ]; then
echo "git apply FAILED"
echo "Sparse Checkout"
  # This does a 'sparse checkout' which configures the repository to think
  # That it is only tracking the changed files
  git config core.sparsecheckout true
  lsdiff --strip=1 -s ${PATCH} |awk '{print $2}' >> .git/info/sparse-checkout
  git read-tree -m -u HEAD

  # This gets the commit ID of when the patch last applied *and passed tests*
  COMMITID=`git log --before="${COMMENT_DATE_OF_PATCH}" -1 --pretty=format:%H`

  # Reset our mini repo to that commit id, reapply the patch, and rebase onto origin/HEAD
  echo "git reset"
  git reset -q ${COMMITID}
  echo "git create branch"
  git checkout -q -b issue-${ISSUEID}
  echo "git checkout the files"
  lsdiff --strip=1 -s $PATCH |awk '!/^\+/ {print $2}' |xargs git checkout --
  echo "applying patch,again"
  git apply ${PATCH}
  echo "adding files to the commit"
  lsdiff --strip=1 ${PATCH} |xargs git add -A
  echo "commiting"
  git commit -m "${PATCH} applied"
  git rebase origin/HEAD
  if [ $? -ne 0 ]; then
    echo "Automatic rebase failed - merge conflicts happened - use \'git mergetool\' to fix"
  else
    echo "Automatic rebase success!"
  fi

else
  echo "git apply Success - Patch Still Applies against current HEAD"
fi
