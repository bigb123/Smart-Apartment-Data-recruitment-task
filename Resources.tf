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

resource "aws_subnet" "public_subnet_1" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "Public subnet 1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Public subnet 2"
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

