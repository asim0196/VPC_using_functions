provider "aws" {
    region = "ap-south-1"
}


resource "aws_vpc" "dev_1" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "Function_VPC"
  }
}

resource "aws_subnet" "dev_1_public_1" {
 count = length(var.vpc_subnet_pub_1)
  map_public_ip_on_launch = var.Pub_ip
  vpc_id     = aws_vpc.dev_1.id
  cidr_block = var.vpc_subnet_pub_1[count.index]
  availability_zone = element(var.vpc_az, count.index)

  tags = {
    Name = "Function_Pub_Sub"
  }
}

resource "aws_subnet" "dev_1_pvt_1" {
  count = length(var.vpc_subnet_pvt_1)

  vpc_id = aws_vpc.dev_1.id
  cidr_block = var.vpc_subnet_pvt_1[count.index]
  availability_zone = element(var.vpc_az, count.index)
  tags = {
    Name = "Function_pvt_sub"
  }
}

resource "aws_route_table" "dev_1_rt" {
  vpc_id = aws_vpc.dev_1.id
   route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Funtion_RTr"
  }
}

resource "aws_route_table_association" "public" {
  count      = length(aws_subnet.dev_1_public_1)
  subnet_id = aws_subnet.dev_1_public_1[count.index].id

  route_table_id = aws_route_table.dev_1_rt.id
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.dev_1.id

  tags = {
    Name = "cdec_b24_igw"
  }
}


resource "aws_instance" "web" {
  ami           = "ami-0763cf792771fe1bd"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.dev_1_public_1[1].id
  security_groups = [aws_security_group.my_sg.id]
  key_name = var.Key_name
  tags = {
    Name = "Func_ec2"
  }
}

resource "aws_security_group" "my_sg" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.dev_1.id

  ingress {
    description = "TLS from VPC"
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

  tags = {
    Name = "Func_sg"
  }
}

output "instance_ip_addr" {
  value = aws_instance.web.public_ip
}
