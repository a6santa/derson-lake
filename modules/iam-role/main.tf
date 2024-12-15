resource "aws_iam_role" "dms_s3_role" {
  count = var.is_dms_role ? 1 : 0
  name  = var.role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "dms.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "dms_s3_policy" {
  count       = var.is_dms_role ? 1 : 0
  name        = var.policy_name
  description = "Policy to allow DMS access to S3 bucket"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Effect   = "Allow",
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dms_s3_role_policy_attachment" {
  count      = var.is_dms_role ? 1 : 0
  role       = aws_iam_role.dms_s3_role[count.index].name
  policy_arn = aws_iam_policy.dms_s3_policy[count.index].arn
}

resource "aws_iam_role" "secrets_manager_access_role" {
  count = var.is_secret_role ? 1 : 0
  name  = var.role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "dms.amazonaws.com"
        },
        Action : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "secrets_manager_policy" {
  count       = var.is_secret_role ? 1 : 0
  name        = var.policy_name
  description = "Policy to allow access to Secrets Manager"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resource = var.resources
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "secrets_manager_policy_attachment" {
  count      = var.is_secret_role ? 1 : 0
  role       = aws_iam_role.secrets_manager_access_role[count.index].name
  policy_arn = aws_iam_policy.secrets_manager_policy[count.index].arn
}

resource "aws_iam_role" "lambda_role" {
  count = var.is_lambda_role ? 1 : 0
  name  = var.role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "logs_policy" {
  count       = var.is_lambda_role ? 1 : 0
  name        = "lambda_logs_policy"
  description = "Policy to allow access to aws logs"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ],
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_iam_policy" "dms_policy" {
  count       = var.is_lambda_role ? 1 : 0
  name        = "lambda_dms_policy"
  description = "Policy to allow access to DMS"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dms:DescribeReplicationInstances",
          "dms:StartReplicationTask",
          "kms:*",
          "dms:DeleteReplicationTask",
          "dynamodb:GetItem",
          "dms:DescribeReplicationInstanceTaskLogs",
          "dms:CreateReplicationTask",
          "dms:DescribeReplicationTasks",
          "dms:DeleteReplicationInstance",
          "dms:CreateReplicationInstance",
          "dms:ModifyEndpoint",
          "dms:AddTagsToResource",
        ],
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "logs_policy_attachment" {
  count      = var.is_lambda_role ? 1 : 0
  role       = aws_iam_role.lambda_role[count.index].name
  policy_arn = aws_iam_policy.logs_policy[count.index].arn

}

resource "aws_iam_role_policy_attachment" "dms_policy_attachment" {
  count      = var.is_lambda_role ? 1 : 0
  role       = aws_iam_role.lambda_role[count.index].name
  policy_arn = aws_iam_policy.dms_policy[count.index].arn
}

resource "aws_iam_role" "step_functions_role" {
  count = var.is_step_functions_role ? 1 : 0
  name  = var.role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "states.amazonaws.com"
        },
        Action : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "step_functions_policy" {
  count       = var.is_step_functions_role ? 1 : 0
  name        = var.policy_name
  description = "Policy to allow Step Functions full access to Lambda, Step Functions, CloudWatch, EventBridge, Glue, and Athena"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "lambda:*",
          "states:*",
          "cloudwatch:*",
          "events:*",
          "glue:*",
          "athena:*",
          "logs:*",
          "dynamodb:*"
        ],
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "step_functions_role_policy_attachment" {
  count      = var.is_step_functions_role ? 1 : 0
  role       = aws_iam_role.step_functions_role[count.index].name
  policy_arn = aws_iam_policy.step_functions_policy[count.index].arn
}

resource "aws_iam_role" "glue_job_role" {
  count = var.is_glue_job ? 1 : 0
  name  = var.role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "glue.amazonaws.com"
        },
        Action : "sts:AssumeRole"
      },
      {
        Effect = "Allow",
        Principal = {
          Service = "lakeformation.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "glue_job_policy" {
  count       = var.is_glue_job ? 1 : 0
  name        = var.policy_name
  description = "Policy to allow Glue to performance jobs"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["*"],
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_job_role_policy_attachment" {
  count      = var.is_glue_job ? 1 : 0
  role       = aws_iam_role.glue_job_role[count.index].name
  policy_arn = aws_iam_policy.glue_job_policy[count.index].arn
}