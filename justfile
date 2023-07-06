#!/usr/bin/env -S just --justfile

export BW_SESSION := env_var_or_default('BW_SESSION', "")
export OAUTH_CLIENT_SECRET := env_var_or_default('OAUTH_CLIENT_SECRET', "")
export OAUTH_CLIENT_ID := env_var_or_default('OAUTH_CLIENT_ID', "")
export TF_TOKEN_app_terraform_io := env_var_or_default('TF_TOKEN_app_terraform_io', "")
export LC_ALL := "en_US.UTF-8"

ansible_dir := "ansible"
terraform_dir := "terraform"

venv_dir := ".venv"

python_dir := if os_family() == "windows" { venv_dir + "/Scripts" } else { venv_dir + "/bin" }
python := python_dir + if os_family() == "windows" { "/python.exe" } else { "/python3" }

# Runs the playbook
run *args="-D -t update":
  cd {{ansible_dir}} && {{python_dir}}/ansible-playbook run.yml {{args}}

# Crypts a ansible value
acrypt *args="":
  cd {{ansible_dir}} && {{python_dir}}/ansible-vault encrypt_string {{args}}

# Crypts a kubernetes value
kcrypt *args="":
  sops --encrypt --in-place kubernetes/.sops/{{args}}.yaml

# Runs terraform apply
tf *args="":
  {{_terraform}} apply {{args}}

# Runs terraform apply
plan *args="":
  {{_terraform}} plan {{args}}

_pip-install:
  cd {{ansible_dir}} && {{python_dir}}/pip install -r requirements.txt

_pre-commit-install:
  {{ansible_dir}}/{{python_dir}}/pre-commit install --install-hooks

_galaxy-install *args:
  cd {{ansible_dir}} && {{python_dir}}/ansible-galaxy install -r requirements.yml {{args}}

_init-venv:
  python3 -m venv {{ansible_dir}}/{{venv_dir}}

_terraform := "cd " + terraform_dir + " && terraform"

_init-terraform *args:
  {{_terraform}} init {{args}}

# Initializes the local folder with a venv and packages
git-init: _init-venv && _pip-install _pre-commit-install _galaxy-install _init-venv _init-terraform
  cd {{ansible_dir}} && {{python_dir}}/pip install wheel
  cd {{ansible_dir}} && {{python_dir}}/pip install --upgrade pip

# Upgrades packages, galaxy and pre-commit
upgrade: _pip-install _pre-commit-install (_galaxy-install "--force") (_init-terraform "-upgrade")

# Just vault (encrypt/decrypt/edit)
vault ACTION VAULT="vault/all.yaml":
  cd {{ansible_dir}} && {{python_dir}}/ansible-vault {{ACTION}} {{VAULT}}
