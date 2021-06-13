resource "random_pet" "env" {
  length    = 2
  separator = "_"
}

module "networking" {
  source                 = "./modules/networking"
  namespace              = var.namespace
  aws_region             = var.aws_region
  aws_zone               = var.aws_zone
  acme_certificate_email = var.acme_certificate_email
  root_domain_name       = var.root_domain_name
  godaddy_api_key        = var.godaddy_api_key
  godaddy_api_secret     = var.godaddy_api_secret
  unique_resource_name   = random_pet.env.id
  is_production          = var.is_production
}

module "security" {
  source                 = "./modules/security"
  namespace              = var.namespace
  unique_resource_name   = random_pet.env.id
  is_production          = var.is_production
  acme_certificate_email = var.acme_certificate_email
  vault_domain_name      = "${var.vault_server_subdomain}.${var.root_domain_name}"
  godaddy_api_key        = var.godaddy_api_key
  godaddy_api_secret     = var.godaddy_api_secret
}

module "server" {
  source               = "./modules/server"
  namespace            = var.namespace
  unique_resource_name = random_pet.env.id

  security = {
    security_group_id = module.networking.security_group_id
    ssh_keyname       = module.security.ssh_keyname
  }

  network = {
    url              = "${var.vault_server_subdomain}.${var.root_domain_name}"
    public_subnet_id = module.networking.public_subnet_id
    aws_region       = var.aws_region
  }

  certificate = {
    full_chain_certificate = module.security.full_chain_certificate
    private_key            = module.security.private_key
  }

  vault_server_running = var.vault_server_running
}

module "domain_name" {
  source    = "./modules/domain_name"
  namespace = var.namespace

  godaddy_api_key    = var.godaddy_api_key
  godaddy_api_secret = var.godaddy_api_secret

  root_domain_ips  = var.domain_record_values.root_domain_ips
  other_records    = var.domain_record_values.other_records
  root_domain_name = var.root_domain_name

  vault_server_subdomain = var.vault_server_subdomain
  vault_server_ip        = module.server.vault_server_ip
  vault_server_running   = var.vault_server_running
}

output "connections" {
  value = module.server.connections
}
