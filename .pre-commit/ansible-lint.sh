#!/bin/bash

# arr=()

prefix="ansible/"

# for _file in "$@"; do
#   #[[ "${_file}" == ${prefix}* ]] &&
#   arr+=("${_file#"${prefix}"}")
# done

source ansible/.venv/bin/activate

cd $prefix

sed -i 's/vault_password_file/#vault_password_file/g' ansible.cfg

ansible-lint --nocolor -p -vv

sed -i 's/#vault_password_file/vault_password_file/g' ansible.cfg
