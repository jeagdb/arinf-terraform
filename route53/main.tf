resource "aws_route53_zone" "route53-zone" {
  name = "example.com"

  vpc {
    vpc_id = var.vpc_id
  }
}

resource "aws_route53_record" "route53-record" {
  count = length(var.hostname)
  name = element(var.hostname, count.index)
  records = [element(var.arecord, count.index)]
  zone_id = aws_route53_zone.route53-zone.id
  type = "A"
  ttl = "300"
}
