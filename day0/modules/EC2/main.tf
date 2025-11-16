# EC2
data "aws_ssm_parameter" "ubuntu_2204" {
  name = "/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
}

resource "aws_instance" "my_ec2" {
  ami           = data.aws_ssm_parameter.ubuntu_2204.value
  instance_type = "t3.micro"
  subnet_id     = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name      = aws_key_pair.sridevi_key.key_name

  tags = {
    Name = "sridevi-ec2"
  }
}

 





