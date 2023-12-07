terraform {
  required_providers {
    tailscale = {
      source  = "tailscale/tailscale"
      version = "0.13.11"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.40.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
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
  endpoint  = "https://pve.rostvik.site:8006/"
  api_token = var.PROXMOX_VE_API_TOKEN
  insecure  = true
  ssh {
    username = var.PROXMOX_VE_SSH_USERNAME
    password = var.PROXMOX_VE_SSH_PASSWORD
  }
}

provider "random" {}

provider "http" {}
