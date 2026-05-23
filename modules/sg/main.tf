resource "aws_default_security_group" "default" {
  vpc_id = var.vpc_id
  tags   = { Name = "Lab01-Default-SG" }
}

resource "aws_security_group" "public_sg" {
  name        = "Public-EC2-SG"
  description = "Allow SSH from specific IP"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "Lab01-Public-SG" }
}

resource "aws_security_group" "private_sg" {
  name        = "Private-EC2-SG"
  description = "Allow SSH only from Public SG"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "Lab01-Private-SG" }
}