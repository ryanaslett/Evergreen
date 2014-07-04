Evergreen
=========

Bash Script to rapidly reroll patches with minimal disk impact

This proof of concept leverages shared .git checkouts along with sparse checkouts
to allow for extremely rapid, and automated rerolling of drupal patches.

For now it requires that you set 4 variables in the script:

* ISSUEID='1920862'
* PATCH='1920862-51.patch'
* COMMENT_DATE_OF_PATCH='May 9, 2014 at 7:22pm'
* DRUPAL8_REPOSITORY='../Drupal_no_checkout'

It will attempt to apply the patch to HEAD first, then apply it to its last known good and attempt to rebase that onto head.

One caveat is that some patches that require rerolls *also* need to verify that their impact hasnt spread to new code
that has been added since the last patch was submitted (i.e. renaming files, refactoring names etc)

If thats the case, then I suggest you create a patch that applies and move it to a full working tree.
