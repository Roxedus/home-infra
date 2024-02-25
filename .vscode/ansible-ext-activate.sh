#!/bin/bash

# This script is used to activate the ansible extension in VSCode
# It is called by the ansible extension in VSCode

# https://github.com/ansible/ansible/issues/78283#issuecomment-1188345809

export LC_ALL=en_US.UTF-8

. ansible/.venv/bin/activate
