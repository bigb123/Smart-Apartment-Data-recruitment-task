# terraform {
#   required_providers {
#     google = {
#       source = "hashicorp/google"
#     }
#   }
#   backend "gcs" {
#       bucket = "terraform-state-file-omiselabs-recruitment-task"
#   }
# }

# provider "google" {
#   version = "3.5.0"
#   credentials = file(var.gcp_credentials_file_path)
#   project = var.project_id
#   region  = "us-central1"
#   zone    = "us-central1-c"
# }


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