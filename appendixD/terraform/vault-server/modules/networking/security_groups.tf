resource "aws_security_group" "vault" {
  name        = "vault-sg-${var.unique_resource_name}"
  description = "vault access"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "vault-security-group-${var.unique_resource_name}"
  }

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Vault Client Traffic
  ingress {
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
