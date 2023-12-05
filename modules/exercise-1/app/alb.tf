resource "aws_security_group" "app-alb-sg" {
  name        = "app-alb-security-group"
  description = "Allow HTTPS traffic"
  vpc_id      = data.aws_vpc.vpc.id
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "app-alb-security-group"
  }
}

resource "aws_security_group_rule" "alb_http_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.app-alb-sg.id
}

resource "aws_security_group_rule" "alb_https_ingress" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.app-alb-sg.id
}

resource "aws_lb" "app-lb" {
  name               = "app-lb"
  load_balancer_type = "application"
  subnets            = [data.aws_subnet.subnet_1.id, data.aws_subnet.subnet_2.id]
  security_groups    = [aws_security_group.app-alb-sg.id]

  tags = {
    Name = "app-lb"
  }
}

resource "aws_lb_target_group" "app-target-group" {
  name     = "app-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_subnet.subnet_1.vpc_id
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 30
    interval            = 40
  }
}

resource "aws_lb_listener" "app-alb-listener" {
  load_balancer_arn = aws_lb.app-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app-target-group.arn
  }

}
