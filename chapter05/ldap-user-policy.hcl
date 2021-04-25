path "kv/data/users/{{identity.entity.aliases.auth_ldap_2f5ce1ce.name}}/*" {
  capabilities = ["create", "update", "read", "list", "delete"]
}

path "kv/data/users/{{identity.entity.aliases.auth_ldap_2f5ce1ce.name}}" {
  capabilities = ["list"]
}

path "kv/metadata/users/{{identity.entity.aliases.auth_ldap_2f5ce1ce.name}}/*" {
  capabilities = ["read"]
}

# required for UI users to see their own secrets from
# the top level. <X>
path "kv/data" {
  capabilities = ["read", "list"]
}

path "kv/data/users" {
  capabilities = ["read", "list"]
}

path "kv/metadata" {
  capabilities = ["list"]
}

path "kv/metadata/users" {
  capabilities = ["list"]
}

