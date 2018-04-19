resource "aws_security_group" "ci_sg" {
  name        = "jenkins-ci-InstanceSecurityGroup-1N45R6TJPJ1YJ"
  description = "Main instance security group"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "allow_ssh_to_ci" {
  security_group_id = "${aws_security_group.ci_sg.id}"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${var.dev_user_ips}"]
}

resource "aws_security_group_rule" "allow_https_to_ci" {
  security_group_id = "${aws_security_group.ci_sg.id}"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["${var.dev_user_ips}"]
}

resource "aws_security_group_rule" "allow_letsencrypt_check" {
  security_group_id = "${aws_security_group.ci_sg.id}"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}
