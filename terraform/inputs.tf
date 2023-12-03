variable "OAUTH_CLIENT_ID" {
  type        = string
  description = "Client ID for Tailscale"
}
variable "OAUTH_CLIENT_SECRET" {
  type        = string
  description = "Secret for Tailscale"
}

variable "PROXMOX_VE_API_TOKEN" {
  type        = string
  description = "API Token for Proxmox"

}
variable "PROXMOX_VE_SSH_USERNAME" {
  type        = string
  description = "SSH Username for Proxmox hosts"
}
variable "PROXMOX_VE_SSH_PASSWORD" {
  type        = string
  description = "SSH Password for Proxmox hosts"
}
