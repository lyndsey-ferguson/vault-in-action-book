data "http" "icanhazip" {
   url = "http://icanhazip.com"
}

resource "vault_token_auth_backend_role" "internal_network_user" {
  role_name = "internal-network-user"
  allowed_policies = ["default"]
  token_bound_cidrs = ["127.0.0.1" , "${chomp(data.http.icanhazip.body)}"]
  token_explicit_max_ttl = "28800"
}

resource "vault_token" "internal_network_user_token" {
  role_name = vault_token_auth_backend_role.internal_network_user.role_name
}

