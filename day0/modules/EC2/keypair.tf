resource "tls_private_key" "sridevi_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "sridevi_key" {
  key_name   = "sridevi-keypair"
  public_key = tls_private_key.sridevi_key.public_key_openssh
}

# Optional: save private key locally
resource "local_file" "private_key" {
  content  = tls_private_key.sridevi_key.private_key_pem
  filename = "${path.module}/sridevi-keypair.pem"
}

