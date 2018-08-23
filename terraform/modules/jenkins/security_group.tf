# Jenkins ELB security group/rules

resource "aws_security_group" "jenkins_elb_security_group" {
  name        = "${var.name}_elb_security_group"
  description = "Security group for Jenkins ELB"
}

resource "aws_security_group_rule" "jenkins_elb_allow_ssh_from_whitelisted_ips" {
  security_group_id = "${aws_security_group.jenkins_elb_security_group.id}"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${var.dev_user_ips}"]
}

resource "aws_security_group_rule" "jenkins_elb_allow_https_from_whitelisted_ips" {
  security_group_id = "${aws_security_group.jenkins_elb_security_group.id}"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["${var.dev_user_ips}", "${aws_eip.jenkins3.public_ip}/32"]
}

resource "aws_security_group_rule" "jenkins_elb_allow_http_to_jenkins_instance" {
  security_group_id        = "${aws_security_group.jenkins_elb_security_group.id}"
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.jenkins_instance_security_group.id}"
}

resource "aws_security_group_rule" "jenkins_elb_allow_ssh_to_jenkins_instance" {
  security_group_id        = "${aws_security_group.jenkins_elb_security_group.id}"
  type                     = "egress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.jenkins_instance_security_group.id}"
}

# Jenkins Instance security groups/rules

resource "aws_security_group" "jenkins_instance_security_group" {
  name        = "${var.name}_instance_security_group"
  description = "Security group for Jenkins Instance"
}

resource "aws_security_group_rule" "jenkins_instance_allow_http_from_jenkins_elb" {
  security_group_id        = "${aws_security_group.jenkins_instance_security_group.id}"
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.jenkins_elb_security_group.id}"
}

resource "aws_security_group_rule" "jenkins_instance_allow_ssh_from_jenkins_elb" {
  security_group_id        = "${aws_security_group.jenkins_instance_security_group.id}"
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.jenkins_elb_security_group.id}"
}

resource "aws_security_group_rule" "jenkins_instance_allow_egress_everywhere" {
  security_group_id = "${aws_security_group.jenkins_instance_security_group.id}"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
