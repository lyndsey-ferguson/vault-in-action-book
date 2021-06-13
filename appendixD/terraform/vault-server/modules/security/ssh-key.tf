resource "tls_private_key" "ssh" {
  algorithm = "RSA"
}

resource "null_resource" "ssh_private_key" {
  provisioner "local-exec" {
    command = "echo \"${tls_private_key.ssh.private_key_pem}\" > '${path.root}/private.key'"
  }

  provisioner "local-exec" {
    command = "chmod 600 private.key"
  }
}

resource "aws_key_pair" "ssh" {
  key_name   = "vault-private-key-${var.unique_resource_name}"
  public_key = tls_private_key.ssh.public_key_openssh
}
