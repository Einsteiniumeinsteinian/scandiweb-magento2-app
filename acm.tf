resource "aws_acm_certificate" "cert" {
  private_key      = file(var.domain_setup.private_key)
  certificate_body = file(var.domain_setup.cert_body)
}

resource "aws_route53_zone" "route53" {
  name = var.domain_setup.domainName
  tags = {
    Name = "${var.tags.name}-route53"
    environment : var.tags.environment
  }
}

resource "aws_route53_record" "www_record" {
  zone_id = aws_route53_zone.route53.zone_id
  name    = var.domain_setup.domainName
  type    = "A"
  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "root_record" {
  zone_id = aws_route53_zone.route53.zone_id
  name    = var.domain_setup.record
  type    = "A"
  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}

output "nameservers" {
  value = aws_route53_zone.route53.name_servers
}
