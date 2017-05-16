module "logs" {
  source = "../log-group"

  name = "${var.name}"
  iam_role_id = "${aws_iam_role.nginx_role.id}"
  log_retention_days = "${var.log_retention_days}"
}

module "json_logs" {
  source = "../log-group"

  name = "${var.name}-json"
  iam_role_id = "${aws_iam_role.nginx_role.id}"
  log_retention_days = "${var.log_retention_days}"
}


module "error_logs" {
  source = "../log-group"

  name = "${var.name}-error"
  iam_role_id = "${aws_iam_role.nginx_role.id}"
  log_retention_days = "${var.log_retention_days}"
}
