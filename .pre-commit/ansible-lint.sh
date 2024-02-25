#!/bin/bash

# arr=()

prefix="ansible/"

# for _file in "$@"; do
#   #[[ "${_file}" == ${prefix}* ]] &&
#   arr+=("${_file#"${prefix}"}")
# done

cd $prefix

ansible-lint --force-color -p
