resource "aws_iam_account_password_policy" "policy" {
  minimum_password_length = 6
  require_lowercase_characters = false
  require_numbers = false
  require_uppercase_characters = false
  require_symbols = false
  allow_users_to_change_password = true
}
