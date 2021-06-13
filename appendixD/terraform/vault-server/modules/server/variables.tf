variable "namespace" {
  type        = string
  description = "The project namespace to use for unique resource naming"
}

variable "vault_url" {
  default = "https://releases.hashicorp.com/vault/1.6.0/vault_1.6.0_linux_amd64.zip"
}

variable "unique_resource_name" {
  type        = string
  description = "A unique name to be used when creating AWS resources"
}

variable "security" {
  type = object({
    security_group_id = string
    ssh_keyname       = string
  })
}

variable "network" {
  type = object({
    url              = string
    public_subnet_id = string
    aws_region       = string
  })
}

variable "certificate" {
  type = object({
    full_chain_certificate = string
    private_key            = string
  })
}

variable "vault_server_running" {
  type        = bool
  description = "True if the Vault server should be running"
}
