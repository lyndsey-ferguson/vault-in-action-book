resource "aws_kms_key" "vault" {
  description             = "Vault unseal key"
  deletion_window_in_days = 10

  tags = {
    Name = "vault-kms-unseal-${var.unique_resource_name}"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = "true"
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "vault" {
  count         = var.vault_server_running ? 1 : 0
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id     = var.network.public_subnet_id
  key_name      = var.security.ssh_keyname

  security_groups = [
    var.security.security_group_id
  ]

  associate_public_ip_address = true
  ebs_optimized               = false
  iam_instance_profile        = aws_iam_instance_profile.vault.id

  tags = {
    Name = "vault-${var.unique_resource_name}"
  }

  user_data = data.template_file.vault.rendered
}

data "template_file" "vault" {
  template = file("${path.module}/userdata.tpl")

  vars = {
    kms_key    = aws_kms_key.vault.id
    vault_url  = var.vault_url
    aws_region = var.network.aws_region
    acme_cert  = var.certificate.full_chain_certificate
    acme_key   = var.certificate.private_key
  }
}

data "template_file" "format_ssh" {
  template = "connect to host with following command: ssh ubuntu@$${admin} -i private.key"

  vars = {
    admin = var.vault_server_running ? aws_instance.vault[0].public_ip : ""
  }
}

