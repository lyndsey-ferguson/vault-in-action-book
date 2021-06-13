data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "vault" {
  statement {
    sid       = "VaultKMSUnseal"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey",
    ]
  }

  statement {
    sid    = "VaultS3StorageList"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "${aws_s3_bucket.vault.arn}",
    ]
  }

  statement {
    sid    = "VaultS3StorageManage"
    effect = "Allow"
    actions = [
      "*"
    ]
    resources = [
      "${aws_s3_bucket.vault.arn}/*"
    ]
  }
}

resource "aws_iam_role" "vault" {
  name               = "vault-${var.unique_resource_name}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = {
    Name = "vault-vpc-${var.unique_resource_name}"
  }
}

resource "aws_iam_role_policy" "vault" {
  name   = "Vault-${var.unique_resource_name}"
  role   = aws_iam_role.vault.id
  policy = data.aws_iam_policy_document.vault.json
}

resource "aws_iam_instance_profile" "vault" {
  name = "vault-${var.unique_resource_name}"
  role = aws_iam_role.vault.name

  tags = {
    Name = "vault-vpc-${var.unique_resource_name}"
  }
}
