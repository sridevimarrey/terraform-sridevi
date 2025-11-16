terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region     = "us-east-1"
}

########################################
# 0. CREATE VPC
########################################

resource "aws_vpc" "project_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "project-vpc" }
}

resource "aws_internet_gateway" "project_igw" {
  vpc_id = aws_vpc.project_vpc.id
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.project_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = { Name = "project-public-subnet" }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.project_vpc.id
  tags = { Name = "project-public-rt" }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.project_igw.id
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

########################################
# 1. CREATE S3 BUCKET
########################################

resource "random_id" "bucket_id" {
  byte_length = 4
}

resource "aws_s3_bucket" "mybucket" {
  bucket        = "project-s3-bucket-${random_id.bucket_id.hex}"
  force_destroy = true
}

########################################
# 2. IAM ROLE FOR EC2
########################################

resource "aws_iam_role" "ec2_role" {
  name = "project-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

########################################
# 3. IAM POLICY FOR S3 ACCESS
########################################

resource "aws_iam_policy" "s3_policy" {
  name = "project-s3-access-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = [aws_s3_bucket.mybucket.arn]
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject"]
        Resource = ["${aws_s3_bucket.mybucket.arn}/*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_s3" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}

########################################
# 4. INSTANCE PROFILE
########################################

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "project-instance-profile"
  role = aws_iam_role.ec2_role.name
}

########################################
# 5. SECURITY GROUP
########################################

resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.project_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

  tags = { Name = "project-ec2-sg" }
}

########################################
# 6. EC2 INSTANCE
########################################

resource "aws_instance" "myec2" {
  ami                    = "ami-06ca3ca175f37dd66"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-EOF
    #!/bin/bash
    echo "EC2 with S3 access created by Terraform" > /home/ec2-user/info.txt
  EOF

  tags = { Name = "project-ec2" }
}

########################################
# 7. OUTPUTS
########################################

output "s3_bucket_name" {
  value = aws_s3_bucket.mybucket.bucket
}

output "ec2_public_ip" {
  value = aws_instance.myec2.public_ip
}