data "aws_availability_zones" "available" {}

// VPC resource
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true
}

// Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

// PUBLIC SUBNETS
resource "aws_subnet" "public_subnet" { 
  count = 2
  cidr_block = var.public_cidrs[count.index]
  vpc_id = aws_vpc.main.id
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "public subnet ${count.index}"
  }
}

// PRIVATE SUBNETS
resource "aws_subnet" "private_subnet" {
  count = 4
  cidr_block = var.private_cidrs[count.index]
  vpc_id = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[count.index % 2]
  tags = {
    Name = "private subnet ${count.index}"
  }
}

// table de routing public
resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public route table"
  }
}
/*
// table de routing privé
resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "private route table"
  }
}*/

// Association routes publiques
resource "aws_route_table_association" "public_subnet_assoc" {
  count = 2
  route_table_id = aws_route_table.public_route.id
  subnet_id = aws_subnet.public_subnet.*.id[count.index]
  depends_on = [aws_route_table.public_route, aws_subnet.public_subnet]
}

/*
// Association routes privées
resource "aws_route_table_association" "private_subnet_assoc" {
  count = 4
  route_table_id = aws_route_table.private_route.id
  subnet_id = aws_subnet.private_subnet.*.id[count.index]
  depends_on = [aws_route_table.private_route, aws_subnet.private_subnet]
}*/


//pare-feu virtuel pour notre vpc afin de contrôler le trafic entrant et sortant.
//se situe au niveau de l'instance et PAS du réseau
resource "aws_security_group" "vpc_sg" {
  name   = "my-vpc-sg"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  /*
  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }*/
}