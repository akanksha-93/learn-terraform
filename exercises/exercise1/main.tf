terraform {
  required_version = ">= 1.4.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

provider "aws" {
  region     = "us-west-2"
  access_key = "AKIA52BLKQMYMCPZ6SVQ"
  secret_key = "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"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "CloudAcademy"
    Demo = "Terraform"
  }
}

resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "Subnet1"
    Type = "Public"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.availability_zones[1]

  tags = {
    Name = "Subnet2"
    Type = "Public"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    "Name"  = "Main"
    "Owner" = "CloudAcademy"
  }
}

resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "Public"
  }
}

resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rt1.id
}

resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.rt1.id
}

resource "aws_security_group" "webserver" {
  name        = "Webserver"
  description = "Webserver network traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.workstation_ip]
  }

  ingress {
    description = "80 from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow traffic"
  }
}

resource "aws_instance" "web" {
  ami                    = var.amis[var.region]
  instance_type          = var.instance_type
  key_name               = aws_key_pair.generated_key.key_name
  subnet_id              = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.webserver.id]

  associate_public_ip_address = true

  #userdata
  user_data = <<EOF
#!/bin/bash
apt-get -y update
apt-get -y install nginx

cd /var/www/html
rm *.html
git clone https://github.com/cloudacademy/webgl-globe/ .
cp -a src/* .
rm -rf {.git,*.md,src,conf.d,docs,Dockerfile,index.nginx-debian.html}

systemctl restart nginx
systemctl status nginx

echo fin v1.00!
EOF

  tags = {
    Name = "CloudAcademy"
  }
}

#Resource to create a SSH private key
resource "tls_private_key" "demo1" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

#Resource to Create Key Pair
resource "aws_key_pair" "generated_key" {
  key_name   = var.key_pair_name
  public_key = tls_private_key.demo1.public_key_openssh
  provisioner "local-exec" {
    command = "echo '${tls_private_key.demo1.private_key_pem}' > ./${var.key_pair_name}.pem"
  }
}