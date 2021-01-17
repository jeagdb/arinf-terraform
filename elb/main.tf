resource "aws_elb" "app-elb" {
  name = "app-elb"

  subnets = var.subnets
  security_groups = [aws_security_group.elb_sg.id]

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

resource "aws_security_group" "elb_sg" {
  name = "elb-sg"
  vpc_id = var.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "AWS default egress rule"
  }
    ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
    ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}