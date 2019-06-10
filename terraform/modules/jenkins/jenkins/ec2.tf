provider "aws" {
  region = "eu-west-1"
}

resource "aws_instance" "jenkins" {
  ami                     = "${var.ami_id}"
  disable_api_termination = true                                                         # prevent this instance from being destroyed from the console
  instance_type           = "${var.instance_type}"
  iam_instance_profile    = "${var.jenkins_instance_profile}"
  key_name                = "${aws_key_pair.jenkins.key_name}"
  vpc_security_group_ids  = ["${aws_security_group.jenkins_instance_security_group.id}"]

  tags {
    Name = "${var.name}"
  }
}

resource "aws_eip" "jenkins" {
  vpc = true
}

resource "aws_eip_association" "jenkins_eip_assoc" {
  instance_id   = "${aws_instance.jenkins.id}"
  allocation_id = "${aws_eip.jenkins.id}"
}

resource "aws_key_pair" "jenkins" {
  key_name   = "${var.jenkins_public_key_name}"
  public_key = "${var.jenkins_public_key}"      # injected by Makefile-common
}

resource "aws_ebs_volume" "jenkins_volume" {
  availability_zone = "${aws_instance.jenkins.availability_zone}"
  type              = "gp2"
  size              = 100

  tags {
    Name      = "jenkins data"
    Size      = "100 GiB"
    Encrypted = "true"
  }
}

resource "aws_volume_attachment" "jenkins_ebs_att" {
  device_name = "/dev/xvdf"
  volume_id   = "${aws_ebs_volume.jenkins_volume.id}"
  instance_id = "${aws_instance.jenkins.id}"
}
