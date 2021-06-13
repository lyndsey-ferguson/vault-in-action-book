output "security_group_id" {
  value = aws_security_group.vault.id
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
}
