#!/bin/bash

ansible_dir=ansible/

cd $ansible_dir || exit 1

.venv/bin/ansible-lint "${@//$ansible_dir/}"
