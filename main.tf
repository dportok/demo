# Define the provider
provider "aws" {
  region = "${var.region}"
}

# Module that builds the Network Infrastructure
module "infra_setup" {
  source             = "./modules/network_setup"
  vpc_cidr_block     = "10.0.0.0/16"
  azones             = "${data.aws_availability_zones.available.names[0]}"
  public_cidr_block  = "10.0.1.0/24"
  private_cidr_block = "10.0.2.0/24"
}

# Create a Security Group for the Traffic that enters the ELB
resource "aws_security_group" "elb" {
  description = "ELB incoming Traffic"
  vpc_id      = "${module.infra_setup.vpc_id_out}"

  tags {
    Name        = "${var.name}-ELB-Traffic"
    Environment = "${var.environment}"
    ManagedBy   = "${var.managed}-${var.name}"
  }
}

# Apply the appropriate rules to the ELB SG
module "elb_sg_rules" {
  source            = "./modules/sg_rules"
  security_group_id = "${aws_security_group.elb.id}"

  ingress_rules_cidrs = <<EOF
tcp | 80 | 80 | 0.0.0.0/0
tcp | 443 | 443 | 0.0.0.0/0
tcp | 22 | 22 | 0.0.0.0/0
EOF

  egress_rules_cidrs = <<EOF
-1 | 0 | 0 | 0.0.0.0/0
EOF
}

# Create a Security Group for the Traffic inside the VPC
resource "aws_security_group" "internal_traffic" {
  description = "VPC Internal Traffic"
  vpc_id      = "${module.infra_setup.vpc_id_out}"
  description = "Allow all traffic between the 2 subnets"

  tags {
    Name        = "${var.name}-Internal-Traffic"
    Environment = "${var.environment}"
    ManagedBy   = "${var.managed}-${var.name}"
  }
}

# Apply the appropriate rules to the Internal Traffic SG
module "internal_traffic_sg_rules" {
  source            = "./modules/sg_rules"
  security_group_id = "${aws_security_group.internal_traffic.id}"

  ingress_rules_cidrs = <<EOF
-1 | 0 | 0 | 10.0.0.0/16
EOF

  egress_rules_cidrs = <<EOF
-1 | 0 | 0 | 0.0.0.0/0
EOF
}

# Create the ELB that will handle the Traffic
resource "aws_elb" "webserver" {
  name            = "Webserver-ASG-ELB"
  subnets         = ["${module.infra_setup.public_subnet_id_out}"]
  security_groups = ["${aws_security_group.elb.id}", "${aws_security_group.internal_traffic.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  tags {
    Name        = "${var.name}-ELB-WebServer"
    Environment = "${var.environment}"
    ManagedBy   = "${var.managed}-${var.name}"
  }
}

# Create the ASG for the HA Setup of the Webservers
resource "aws_autoscaling_group" "ha_webserver" {
  launch_configuration = "${aws_launch_configuration.webserver.name}"
  vpc_zone_identifier  = ["${module.infra_setup.private_subnet_id_out}"]

  min_size          = 2
  max_size          = 6
  load_balancers    = ["${aws_elb.webserver.name}"]
  health_check_type = "ELB"

  tag {
    key                 = "${var.name}-HA-WebServer"
    value               = "${var.environment}-ASG"
    propagate_at_launch = true
  }

  depends_on = ["module.infra_setup"]
}

# Create the Launch Configuration for the instances of the ASG
resource "aws_launch_configuration" "webserver" {
  image_id        = "ami-e3051987"
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.internal_traffic.id}"]
  key_name        = "demo"
  user_data       = "${data.template_file.webserver.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

# The template file according to which the new instances will be created
data "template_file" "webserver" {
  template = "${file("./templates/httpd_install.sh")}"

  vars {
    index = "https://s3.eu-west-2.amazonaws.com/testing-dportok-static/index.html"
    image = "https://s3.eu-west-2.amazonaws.com/testing-dportok-static/linux.png"
  }
}

# A bastion-like instance in order to access the WebServers
resource "aws_instance" "bastion-instance" {
  ami                    = "ami-e3051987"
  subnet_id              = "${module.infra_setup.public_subnet_id_out}"
  instance_type          = "t2.nano"
  key_name               = "demo"
  vpc_security_group_ids = ["${aws_security_group.elb.id}", "${aws_security_group.internal_traffic.id}"]

  tags {
    Name        = "${var.name}-Bastion"
    Environment = "${var.environment}"
    ManagedBy   = "${var.managed}-${var.name}"
  }
}

############################# Static Content to be Served ######################
resource "aws_s3_bucket" "testing-bucket-dportok" {
  bucket = "testing-dportok-static"
  acl    = "public-read"

  tags {
    Name        = "${var.name}"
    Environment = "${var.environment}"
    ManagedBy   = "${var.managed}-${var.name}"
  }
}

resource "aws_s3_bucket_object" "image" {
  acl    = "public-read"
  key    = "linux.png"
  bucket = "${aws_s3_bucket.testing-bucket-dportok.bucket}"
  source = "./site/linux.png"
}

resource "aws_s3_bucket_object" "index" {
  acl    = "public-read"
  key    = "index.html"
  bucket = "${aws_s3_bucket.testing-bucket-dportok.bucket}"
  source = "./site/index.html"
}
