/******************************************************************************
 *
 * vpc.tf - IAM profile, security groups, and instances
 *
 ******************************************************************************/

resource "aws_vpc" "vpc" {

    cidr_block = "${var.vpc_network_cidr}"
    enable_dns_support = "true"
    enable_dns_hostnames = "true"

    tags {
        Name = "vpc-${var.Project}-${var.Environment}"
        Project = "${var.Project}"
        Environment = "${var.Environment}"
    }
}

resource "aws_subnet" "subnet" {
  count = "${var.vpc_subnet_count}"
  
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${cidrsubnet(var.vpc_network_cidr, var.vpc_subnet_network_bits, count.index)}"
  availability_zone = "${element(split(",",lookup(var.aws_availability_zones, var.aws_region)), count.index % length(split(",",lookup(var.aws_availability_zones, var.aws_region))))}"

  tags {
    Name = "subnet${count.index}-${var.Project}-${var.Environment}"
    Project = "${var.Project}"
    Environment = "${var.Environment}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "igw-${var.Project}-${var.Environment}"
    Project = "${var.Project}"
    Environment = "${var.Environment}"
  }
}

resource "aws_route_table" "route" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags {
    Name = "route-${var.Project}-${var.Environment}"
    Project = "${var.Project}"
    Environment = "${var.Environment}"
  }
}

resource "aws_route_table_association" "rta" {
  count = "${var.vpc_subnet_count}"
  
  subnet_id = "${element(aws_subnet.subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.route.id}"
}

resource "aws_security_group" "sg" {
  name = "${var.Project}-${var.Environment}"
  description = "Security Group for ${var.Project}-${var.Environment}"
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
      Name = "sg-${var.Project}-${var.Environment}"
      Project = "${var.Project}"
      Environment = "${var.Environment}"
  }
}

resource "aws_security_group_rule" "sg_ingress_ssh" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.sg.id}"
}

resource "aws_security_group_rule" "sg_ingress_docker" {
    type = "ingress"
    from_port = 2376
    to_port = 2376
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.sg.id}"
}

resource "aws_security_group_rule" "sg_ingress_all_icmp" {
    type = "ingress"
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.sg.id}"
}

resource "aws_security_group_rule" "sg_ingress_nifi" {
    type = "ingress"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.sg.id}"
}

resource "aws_security_group_rule" "sg_ingress_all_internal" {
    type = "ingress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_group_id = "${aws_security_group.sg.id}"
    source_security_group_id = "${aws_security_group.sg.id}"
}

resource "aws_security_group_rule" "sg_egress_all_out" {
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.sg.id}"
}

resource "aws_iam_role" "iam_role" {
    name = "${var.Project}-${var.Environment}-instance_role"
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

resource "aws_iam_policy" "iam_policy" {
    name = "${var.Project}-${var.Environment}-instance_policy"
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

resource "aws_iam_policy_attachment" "iam_policy_attachment" {
    name = "${var.Project}-${var.Environment}-policy_attach"
    roles = ["${aws_iam_role.iam_role.name}"]
    policy_arn = "${aws_iam_policy.iam_policy.arn}"
}

resource "aws_iam_instance_profile" "iam_instance_profile" {
    name = "${var.Project}-${var.Environment}-instance_profile"
    roles = ["${aws_iam_role.iam_role.name}"]
}

resource "aws_key_pair" "ssh_key" {
  key_name = "${var.Project}-${var.Environment}" 
  public_key = "${file("${var.ssh_key_path}.pub")}"
}

resource "aws_ebs_volume" "ebs" {
  count = "${var.aws_instance_count}"

  availability_zone = "${element(split(",",lookup(var.aws_availability_zones, var.aws_region)), count.index % length(split(",",lookup(var.aws_availability_zones, var.aws_region))))}"

  size = "${var.ebs_data_volume_size}"
  type = "gp2"

  tags {
    Name = "${var.Project}-${var.Environment}-${count.index}-data"
  }
}

resource "aws_instance" "instance" {
  count = "${var.aws_instance_count}"
    
  availability_zone = "${element(split(",",lookup(var.aws_availability_zones, var.aws_region)), count.index % length(split(",",lookup(var.aws_availability_zones, var.aws_region))))}"
  
  instance_type = "${var.aws_instance_type}"
  ami = "${lookup(var.ami, "${var.aws_region}-${var.linux_distro_name}-${var.linux_distro_version}")}"
  
  iam_instance_profile = "${aws_iam_instance_profile.iam_instance_profile.id}"
  vpc_security_group_ids = [ "${aws_security_group.sg.id}" ]
  subnet_id = "${element(aws_subnet.subnet.*.id, count.index)}"
  associate_public_ip_address = "true"
  
  key_name = "${aws_key_pair.ssh_key.key_name}"

  connection {
    user = "ubuntu"
    key_file = "${var.ssh_key_path}"
  }

  tags {
    Name = "${var.Project}-${var.Environment}-${count.index}"
    Project = "${var.Project}"
    Environment = "${var.Environment}"
  }
    
  root_block_device {
    volume_type = "gp2"
    delete_on_termination = true
    volume_size = "${var.ebs_root_volume_size}"
  }

  user_data = "${file("../user-env.sh")}"
}

resource "aws_volume_attachment" "instance-lvm-attachment" {
  count = "${var.aws_instance_count}"
  device_name = "xvdh"
  instance_id = "${element(aws_instance.instance.*.id, count.index)}"
  volume_id = "${element(aws_ebs_volume.ebs.*.id, count.index)}"
  force_detach = true
}

#output "hostname_list" {
#  value = "${join(\",\", aws_instance.instance.*.tags.Name)}"
#}
#
#output "ec2_ids" {
#  value = "${join(\",\", aws_instance.instance.*.id)}"
#}
#
#output "ec2_ips" {
#  value = "${join(\",\", aws_instance.instance.*.public_ip)}"
#}
#
