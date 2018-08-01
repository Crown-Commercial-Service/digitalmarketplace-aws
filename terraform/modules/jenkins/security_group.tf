resource "aws_security_group" "jenkins_security_group" {
  name        = "jenkins_security_group"
  description = "Security group for Jenkins"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "allow_ssh_to_jenkins" {
  security_group_id = "${aws_security_group.jenkins_security_group.id}"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${var.dev_user_ips}"]
}

resource "aws_security_group_rule" "allow_https_to_jenkins" {
  security_group_id = "${aws_security_group.jenkins_security_group.id}"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["${var.dev_user_ips}", "${aws_eip.jenkins3.public_ip}/32"]
}

resource "aws_security_group_rule" "allow_letsencrypt_check" {
  security_group_id = "${aws_security_group.jenkins_security_group.id}"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}
