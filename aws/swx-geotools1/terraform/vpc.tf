/******************************************************************************
 *
 * vpc.tf - IAM profile, security groups, and instances
 *
 ******************************************************************************/

provider "aws" {
  region = "${var.aws_region}"
  access_key = "${var.aws_access_key_id}"
  secret_key = "${var.aws_secret_access_key}"
}

resource "aws_vpc" "vpc" {

    cidr_block = "${var.vpc_network_cidr}"
    enable_dns_support = "true"
    enable_dns_hostnames = "true"
    assign_generated_ipv6_cidr_block = true

    tags {
        Name = "vpc-${var.Project}-${var.Lifecycle}"
        Project = "${var.Project}"
        Lifecycle = "${var.Lifecycle}"
    }
}

resource "aws_subnet" "instances" {
  count = "${var.vpc_subnet_count}"
  
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${cidrsubnet(var.vpc_network_cidr, var.vpc_subnet_network_bits, (count.index+1) * 2)}"
  availability_zone = "${element(split(",",lookup(var.aws_availability_zones, var.aws_region)), count.index % length(split(",",lookup(var.aws_availability_zones, var.aws_region))))}"

  map_public_ip_on_launch = true
  ipv6_cidr_block = "${cidrsubnet(aws_vpc.vpc.ipv6_cidr_block, 8, (count.index+1) * 2)}" /* Even numbered /64 networks are for instances eth0 */
  assign_ipv6_address_on_creation = true

  tags {
    Name = "subnet${count.index}-${var.Project}-${var.Lifecycle}-instances"
    Project = "${var.Project}"
    Lifecycle = "${var.Lifecycle}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "igw-${var.Project}-${var.Lifecycle}"
    Project = "${var.Project}"
    Lifecycle = "${var.Lifecycle}"
  }
}

resource "aws_route_table" "default" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags {
    Name = "route-${var.Project}-${var.Lifecycle}-default"
    Project = "${var.Project}"
    Lifecycle = "${var.Lifecycle}"
  }
}

resource "aws_route_table_association" "default" {
  count = "${var.vpc_subnet_count}"
  
  subnet_id = "${element(aws_subnet.instances.*.id, count.index)}"
  route_table_id = "${aws_route_table.default.id}"
}

resource "aws_security_group" "sg" {
  name = "${var.Project}-${var.Lifecycle}"
  description = "Security Group for ${var.Project}-${var.Lifecycle}"
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
      Name = "sg-${var.Project}-${var.Lifecycle}"
      Project = "${var.Project}"
      Lifecycle = "${var.Lifecycle}"
  }
}

resource "aws_security_group_rule" "sg_ingress_ssh" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

    security_group_id = "${aws_security_group.sg.id}"
}

resource "aws_security_group_rule" "sg_ingress_http" {
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

    security_group_id = "${aws_security_group.sg.id}"
}

resource "aws_security_group_rule" "sg_ingress_https" {
    type = "ingress"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

    security_group_id = "${aws_security_group.sg.id}"
}

resource "aws_security_group_rule" "sg_ingress_docker" {
    type = "ingress"
    from_port = 2376
    to_port = 2376
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

    security_group_id = "${aws_security_group.sg.id}"
}

resource "aws_security_group_rule" "sg_ingress_rdp" {
    type = "ingress"
    from_port = 3389
    to_port = 3389
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

    security_group_id = "${aws_security_group.sg.id}"
}

resource "aws_security_group_rule" "sg_ingress_neo4j-js" {
    type = "ingress"
    from_port = 4200
    to_port = 4200
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

    security_group_id = "${aws_security_group.sg.id}"
}
resource "aws_security_group_rule" "sg_ingress_neo4j-js2" {
    type = "ingress"
    from_port = 49153
    to_port = 49153
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

    security_group_id = "${aws_security_group.sg.id}"
}

resource "aws_security_group_rule" "sg_ingress_guacd" {
    type = "ingress"
    from_port = 4822
    to_port = 4822
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

    security_group_id = "${aws_security_group.sg.id}"
}

resource "aws_security_group_rule" "sg_ingress_bolt" {
    type = "ingress"
    from_port = 7687
    to_port = 7687
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

    security_group_id = "${aws_security_group.sg.id}"
}

resource "aws_security_group_rule" "sg_ingress_osh" {
    type = "ingress"
    from_port = 8181
    to_port = 8181
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

    security_group_id = "${aws_security_group.sg.id}"
}

