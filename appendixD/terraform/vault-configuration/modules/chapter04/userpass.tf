resource "vault_auth_backend" "userpass" {
  type = "userpass"
}

resource "vault_policy" "userpass-management" {
  name = "userpass-management"
  policy = <<EOF
path "auth/userpass/users/*" {
  capabilities = ["create", "list", "delete"]
}

path "auth/userpass/users/" {
  capabilities = ["list"]
}
EOF

}

resource "vault_policy" "all-kv-secrets" {
  name = "all-kv-secrets"

  policy = <<EOF
path "kv/*" {
  capabilities = [
    "create",
    "read",
    "update",
    "list",
    "delete"
  ]
}

path "kv" {
  capabilities = ["list"]
}
EOF
}

# use random_password instead of string in real-world
resource "random_string" "passwords" {
  count = length(var.vault_admin_users)
  length = 12
}

resource "vault_generic_endpoint" "admin_user" {
  count                = length(var.vault_admin_users)
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/userpass/users/${var.vault_admin_users[count.index]}"

  ignore_absent_fields = true

  data_json = <<EOT
{
  "policies": ["userpass-management", "all-kv-secrets"],
  "password": "${random_string.passwords[count.index].result}"
}
EOT
}
