#!/bin/bash

# arr=()

prefix="ansible/"

# for _file in "$@"; do
#   #[[ "${_file}" == ${prefix}* ]] &&
#   arr+=("${_file#"${prefix}"}")
# done

source ansible/.venv/bin/activate

cd $prefix

yq -i '.mock_roles = [load("requirements.yml").roles[].name]' .ansible-lint

sed -i 's/vault_password_file/#vault_password_file/g' ansible.cfg

ansible-lint --nocolor -p

real_exit=$?

sed -i 's/#vault_password_file/vault_password_file/g' ansible.cfg

exit $real_exit
