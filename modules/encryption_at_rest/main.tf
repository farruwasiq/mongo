resource "mongodbatlas_encryption_at_rest" "aws_encryption_at_rest" {
  project_id = var.atlas_project_id

  aws_kms = {
    enabled                = 1
    access_key_id          = var.atlas_encryption_user_access_key
    secret_access_key      = var.atlas_encryption_user_secret_access_key
    customer_master_key_id = aws_kms_key.atlas_encryption_at_rest_key.key_id
    region                 = var.atlas_region
  }
}

resource "aws_kms_key" "atlas_encryption_at_rest_key" {
  description = "MongoDB Atlas encryption at rest key"

  tags = {
    env = var.env
  }
}

//TODO refactor name: it should depend on the env-workload name. Problem: Renaming it will cause the replacement
resource "aws_kms_alias" "atlas_encryption_at_rest_key_alias" {
  name          = "alias/atlasEncryptionAtRestCMK"
  target_key_id = aws_kms_key.atlas_encryption_at_rest_key.key_id
}

resource "aws_iam_user" "atlas-encryption-iam-user" {
  name = "atlas-encryption-user-${var.env}"
}

resource "aws_iam_user_policy" "kms-mongo-atlas-encryption-key" {
  name = "kms-mongo-atlas-encryption-key"
  user = aws_iam_user.atlas-encryption-iam-user.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "kms:Decrypt",
        "kms:Encrypt",
        "kms:DescribeKey"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:kms:${var.aws_region}:${var.aws_account}:key/${aws_kms_key.atlas_encryption_at_rest_key.key_id}"
    }
  ]
}
EOF
}