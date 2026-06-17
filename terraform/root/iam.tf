resource "aws_iam_role" "taskapp_backend_role" {
  name = "taskapp-backend-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "taskapp_backend_ssm_read" {
  name        = "taskapp-backend-ssm-read"
  description = "Least-privilege read access to TaskApp SSM parameters"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ]
        Resource = "arn:aws:ssm:eu-west-3:709716141727:parameter/taskapp/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "taskapp_backend_attach" {
  role       = aws_iam_role.taskapp_backend_role.name
  policy_arn = aws_iam_policy.taskapp_backend_ssm_read.arn
}