variable "aws_region" {
  default = "us-east-1"
}

variable "aws_zone" {
  default = "us-east-1a"
}

variable "namespace" {
  default = "vault-configuration"
}

variable "is_production" {
  type    = bool
  default = false
}

variable "vault_address" {
  type        = string
  description = "The URL for the Vault server instance"
  default     = ""
}

variable "vault_token" {
  type        = string
  description = "A Vault token that has permissions to enable a secrets engine"
  default     = ""
}

variable "root_domain_name" {}
variable "vault_server_subdomain" {}

