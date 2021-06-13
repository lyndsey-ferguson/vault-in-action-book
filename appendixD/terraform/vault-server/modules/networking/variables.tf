variable "aws_region" {
  type        = string
  description = "The AWS region within which to create the resources"
}

variable "aws_zone" {
  type        = string
  description = "The AWS zone where teh resources will be created"
}

variable "namespace" {
  type        = string
  description = "The project namespace to use for unique resource naming"
}

variable "vpc_cidr" {
  type    = string
  default = "192.168.100.0/24"
}

variable "root_domain_name" {
  type        = string
  description = "The root domain name which the subdomain name will be prefixed to. For example, 'example.com'"
}

variable "unique_resource_name" {
  type        = string
  description = "A name appended to resources to keep them unique"
}

variable "acme_certificate_email" {
  type        = string
  description = "The email address that Let's Encrypt will associate with the SSL certificates account"
}

variable "godaddy_api_key" {
  type        = string
  description = "The GoDaddy API key to manage Domains"
}

variable "godaddy_api_secret" {
  type        = string
  description = "The GoDaddy API secret to authenticate into the Domain management system"
}

variable "is_production" {
  type        = bool
  description = "Whether or not to create a certificate using the Let's Encrypt staging server and avoiding rate limits"
  default     = false
}
