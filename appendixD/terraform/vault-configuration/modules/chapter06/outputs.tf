output "internal_network_user_token" {
 value = tostring(vault_token.internal_network_user_token.client_token)
}