resource "aws_security_group_rule" "sg_ingress_structr" {
    type = "ingress"
    from_port = 8582
    to_port = 8582
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

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

resource "aws_security_group_rule" "sg_ingress_all_icmpv6" {
    type = "ingress"
    from_port = -1
    to_port = -1
    protocol = "icmpv6"
    ipv6_cidr_blocks = ["::/0"]

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
    ipv6_cidr_blocks = ["::/0"]
    security_group_id = "${aws_security_group.sg.id}"
}

resource "aws_iam_role" "iam_role" {
    name = "${var.Project}-${var.Lifecycle}-instance_role"
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
    name = "${var.Project}-${var.Lifecycle}-instance_policy"
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
    name = "${var.Project}-${var.Lifecycle}-policy_attach"
    roles = ["${aws_iam_role.iam_role.name}"]
    policy_arn = "${aws_iam_policy.iam_policy.arn}"
}

resource "aws_iam_instance_profile" "iam_instance_profile" {
    name = "${var.Project}-${var.Lifecycle}-instance_profile"
    role = "${aws_iam_role.iam_role.name}"
}

resource "aws_key_pair" "ssh_key" {
  key_name = "${var.Project}-${var.Lifecycle}" 
  public_key = "${file("${var.ssh_key_path}.pub")}"
}

resource "aws_eip" "instance" {
  count = "${var.aws_instance_count}"

  vpc = true
}

resource "aws_eip_association" "eip_assoc" {
  count = "${var.aws_instance_count}"

  instance_id   = "${element(aws_instance.instance.*.id, count.index)}"
  allocation_id = "${element(aws_eip.instance.*.id, count.index)}"
}

resource "aws_ebs_volume" "home" {
  count = "${var.aws_instance_count}"

  availability_zone = "${element(split(",",lookup(var.aws_availability_zones, var.aws_region)), count.index % length(split(",",lookup(var.aws_availability_zones, var.aws_region))))}"

  size = "${var.ebs_home_volume_size}"
  type = "standard"

  encrypted = true

  tags {
    Name = "${var.Project}-${var.Lifecycle}-${count.index}"
  }
}

resource "aws_ebs_volume" "docker" {
  count = "${var.aws_instance_count}"

  availability_zone = "${element(split(",",lookup(var.aws_availability_zones, var.aws_region)), count.index % length(split(",",lookup(var.aws_availability_zones, var.aws_region))))}"

  size = "${var.ebs_docker_volume_size}"
  type = "standard"

  encrypted = true

  tags {
    Name = "${var.Project}-${var.Lifecycle}-${count.index}"
  }
}

resource "aws_ebs_volume" "docker2" {
  count = "${var.aws_instance_count}"

  availability_zone = "${element(split(",",lookup(var.aws_availability_zones, var.aws_region)), count.index % length(split(",",lookup(var.aws_availability_zones, var.aws_region))))}"

  size = "${var.ebs_docker2_volume_size}"
  type = "gp2"

  encrypted = true

  tags {
    Name = "${var.Project}-${var.Lifecycle}-${count.index}"
  }
}

resource "aws_instance" "instance" {
  count = "${var.aws_instance_count}"
    
  availability_zone = "${element(split(",",lookup(var.aws_availability_zones, var.aws_region)), count.index % length(split(",",lookup(var.aws_availability_zones, var.aws_region))))}"
  
  instance_type = "${var.aws_instance_type}"
  ami = "${lookup(var.ami, "${var.aws_region}-${var.linux_distro_name}-${var.linux_distro_version}")}"
  
  iam_instance_profile = "${aws_iam_instance_profile.iam_instance_profile.id}"
  vpc_security_group_ids = [ "${aws_security_group.sg.id}" ]
  subnet_id = "${element(aws_subnet.instances.*.id, count.index)}"
  associate_public_ip_address = "true"
  ipv6_address_count = 1
  
  key_name = "${aws_key_pair.ssh_key.key_name}"

  connection {
    user = "ubuntu"
    key_file = "${var.ssh_key_path}"
  }

  tags {
    Name = "${var.Project}-a-${var.Lifecycle}-osgeo${count.index}"
    Project = "${var.Project}"
    Lifecycle = "${var.Lifecycle}"
  }
    
  root_block_device {
    volume_type = "standard"
    delete_on_termination = true
    volume_size = "${var.ebs_root_volume_size}"
  }

  volume_tags {
    Name = "${var.Project}-${var.Lifecycle}-${count.index}"
  }
  user_data = "${file("../user-data.sh")}"
}

data "aws_route53_zone" "selected" {
  name         = "${var.dns_zone}"
  private_zone = false
}

resource "aws_volume_attachment" "instance-home" {
  count = "${var.aws_instance_count}"
  device_name = "xvdh"
  instance_id = "${element(aws_instance.instance.*.id, count.index)}"
  volume_id = "${element(aws_ebs_volume.home.*.id, count.index)}"
  force_detach = true
}

resource "aws_volume_attachment" "instance-docker" {
  count = "${var.aws_instance_count}"
  device_name = "xvdi"
  instance_id = "${element(aws_instance.instance.*.id, count.index)}"
  volume_id = "${element(aws_ebs_volume.docker.*.id, count.index)}"
  force_detach = true
}

resource "aws_volume_attachment" "instance-docker2" {
  count = "${var.aws_instance_count}"
  device_name = "xvdj"
  instance_id = "${element(aws_instance.instance.*.id, count.index)}"
  volume_id = "${element(aws_ebs_volume.docker.*.id, count.index)}"
  force_detach = true
}

/* Define a project-environment-instance.zone A record */
resource "aws_route53_record" "instance" {
  count = "${var.aws_instance_count}"
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "${element(aws_instance.instance.*.tags.Name, count.index)}.${var.dns_zone}"
  type    = "A"
  ttl     = "300"
  records = ["${element(aws_eip.instance.*.public_ip, count.index)}"]
}

/* Define a project-environment.zone round-robin of A records */
resource "aws_route53_record" "project-name-ipv4" {
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "${var.Lifecycle}.${var.dns_zone}"
  type    = "A"
  ttl     = "300"
  records = ["${join(",", aws_eip.instance.*.public_ip)}"]
}

/* Define a project-environment.zone round-robin of AAAA records */
resource "aws_route53_record" "project-name-ipv6" {
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "${var.Lifecycle}.${var.dns_zone}"
  type    = "AAAA"
  ttl     = "300"
  records = ["${join(",", flatten(aws_instance.instance.*.ipv6_addresses))}"]
}

/* Define traefik.project-environment.zone round-robin A records */
resource "aws_route53_record" "traefik-ipv4" {
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "traefik.${var.Lifecycle}.${var.dns_zone}"
  type    = "A"
  ttl     = "300"
  records = ["${join(",", aws_eip.instance.*.public_ip)}"]
}

/* Define traefik.project-environment.zone round-robin AAAA records */
resource "aws_route53_record" "traefik-ipv6" {
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "traefik.${var.Lifecycle}.${var.dns_zone}"
  type    = "AAAA"
  ttl     = "300"
  records = ["${join(",", flatten(aws_instance.instance.*.ipv6_addresses))}"]
}

/* Define guacamole.project-environment.zone round-robin A records */
resource "aws_route53_record" "guacamole-ipv4" {
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "guacamole.${var.Lifecycle}.${var.dns_zone}"
  type    = "A"
  ttl     = "300"
  records = ["${join(",", aws_eip.instance.*.public_ip)}"]
}

/* Define guacamole.project-environment.zone round-robin AAAA records */
resource "aws_route53_record" "guacamole-ipv6" {
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "guacamole.${var.Lifecycle}.${var.dns_zone}"
  type    = "AAAA"
  ttl     = "300"
  records = ["${join(",", flatten(aws_instance.instance.*.ipv6_addresses))}"]
}

/* Define a project-environment.zone wildcard of round-robin A records */
resource "aws_route53_record" "wildcard_project_name_ipv4" {
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "*.${var.Lifecycle}.${var.dns_zone}"
  type    = "A"
  ttl     = "300"
  records = ["${join(",", aws_eip.instance.*.public_ip)}"]
}

resource "aws_route53_record" "wildcard_project_name_ipv6" {
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "*.${var.Lifecycle}.${var.dns_zone}"
  type    = "AAAA"
  ttl     = "300"
  records = ["${join(",", flatten(aws_instance.instance.*.ipv6_addresses))}"]
}

output "hostname_list" {
  value = "${join(",", aws_instance.instance.*.tags.Name)}"
}

output "ec2_ids" {
  value = "${join(",", aws_instance.instance.*.id)}"
}

output "ec2_ipv4" {
  value = "${join(",", aws_eip.instance.*.public_ip)}"
}

output "ec2_ipv6" {
  value = "${join(",", flatten(aws_instance.instance.*.ipv6_addresses))}"
}

output "fqdns" {
  value = "${join(",", aws_route53_record.instance.*.fqdn)}"
}


