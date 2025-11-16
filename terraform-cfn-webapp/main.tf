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

resource "aws_cloudformation_stack" "webapp" {
  name          = "full-webapp-cfn-stack"
  template_body = file("${path.module}/cloudformation/webapp.yaml")

  parameters = {
    InstanceType = "t2.micro"
  }

  capabilities = ["CAPABILITY_NAMED_IAM", "CAPABILITY_IAM"]
}

output "webapp_outputs" {
  value = aws_cloudformation_stack.webapp.outputs
}