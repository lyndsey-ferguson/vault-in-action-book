variable "namespace" {
  type = string
}

variable "unique_resource_name" {
  type = string
}

variable "is_production" {
  type = bool
}

variable "acme_certificate_email" {
  type = string
}

variable "vault_domain_name" {
  type = string
}

variable "godaddy_api_key" {
  type = string
}

variable "godaddy_api_secret" {
  type = string
}

