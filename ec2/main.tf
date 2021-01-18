data "aws_availability_zones" "available" {}

resource "aws_key_pair" "admin" {
  key_name = "admin"
  public_key = file(var.my_public_key)
}

data "template_file" "initMaster" {
  template = file("${path.module}/userdataMaster.tpl")
}

data "template_file" "initSlave" {
  template = file("${path.module}/userdataSlave.tpl")
}

resource "aws_instance" "db_master" {
  ami = "ami-0d3f551818b21ed81"
  instance_type = var.instance_type
  key_name = aws_key_pair.admin.id
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  subnet_id = var.public_subnet3
  user_data = data.template_file.initMaster.rendered
  tags = {
    Name = "db master"
  }
}

resource "aws_instance" "db_slave" {
  ami = "ami-0d3f551818b21ed81"
  instance_type = var.instance_type
  key_name = aws_key_pair.admin.id
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  subnet_id = var.public_subnet4
  user_data = data.template_file.initSlave.rendered
  tags = {
    Name = "db slave"
  }
}

/*
resource "aws_security_group" "db_sg" {
  name   = "db_sg"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "inbound_ssh" {
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.db_sg.id
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "inbound_http" {
  from_port         = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.db_sg.id
  to_port           = 80
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "custom_port_app" {
  from_port         = 3000
  protocol          = "tcp"
  security_group_id = aws_security_group.db_sg.id
  to_port           = 3000
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "postgres" {
  from_port         = 5432
  protocol          = "tcp"
  security_group_id = aws_security_group.db_sg.id
  to_port           = 5432
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}


resource "aws_security_group_rule" "outbound_all" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.db_sg.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}
*/

resource "aws_security_group" "db_sg" {
    vpc_id = var.vpc_id
    
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        from_port = 5432
        to_port = 5432
    }

    ingress {
        protocol = "tcp"
        security_groups = [ var.vpc_sg ]
        from_port = 5432
        to_port = 5432
    }

    tags = {
        Name = "db_sg"
    }
}