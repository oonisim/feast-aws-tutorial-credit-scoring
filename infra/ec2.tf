# Example EC2 instance using the IAM role
resource "aws_instance" "example" {
  ami                    = "ami-0c02fb55956c7d316" # Amazon Linux 2
  instance_type          = "t3.micro"
  iam_instance_profile   = aws_iam_instance_profile.ec2_service_profile.name
  vpc_security_group_ids = [
    aws_security_group.ssm.id,
    aws_security_group.feast_registry_sg.id
  ]

  # No need for SSH key pair when using SSM Session Manager
  # key_name = "your-key-pair"

  tags = {
    Name = "${var.project_name}-allow-ssm-login"
  }

  # User data to install SSM agent (if not already installed)
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y amazon-ssm-agent
              systemctl enable amazon-ssm-agent
              systemctl start amazon-ssm-agent
              EOF
}

# Security group allowing HTTPS outbound for SSM
resource "aws_security_group" "ssm" {
  name_prefix = "${var.project_name}-ssm-sg"

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [
      data.aws_vpc.vpc.cidr_block,
      "10.0.0.0/8"
    ]
  }

  tags = {
    Name = "${var.project_name}-ssm-sg"
  }
}