terraform {
  required_providers {
    tailscale = {
      source  = "tailscale/tailscale"
      version = "0.13.10"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.32.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.4.0"
    }
  }
}
provider "tailscale" {
  tailnet             = "rostvik.no"
  scopes              = ["all"]
  oauth_client_id     = var.OAUTH_CLIENT_ID
  oauth_client_secret = var.OAUTH_CLIENT_SECRET
}

provider "proxmox" {
  endpoint = "https://pve.rostvik.site:8006/"
  username = var.PROXMOX_VE_USERNAME
  password = var.PROXMOX_VE_PASSWORD
  insecure = true
  ssh {
    username = var.PROXMOX_VE_SSH_USERNAME
    password = var.PROXMOX_VE_SSH_PASSWORD
  }
}

provider "random" {}

provider "http" {}
