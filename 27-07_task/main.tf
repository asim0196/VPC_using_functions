provider "aws" {
  region = "ap-south-1"
}
########### vpc ##########
resource "aws_vpc" "terra_my_vpc"{
    cidr_block = var.vpc_cidr
    instance_tenancy = "default"
    tags = {
        Name = "terra_my_vpc"
    }
}
###############3 pub subnet ###########
resource "aws_subnet" "terra_pub_sub" {
  vpc_id     = aws_vpc.terra_my_vpc.id
  cidr_block = var.pub_sub_cidr
  map_public_ip_on_launch = var.public_ip_enable
  availability_zone = var.vpc_az[0]
  tags = {
    Name = "terra_my_pub_sub"
  }
}
############# pvt subnet ###########
resource "aws_subnet" "terra_pvt_sub" {
  vpc_id     = aws_vpc.terra_my_vpc.id
  cidr_block = var.pvt_sub_cidr
  availability_zone = var.vpc_az[1]
  tags = {
    Name = "terra_my_pvt_sub"
  }
}
######################################

locals {
    ingress_rules = [{
        port = 22
        description = "Ingress rule for port 22"
    },
    {
        port = 80
        description = "Ingress rule for port 80"
    },
    {
        port = 443
        description = "Ingress rule for port 443"
    },
    {
        port = 8080
        description = "Ingress rule for port 8080"
    }]
}

############# SG ##############
resource "aws_security_group" "cloud_sg" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.terra_my_vpc.id

  dynamic "ingress" {
    for_each = local.ingress_rules

    content {
      
    
    description      = ingress.value.description
    from_port        = ingress.value.port
    to_port          = ingress.value.port
    protocol         = "tcp"
    cidr_blocks      = [var.anywhere_cidr]
    
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.anywhere_cidr]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "cloud_sg"
  }
}
############## IGW ###########
resource "aws_internet_gateway" "terra_igw" {
  vpc_id = aws_vpc.terra_my_vpc.id

  tags = {
    Name = "terra_igw"
  }
}
############## RT ###########
resource "aws_route_table" "terra_rt" {
  vpc_id = aws_vpc.terra_my_vpc.id

  route {
    cidr_block = var.anywhere_cidr
    gateway_id = aws_internet_gateway.terra_igw.id
  }

  tags = {
    Name = "terra_RT"
  }

}

resource "aws_route_table_association" "Pub_sub_associte" {
  subnet_id      = aws_subnet.terra_pub_sub.id
  route_table_id = aws_route_table.terra_rt.id
}

resource "aws_instance" "Pub_ec2" {
  ami           = var.inst_ami
  instance_type = var.inst_type
  subnet_id = aws_subnet.terra_pub_sub.id
  security_groups = [aws_security_group.cloud_sg.id]
  tags = {
    Name = "Pub_ec2"
  }
}

resource "aws_instance" "Pvt_ec2" {
  ami           = var.inst_ami
  instance_type = var.inst_type
  subnet_id = aws_subnet.terra_pvt_sub.id
  security_groups = [aws_security_group.cloud_sg.id]
  tags = {
    Name = "Pvt_ec2"
  }
}

