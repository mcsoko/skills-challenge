terraform {
  required_providers {

    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
    vault = {

    }
  }

  required_version = "~> 1.2"

  # backend "s3" {
  #   bucket       = "soko-demo-terraform-state-2026"
  #   key          = "tf-state/terraform.tfstate"
  #   region       = "us-east-2"
  #   use_lockfile = true # The new v1.12+ best practice
  # }
}