module "preview_logs" {
  source = "../logs"

  name = "${var.name}"
  iam_role_id = "${aws_iam_role.nginx_role.id}"
  log_retention_days = "${var.log_retention_days}"
}
