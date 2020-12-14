data "aws_availability_zones" "available" {}

resource "aws_key_pair" "admin" {
  key_name = "admin"
  public_key = file(var.my_public_key)
}

data "template_file" "init" {
  template = file("${path.module}/userdata.tpl")
}

resource "aws_instance" "back" {
  count = var.private_instance_count
  ami = "ami-0d3f551818b21ed81"
  instance_type = var.instance_type
  key_name = aws_key_pair.admin.id
  vpc_security_group_ids = [var.security_group]
  subnet_id = element(var.private_subnets, count.index)
  user_data = data.template_file.init.rendered
  tags = {
    Name = "backend ec2 ${count.index}"
  }
}

resource "aws_instance" "front" {
  count = var.public_instance_count
  ami = "ami-0d3f551818b21ed81"
  instance_type = var.instance_type
  key_name = aws_key_pair.admin.id
  associate_public_ip_address = true
  vpc_security_group_ids = [var.security_group]
  subnet_id = element(var.public_subnets, count.index)
  user_data = data.template_file.init.rendered
  tags = {
    Name = "front ec2 ${count.index}"
  }
}