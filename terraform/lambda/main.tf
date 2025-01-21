locals {
  lambda_source_dir = "../lambdas/build"
  lambda_zip_file   = "${var.lambda_name}.zip"
}

# Upload Lambda Code to S3
resource "aws_s3_object" "code" {
  bucket = var.s3_bucket
  key    = local.lambda_zip_file
  source = "${local.lambda_source_dir}/${local.lambda_zip_file}"
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_execution_role" {
  name = "beer-app-lambda-${var.lambda_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attach Policies to Lambda Role
resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = var.lambda_policy_arn
}

resource "aws_iam_role_policy_attachment" "lambda_logging_policy" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda Function
resource "aws_lambda_function" "lambda" {
  function_name = var.lambda_name
  s3_bucket     = var.s3_bucket
  s3_key        = aws_s3_object.code.key
  handler       = "${var.lambda_name}.lambda_handler"
  runtime       = "python3.10" # Match your Lambda's runtime
  role          = aws_iam_role.lambda_execution_role.arn
  timeout       = 10
  memory_size   = 128

  environment {
    variables = var.lambda_variables
  }
}

# Lambda Function URL
resource "aws_lambda_function_url" "lambda_url" {
  count = var.create_function_url ? 1 : 0

  function_name      = aws_lambda_function.lambda.function_name
  authorization_type = "NONE" # No auth, since you're the only user
}

# Permission for Lambda URL
resource "aws_lambda_permission" "allow_function_url" {
  count = var.create_function_url ? 1 : 0

  statement_id           = "AllowFunctionUrl"
  action                 = "lambda:InvokeFunctionUrl"
  function_name          = aws_lambda_function.lambda.function_name
  principal              = "*"
  function_url_auth_type = "NONE"
}

# CloudWatch Alarm to track Lambda invocations
resource "aws_cloudwatch_metric_alarm" "invocation_alarm" {
  alarm_name          = "lambda-${var.lambda_name}-invocation-limit"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Invocations"
  namespace           = "AWS/Lambda"
  period              = 3600 # Check hourly
  statistic           = "Sum"
  threshold           = 20 # Limit of invocations per hour

  dimensions = {
    FunctionName = aws_lambda_function.lambda.function_name
  }

  alarm_actions = [var.sns_alarm_topic_arn]
}