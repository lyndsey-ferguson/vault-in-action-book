variable "aws_region" {
  default = "us-east-1"
}

variable "aws_zone" {
  default = "us-east-1a"
}

variable "vault_server_running" {
  type    = bool
  default = true
}

variable "is_production" {
  type    = bool
  default = false
}

variable "namespace" {}
variable "acme_certificate_email" {}
variable "godaddy_api_key" {}
variable "godaddy_api_secret" {}
variable "root_domain_name" {}
variable "vault_server_subdomain" {}
variable "domain_record_values" {}

variable "vault_address" {
  type        = string
  description = "The URL for the Vault server instance"
  default     = ""
}

