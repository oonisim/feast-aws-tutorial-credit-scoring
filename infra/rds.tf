# https://developer.hashicorp.com/terraform/tutorials/aws/aws-rds
resource "aws_db_subnet_group" "feast_registry" {
  name       = "${var.project_name}-feast-registry-subnet-group"
  subnet_ids = var.rds_subnet_ids

  tags = {
    Name = "${var.project_name}-feast-registry-subnet-group"
  }
}

resource "aws_security_group" "feast_registry_sg" {
  name        = "${var.project_name}-feast-registry-sg"
  description = "Allow access to RDS from specific CIDR blocks"
  vpc_id = data.aws_vpc.vpc.id

  # Allow inbound traffic to RDS
  ingress {
    self = true
    from_port = var.feast_registry_db_port
    to_port   = var.feast_registry_db_port
    protocol  = "tcp"
    cidr_blocks = [
      data.aws_vpc.vpc.cidr_block,
      "10.0.0.0/8"
    ]
  }
  # Allow all outbound traffic
  egress {
    self = true
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      data.aws_vpc.vpc.cidr_block,
      "10.0.0.0/8"
    ]
  }

  tags = {
    Name  = "${var.project_name}-feast-registry-ssg"
    Owner = "masayuki.onishi@cba.com.au"
  }
}

#resource "aws_db_parameter_group" "feast_registry" {
#  name = "${var.project_name}-feast-registry-parameters"
#  # family = "postgres15"
#  family = "aurora-postgresql15"
#
#  parameter {
#    name  = "rds.force_ssl"
#    value = "1"
#  }
#}

resource "aws_db_instance" "feast_registry" {
  identifier           = "${var.project_name}-feast-registry"
  instance_class       = "db.t3.micro"
  allocated_storage    = 5
  engine               = "postgres"
  engine_version       = "15.10"
  username             = var.feast_registry_db_admin
  password             = var.feast_registry_db_password
  db_subnet_group_name = aws_db_subnet_group.feast_registry.name
  port                 = var.feast_registry_db_port
  vpc_security_group_ids = [
    aws_security_group.feast_registry_sg.id
  ]
  # InvalidParameterValue: Could not find parameter with name: rds.force_ssl
  # parameter_group_name = aws_db_parameter_group.feast_registry.name
  publicly_accessible  = false
  skip_final_snapshot  = true
}


output "feast_registry_db_endpoint_endpoint" {
  description = "The endpoint of the Feast registry database"
  value       = aws_db_instance.feast_registry.endpoint
}
output "feast_registry_db_endpoint_engine" {
  description = "The engine of the Feast registry database"
  value       = aws_db_instance.feast_registry.engine
}