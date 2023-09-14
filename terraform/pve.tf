locals {
  pve_node = "pve"
}

data "http" "github_keys" {
  url = "https://github.com/roxedus.keys"
}

data "proxmox_virtual_environment_datastores" "node" {
  node_name = local.pve_node
}

resource "random_password" "container_password" {
  length           = 32
  override_special = "_%@"
  special          = true
}

# resource "proxmox_virtual_environment_file" "ubuntu_2204" {
#   content_type = "vztmpl"
#   datastore_id = "local-btrfs"
#   node_name    = local.pve_node

#   source_file {
#     path = "http://download.proxmox.com/images/system/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
#   }
# }

resource "proxmox_virtual_environment_container" "siem_container" {
  description = "Managed by Terraform"

  node_name = local.pve_node

  initialization {
    hostname = "siem"

    dns {
      domain = "rostvik.site"
      server = "10.0.0.31"
    }

    ip_config {
      ipv4 {
        address = "10.0.0.35"
      }
    }

    user_account {
      keys     = split("\n", trimspace(data.http.github_keys.response_body))
      password = random_password.container_password.result
    }
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 2048
  }

  disk {
    datastore_id = element(data.proxmox_virtual_environment_datastores.node.datastore_ids, index(data.proxmox_virtual_environment_datastores.node.datastore_ids, "Nvme"))
    size         = 100
  }

  network_interface {
    name = "veth0"
  }

  operating_system {
    template_file_id = "local-btrfs:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst" #proxmox_virtual_environment_file.ubuntu_2204.id
    type             = "ubuntu"
  }

}
