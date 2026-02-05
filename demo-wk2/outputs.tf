output "az_subnet_instance_url" {
  description = "Map of AZ to subnet, instance ID, and URL"
  value = {
    for inst in aws_instance.web_server : inst.availability_zone => {
      subnet_id   = inst.subnet_id
      instance_id = inst.id
      url         = "http://${inst.public_dns}"
    }
  }
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket for logs"
  value       = module.s3_bucket.s3_bucket_id
}