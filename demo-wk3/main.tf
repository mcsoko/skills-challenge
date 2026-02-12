provider "aws" {
  region = "us-east-2"
}


import {
   id = "test-skills-challenge"
   to = aws_s3_bucket.imported
}


# __generated__ by Terraform from "test-skills-challenge"
resource "aws_s3_bucket" "imported" {
  bucket              = "test-skills-challenge"
  bucket_prefix       = null
  force_destroy       = false
  object_lock_enabled = false
  region              = "us-east-2"
  tags                = {}
  tags_all            = {}
}

# removed {
#   from = aws_s3_bucket.imported

#   lifecycle {
#     destroy = false
#   }
# }