resource "aws_iam_user" "jamieeunson" {
  name          = "jamieeunson"
  force_destroy = true
}

resource "aws_iam_user" "timothysouth" {
  name          = "timothysouth"
  force_destroy = true
}

resource "aws_iam_user" "thomasberey" {
  name          = "thomasberey"
  force_destroy = true
}
