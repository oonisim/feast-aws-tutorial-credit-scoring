# Data source for current AWS account ID
data "aws_caller_identity" "current" {}

# IAM Role for EC2 instance
resource "aws_iam_role" "ec2_service_role" {
  name = "EC2-Service-Role"

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
    Name        = "EC2-Service-Role"
    Environment = "production"
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
      # RDS Permissions
      {
        Sid    = "RDSAccess"
        Effect = "Allow"
        Action = [
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
        Resource = "*"
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
          "ssm:UpdateInstanceInformation",
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel",
          "ec2messages:AcknowledgeMessage",
          "ec2messages:DeleteMessage",
          "ec2messages:FailMessage",
          "ec2messages:GetEndpoint",
          "ec2messages:GetMessages",
          "ec2messages:SendReply"
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
resource "aws_iam_instance_profile" "ec2_service_profile" {
  name = "EC2-Service-Profile"
  role = aws_iam_role.ec2_service_role.name
}

# Optional: Create a more restrictive S3 policy for specific buckets
resource "aws_iam_policy" "s3_specific_bucket_policy" {
  name        = "S3-Specific-Bucket-Policy"
  description = "Policy for specific S3 bucket access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3SpecificBucketAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::your-specific-bucket-name",
          "arn:aws:s3:::your-specific-bucket-name/*"
        ]
      }
    ]
  })
}

# Output the role ARN and instance profile name
output "iam_role_arn" {
  description = "ARN of the IAM role"
  value       = aws_iam_role.ec2_service_role.arn
}

output "instance_profile_name" {
  description = "Name of the instance profile"
  value       = aws_iam_instance_profile.ec2_service_profile.name
}

output "instance_profile_arn" {
  description = "ARN of the instance profile"
  value       = aws_iam_instance_profile.ec2_service_profile.arn
}