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
