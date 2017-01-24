resource "aws_kms_key" "sops_credentials_primary" {
  description = "Key for encrypting/decrypting secrets in the digitalmarketplace-credentials repo using Mozilla SOPS"
}

resource "aws_kms_alias" "sops_credentials_primary" {
  name = "alias/sops-credentials"
  target_key_id = "${aws_kms_key.sops_credentials_primary.key_id}"
}

resource "aws_kms_key" "sops_credentials_secondary" {
  provider = "aws.london"
  description = "Key for encrypting/decrypting secrets in the digitalmarketplace-credentials repo using Mozilla SOPS"
}

resource "aws_kms_alias" "sops_credentials_secondary" {
  provider = "aws.london"
  name = "alias/sops-credentials"
  target_key_id = "${aws_kms_key.sops_credentials_secondary.key_id}"
}
