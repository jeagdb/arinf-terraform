data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_default_route_table" "private_route" {
  default_route_table_id = aws_vpc.main.default_route_table_id
}

resource "aws_route_table_association" "private_subnet_assoc" {
  count = 4
  route_table_id = aws_default_route_table.private_route.id
  subnet_id = aws_subnet.private_subnet.*.id[count.index]
  depends_on = [aws_default_route_table.private_route, aws_subnet.private_subnet]
}

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

resource "aws_subnet" "private_subnet" {
  count = 4
  cidr_block = var.private_cidrs[count.index]
  vpc_id = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[count.index % 2]
  tags = {
    Name = "private subnet ${count.index}"
  }
}

//pare-feu virtuel pour notre vpc afin de contrôler le trafic entrant et sortant.
//se situe au niveau de l'instance et PAS du réseau
resource "aws_security_group" "vpc_sg" {
  name   = "my-vpc-sg"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group_rule" "ssh_inbound_access" {
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.vpc_sg.id
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "http_inbound_access" {
  from_port         = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.vpc_sg.id
  to_port           = 80
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "all_outbound_access" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.vpc_sg.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}