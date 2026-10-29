terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

provider "aws" { region = "ap-south-1" }

# ─────────────────────────────────────────────────────────────
# ECR Repository
# ─────────────────────────────────────────────────────────────
resource "aws_ecr_repository" "app" {
  name                 = "full-cicd-capstone"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

# ─────────────────────────────────────────────────────────────
# Security Group
# ─────────────────────────────────────────────────────────────
resource "aws_security_group" "web" {
  name        = "capstone-web-sg"
  description = "Allow SSH and HTTP"

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
}

# ─────────────────────────────────────────────────────────────
# Ubuntu AMI lookup
# ─────────────────────────────────────────────────────────────
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# ─────────────────────────────────────────────────────────────
# ✅ FIX #4 — IAM role so EC2 can pull images from ECR
# ─────────────────────────────────────────────────────────────
resource "aws_iam_role" "ec2_ecr" {
  name = "capstone-ec2-ecr-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_ecr_readonly" {
  role       = aws_iam_role.ec2_ecr.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "ec2_ecr" {
  name = "capstone-ec2-ecr-profile"
  role = aws_iam_role.ec2_ecr.name
}

# ─────────────────────────────────────────────────────────────
# EC2 Instance  ← ⚠️ the iam_instance_profile line goes INSIDE this block
# ─────────────────────────────────────────────────────────────
resource "aws_instance" "app" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.web.id]
  key_name               = var.key_name

  # ✅ FIX #4 — attach the IAM profile (this ONE line)
  iam_instance_profile = aws_iam_instance_profile.ec2_ecr.name

  user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y docker.io awscli
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ubuntu
  EOF

  tags = { Name = "capstone-server" }
}

# ─────────────────────────────────────────────────────────────
# Outputs
# ─────────────────────────────────────────────────────────────
output "ecr_repository_url" { value = aws_ecr_repository.app.repository_url }
output "ec2_public_ip" { value = aws_instance.app.public_ip }
