resource "aws_launch_configuration" "launch-config" {
  image_id = "ami-0c3d23d707737957d"
  instance_type = "t2.micro"
  security_groups = var.security_groups

  user_data = <<-EOF
              #!/bin/bash
              yum -y install httpd
              echo "Hello, from Terraform" > /var/www/html/index.html
              service httpd start
              chkconfig httpd on
              EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "app-asg" {
  launch_configuration = aws_launch_configuration.launch-config.id
  vpc_zone_identifier = [var.subnet1, var.subnet2]
  load_balancers = [var.elb]
  health_check_type = "ELB"

  min_size = 2
  max_size = 10
}
