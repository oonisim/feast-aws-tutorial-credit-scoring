# Example EC2 instance using the IAM role
resource "aws_instance" "feast" {
  ami                  = var.ec2_ami_id
  instance_type        = "t3.xlarge"
  iam_instance_profile = aws_iam_instance_profile.ec2_service_profile.name
  subnet_id            = var.ec2_subnet_id
  vpc_security_group_ids = [
    aws_security_group.ec2.id,
    aws_security_group.feast_registry_sg.id,
    aws_security_group.feast_redshift_sg.id
  ]
  associate_public_ip_address = true
  # No need for SSH key pair when using SSM Session Manager
  # key_name = "your-key-pair"

  tags = {
    Name = "${var.project_name}-test-feast-ec2"
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
resource "aws_security_group" "ec2" {
  name_prefix = "${var.project_name}-ec2-sg"
  vpc_id      = data.aws_vpc.vpc.id
  ingress {
    description = "All inbound within VPC CIDR"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      data.aws_vpc.vpc.cidr_block,
      "10.0.0.0/8"
    ]
    self = true
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = -1
    cidr_blocks = [
      data.aws_vpc.vpc.cidr_block,
      "10.0.0.0/8"
    ]
  }

  tags = {
    Name = "${var.project_name}-ec2-sg"
  }
}


output "ec2_feast_id" {
  value = aws_instance.feast.id
}
output "ec2_feast_profile" {
  value = aws_instance.feast.iam_instance_profile
}
output "ec2_feast_private_ip" {
  value = aws_instance.feast.private_ip
}
output "ec2_feast_subnet" {
  value = aws_instance.feast.subnet_id
}

