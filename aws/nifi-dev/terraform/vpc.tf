/******************************************************************************
 *
 * docker.tf - IAM profile, security groups, and docker instances
 *
 ******************************************************************************/

resource "aws_security_group" "sg_docker" {
  name = "${var.Project}-${var.Environment}-docker"
  description = "Security Group for ${var.Project}-${var.Environment} docker Tunnelling"
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
      Name = "sg-${var.Project}-${var.Environment}-docker"
      Project = "${var.Project}"
      Environment = "${var.Environment}"
  }
}

resource "aws_security_group_rule" "sg_docker_ingress_ssh" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.sg_docker.id}"
}

resource "aws_security_group_rule" "sg_docker_ingress_docker" {
    type = "ingress"
    from_port = 2376
    to_port = 2376
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.sg_docker.id}"
}

resource "aws_security_group_rule" "sg_docker_ingress_all_icmp" {
    type = "ingress"
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.sg_docker.id}"
}

resource "aws_security_group_rule" "sg_docker_ingress_nifi" {
    type = "ingress"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.sg_docker.id}"
}

resource "aws_security_group_rule" "sg_docker_ingress_all_internal" {
    type = "ingress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_group_id = "${aws_security_group.sg_docker.id}"
    source_security_group_id = "${aws_security_group.sg_docker.id}"
}

resource "aws_security_group_rule" "sg_docker_egress_all_out" {
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.sg_docker.id}"
}

resource "aws_iam_role" "iam_role_docker" {
    name = "${var.Project}-${var.Environment}-docker_instance_role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "iam_policy_docker" {
    name = "${var.Project}-${var.Environment}-docker_instance_policy"
    path = "/"
    description = "Platform IAM Policy"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
       "Effect": "Allow",
       "Action": [
         "iam:ListInstanceProfiles"
       ],
       "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "iam_policy_attachment_docker" {
    name = "${var.Project}-${var.Environment}-docker_policy_attach"
    roles = ["${aws_iam_role.iam_role_docker.name}"]
    policy_arn = "${aws_iam_policy.iam_policy_docker.arn}"
}

resource "aws_iam_instance_profile" "iam_instance_profile_docker" {
    name = "${var.Project}-${var.Environment}-docker_instance_profile"
    roles = ["${aws_iam_role.iam_role_docker.name}"]
}

resource "aws_key_pair" "ssh_key_docker" {
  key_name = "${var.Project}-${var.Environment}-docker" 
  public_key = "${file("${var.ssh_key_path_docker}.pub")}"
}

resource "aws_instance" "aws_instance_docker" {
  count = "${var.aws_instance_count_docker}"
    
  availability_zone = "${element(split(",",lookup(var.aws_availability_zones, var.aws_region)), count.index % length(split(",",lookup(var.aws_availability_zones, var.aws_region))))}"
  
  instance_type = "${var.aws_instance_type_docker}"
  ami = "${lookup(var.ami, "${var.aws_region}-${var.linux_distro_name_docker}-${var.linux_distro_version_docker}")}"
  
  iam_instance_profile = "${aws_iam_instance_profile.iam_instance_profile_docker.id}"
  vpc_security_group_ids = [ "${aws_security_group.sg_docker.id}" ]
  subnet_id = "${element(aws_subnet.subnet.*.id, count.index)}"
  associate_public_ip_address = "true"
  
  key_name = "${aws_key_pair.ssh_key_docker.key_name}"

  connection {
    user = "ubuntu"
    key_file = "${var.ssh_key_path_docker}"
  }

  tags {
    Name = "${var.Project}-${var.Environment}-docker-${count.index}"
    Project = "${var.Project}"
    Environment = "${var.Environment}"
  }
    
  root_block_device = {
    volume_type = "gp2"
    volume_size = "${var.ebs_root_volume_size_docker}"
  }

  user_data = "${file("../user-env.sh")}"
}
