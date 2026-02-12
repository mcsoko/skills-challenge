terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.5.0"
    }
  }

  cloud {
    organization = "rakatan"
    workspaces {
      tags = ["test-cli"]
    }
  }

  required_version = "~> 1.2"
}