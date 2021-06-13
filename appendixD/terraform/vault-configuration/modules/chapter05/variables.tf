variable "namespace" {
  type = string
}

variable "vault_admin_users" {
  type = list(string)
  description = "A list of the system admin users for the Vault server"
}
