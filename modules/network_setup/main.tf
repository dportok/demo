# ################################ NETWORK SETUP ###############################
resource "aws_vpc" "vpc_demo" {
  cidr_block           = "${var.vpc_cidr_block}"
  enable_dns_support   = "${var.enable_dns_support}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"

  tags {
    Name        = "${var.name}-VPC"
    Environment = "${var.environment}"
    ManagedBy   = "${var.managed}-${var.name}"
  }
}

# Remove all rules from the default SG and adopt it to Terraform
resource "aws_default_security_group" "default_sg" {
  vpc_id = "${aws_vpc.vpc_demo.id}"

  tags {
    Name        = "${var.name}-SG-Default"
    Environment = "${var.environment}"
    ManagedBy   = "${var.managed}-${var.name}"
  }
}

# Remove all rules from the default RT and adopt it to Terraform
resource "aws_default_route_table" "default_rt" {
  default_route_table_id = "${aws_vpc.vpc_demo.default_route_table_id}"

  tags {
    Name        = "${var.name}-Route-Table-Default"
    Environment = "${var.environment}"
    ManagedBy   = "${var.managed}-${var.name}"
  }
}

# Create a public subnet
resource "aws_subnet" "webserver-public-subnet" {
  vpc_id                  = "${aws_vpc.vpc_demo.id}"
  availability_zone       = "${var.azones}"
  cidr_block              = "${var.public_cidr_block}"
  map_public_ip_on_launch = true

  tags {
    Name        = "${var.name}-Public-Subnet"
    Environment = "${var.environment}"
    ManagedBy   = "${var.managed}-${var.name}"
  }
}

# Create a private subnet
resource "aws_subnet" "webserver-private-subnet" {
  vpc_id            = "${aws_vpc.vpc_demo.id}"
  availability_zone = "${var.azones}"
  cidr_block        = "${var.private_cidr_block}"

  tags {
    Name        = "${var.name}-Private-Subnet"
    Environment = "${var.environment}"
    ManagedBy   = "${var.managed}-${var.name}"
  }
}

# Create a route to the Internet for the VPC
resource "aws_internet_gateway" "internet_access" {
  vpc_id = "${aws_vpc.vpc_demo.id}"

  tags {
    Name        = "${var.name}-IGW"
    Environment = "${var.environment}"
    ManagedBy   = "${var.managed}-${var.name}"
  }
}

# Create a route table for the Public Subnet
resource "aws_route_table" "public-face" {
  vpc_id = "${aws_vpc.vpc_demo.id}"

  tags {
    Name        = "${var.name}-Public-Face"
    Environment = "${var.environment}"
    ManagedBy   = "${var.managed}-${var.name}"
  }
}

# Create a route table for the Private Subnet
resource "aws_route_table" "private-face" {
  vpc_id = "${aws_vpc.vpc_demo.id}"

  tags {
    Name        = "${var.name}-Private-Face"
    Environment = "${var.environment}"
    ManagedBy   = "${var.managed}-${var.name}"
  }
}

# Create an EIP
resource "aws_eip" "demo_eip" {
  vpc        = true
  depends_on = ["aws_internet_gateway.internet_access"]
}

# Create a NAT GW
resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.demo_eip.id}"
  subnet_id     = "${aws_subnet.webserver-public-subnet.id}"
  depends_on    = ["aws_internet_gateway.internet_access"]
}

# Addd a route to the internet for the IGW
resource "aws_route" "internet-route" {
  route_table_id         = "${aws_route_table.public-face.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.internet_access.id}"
}

resource "aws_route_table_association" "public" {
  subnet_id      = "${aws_subnet.webserver-public-subnet.id}"
  route_table_id = "${aws_route_table.public-face.id}"
}

# Addd a route to the internet for the Private Subnet
resource "aws_route" "private-route" {
  route_table_id         = "${aws_route_table.private-face.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.nat.id}"
}

resource "aws_route_table_association" "private" {
  subnet_id      = "${aws_subnet.webserver-private-subnet.id}"
  route_table_id = "${aws_route_table.private-face.id}"
}
