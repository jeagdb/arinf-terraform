data "aws_availability_zones" "available" {}

resource "aws_key_pair" "admin" {
  key_name = "admin"
  public_key = file(var.my_public_key)
}

data "template_file" "init" {
  template = file("${path.module}/userdata.tpl")
}

resource "aws_instance" "server" {
  count = 2
  ami = "ami-0c3d23d707737957d"
  instance_type = var.instance_type
  key_name = aws_key_pair.admin.id
  vpc_security_group_ids = [var.security_group]
  subnet_id = element(var.subnets, count.index)
  user_data = data.template_file.init.rendered
}
