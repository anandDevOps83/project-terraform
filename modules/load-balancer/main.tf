resource "aws_security_group" "load-balancer" {
  name        = "${var.name}-${var.env}-alb-sg"
  description = "${var.name}-${var.env}-alb-sg"
  vpc_id      = var.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-${var.env}-alb-sg"
  }
}

resource "aws_lb" "main" {
  name               = "${var.name}-${var.env}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load-balancer.id]
  subnets            = var.subnet_ids

  tags = {
    Environment = "${var.name}-${var.env}"
  }
}

resource "aws_lb_target_group" "main" {
  name     = "${var.name}-${var.env}"
  port     = var.allow_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 5
    path                = "/health"
    timeout             = 3
  }

}

resource "aws_lb_target_group_attachment" "main" {
  target_group_arn = aws_lb_target_group.main.arn
  target_id        = var.instance_id
  port             = 80
}

resource "aws_lb_listener" "public-http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_route53_record" "lb" {
  zone_id = var.zone_id
  name    = "${var.name}.${var.env}"
  type    = "CNAME"
  ttl     = 10
  records = [aws_lb.main.dns_name]
}

resource "aws_lb_listener_rule" "listener-rule" {
  listener_arn = aws_lb_listener.public-http.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  condition {
    host_header {
      values = [aws_route53_record.lb.fqdn]
    }
  }
}