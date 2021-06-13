resource "aws_s3_bucket" "vault" {
  bucket = "ldf-vault-in-action-bucket"
  acl    = "private"

  tags = {
    Name = "vault-vpc-${var.unique_resource_name}"
  }
}
