resource "vault_policy" "policy-management" {
  name = "policy-management"
  policy = <<EOF
path "sys/policy" {
  capabilities = ["read"]
}

path "sys/policy/*" {
  capabilities = [
    "create",
    "read",
    "update",
    "delete",
    "list",
    "sudo"
  ]
}

path "sys/policies/acl/*" {
  capabilities = [
    "create",
    "read",
    "update",
    "delete",
    "list",
    "sudo"
  ]
}

path "sys/policy/default" {
  capabilities = ["read"]
}

path "sys/policies/acl/default" {
  capabilities = ["read"]
}
EOF
}

resource "vault_policy" "auth-management" {
  name = "auth-management"
  policy = <<EOF
path "sys/auth/*" {
  capabilities = [
    "create",
    "read",
    "update",
    "list",
    "delete",
    "sudo"
  ]
}

path "sys/auth" {
  capabilities = ["list", "read"]
}

path "auth/*" {
  capabilities = [
    "create",
    "list",
    "read",
    "update",
    "delete"
  ]
}

path "auth/" {
  capabilities = ["list"]
}
EOF
}

resource "vault_policy" "secrets-management" {
  name = "secrets-management"
  policy = <<EOF
path "sys/mounts" {
  capabilities = ["read"]
}

path "sys/mounts/*" {
  capabilities = [
    "create",
    "read",
    "update",
    "list",
    "delete"
  ]
}
EOF
}

resource "vault_policy" "lease-management" {
  name = "lease-management"

  policy = <<EOF
path "sys/leases/*" {
  capabilities = ["create", "update", "list", "sudo"]
}
EOF
}

resource "vault_policy" "seal-management" {
  name = "seal-management"
  policy = <<EOF
path "sys/seal" {
  capabilities = ["update", "sudo"]
}
EOF
}

resource "vault_generic_endpoint" "admin_users" {
  count                = length(var.vault_admin_users)
  path                 = "auth/userpass/users/${var.vault_admin_users[count.index]}/policies"

  disable_read = true
  disable_delete = true

  data_json = <<EOT
{
  "policies": ["userpass-management", "all-kv-secrets", "policy-management", "auth-management", "secrets-management", "lease-management", "seal-management"]
}
EOT
}

