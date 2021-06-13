output "ssh_keyname" {
  value = aws_key_pair.ssh.key_name
}

output "full_chain_certificate" {
  value = var.is_production ? "${acme_certificate.vault_certificate[0].certificate_pem}${acme_certificate.vault_certificate[0].issuer_pem}" : "${acme_certificate.staging_vault_certificate[0].certificate_pem}${acme_certificate.staging_vault_certificate[0].issuer_pem}"
}

output "private_key" {
  value = var.is_production? acme_certificate.vault_certificate[0].private_key_pem : acme_certificate.staging_vault_certificate[0].private_key_pem
}

