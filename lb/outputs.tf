output "lb_dns_name" {
  value = aws_lb.app-lb.dns_name
}

output "lb_target_group_arn" {
  value = aws_lb_target_group.lb-target-group.arn
}
