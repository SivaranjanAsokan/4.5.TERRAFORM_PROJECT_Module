#Application LoadBalancer
resource "aws_lb" "alb2" {
  name               = "test-lb-tf2"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_tls.id]
  subnets            = [aws_subnet.pub-subnet1.id, aws_subnet.pub-subnet2.id]

  enable_deletion_protection = false

  tags = {
    Environment = "test"
  }
}

//Target Group
resource "aws_lb_target_group" "albtg2" {
  name     = "tf-example-lb-tg2"
  port     = 80
  protocol = "HTTP"
  target_type = "instance"
  vpc_id   = aws_vpc.vpc-2.id

  health_check {    
    healthy_threshold   = 3    
    unhealthy_threshold = 10    
    timeout             = 5    
    interval            = 10    
    path                = "/"    
    port                = 80  
  }
}

#TG attachment
resource "aws_lb_target_group_attachment" "front_end2" {
  target_group_arn = aws_lb_target_group.albtg2.arn
  target_id        = aws_instance.ec2.id
  port             = 80
  
}

//Listener
resource "aws_lb_listener" "alb2" {
  load_balancer_arn = aws_lb.alb2.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.albtg2.arn
  }
}
