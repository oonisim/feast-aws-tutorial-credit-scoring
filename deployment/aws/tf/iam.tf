# Data source for current AWS account ID
data "aws_caller_identity" "current" {}

# IAM Role for EC2 instance
resource "aws_iam_role" "ec2_service_role" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-ec2-role"
  }
}

# Custom IAM Policy with S3, RDS, Redshift, and SSM permissions
resource "aws_iam_policy" "ec2_service_policy" {
  name        = "EC2-Service-Policy"
  description = "Policy for EC2 access to S3, RDS, Redshift, and SSM"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # S3 Permissions
      {
        Sid    = "S3Access"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:GetObjectVersion",
          "s3:PutObjectAcl",
          "s3:GetObjectAcl",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts"
        ]
        Resource = [
          "arn:aws:s3:::*",
          "arn:aws:s3:::*/*"
        ]
      },
      # DynamoDB Table
      {
        Sid    = "DynamoDBTable"
        Effect = "Allow"
        Action = [
          "dynamodb:*",
        ]
        Resource = "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/*"
      },
      # RDS Permissions
      {
        Sid    = "RDSAccess"
        Effect = "Allow"
        Action = [
          "rds:*",
          "rds:DescribeDBInstances",
          "rds:DescribeDBClusters",
          "rds:DescribeDBSnapshots",
          "rds:DescribeDBClusterSnapshots",
          "rds:ListTagsForResource",
          "rds:DescribeDBParameterGroups",
          "rds:DescribeDBParameters",
          "rds:DescribeOptionGroups",
          "rds:DescribeDBSubnetGroups",
          "rds-db:connect"
        ]
        Resource = aws_db_instance.feast_registry.arn
      },
      # Redshift Permissions
      {
        Sid    = "RedshiftAccess"
        Effect = "Allow"
        Action = [
          "redshift:DescribeClusters",
          "redshift:DescribeClusterSnapshots",
          "redshift:DescribeClusterParameters",
          "redshift:DescribeClusterParameterGroups",
          "redshift:DescribeClusterSubnetGroups",
          "redshift:DescribeClusterSecurityGroups",
          "redshift:GetClusterCredentials",
          "redshift-data:BatchExecuteStatement",
          "redshift-data:CancelStatement",
          "redshift-data:DescribeStatement",
          "redshift-data:DescribeTable",
          "redshift-data:ExecuteStatement",
          "redshift-data:GetStatementResult",
          "redshift-data:ListDatabases",
          "redshift-data:ListSchemas",
          "redshift-data:ListStatements",
          "redshift-data:ListTables"
        ]
        Resource = "*"
      },
      # SSM Permissions for Session Manager
      {
        Sid    = "SSMSessionManager"
        Effect = "Allow"
        Action = [
          "ssm:*",
          "ssmmessages:*",
          "ec2messages:*",
        ]
        Resource = "*"
      },
      # Additional SSM Permissions
      {
        Sid    = "SSMParameterStore"
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath",
          "ssm:PutParameter",
          "ssm:DescribeParameters",
          "ssm:GetParameterHistory"
        ]
        Resource = [
          "arn:aws:ssm:*:${data.aws_caller_identity.current.account_id}:parameter/*"
        ]
      },
      # CloudWatch Logs for SSM Session Manager (optional but recommended)
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:/aws/ssm/*"
      }
    ]
  })
}

# Attach the custom policy to the role
resource "aws_iam_role_policy_attachment" "ec2_service_policy_attachment" {
  role       = aws_iam_role.ec2_service_role.name
  policy_arn = aws_iam_policy.ec2_service_policy.arn
}

# Attach AWS managed policy for SSM (alternative approach)
resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  role       = aws_iam_role.ec2_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create instance profile for EC2
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.project_name}-feast-ec2-instance-profile"
  role = aws_iam_role.ec2_service_role.name
}

# Output the role ARN and instance profile name
output "iam_role_arn" {
  description = "ARN of the IAM role"
  value       = aws_iam_role.ec2_service_role.arn
}

output "instance_profile_name" {
  description = "Name of the instance profile"
  value       = aws_iam_instance_profile.ec2_instance_profile.name
}

output "instance_profile_arn" {
  description = "ARN of the instance profile"
  value       = aws_iam_instance_profile.ec2_instance_profile.arn
}