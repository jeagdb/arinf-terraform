data "template_file" "init" {
  template = file("${path.module}/userdata.tpl")
  vars = {
    master = var.master_ip
  }
}

resource "aws_launch_configuration" "launch-config" {
  image_id = "ami-0d3f551818b21ed81"
  instance_type = "t2.micro"
  security_groups = var.security_groups

  user_data =  data.template_file.init.rendered

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "app-asg" {
  launch_configuration = aws_launch_configuration.launch-config.id
  vpc_zone_identifier = [var.subnet1, var.subnet2]
  target_group_arns = [var.target_group_arn]
  health_check_type = "ELB"

  min_size = 2
  max_size = 10
}