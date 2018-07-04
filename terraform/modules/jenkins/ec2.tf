provider "aws" {
  region = "eu-west-1"
}

resource "aws_instance" "jenkins2" {
  ami                    = "ami-785db401"
  instance_type          = "t2.large"
  iam_instance_profile   = "${aws_iam_instance_profile.jenkins.name}"
  key_name               = "${aws_key_pair.jenkins2_2.key_name}"
  vpc_security_group_ids = "${var.jenkins_security_group_ids}"

  tags {
    Name = "Jenkins2"
  }
}

resource "aws_eip" "jenkins2" {
  vpc = true
}

resource "aws_eip_association" "jenkins2_eip_assoc" {
  instance_id   = "${aws_instance.jenkins2.id}"
  allocation_id = "${aws_eip.jenkins2.id}"
}

resource "aws_key_pair" "jenkins2_2" {
  key_name   = "${var.ssh_key_name}"
  public_key = "${var.jenkins_public_key}"  # injected by Makefile-common
}

resource "aws_ebs_volume" "jenkins2_volume" {
  availability_zone = "${aws_instance.jenkins2.availability_zone}"
  type              = "gp2"
  size              = 100
}

resource "aws_volume_attachment" "jenkins2_ebs_att" {
  device_name = "/dev/xvdf"
  volume_id   = "${aws_ebs_volume.jenkins2_volume.id}"
  instance_id = "${aws_instance.jenkins2.id}"
}
