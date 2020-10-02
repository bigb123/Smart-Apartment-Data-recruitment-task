# resource "google_container_cluster" "kube-cluster" {
#   name = var.kubernetes_cluster_name
#   description = "The Kubernetes cluster created in Amity recruitment task purposes"
#   location = var.gcp_region
#   remove_default_node_pool = true
#   initial_node_count = 1
#   min_master_version = "1.16.13-gke.1"
# }

# resource "google_container_node_pool" "kube-node-pool" {
#   name = "kube-node-pool"
#   location = var.gcp_region
#   cluster = google_container_cluster.kube-cluster.name
#   node_count = 1

#   autoscaling {
#     min_node_count = 1
#     max_node_count = 1
#   }
# }


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

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "Public subnet"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.128.0/24"

  tags = {
    Name = "Private subnet 1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.129.0/24"

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
  subnet_id      = aws_subnet.public_subnet.id
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
  subnet_id = aws_subnet.public_subnet.id
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

resource "aws_launch_template" "asg_launch_template" {
  name = "asg-sat-recruitment-task"
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
  
  disable_api_termination = false
  ebs_optimized = true
  image_id = "ami-0817d428a6fb68645"
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t2.micro"
  
  # metadata_options {
  #   http_endpoint               = "enabled"
  #   http_tokens                 = "required"
  #   http_put_response_hop_limit = 1
  # }

  monitoring {
    enabled = true
  }

  # network_interfaces {
  #   associate_public_ip_address = true
  # }

  # placement {
  #   availability_zone = "us-east-1a"
  # }

  # tag_specifications {
  #   resource_type = "instance"

  #   tags = {
  #     Name = "ASG instance"
  #   }
  # }
}

# resource "aws_autoscaling_group" "ubuntu_asg" {
#   name = "ubuntu_asg"
#   # launch_configuration = aws_launch_configuration.ubuntu.name
#   launch_template {
#     id = aws_launch_template.asg_launch_template.id
#     version = "$Latest"
#   }
#   min_size = 1
#   desired_capacity = 1
#   max_size = 3
#   # availability_zones = ["us-east-1a"]
#   health_check_grace_period = 300
#   health_check_type = "ELB"
#   vpc_zone_identifier = [ aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id ]
# }