output "vault_server_ip" {
  value = var.vault_server_running ? aws_instance.vault[0].public_ip : ""
}

output "connections" {
  value = var.vault_server_running == false ? "" : <<VAULT
Connect to Vault via SSH:
  ssh ubuntu@${aws_instance.vault[0].public_ip}
  ssh ubuntu@${var.network.url} -i private.key -o 'StrictHostKeyChecking no'

Vault web interface
  https://${aws_instance.vault[0].public_ip}:8200/ui
  https://${var.network.url}:8200/ui
VAULT

}
