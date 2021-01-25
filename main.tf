provider "aws" {
  region     = var.region
}

terraform {
  backend "s3" {
    encrypt = true
    bucket  = "theo-bucket"
    region  = "eu-west-3"
    key     = "instances_feugeas.tfstate"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  count         = var.create_instance ? var.instance_number : 0
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name = "tp_dev_ynov"

  tags = {
    Name = var.instance_name
  }
}

resource "aws_security_group" "security_group_terraform_theo-ssh" {
  name = "security_group_terraform_theo-ssh"

  ingress {
    description = "SSH from EC2"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
