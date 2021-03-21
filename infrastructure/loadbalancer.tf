resource "aws_alb_target_group" "loadbalancer-target-group" {
  name     = "loadbalancer-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.terra_vpc.id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    path                = "/index.html"
    port                = 80
    protocol            = "HTTP"
    interval            = 30
  }
}

resource "aws_alb" "loadbalancer" {
  name               = "application-loadbalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.loadbalancer-sg.id]
  subnets            = tolist(aws_subnet.public.*.id)

  enable_deletion_protection = false
}

resource "aws_alb_listener" "loadbalancer-listener" {
  load_balancer_arn = aws_alb.loadbalancer.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.loadbalancer-target-group.id
    type             = "forward"
  }
}

output "elb-dns-name" {
  value = "${aws_alb.loadbalancer.dns_name}"
}