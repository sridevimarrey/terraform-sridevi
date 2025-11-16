# Security Group
resource "aws_security_group" "allow_ssh" {
  vpc_id = aws_vpc.my_vpc.id
  name   = "allow-ssh"

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sridevi-sg"
  }
}
