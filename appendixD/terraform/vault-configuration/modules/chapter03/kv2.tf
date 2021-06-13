resource "vault_mount" "kv_v2" {
  path        = "kv"
  type        = "kv"
  description = "stores versioned key value pair secrets"
  options = {
    version = "2"
  }
}

