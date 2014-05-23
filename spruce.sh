#!/bin/bash
ISSUEID='1920862'
PATCH='1920862-51.patch'
COMMENT_DATE_OF_PATCH='May 9, 2014 at 7:22pm'




#echo $ISSUEID
#echo $PATCH
#echo $COMMENT_DATE_OF_PATCH
echo "cloning"
git clone -n -s -q Drupal_no_checkout issue_${ISSUEID}
cd issue_${ISSUEID}
wget https://drupal.org/files/issues/${PATCH}
lsdiff --strip=1 -s ${PATCH} |grep -v ^\+|awk '{print $2}' |xargs git checkout HEAD
echo "applying patch"
git apply ${PATCH}
if [ $? -ne 0 ]; then
echo "git apply FAILED"
echo "Sparse Checkout"
  git config core.sparsecheckout true
  lsdiff --strip=1 -s ${PATCH} |awk '{print $2}' >> .git/info/sparse-checkout
  git read-tree -m -u HEAD


  COMMITID=`git log --before="${COMMENT_DATE_OF_PATCH}" -1 --pretty=format:%H`

  echo "git reset"
  git reset -q ${COMMITID}
  echo "git create branch"
  git checkout -q -b issue-${ISSUEID}
  echo "git checkout the files"
  lsdiff --strip=1 -s $PATCH |grep -v ^\+|awk '{print $2}' |xargs git checkout --
  echo "applying patch,again"
  git apply ${PATCH}

  echo "adding files to the commit"
  lsdiff --strip=1 ${PATCH} |xargs git add -A
  echo "commiting"
  git commit -m "${PATCH} applied"
  # This


fi
