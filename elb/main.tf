resource "aws_elb" "app-elb" {
  name = "app-elb"

  subnets = var.subnets
  security_groups = [aws_security_group.elb-sg.id]

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:80/index.html"
    interval = 30
  }

  instances = var.instances
  cross_zone_load_balancing = true
  idle_timeout = 100
  connection_draining = true
  connection_draining_timeout = 300

  tags = {
    Name = "app-elb"
  }
}

resource "aws_security_group" "elb-sg" {
  name = "elb-sg"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "inbound_ssh" {
  from_port = 22
  protocol = "tcp"
  security_group_id = aws_security_group.elb-sg.id
  to_port = 22
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "inbound_http" {
  from_port = 80
  protocol = "tcp"
  security_group_id = aws_security_group.elb-sg.id
  to_port = 80
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "outbound_all" {
  from_port = 0
  protocol = "-1"
  security_group_id = aws_security_group.elb-sg.id
  to_port = 0
  type = "egress"
  cidr_blocks = ["0.0.0.0/0"]
}
