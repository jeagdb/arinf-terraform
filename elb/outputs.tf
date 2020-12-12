output "elb_dns_name" {
  value = aws_elb.app-elb.dns_name
}

output "elb_name" {
  value = aws_elb.app-elb.name
}