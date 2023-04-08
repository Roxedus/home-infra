#!/bin/bash
# Based on https://gist.github.com/leucos/a9f42e111a8cfc2ebf6e#file-git_hooks_pre-commit

FILES_PATTERN='ansible/.*vault.*\.*$|ansible/vault/*'
REQUIRED='ANSIBLE_VAULT'

EXIT_STATUS=0
wipe="\033[1m\033[0m"
yellow='\033[1;33m'

for f in $(git diff --cached --name-only | grep -E $FILES_PATTERN)
do
  # test for the presence of the required bit.
  MATCH=$(git show :$f | head -n1 | grep --no-messages $REQUIRED)
  if [ ! $MATCH ] ; then
    # Build the list of unencrypted files if any
    UNENCRYPTED_FILES="$f$UNENCRYPTED_FILES"
    EXIT_STATUS=1
  fi
done

if [ ! $EXIT_STATUS = 0 ] ; then
  echo '# COMMIT REJECTED'
  echo '# Looks like unencrypted ansible-vault files are part of the commit:'
  echo '#'
  while read -r line; do
    if [ -n "$line" ]; then
      echo -e "#\t${yellow}unencrypted:   $line${wipe}"
    fi
  done <<< "$UNENCRYPTED_FILES"
  echo '#'
  echo "# Please encrypt them with 'ansible-vault encrypt <file>'"
  echo "#   (or force the commit with '--no-verify')."
  exit $EXIT_STATUS
fi

exit $EXIT_STATUS
