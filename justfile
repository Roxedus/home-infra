#!/usr/bin/env -S just --justfile

export BW_SESSION := env_var_or_default('BW_SESSION', "")

ansible_dir := "ansible"
venv_dir := ".venv"

python_dir := if os_family() == "windows" { venv_dir + "/Scripts" } else { venv_dir + "/bin" }
python := python_dir + if os_family() == "windows" { "/python.exe" } else { "/python3" }

# Runs the playbook
run *args="-D -t update":
  cd {{ansible_dir}} && {{python_dir}}/ansible-playbook run.yml {{args}}

_pip-install:
  cd {{ansible_dir}} && {{python_dir}}/pip install -r requirements.txt

_pre-commit-install:
  {{ansible_dir}}/{{python_dir}}/pre-commit install --install-hooks

_galaxy-install:
  cd {{ansible_dir}} && {{python_dir}}/ansible-galaxy install -r requirements.yml --force

_init-venv:
  python3 -m venv {{ansible_dir}}/{{venv_dir}}

# Initializes the local folder with a venv and packages
git-init: _init-venv && _pip-install _pre-commit-install _galaxy-install _init-venv
  cd {{ansible_dir}} && {{python_dir}}/pip install wheel
  cd {{ansible_dir}} && {{python_dir}}/pip install --upgrade pip

# Upgrades packages, galaxy and pre-commit
upgrade: _pip-install _pre-commit-install _galaxy-install

# Just vault (encrypt/decrypt/edit)
vault ACTION VAULT="vault/all.yaml":
  cd {{ansible_dir}} && {{python_dir}}/ansible-vault {{ACTION}} {{VAULT}}
