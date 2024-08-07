#!/usr/bin/env -S just --justfile

export BW_SESSION := env_var_or_default('BW_SESSION', "")
export TF_VAR_OAUTH_CLIENT_SECRET := env_var_or_default('OAUTH_CLIENT_SECRET', "")
export TF_VAR_OAUTH_CLIENT_ID := env_var_or_default('OAUTH_CLIENT_ID', "")
export UID := env_var_or_default('UID', "")
export GID := env_var_or_default('GID', "")
export LC_ALL := "en_US.UTF-8"

ansible_dir := "ansible"
terraform_dir := "terraform"
packer_dir := "packer"

venv_dir := ".venv"

python_dir := if os_family() == "windows" { venv_dir + "/Scripts" } else { venv_dir + "/bin" }
python := python_dir + if os_family() == "windows" { "/python.exe" } else { "/python3" }

default:
  just --list

# Runs the playbook
run *args="-D -t update":
  cd {{ansible_dir}} && {{python_dir}}/ansible-playbook run.yml {{args}}

# Crypts a ansible value
acrypt *args="":
  cd {{ansible_dir}} && {{python_dir}}/ansible-vault encrypt_string {{args}}

afact *host="":
  cd {{ansible_dir}} && {{python_dir}}/ansible {{host}} -m ansible.builtin.setup

# Crypts a kubernetes value
kcrypt *args="":
  sops --encrypt --in-place kubernetes/{{args}}.sops.yaml

# Crypts a kubernetes value
sops_mac *args="":
  EDITOR="vim -es +'norm Go' +':wq'"  sops --ignore-mac kubernetes/"{{args}}".sops.yaml

# Runs terraform apply
tf *args="":
  {{_terraform}} apply {{args}}

# Runs terraform apply
plan *args="":
  {{_terraform}} plan {{args}}

pack node="" type="kube":
  {{_packer}} build -var 'node={{node}}' -var 'type={{type}}' arm64-ubuntu2204-node.pkr.hcl

pack_base:
  {{_packer}} build arm64-ubuntu2204-base.pkr.hcl

kicks:
  docker run --rm -t -u $UID:$GID -v ${PWD}:/path --workdir /path checkmarx/kics:latest scan --config ./.kics/config.yml

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

_get_state:
  kubectl get secret tfstate-default-home-infra -n flux-system \
    -ojsonpath='{.data.tfstate}' \
    | base64 -d | gzip -d > terraform/terraform.tfstate

_push_state:
  gzip terraform/terraform.tfstate -c | \
    kubectl create secret \
      generic tfstate-default-home-infra -n flux-system \
      --from-file=tfstate=/dev/stdin \
      --dry-run=client -o=yaml \
        | yq e '.metadata.annotations["encoding"]="gzip"' - \
          > kubectl apply -f -

_packer:= "cd " + packer_dir + "&& docker run --rm --privileged -v /dev:/dev -v ${PWD}:/build mkaczanowski/packer-builder-arm:1.0.9"

# Initializes the local folder with a venv and packages
git-init: _init-venv && _pip-install _pre-commit-install _galaxy-install _init-terraform
  cd {{ansible_dir}} && {{python_dir}}/pip install wheel
  cd {{ansible_dir}} && {{python_dir}}/pip install --upgrade pip

# Upgrades packages, galaxy and pre-commit
upgrade: _pip-install _pre-commit-install (_galaxy-install "--force") (_init-terraform "-upgrade")

# Just vault (encrypt/decrypt/edit)
vault ACTION VAULT="vault/all.yaml":
  cd {{ansible_dir}} && {{python_dir}}/ansible-vault {{ACTION}} {{VAULT}}
