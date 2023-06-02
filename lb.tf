resource "aws_lb" "alb" {
  name               = "${var.tags.name}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = ["${module.custom_vpc_config.vpc.public_subnet_id[0]}", "${module.custom_vpc_config.vpc.public_subnet_id[1]}"] # Replace with your subnet IDs
  security_groups    = [module.custom_vpc_config.vpc.security_group_id[1]]
  depends_on = [
    module.custom_vpc_config,
    aws_instance.magento,
    aws_instance.varnish,
  ]
  #   enable_deletion_protection = true
  tags = {
    Name = "${var.tags.name}-Aplication-Load-Balancer"
    environment : var.tags.environment
  }
}

resource "aws_lb_listener" "alb_http_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
  tags = {
    Name = "${var.tags.name}-http-listener"
    environment : var.tags.environment
  }
}

resource "aws_lb_listener" "alb_https_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.varnish_target_group.arn
  }

  depends_on = [aws_acm_certificate.cert]

  tags = {
    Name = "${var.tags.name}-https-listener"
    environment : var.tags.environment
  }
}

resource "aws_lb_target_group" "varnish_target_group" {
  name     = "varnish-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.custom_vpc_config.vpc.vpc_id

  tags = {
    Name = "${var.tags.name}-varnish-target-group"
    environment : var.tags.environment
  }
}

resource "aws_lb_target_group" "magento_target_group" {
  name     = "magento-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.custom_vpc_config.vpc.vpc_id

  tags = {
    Name = "${var.tags.name}-magento-target-group"
    environment : var.tags.environment
  }
}

resource "aws_lb_target_group_attachment" "varnish_tga" {
  target_group_arn = aws_lb_target_group.varnish_target_group.arn
  target_id        = aws_instance.varnish.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "magento_tga" {
  target_group_arn = aws_lb_target_group.magento_target_group.arn
  target_id        = aws_instance.magento.id
  port             = 80
}

resource "aws_lb_listener_rule" "listener_rule1" {
  listener_arn = aws_lb_listener.alb_https_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.magento_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/static/*", "/media/*"]
    }
  }
  tags = {
    Name = "${var.tags.name}-static-media-rule"
    environment : var.tags.environment
  }
}
