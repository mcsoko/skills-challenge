variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-2"
}

variable "instance_type" {
  description = "AWS instance type to deploy"
  type        = string
  default     = "t3.micro"

  validation {
    condition     = contains(["t3.micro", "t3.small", "t3.medium"], var.instance_type)
    error_message = "Invalid instance type. Allowed values are: t3.micro, t3.small, t3.medium."
  }
}

variable "instance_count" {
  description = "Number of AWS instances to deploy"
  type        = number
  validation {
    condition     = var.instance_count > 1
    error_message = "Requires more than 1 instance"
  }
}

variable "app_secret" {
  description = "Sensitive value injected into the instance"
  type        = string
  sensitive   = true
}

