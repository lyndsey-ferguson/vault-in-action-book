provider "vault" {
  address         = "https://${var.vault_server_subdomain}.${var.root_domain_name}:8200"
  skip_tls_verify = !var.is_production
  token           = var.vault_token
}

resource "random_pet" "env" {
  length    = 2
  separator = "_"
}

module "chapter3" {
  source    = "./modules/chapter03"
  namespace = var.namespace
}

module "chapter4" {
  source    = "./modules/chapter04"
  namespace = var.namespace

  vault_admin_users = ["sean", "ruth", "beth"]
}

module "chapter5" {
  source    = "./modules/chapter05"
  namespace = var.namespace

  vault_admin_users = ["sean", "ruth", "beth"]
}

module "chapter6" {
  source    = "./modules/chapter06"
  namespace = var.namespace
}

output "vault_admin_users" {
  value = module.chapter4.admin_user_password_map
}

output "internal_network_user_token" {
  value = module.chapter6.internal_network_user_token
}
