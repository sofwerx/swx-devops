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

data "aws_route53_zone" "selected" {
  name         = "${var.dns_zone}"
  private_zone = false
}

/* Define a supermicro0.opswerx.org CNAME record */
resource "aws_route53_record" "project-name-cname" {
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "${var.Lifecycle}.${var.dns_zone}"
  type    = "A"
  ttl     = "300"
  records = ["172.109.143.82"]
}

/* Define a *.supermicro0.opswerx.org CNAME record */
resource "aws_route53_record" "project-name-wildcard" {
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "*.${var.Lifecycle}.${var.dns_zone}"
  type    = "A"
  ttl     = "300"
  records = ["172.109.143.82"]
}

