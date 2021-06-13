terraform {
  required_version = ">= 0.12"
  required_providers {
    acme = {
      source                = "vancluever/acme"
      version               = "~> 2.0"
      configuration_aliases = [acme.production]
    }
  }
}

