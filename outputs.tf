output "available" {
  value = "${data.aws_availability_zones.available.names}"
}

output "elb_dns_name" {
  value = "${aws_elb.webserver.dns_name}"
}
