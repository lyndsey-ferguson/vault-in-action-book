variable "namespace" {
  type        = string
  description = "The project namespace to use for unique resource naming"
}

variable "godaddy_api_key" {
  type        = string
  description = "The GoDaddy API key to manage Domains"
}

variable "godaddy_api_secret" {
  type        = string
  description = "The GoDaddy API secret to authenticate into the Domain management system"
}

variable "root_domain_name" {
  type        = string
  description = "The root domain name which the subdomain name will be prefixed to. For example, 'example.com'"
}

variable "root_domain_ips" {
  type        = list(string)
  description = "The IP address that the root domain name will point to. For example, \"example.com\" -> <root_domain_ip>"

  validation {
    condition     = length(var.root_domain_ips) > 0
    error_message = "There must be at least one root IP address for the root domain."
  }
}

variable "vault_server_subdomain" {
  type        = string
  description = "The subdomain for the Vault server"
}

variable "vault_server_ip" {
  type        = string
  description = "The IP address for the Vault server"
}

variable "vault_server_running" {
  type        = bool
  description = "True if the Vault server should be running"
}

variable "other_records" {
  type = list(object({
    name     = string
    type     = string
    data     = string
    ttl      = number
    port     = number
    priority = number
    weight   = number
  }))
  description = "Other records to associate with the domain record"
}
