# =============================================================================
# 3. LOAD BALANCER (AWS ALB)
# =============================================================================

resource "aws_lb" "f1_alb" {
  name               = "f1-app-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

resource "aws_lb_target_group" "f1_tg" {
  name     = "f1-k3s-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.k3s_vpc.id
  
  health_check {
    path = "/" 
    matcher = "200,404"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.f1_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.f1_tg.arn
  }
}