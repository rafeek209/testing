provider "aws" {
  region     = "us-east-1"
}

data "aws_vpc" "existing_vpc" {
  filter {
    name   = "tag:Name"
    values = ["existing-vpc"]
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = data.aws_vpc.existing_vpc.id
  cidr_block = var.public_subnet_cidr

  tags = {
    Name = var.public_subnet_name
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = data.aws_vpc.existing_vpc.id

  tags = {
    Name = "internet-gateway"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = data.aws_vpc.existing_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = data.aws_vpc.existing_vpc.id
  cidr_block = var.private_subnet_cidr

  tags = {
    Name = var.private_subnet_name
  }
}

resource "aws_instance" "public_instance" {
  ami           = "ami-0ebfd941bbafe70c6"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = var.public_instance_name
  }
}

resource "aws_instance" "private_instance" {
  ami           = "ami-0ebfd941bbafe70c6"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_subnet.id

  tags = {
    Name = var.private_instance_name
  }
}

output "ec2_private_ip" {
  value = aws_instance.private_instance.private_ip
}

output "ec2_state" {
  value = aws_instance.private_instance.instance_state
}
