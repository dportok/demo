output "vpc_id_out" {
  description = "The ID of the VPC"
  value       = "${aws_vpc.vpc_demo.id}"
}

output "public_subnet_id_out" {
  description = "The ID of the Public subnet"
  value       = "${aws_subnet.webserver-public-subnet.id}"
}

output "private_subnet_id_out" {
  description = "The ID of the Private subnet"
  value       = "${aws_subnet.webserver-private-subnet.id}"
}

output "nat_gateway_id_out" {
  description = "The ID of the NAT Gateway"
  value       = "aws_nat_gateway.nat.id"
}
