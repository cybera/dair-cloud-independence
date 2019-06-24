provider "aws" {
  region = "${var.aws_location}"
}

resource "aws_vpc" "django_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  tags = "${var.tags}"
}

resource "aws_internet_gateway" "django_gw" {
  vpc_id = "${aws_vpc.django_vpc.id}"

  tags = "${var.tags}"
}

resource "aws_route_table" "django_rt1" {
  vpc_id = "${aws_vpc.django_vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.django_gw.id}"
  }

  tags = "${var.tags}"
}

resource "aws_subnet" "django_sub" {
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = "true"
  vpc_id                  = "${aws_vpc.django_vpc.id}"

  tags = "${var.tags}"
}

resource "aws_route_table_association" "association-subnet" {
  subnet_id      = "${aws_subnet.django_sub.id}"
  route_table_id = "${aws_route_table.django_rt1.id}"
}

resource "aws_security_group" "django_sg" {
  name   = "${var.name}.${var.domain}"
  vpc_id = "${aws_vpc.django_vpc.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "icmp"
    from_port   = -1
    to_port     = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["${var.allowed_net}"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 8000
    to_port     = 8000
    cidr_blocks = ["${var.allowed_net}"]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 3000
    to_port     = 3000
    cidr_blocks = ["${var.allowed_net}"]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["${var.allowed_net}"]
  }

  tags = "${var.tags}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_key_pair" "django_key" {
  key_name   = "${var.name}"
  public_key = "${file("../../key/id_rsa.pub")}"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "django_instance" {
  ami                         = "${data.aws_ami.ubuntu.id}"
  instance_type               = "t3.small"
  key_name                    = "${aws_key_pair.django_key.key_name}"
  associate_public_ip_address = true
  subnet_id                   = "${aws_subnet.django_sub.id}"
  vpc_security_group_ids      = ["${aws_security_group.django_sg.id}"]

  tags = "${var.tags}"
}

resource "aws_eip" "django_eip" {
  instance = "${aws_instance.django_instance.id}"
  vpc      = true

  tags = "${var.tags}"
}

# Deploy the application to the virtual machine
module "deploy_app" {
  source     = "../deploy_app"
  ip_address = "${aws_instance.django_instance.public_ip}"
  ssh_key    = "${file("../../key/id_rsa")}"
}

output "public_ip" {
  value = "${aws_instance.django_instance.public_ip}"
}
