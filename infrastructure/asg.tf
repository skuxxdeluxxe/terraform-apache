resource "aws_launch_configuration" "bastion-lc" {
  name_prefix     = "bastion-lc-"
  image_id        = var.ami
  instance_type   = "t2.micro"
  key_name        = var.key_name
  security_groups = [aws_security_group.bastion-sg.id]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "bastion-asg" {
  name                 = "bastion-asg"
  launch_configuration = aws_launch_configuration.bastion-lc.name
  min_size             = 1
  max_size             = 1
  vpc_zone_identifier  = tolist(aws_subnet.public.*.id)

  lifecycle {
    create_before_destroy = true
  }
}
