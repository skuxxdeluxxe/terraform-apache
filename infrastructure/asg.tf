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

resource "aws_launch_configuration" "webserver-lc" {
  name_prefix     = "webserver-lc-"
  image_id        = var.ami
  instance_type   = "t2.micro"
  key_name        = var.key_name
  security_groups = [aws_security_group.webserver-sg.id]
  user_data       = <<-EOF
                #!/bin/bash
                sudo yum update
                sudo yum install -y httpd
                sudo chkconfig httpd on
                sudo service httpd start
                echo "<h1>Hello Plexure!</h1>" | sudo tee /var/www/html/index.html
              EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "webserver-asg" {
  name                 = "webserver-asg"
  launch_configuration = aws_launch_configuration.webserver-lc.name
  min_size             = 1
  max_size             = 1
  vpc_zone_identifier  = tolist(aws_subnet.private.*.id)
  target_group_arns    = [aws_alb_target_group.loadbalancer-target-group.id]

  lifecycle {
    create_before_destroy = true
  }
}
