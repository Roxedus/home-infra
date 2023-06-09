terraform {
  required_providers {
    tailscale = {
      source  = "tailscale/tailscale"
      version = "0.13.7"
    }
  }
  # cloud {
  #   organization = "rostvik_no"

  #   workspaces {
  #     name = "home-infra"
  #   }
  # }
}
provider "tailscale" {
  tailnet             = "rostvik.no"
  scopes              = ["all"]
  oauth_client_id     = var.OAUTH_CLIENT_ID
  oauth_client_secret = var.OAUTH_CLIENT_SECRET
}
