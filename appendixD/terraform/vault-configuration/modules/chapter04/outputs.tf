output "admin_user_password_map" {
  value = zipmap(var.vault_admin_users, random_string.passwords.*.result)
}
