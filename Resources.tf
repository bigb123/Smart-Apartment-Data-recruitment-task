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

# resource "aws_route_table" "route_table_internet" {
#   vpc_id = aws_vpc.vpc.id

#   route {
#     cidr_block = "10.0.0.0/16"
#     gateway_id = aws_internet_gateway.internet_gateway.id
#   }

#   tags = {
#     Name = "Public (Internet) route table"
#   }
# }

# resource "aws_route_table_association" "route_table_public_subnet_association" {
#   gateway_id     = aws_internet_gateway.internet_gateway.id
#   route_table_id = aws_route_table.route_table_internet.id
# }

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

