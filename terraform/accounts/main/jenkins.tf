resource "aws_key_pair" "jenkins" {
  key_name   = "${var.ssh_key_name}"
  public_key = "${var.jenkins_public_key}" # injected by Makefile-common
}

module "jenkins_elb_log_bucket" {
  source = "../../modules/jenkins/log_bucket"
  name   = "jenkins-ci.marketplace.team-logs-bucket"
}

module "jenkins_2" {
  source                            = "../../modules/jenkins/jenkins"
  name                              = "jenkins2"
  aws_account_and_jenkins_login_ips = "${var.aws_account_and_jenkins_login_ips}"
  jenkins_public_key_name           = "${aws_key_pair.jenkins.key_name}"                            # Or ${var.ssh_key_name}
  jenkins_instance_profile          = "${aws_iam_instance_profile.jenkins.name}"
  jenkins_wildcard_elb_cert_arn     = "${aws_acm_certificate.jenkins_wildcard_elb_certificate.arn}"
  ami_id                            = "ami-01e6a0b85de033c99"
  instance_type                     = "t3.large"
  dns_zone_id                       = "${aws_route53_zone.marketplace_team.zone_id}"
  dns_name                          = "ci.marketplace.team"
  log_bucket_name                   = "${module.jenkins_elb_log_bucket.bucket_id}"
}

module "jenkins_snapshots" {
  source = "../../modules/jenkins/snapshots"
}
