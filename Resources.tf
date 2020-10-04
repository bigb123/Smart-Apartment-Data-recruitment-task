#
# VPC
#

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  # instance_tenancy = default
  tags = {
    Name = "Smart Appartment Data recruitment task"
  }
}


#
# Subnets
#

resource "aws_subnet" "public_subnet_1" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Public subnet 1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Public subnet 2"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.128.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Private subnet 1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.129.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Private subnet 2"
  }
}

###
#
# Traffic routing
#
####

#
# Public routing
#

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "Internet Gateway"
  }
}

resource "aws_route_table" "route_table_internet" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "Public (Internet) route table"
  }
}

resource "aws_route_table_association" "route_table_internet_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.route_table_internet.id
}

resource "aws_route_table_association" "route_table_internet_association_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.route_table_internet.id
}

#
# Nat routing 
#

resource "aws_eip" "elastic_ip_nat_gateway" {
  vpc      = true
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.elastic_ip_nat_gateway.id
  subnet_id = aws_subnet.public_subnet_1.id
  depends_on = [ aws_internet_gateway.internet_gateway ]

  tags = {
    Name = "Nat Gateway"
  }
}

resource "aws_route_table" "route_table_private_subnet" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "Private (internal) route table"
  }
}

resource "aws_route_table_association" "route_table_private_subnet_1_association" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.route_table_private_subnet.id
}

resource "aws_route_table_association" "route_table_private_subnet_2_association" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.route_table_private_subnet.id
}


###
#
# EC2 instances
#
###

# resource "aws_launch_configuration" "ubuntu" {
#   name_prefix = "recruitment_task_"
#   image_id = "ami-0817d428a6fb68645"
#   instance_type = "t2.small"
#   associate_public_ip_address = false
#   ebs_optimized = true
#   root_block_device {
#     volume_size = 10
#   }
# }

resource "aws_security_group" "allow_http_internal" {
  name        = "allow_http_internal"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_http_internal"
  }
}

resource "aws_security_group" "allow_http_external" {
  name        = "allow_http_external"
  description = "Allow HTTP inbound traffic from the Internet"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "HTTP from outside world"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_http_external"
  }
}

resource "aws_lb" "app_load_balancer" {
  name = "alb-sad-recruitment-task"
  internal = false
  load_balancer_type = "application"
  security_groups = [ aws_security_group.allow_http_external.id ]
  subnets = [ aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id ]

}

resource "aws_lb_target_group" "load_balancer_target_group" {
  name     = "tg-sad-recruitment-task"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
}

resource "aws_lb_listener" "listener_http_80" {
  load_balancer_arn = aws_lb.app_load_balancer.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.load_balancer_target_group.arn
  }
}

resource "aws_launch_template" "nginx_template" {
  name = "asg-sad-recruitment-task"
  description = "Launch template for Smart Appartment Data recruitment task"
  update_default_version = true

  # block_device_mappings {
  #   device_name = "/dev/sda"

  #   ebs {
  #     volume_size = 20
  #     delete_on_termination = true
  #     volume_type = "gp2"
  #   }
  # }
  
  # capacity_reservation_specification {
  #   capacity_reservation_preference = "open"
  # }
  
  # cpu_options {
  #   core_count       = 2
  #   threads_per_core = 2
  # }

  ebs_optimized = false
  image_id = "ami-0708a0921e5eaf65d"
  # ubuntu: ami-0817d428a6fb68645
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ aws_security_group.allow_http_internal.id ]
  iam_instance_profile {
    arn =  aws_iam_role_policy_attachment.ec2_s3_access_permissions.arn
  }
  
  # metadata_options {
  #   http_endpoint               = "enabled"
  #   http_tokens                 = "required"
  #   http_put_response_hop_limit = 1
  # }

  monitoring {
    enabled = true
  }

  key_name = "sad-recruitment-task"

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "ASG instance SAD recruitment task"
    }
  }
}

resource "aws_autoscaling_group" "nginx_asg" {
  name = "nginx_asg"
  # launch_configuration = aws_launch_configuration.ubuntu.name
  launch_template {
    id = aws_launch_template.nginx_template.id
    version = "$Latest"
  }
  min_size = 1
  # desired_capacity = 1
  max_size = 3
  # availability_zones = ["us-east-1a"]
  health_check_grace_period = 300
  health_check_type = "ELB"
  vpc_zone_identifier = [ aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id ]
  target_group_arns = [ aws_lb_target_group.load_balancer_target_group.arn ]
}

resource "aws_autoscaling_policy" "cpu_load_autoscaling" {
  name = "cpu_load_autoscaling"
  autoscaling_group_name = aws_autoscaling_group.nginx_asg.name
  policy_type = "TargetTrackingScaling"
  estimated_instance_warmup = "180"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 60.0
  }
}


###
#
# Lambda
#
###

#
# IAM Permissions
#

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_access_permissions" {
  role = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

#
# Function
# 

resource "aws_lambda_function" "lambda_in_vpc" {
  function_name = "run_simple_code"
  description = <<EOF
"Function created for Smart Appartment Data recruitment task to 
demonstrate the ability to connect with local instances in VPC and with outside 
world."
EOF
  filename      = "lambda_function_source_code.zip"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.handler"
  publish       = true
  source_code_hash = filebase64sha256("lambda_function_source_code.zip")
  runtime = "nodejs12.x"
  
  vpc_config {
    subnet_ids = [ aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id ]
    security_group_ids = [ aws_security_group.allow_http_external.id ]
  }
}


###
#
# Code deploy
#
###

#
# IAM role for EC2 instance
#

resource "aws_iam_role" "iam_for_ec2" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ec2_s3_access_permissions" {
  role = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
}