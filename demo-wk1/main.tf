provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "demo-bucket" {
  bucket = "my-skills-challenge-bucket-wk1"
  tags = {
    ManagedBy = "terraform"
    CreatedBy = "soko"
  }
}

