resource "aws_eip" "redshift" {
  vpc = true
}

resource "aws_route53_record" "redshift" {
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "redshift-${var.Project}-${var.Lifecycle}.${var.dns_zone}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_eip.redshift.public_ip}"]
}

resource "aws_redshift_cluster" "default" {
  cluster_identifier = "${var.Project}-${var.Lifecycle}-redshift-cluster"
  database_name = "${var.Project}_${var.Lifecycle}"
  master_username = "${var.redshift_master_username}"
  master_password = "${var.redshift_master_password}"
  cluster_type = "single_node"
  node_type = "dc1.large"
  cluster_type = "single-node"
  availability_zone = "us-east-1a"
  elastic_ip = "${aws_eip.redshift.public_ip}"
  encrypted  = true
  final_snapshot_identifier = "${var.Project}-${var.Lifecycle}"
  skip_final_snapshot = false
  bucket_name = "sofwerx-logs"
  enable_logging = true
  s3_key_prefix = "/${var.Project}-${var.Lifecycle}/redshift"

  tags {
    Name = "${var.Project}-${var.Lifecycle}"
    Project = "${var.Project}"
    Lifecycle = "${var.Lifecycle}"
  }
}

resource "aws_redshift_subnet_group" "default" {
  name       = "${var.Project}-${var.Lifecycle}"
  subnet_ids = ["${join(",", aws_subnet.instances.*.id)}"]

  tags {
    Name = "${var.Project}-${var.Lifecycle}"
    Project = "${var.Project}"
    Lifecycle = "${var.Lifecycle}"
  }
}

resource "aws_redshift_parameter_group" "default" {
  name   = "parameter-group-test-terraform"
  family = "redshift-1.0"

  parameter {
    name  = "require_ssl"
    value = "true"
  }

  parameter {
    name  = "query_group"
    value = "example"
  }

  parameter {
    name  = "enable_user_activity_logging"
    value = "true"
  }
}
