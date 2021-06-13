# ACME Providers
# Staging allows for multiple test runs without giving you a completely trusted certificate
# Non-staging gives you a fully trusted certificate, but do not spam the URL as you
# will be rate limited and your certificate will not be trusted

provider "acme" {
  server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
}

provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
  alias      = "production"
}

# Private key creation
# These keys are used when creating the ACME registration account.
# Each key is associated to a different account. Each account must
# point to a different server url to be considered correct

resource "tls_private_key" "staging_certificate" {
  algorithm = "RSA"
}

resource "tls_private_key" "certificate" {
  algorithm = "RSA"
}

# ACME Registration
# There is a registration for the staging purposes and one for
# the production purpose

resource "acme_registration" "staging_reg" {
  count    = var.is_production ? 0 : 1
  provider = acme

  account_key_pem = tls_private_key.staging_certificate.private_key_pem
  email_address   = var.acme_certificate_email
}

resource "acme_registration" "reg" {
  count    = var.is_production ? 1 : 0
  provider = acme.production

  account_key_pem = tls_private_key.certificate.private_key_pem
  email_address   = var.acme_certificate_email
}

# ACME Certificates. One is for staging, and the other is for
# production.

resource "acme_certificate" "staging_vault_certificate" {
  count    = var.is_production ? 0 : 1
  provider = acme

  account_key_pem = acme_registration.staging_reg[0].account_key_pem
  common_name     = var.vault_domain_name

  pre_check_delay = 5

  dns_challenge {
    provider = "godaddy"
    config = {
      GODADDY_API_KEY    = "${var.godaddy_api_key}"
      GODADDY_API_SECRET = "${var.godaddy_api_secret}"
    }
  }
}

resource "acme_certificate" "vault_certificate" {
  count    = var.is_production ? 1 : 0
  provider = acme.production

  account_key_pem = acme_registration.reg[0].account_key_pem
  common_name     = var.vault_domain_name

  pre_check_delay = 5

  dns_challenge {
    provider = "godaddy"
    config = {
      GODADDY_API_KEY    = "${var.godaddy_api_key}"
      GODADDY_API_SECRET = "${var.godaddy_api_secret}"
    }
  }
}

