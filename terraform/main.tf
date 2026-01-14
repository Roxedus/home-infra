terraform {
  required_providers {
    tailscale = {
      source  = "tailscale/tailscale"
      version = "0.25.0"
    }
  }
}
provider "tailscale" {
  tailnet             = "rostvik.no"
  scopes              = ["all"]
  oauth_client_id     = var.OAUTH_CLIENT_ID
  oauth_client_secret = var.OAUTH_CLIENT_SECRET
}
