#terraform Block 
terraform {
  required_version = "~> 1.5"  # Terraform version

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"         # Provider AWs version 
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"  # Check latest version
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"  # Check latest version
    }
  }
}

provider "aws" {
  region = var.aws_region
}