terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  backend "s3" {
    bucket = "terraform-state-file-smart-appartment-data-recruitment-task"
    key    = "terraform_state_file.tfstate"
    # region = var.aws_region
    dynamodb_table = "terraform-state-file-lock-smart-appartment-data-recruitment-task"
  }
}

provider "aws" {
  region = "us-east-1"
}