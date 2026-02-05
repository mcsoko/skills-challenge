# Configuration for providers


# Data sources 
data "aws_vpc" "default" {
  default = true
}

data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_subnet" "by_id" {
  for_each = toset(data.aws_subnets.default.ids)
  id       = each.value
}

data "aws_ami" "latest_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

data "http" "endpoint" {
  for_each = { for index, instance in aws_instance.web_server : index => instance }
  url      = "http://${each.value.public_dns}"

  retry {
    attempts     = 5
    min_delay_ms = 3000
    max_delay_ms = 10000
  }

}

data "vault_generic_secret" "example" {
  path = "secret/foo"
}


#construct the map of az-subnet from data sources
locals {
  az_to_subnet = { for subnet in data.aws_subnet.by_id : subnet.availability_zone => subnet.id }
  az_names     = sort(keys(local.az_to_subnet))
}


module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = ">=5.10.0"

  bucket_prefix = "demo-web-logs-"

  versioning = {
    enabled = true
  }

  tags = {
    Environment = "demo"
    Purpose     = "web-server-logs"
  }
}

resource "aws_security_group" "web" {
  name_prefix = "demo-sg"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "web" {
  name = "iam-web-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.web.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_iam_instance_profile" "web" {
  name = "iam-profile"
  role = aws_iam_role.web.name
}

resource "aws_instance" "web_server" {
  count         = var.instance_count
  ami           = data.aws_ami.latest_linux.id
  instance_type = var.instance_type
  subnet_id     = local.az_to_subnet[local.az_names[count.index % length(local.az_names)]]

  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.web.id]
  iam_instance_profile   = aws_iam_instance_profile.web.name

  tags = {
    Name = "demo-web-instance-${count.index}"
  }

  user_data = <<-EOF
  #!/bin/bash
  sudo yum update -y
  sudo yum install httpd -y
  sudo systemctl enable httpd
  sudo systemctl start httpd
  echo "APP_SECRET=${var.app_secret}" | sudo tee /etc/app.env
  echo "APP_SECRET=${var.app_secret}" | sudo tee /dev/console
  echo "<html>
  <body style='background-color: black; color: white; text-align: center; font-family: sans-serif; padding-top: 50px;'>
    <img src='https://firebasestorage.googleapis.com/v0/b/standards-site-beta.appspot.com/o/documents%2F4a24m5t0li5%2Fantwtl4lq0z%2FHashiCorp_an_IBM_Company_lockup_smalluse_rev_white_RGB%20(1)_1736205271749_2500x2500.png?alt=media&token=72f9e075919' width='200'>
  <div><h1>Terraform Rocks!</h1></div>
  <div><strong>Instance Index:</strong> ${count.index}</div>
  </body></html>" > /var/www/html/index.html
  EOF

  lifecycle {
    precondition {
      condition     = var.instance_count % length(data.aws_availability_zones.available.names) == 0
      error_message = "The number of instances (${var.instance_count}) must be evenly divisible by the number of availability zones (${length(data.aws_availability_zones.available.names)})."
    }
  }
}



check "instance_az_count" {
  assert {
    condition     = var.instance_count <= length(local.az_names)
    error_message = "instance_count must be less than or equal to the number of available AZs in this region."
  }
}

check "health_check" {
  assert {
    condition     = alltrue([for instance in data.http.endpoint : instance.status_code == 200])
    error_message = "Health check failed: one or more endpoints did not return HTTP 200."
  }
}


module "website_s3_bucket" {
  source = "./modules/aws-s3-static-website-bucket"

  bucket_name = "stifel-skills-test-2026"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

output "test" {
  value = var.app_secret
}